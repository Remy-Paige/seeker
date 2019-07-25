class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  respond_to :html, :js

  # GET /collections
  # GET /collections.json
  def index
    @collections = current_user.collections
    sections = []

    @collections.each do |collection|
      collection.collection_documents.each do |relation|
        document = Document.find(relation.document_id)
        sections.push(document.sections.where("section_number = '" + relation.section_number.to_s + "'").first)
      end
    end
    @sections = sections

    @blank = Collection.new

  end

  def save_section
    # can only save sections not whole documents
    collection = current_user.collections.where("name = '" + params[:collection].to_s + "'").first

    if collection == nil
      respond_to do |format|
        format.js { flash.now[:notice] = "Please Select or Create a Collection" }
        format.json { flash.now[:notice] = "Please Select or Create a Collection" }
      end
      return
    end

    document = Document.find(params[:document_id])

    section_list = collection.collection_documents.where("section_number = '" + params[:section_number].to_s + "'")

    #if the section is not already in the collection
    if section_list.length == 0
      # add a new relation
      collection.documents << document
      # this is why the section number validation doesnt work

      # edit the new relation to include the section number
      relation = collection.collection_documents.where("section_number IS ?", nil).first
      relation.section_number = params[:section_number]
      relation.save
      respond_to do |format|
        format.js { flash.now[:notice] = "Successfully Added to Collection" }
        format.json { flash.now[:notice] = "Successfully Added to Collection" }
      end
    else
      #would put a failure notice here but the click happens twice and idk how to stop that
      respond_to do |format|
        format.js { flash.now[:notice] = "Successfully Added to Collection" }
        format.json { flash.now[:notice] = "Successfully Added to Collection" }
      end
    end



  end

  def remove
    @collection = Collection.find(params[:id])
    relation = @collection.collection_documents.where("document_id =" + params[:document_id] + "AND section_number = '" + params[:section_number] + "'").first
    relation.destroy
    redirect_to(:back)
  end

  def export

    if params[:export_type] == 'collection'
      collection = Collection.find(params[:id])

      # cant delete the file - so create new at beginning every time

      File.open('export.txt', 'w') {
          |file|
      }

      # cant each or map over a active record association
      # section name has a \n at the end of it
      for index in 0..collection.collection_documents.length - 1
        relation = collection.collection_documents[index]
        document = Document.find(relation.document_id)
        country = Country.find(document.country_id)
        section = document.sections.where("section_number = '" + relation.section_number.to_s + "'").first
        File.open('export.txt', 'a') {
            |file| file.write('URL: ' + document.url.to_s + "\n" + 'type: ' + Document::DOCUMENT_TYPES[document.document_type].to_s + "\n" + 'year: ' + document.year.to_s + "\n" + 'cycle: ' + document.cycle.to_s + "\n" + 'country: ' + country.name.to_s + "\n" + 'section name: ' + section.section_name.to_s + 'section number: ' + section.section_number.to_s + "\n" + "\n")
        }
      end

      send_file('export.txt')

    else
      document = Document.find(params[:document_id])
      section = document.sections.where("section_number = '" + params[:section_number].to_s + "'").first

      File.open('export.txt', 'w') {
          |file| file.write('URL: ' + document.url.to_s + "\n" + 'type: ' + Document::DOCUMENT_TYPES[document.document_type].to_s + "\n" + 'year: ' + document.year.to_s + "\n" + 'cycle: ' + document.cycle.to_s + "\n" + 'country: ' + country.name.to_s + "\n" + 'section name: ' + section.section_name.to_s + 'section number: ' + section.section_number.to_s + "\n" + "\n")
      }

      send_file('export.txt')

    end


  end

  # GET /collections/1
  # GET /collections/1.json
  def show
    @collection = Collection.find(params[:id])
    @queries = @collection.queries


    section_list = []

    @collection.collection_documents.each do |relation|
      document = Document.find(relation.document_id)
      document.sections.group_by(&:section_number).map do |section_number, sections|
        section_name = sections.first.section_name
        language_sections = sections.first.language_sections
        page_number = sections.first.page_number
        content = sections.sort_by(&:section_part).map(&:content).join
        sec = Section.new(section_number: section_number, section_name: section_name, content: content, page_number: page_number, document_id: relation.document_id)
        if relation.section_number == section_number
          language_sections&.each do |relation2|
            sec.language_sections << relation2
          end
          section_list.push(sec)
        end
      end

    end
    @languages = Language.all
    @sections = section_list
  end



  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections
  # POST /collections.json
  def create

    collections = current_user.collections
    present = false
    collections.each do |collect|
      if collection_params[:name] == collect.name
        present = true
      end
    end
    if present
      respond_to do |format|
        format.html { redirect_to collections_path, notice: 'Collection already present' }
        format.json { render :show, status: :created, location: @collection }
      end
    else
      @collection = Collection.new(collection_params)

      current_user.collections << @collection

      respond_to do |format|
        if @collection.save
          format.html { redirect_to @collection, notice: 'Collection was successfully created.' }
          format.json { render :show, status: :created, location: @collection }
        else
          format.html { render :new }
          format.json { render json: @collection.errors, status: :unprocessable_entity }
        end
      end
    end



  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: 'Collection was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      params.require(:collection).permit(:name, :collection, :document_id, :section_number, :save_type, :query)
    end


end
