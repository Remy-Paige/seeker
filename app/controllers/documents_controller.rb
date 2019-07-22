class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :edit_section_separation, :update, :update_section_separation, :destroy]
  before_action :authenticate_user!, except: [:index, :search, :advanced_search, :show]

  # GET /documents
  # GET /documents.json
  def index
    @grouped_documents = Document.all.sort_by(&:country).group_by(&:country)
  end

  # GET /documents/
  # GET /documents/.json
  def show
    # reconstruct a temporary section from parts
    @languages = Language.all
    @sections =
        @document.sections.group_by(&:section_number).map do |section_number, sections|
          section_name = sections.first.section_name
          page_number = sections.first.page_number
          language_sections = sections.first.language_sections
          content = sections.sort_by(&:section_part).map(&:content).join
          sec = Section.new(section_number: section_number, section_name: section_name, content: content, page_number: page_number)
          language_sections&.each do |relation|
            sec.language_sections << relation
          end
          # this line avoids an undefined method for [] array error
          sec
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
    unless current_user.admin?
      redirect_to('/404')
    end

    @languages = Language.all
    gon.languages = @languages
    # reconstruct a temporary section from parts
    @sections =
      @document.sections.group_by(&:section_number).map do |section_number, sections|
        section_name = sections.first.section_name
        page_number = sections.first.page_number
        language_sections = sections.first.language_sections
        content = sections.sort_by(&:section_part).map(&:content).join
        sec = Section.new(section_number: section_number, section_name: section_name, content: content, page_number: page_number)
        language_sections&.each do |relation|
          sec.language_sections << relation
        end
        # this line avoids an undefined method for [] array error
        sec
      end.sort_by(&:section_number)
  end

  # POST /documents
  # POST /documents.json
  def create

    if Document.where("url = '" + document_params[:url] + "'").first != nil
      respond_to do |format|
        format.html { redirect_to :documents, notice: 'Document already exists' }
        format.json { render :show, status: :created, location: @document }
      end
    else
      begin
        @document = Document.create(document_params)

        # parse document asynchronously
        begin
          DocumentParserJob.perform_async(@document)
        rescue OpenURI::HTTPError => e
          # TODO check 404 and respond accordingly
          # todo: check 'restriced access'
          respond_to do |format|
            format.html { redirect_to :documents, notice: '404 at the supplied URL' }
            format.json { render :show, status: :created, location: @document }
          end
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


      rescue StandardError => e
        respond_to do |format|
          format.html { redirect_to :documents, notice: e.to_s }
          format.json { render :show, status: :created, location: @document }
        end
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

    Document.remove_sections(params[:id])
    Document.reconstruct_sections(params)

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

  # thse 2 are hidden dev only methods only accesible through a link
  # normal users can overload the server using them
  # add a status or notice for this?
  # TODO: admin only
  def language_parse
    Document.language_parse(params[:id])
    redirect_to document_path(params[:id])
  end
  def resection_document
    Document.resection_document(params[:id])
    redirect_to document_path(params[:id])
  end

  def advanced_search
    #abcdefgh jklmnopq rstuvwxyz
    # this skeleton copies the format of the queries that searchkick runs if you use it as a wrapper, with a few edits
    # TODO: move into model?

    numeric_queries = [:year, :cycle]
    logical_queries = [:country, :strong_language, :medium_language, :weak_language]
    # text_search, section_number are the other two
    # numeric_filters ['all','only','less than','greater than','between']
    # logical_filters ['all','only','none of','one of']


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
        # both text_search and section_number do text searches - but section number has the word start option and has to be treated separatle
        # text searches need the dis_max skeleton - this is added only if its needed
        if filter_type == :none_of

          if query_type == :text_search
            #so that we know to append the dismax queries - if we include dis_max in the skeleton with an empty array es complains
            must_not_text_search_present = true
            keyword&.each do |word|
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search"}}})
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search2"}}})
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:1,operator:"and",analyzer:"searchkick_search",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
              must_not_text_arr.append({match:{"content.analyzed":{"query": word,boost:1,operator:"and",analyzer:"searchkick_search2",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
            end
          elsif query_type == :section_number

            must_not_text_search_present = true
            keyword&.each do |word|
              must_not_text_arr.append({match:{"section_number.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
            end
          #the numerical queries don't have a none_of option
          elsif logical_queries.include?(query_type)
            must_not_arr.append(logical_queries(query_type, filter_type, keyword))
          end

        elsif query_type == :text_search
          #so that we know to append the dismax queries - if we include dis_max in the skeleton with an empty array elastic search complains
          text_search_present = true
          keyword&.each do |word|
            # not good results
            text_arr.append({match:{"content":{query: word,boost:10,operator:"and"}}})
            # Manx Gaelic : Manx Gaelic, Scottish-Gaelic: Scottish Gaelic Socttish-Gaelic
            text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search"}}})
            # Scottish-Gaelic: Gaelic Scottish Socttish, Manx Gaelic: Gaelic scottish-gaelic socttish gaelic Manx
            text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search2"}}})
            text_arr.append({match:{"content.analyzed":{query: word,boost:1,operator:"and",analyzer:"searchkick_search",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
            text_arr.append({match:{"content.analyzed":{"query": word,boost:1,operator:"and",analyzer:"searchkick_search2",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
          end
        elsif query_type == :section_number
          keyword&.each do |word|
            if word != ""
              text_search_present = true
            text_arr.append({match:{"section_number.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
            end
          end
        # dont need to loop over words for these - keyword array just gets dumped into es
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
          "highlight":{"fields":{"content.analyzed":{"type":"plain","fragment_size":1250}},"pre_tags":["\u003cstrong\u003e"],"post_tags":["\u003c/strong\u003e"]},"fields":[]}
      ).with_details



      @languages = Language.all
      @collections = current_user&.collections
      @search_results = @search_results.paginate(page: params[:page], per_page: 10)
      render :search_results
    else

      @languages = Language.all
      gon.languages = @languages
      @countries = Country.all
      gon.countries = @countries

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
      #use the terms function in the elastic search DSL because we don't need to worry about the analysis of the text
      if filter_type == :all
        {}
      else
        # map! edits the og array
        keyword.map! do |word|
          if word.include? "_"
            word.gsub!('_', ' ')
          else
            word
          end
        end

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
