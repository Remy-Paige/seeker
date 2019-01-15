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

  def save
    # can only save sections and queries, not whole documents
    collection = current_user.collections.where("name = '" + params[:collection].to_s + "'").first

    if params[:save_type] == 'section'

      document = Document.find(params[:document_id])

      section_list = collection.collection_documents.where("section_number = '" + params[:section_number].to_s + "'")

      if section_list.length == 0
        collection.documents << document

        relation = collection.collection_documents.where("section_number IS ?", nil).first
        relation.section_number = params[:section_number]
        relation.save
        #TODO: display notice
      else
        #TODO: display notice
      end
    else
    #   save query
    # class => string
    #

      existing_queries = collection.queries
      query_list = existing_queries.where("query = '" + params[:query] + "'")

      if query_list.length == 0
        @query = Query.new(:collection_id => collection.id, :query => params[:query])
        @query.save
      else

      end

    end

  end

  def remove
    @collection = Collection.find(params[:id])
    relation = @collection.collection_documents.where("document_id =" + params[:document_id] + "AND section_number = '" + params[:section_number] + "'").first
    relation.destroy
    redirect_to(:back)
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
    @collection = Collection.find(params[:id])
    @queries = @collection.queries
    sections = []

    @collection.collection_documents.each do |relation|
      document = Document.find(relation.document_id)
      sections.push(document.sections.where("section_number = '" + relation.section_number.to_s + "'").first)
    end
    @sections = sections
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
