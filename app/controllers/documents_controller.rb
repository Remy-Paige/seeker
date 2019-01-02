class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :edit_section_separation, :update, :update_section_separation, :destroy]
  before_action :authenticate_user!, except: [:index, :search, :advanced_search]

  # GET /documents
  # GET /documents.json
  def index
    @grouped_documents = Document.all.sort_by(&:country).group_by(&:country)
  end

  # GET /documents/
  # GET /documents/.json
  def show
    # each section is made up of lots of section parts because of elastic search - this coellates the sections parts into a section
    # honestly I'm not 100% sure how it works
    @sections = @document.sections.group_by(&:section_number).map do |section_number, sections|
          section_name = sections.first.section_name
          language_id = sections.first.language_id
          page_number = sections.first.page_number
          content = sections.sort_by(&:section_part).map(&:content).join
          Section.new(section_number: section_number, page_number: page_number, section_name: section_name, content: content, language_id: language_id)
        end.sort_by(&:section_number)
  end

  # GET /documents/new
  def new
    @document = Document.new
    @countries = Country.all
    @document_types = Document::DOCUMENT_TYPES_ID
  end

  # GET /documenfetch(:document, {})fetch(:document, {})ts/1/edit
  def edit
    @countries = Country.all
    @document_types = Document::DOCUMENT_TYPES_ID
  end

  # for each section - create a new section - because each will be deleted and made new on update
  # these are section PARTS - we are grouping sections together and
  def edit_section_separation
    @languages = @document.country.languages
    @sections =
      @document.sections.group_by(&:section_number).map do |section_number, sections|
        section_name = sections.first.section_name
        language_id = sections.first.language_id
        page_number = sections.first.page_number
        content = sections.sort_by(&:section_part).map(&:content).join
        Section.new(section_number: section_number, section_name: section_name, content: content, language_id: language_id, page_number: page_number)
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

    # create new sections with custom method
    # each section created new - split into section parts in the model
    params[:section_number].count.times do |idx|
      @document.sections.add_section(
        section_number: params[:section_number][idx],
        section_name: params[:section_name][idx],
        content: params[:content][idx],
        language_id: params[:language][idx].presence,
        page_number: params[:page_number][idx]
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

  # this is the old search function - remove?
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
    #abcdefgh jklmnopq rstuvwxyz

    numeric_queries = [:year, :cycle]
    logical_queries = [:section_number,:country, :language]
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

      must_arr = []
      must_not_text_arr = []
      # must_arr.push({dis_max:{queries: text_arr}})
      filter_arr = []
      must_not_arr = []
      text_arr = []

      text_search_present = false
      must_not_text_search_present = false

      params[:keyword]&.each_key do |key|
        #these are all arrays (so that the ID is constant) but there is only one element
        query_type = params[:query_type][key][0].parameterize.underscore.to_sym
        filter_type = params[:filter_type][key][0].parameterize.underscore.to_sym
        #variable number of elements so keep as an array
        keyword = params[:keyword][key]

        #first search for none_of filter type because the filter overrides the query in this case
        if filter_type == :none_of

          if query_type == :text_search
            #so that we know to append the dismax queries - if we include it in the skeleton with an empty array es compains
            must_not_text_search_present = true
            keyword&.each do |word|
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search"}}})
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search2"}}})
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:1,operator:"and",analyzer:"searchkick_search",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
              must_not_text_arr.append({match:{"content.analyzed":{"query": word,boost:1,operator:"and",analyzer:"searchkick_search2",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
            end
          #the numerical queries don't have a none_of option
          elsif logical_queries.include?(query_type)
            must_not_arr.append(logical_queries(query_type, filter_type, keyword))
          end

        elsif query_type == :text_search
          #so that we know to append the dismax queries - if we include it in the skeleton with an empty array es compains
          text_search_present = true
          keyword&.each do |word|
            text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search"}}})
            text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search2"}}})
            text_arr.append({match:{"content.analyzed":{query: word,boost:1,operator:"and",analyzer:"searchkick_search",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
            text_arr.append({match:{"content.analyzed":{"query": word,boost:1,operator:"and",analyzer:"searchkick_search2",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
          end

        elsif logical_queries.include?(query_type)
          filter_arr.append(logical_queries(query_type, filter_type, keyword))
        elsif numeric_queries.include?(query_type)
          filter_arr.append(numeric_queries(query_type,filter_type,keyword))
        end

      end
      if must_not_text_search_present
        must_not_arr.append(dis_max:{queries: must_not_text_arr})
      end
      if text_search_present
        must_arr.append(dis_max:{queries: text_arr})
      end

      # boost searches that are from a section, not a full document
      # highlight the query in bold - this will also highlight everything between 2 instances of a query
      # highlighting doesnt pick up any other filers

      @search_results = Section.search(body: {
          query:{
              function_score:{
                  functions:[{filter:{and:[{term:{full_content:false}}]},boost_factor:1000}],
                  query:{
                      bool:{
                          must: must_arr,
                          filter:filter_arr,
                          must_not: must_not_arr
                      }
                  },
                  "score_mode":"sum"
              }
          },
          "size":1000,
          "from":0,
          "highlight":{"fields":{"content.analyzed":{"type":"plain","fragment_size":6}},"pre_tags":["\u003cstrong\u003e"],"post_tags":["\u003c/strong\u003e"]},"fields":[]}
      ).with_details


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


    def logical_queries(query_type, filter_type, keyword)
      #TODO: fix word_start option for section number
      #use the terms function in the elastic search DSL because we don't need to worry about the analysis of the text
      if filter_type == :all
        {}
      else
        search = Hash.new
        search[query_type] = keyword
        {terms: search}
      end
    end

    def numeric_queries(query_type, filter_type, keyword)
      if filter_type == :all
        #do nothing
        return {}
      elsif filter_type == :only
        word = Integer(keyword[0])
        search_terms = Hash.new
        search_terms[:lt] = String(word+1)
        search_terms[:gt] = String(word-1)
        search = Hash.new
        search[query_type] = search_terms
        #{query_type: {"gt" : word-1, "lt" : word+1}}
        return {range: search}
      elsif filter_type == :less_than
        word = keyword[0]
        search_terms = {lt: word}
        search = Hash.new
        search[query_type] = search_terms
        #{query_type: {lt: word}}
        return {range: search}
      elsif filter_type == :greater_than
        word = keyword[0]
        search_terms = {gt: word}
        search = Hash.new
        search[query_type] = search_terms
        #{query_type: {gt: word}}
        return {range: search}
      elsif filter_type == :between

        if keyword[0] > keyword[1]
          big = keyword[0]
          small = keyword[1]
        else
          big = keyword[1]
          small = keyword[0]
        end
        search_terms = Hash.new
        search_terms[:lt] = big
        search_terms[:gt] = small
        search = Hash.new
        search[query_type] = search_terms
        #{query_type: {"gt" : small, "lt" : big}}
        return {range: search}
      end
    end

end
