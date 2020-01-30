require 'services/search_generator'
# I wanna name this something better but it wont? asdfghjk

class DocumentsController < ApplicationController
  include SearchGenerator
  before_action :set_document, only: [:show, :edit, :edit_section_separation, :update, :update_section_separation, :destroy]
  # before_action :authenticate_user!, except:
  before_action :authenticate_user!, except: [:index, :search_form, :submit_search, :show]
  before_action :authenticate_admin, except: [:index, :search_form, :submit_search, :show]



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
    @sections = @document.sections

    render "documents/show"
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
    @languages = Language.all
    gon.languages = @languages
    # construct a temporary section from parts
    @sections = @document.construct_sections_from_parts

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
      format.html { redirect_to documents_url, notice: 'Document was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # these 2 are hidden dev only methods only accesible through a link
  def language_parse
    document = Document.find(params[:id])
    document.language_parse
    # document.test_pdf
    redirect_to document_path(params[:id])
  end
  def resection_document
    document = Document.find(params[:id])
    document.resection_document
    redirect_to document_path(params[:id])
  end

  def search_form

    # give vue what it wants
    @languages = Language.all.map{ |language| [language.name, language.name] }.to_h
    gon.languages = @languages
    @countries = Country.all.map{ |country| [country.name, country.name] }.to_h
    gon.countries = @countries
    @report_types = Document::DOCUMENT_TYPES.map { |type| [type, type] }.to_h
    gon.report_types = @report_types

    render 'home/advanced_search'

  end

  def submit_search
    @search_results = Section.search(SearchGenerator.generate_search_hash(JSON.parse(params['query']))).with_details

    @languages = Language.all
    @collections = current_user&.collections
    @search_results_number = @search_results.length
    @search_results = @search_results.paginate(page: params[:page], per_page: 10)
    render :search_results
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

    def authenticate_admin
      redirect_to new_user_session_path unless current_user && current_user.admin?
    end

end
