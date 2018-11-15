class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :edit_section_separation, :update, :update_section_separation, :destroy]
  before_action :authenticate_user!, except: [:index, :search]

  # GET /documents
  # GET /documents.json
  def index
    @grouped_documents = Document.all.sort_by(&:country).group_by(&:country)
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
    @countries = Country.all
    @document_types = Document::DOCUMENT_TYPES_ID
  end

  # GET /documenfetch(:document, {})fetch(:document, {})ts/1/edit
  def edit
  end

  def edit_section_separation
    @languages = @document.country.languages
    @sections =
      @document.sections.group_by(&:section_number).map do |section_number, sections|
        section_name = sections.first.section_name
        language_id = sections.first.language_id
        content = sections.sort_by(&:section_part).map(&:content).join
        Section.new(section_number: section_number, section_name: section_name, content: content, language_id: language_id)
      end.sort_by(&:section_number)
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.create(document_params)

    # parse document asynchronously
    begin
      DocumentParserJob.perform_async(@document)
    rescue OpenURI::HTTPError => e
      # TODO check 404 and respond accordingly
    end

    respond_to do |format|
      if @document.save
        format.html { redirect_to :documents, notice: 'Document was successfully added to processing queue.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to :documents, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_section_separation
    # destroy previous sections
    @document.sections.map(&:destroy)

    # create new sections
    params[:section_number].count.times do |idx|
      @document.sections.add_section(
        section_number: params[:section_number][idx],
        section_name: params[:section_name][idx],
        content: params[:content][idx],
        language_id: params[:language][idx].presence
      )
    end

    redirect_to documents_path, notice: 'Sections Updated!'
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    # An object is present if it's not blank.
    #                                               The & calls to_proc on the object, and passes it as a block to the method
    # params is the q, and array of query (field types) and array of keyword (values)
    if params[:q].present? || params[:keyword]&.any?(&:present?)
      #simply creates an array with 2 symbols
      numeric_queries = [:year, :cycle]

      #grab ONLY numeric filters and put them in 'query' - use in initial content search
      # it only does one of them - if you put in 2 years it doesn't work
      query = params[:keyword]&.each_with_index&.map do |keyword, idx|
        if keyword.present?
          field = params[:query][idx].parameterize.underscore.to_sym
          next unless numeric_queries.include?(field)
          [field, keyword]
        end
      end&.compact&.to_h

      highlight = { tag: "<strong>" }
      boost_where = { full_content: false }


      @search_results =
        Section.search(params[:q].presence || '*',
                       fields: [:content],
                       where: query,
                       highlight: highlight.merge({ fields: { content: { type: 'plain', fragment_size: (params[:q].presence&.length || 100) } } }),
                       boost_where: boost_where, debug: true).with_details

      #grab the other filters - ignore the numeric ones
      params[:query]&.each_with_index do |query, idx|
        if (keyword = params[:keyword][idx]).present?
          field = query.parameterize.underscore.to_sym
          next if numeric_queries.include?(field)
          options = {
            fields: [field],
            highlight: highlight,
            boost_where: boost_where,
            misspellings: {
              below: 10
            }
          }
          #special options for the section number
          options.merge!(match: :word_start, misspellings: false) if field == :section_number
          @search_results.intersect_nested_search_result!(Section.search(keyword, options).with_details)
        end
      end
      @search_results = @search_results.paginate(page: params[:page], per_page: 10)
      render :search_results
    else
      @available_queries = [
        'Section Number',
        'Section Name',
        'Country',
        'Year',
        'Cycle',
        'Language'
      ]
      render 'home/index'
    end
  end



  def advanced_search
    # parameters
    # {"utf8"=>"✓",
    #  "query_type"=>["Section Number", "Section Number", "Section Number", "Text Search", "Text Search"],
    #  "filter_type"=>["all", "one of", "none of", "one of", "none of"],
    #  "keyword"=>{"1"=>["11", "12", "13", "14"],
    #              "2"=>["21", "22"],
    #              "4"=>["41", "42", "43"],
    #              "5"=>["51", "52"]},
    #  "commit"=>"Search documents"}
    #
    # Plan of action:
    #
    # completed: convert parameters into form that is standard
    # completed: fix highlight issue when only search for a numeric query
    # TODO: none of / exclude terms
    # TODO: check that 'all' actually really does do nothing
    # TODO: fix text searches go last
    # TODO: fix the text search intersection problem
    # TODO: make the logical queries use the DSL to reuce the number of network calls to elasticsearch
    #
    numeric_queries = [:year, :cycle]
    logical_queries = [:section_number,:country, :language, :text_search]
    numeric_filters = ['all','only','less than','greater than','between']
    logical_filters = ['all','only','none of','one of']

    highlight = { tag: "<strong>" }
    boost_where = { full_content: false }

    #the keys to do last because they're text search
    text_search_keepback = []
    search_result_sets = []
    #check post, otherwise get
    if params[:keyword]&.any?(&:present?)
      # IMPORTANT - need .with_details to get the individual section hashes


      params[:keyword]&.each_key do |key|
        #these are all arrays (so that the ID is constant) but there is only one element
        query_type = params[:query_type][key][0].parameterize.underscore.to_sym
        filter_type = params[:filter_type][key][0].parameterize.underscore.to_sym
        #variable number of elements so keep as an array
        keyword = params[:keyword][key]

        if query_type == :text_search
          #do these last
          text_search_keepback.push(key)

        elsif logical_queries.include?(query_type)
          options = {
              fields: [query_type],
              highlight: highlight,
              boost_where: boost_where,
              misspellings: {
                  below: 10
              }
          }
          #special options for the section number
          options.merge!(match: :word_start, misspellings: false) if query_type == :section_number

          #use the terms function in the elastic search DSL because we don't need to worry about the analysis of the text
          if filter_type == 'all'

          else
            # only need to concatonate because all logical ones are mut exclusive
            concatise = []
            keyword&.each do |word|
              concatise.push(Section.search(word, options).with_details)
            end
            concat = []
            concatise&.each_index do |i|
              concat = concat + concatise[i]
            end
            search_result_sets.push(concat)
            #search_result_sets.push(Section.search(body: {query: {terms: {'Country': 'united kingdom', 'austria'}}}).with_details)
          end

        elsif numeric_queries.include?(query_type)
          if filter_type == :all
            #do nothing
          elsif filter_type == :only
            word = keyword[0]
            query = Hash.new
            query[query_type] = word
            search_result_sets.push(Section.search(where: query).with_details)
            #doesnt work - search_result_sets.push(Section.search(word, options).with_details)
            #search_result_sets.push(Section.search(body: {query: {terms: {query_type: keyword}}}).with_details)
          elsif filter_type == :less_than

            word = keyword[0]
            first_nest = {lt: word}
            second_nest = Hash.new
            second_nest[query_type] = first_nest
            search_result_sets.push(Section.search(where: second_nest).with_details)
          elsif filter_type == :greater_than

            word = keyword[0]
            first_nest = {gt: word}
            second_nest = Hash.new
            second_nest[query_type] = first_nest
            search_result_sets.push(Section.search(where: second_nest).with_details)
            #search_result_sets.push(Section.search(body: {query: {range: {query_type: {gt: keyword}}}}).with_details)
          elsif filter_type == :between

            if keyword[0] > keyword[1]
              big = keyword[0]
              small = keyword[1]
            else
              big = keyword[1]
              small = keyword[0]
            end

            lt_first_nest = {lt: big}
            lt_second_nest = Hash.new
            lt_second_nest[query_type] = lt_first_nest
            intersect1 = Section.search(where: lt_second_nest).with_details
            gt_first_nest = {gt: small}
            gt_second_nest = Hash.new
            gt_second_nest[query_type] = gt_first_nest
            intersect2 = Section.search(where: gt_second_nest).with_details

            intersect = intersect1 & intersect2
            search_result_sets.push(intersect)

            #search_result_sets.push(Section.search(body: {query: {range: {query_type: {gt: small, lt:big}}}}).with_details)
          end

        end
        text_search_keepback.each do |key|
          query_type = params[:query_type][key][0].parameterize.underscore.to_sym
          filter_type = params[:filter_type][key][0].parameterize.underscore.to_sym
          #variable number of elements so keep as an array
          keyword = params[:keyword][key]

          #get all sections with the keyword inside them
          if filter_type == :only
            word = keyword[0]
            search_result_sets.push(Section.search(word,
                                                   fields: [:content],
                                                   highlight: highlight.merge({ fields: { content: { type: 'plain', fragment_size: (word.length || 100) } } }),
                                                   boost_where: boost_where, debug: true).with_details)

          else
            #for each keyword, get all sections with the keyword inside them, unionise
            unionise = []
            keyword&.each do |word|
              unionise.push(Section.search(word,
                                           fields: [:content],
                                           highlight: highlight.merge({ fields: { content: { type: 'plain', fragment_size: (word.length || 100) } } }),
                                           boost_where: boost_where, debug: true).with_details)
            end
            # this doesnt pick up the same section when the highlighting is entirly different because of the behaviour of the function in array.rb
            union = []
            unionise&.each_index do |i|
              if i == 0
                union = unionise[0]
              else
                exclusive_middle_middle = union + unionise[i]
                union = exclusive_middle_middle
              end
            end

            search_result_sets.push(union)
          end

        end
      end

      #finally, intersect everything together
      search_result_sets.each_index do |i|
        if i == 0
          @search_results = search_result_sets[i]
        else
          @search_results.intersect_nested_search_result!(search_result_sets[i])
        end
      end

      @search_results = @search_results.paginate(page: params[:page], per_page: 10)
      render :search_results
    else
      render 'home/advanced_search'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:url, :country_id, :document_type, :year, :cycle)
    end
end
