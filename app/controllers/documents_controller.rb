require 'services/search_generator'
# I wanna name this something better but it wont? asdfghjk

class DocumentsController < ApplicationController
  include SearchGenerator
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

    document = Document.find(params[:id])

    document.remove_sections
    # TODO: blank comes from the dropdown
    document.reconstruct_sections(params)

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
    document = Document.find(params[:id])
    document.resection_document
    redirect_to document_path(params[:id])
  end



  def advanced_search
    #check post, otherwise get
    if params[:keyword]&.any?(&:present?)

      @search_results = Section.search(SearchGenerator.generate_search_hash(params)).with_details

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

end
