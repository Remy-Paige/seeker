class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :edit_section_separation, :update, :update_section_separation, :destroy]
  before_action :authenticate_user!

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
        format.html { redirect_to @document, notice: 'Document was successfully added to processing queue.' }
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
        format.html { redirect_to @document, notice: 'Document was successfully updated.' }
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
    @search_result = Section.search(params[:s], fields: [:content], highlight: { tag: "<strong>" })
    render :search_result
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
