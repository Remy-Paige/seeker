class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token, :only => [:save_section]
  respond_to :html, :js

  # GET /collections
  # GET /collections.json
  def index
    @collections = current_user.collections
  end

  def save_section
    # can only save sections not whole documents

    result = Collection.save_section(params, current_user)

    if result == 'nil collection'
      respond_to do |format|
        format.html { redirect_to :back, notice: "Please Create a Collection" }
        format.js { flash.now[:notice] = "Please Create a Collection" }
        format.json { flash.now[:notice] = "Please Create a Collection" }
      end
    elsif result == 'first submit'
      respond_to do |format|
        format.html { redirect_to :back, notice: "Successfully Added to Collection" }
        format.js { flash.now[:notice] = "Successfully Added to Collection" }
        format.json { flash.now[:notice] = "Successfully Added to Collection" }
      end
    elsif result == 'second submit'
      #the click happens twice and idk how to stop that, so its just repeated
      respond_to do |format|
        format.html { redirect_to :back, notice: "Successfully Added to Collection" }
        format.js { flash.now[:notice] = "Successfully Added to Collection" }
        format.json { flash.now[:notice] = "Successfully Added to Collection" }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, notice: "Failed to add to Collection, Contact Administrator" }
        format.js { flash.now[:notice] = "Failed to add to Collection, Contact Administrator" }
        format.json { flash.now[:notice] = "Failed to add to Collection, Contact Administrator" }
      end
    end


  end

  def remove
    collection = Collection.find(params[:id])
    collection.remove_section(params)
    redirect_to(:back)
  end

  def export
    # both types of export come here and get sorted out
    # put in a service? or the 2 separate controllers? They Could go in the 2 controllers
    if params[:export_type] == 'collection'
      collection = Collection.find(params[:id])
      collection.export_collection
    else
      Collection.export_section(params)
    end
    send_file('export.txt')
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
    @collection = Collection.find(params[:id])
    @collections = current_user.collections
    @queries = @collection.queries
    @languages = Language.all

    @vue_languages = @languages.map{ |language| [language.name, language.name] }.to_h
    @countries = Country.all.map{ |country| [country.name, country.name] }.to_h
    @report_types = Document::DOCUMENT_TYPES.map { |type| [type, type] }.to_h
    @sections = @collection.construct_sections_from_parts
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

    if Collection.check_exists(collection_params, current_user)
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
      format.html { redirect_to collections_url, notice: 'Collection was successfully deleted.' }
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
      params.require(:collection).permit(:name, :description, :collection, :document_id, :section_uid, :save_type, :query)
    end

end
