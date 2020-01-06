class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token, :only => [:save_query]
  # GET /queries
  # GET /queries.json
  def index
    @queries = Query.all
  end

  def save_query

    result = Query.save_query(params, current_user)

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

  # GET /queries/1
  # GET /queries/1.json
  def show
  end

  # GET /queries/new
  def new
    @query = Query.new
  end

  # GET /queries/1/edit
  def edit
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)

    respond_to do |format|
      if @query.save
        format.html { redirect_to @query, notice: 'Query was successfully created.' }
        format.json { render :show, status: :created, location: @query }
      else
        format.html { render :new }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /queries/1
  # PATCH/PUT /queries/1.json
  def update
    respond_to do |format|
      if @query.update(query_params)
        format.html { redirect_to @query, notice: 'Query was successfully updated.' }
        format.json { render :show, status: :ok, location: @query }
      else
        format.html { render :edit }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.json
  def destroy
    @query.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
      params.fetch(:query, {})
    end

end
