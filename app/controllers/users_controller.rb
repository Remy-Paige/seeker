class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  #TODO: improve the admin protection method - but it is mostly guarding against direct url input so

  # GET /users
  # GET /users.json
  # admins: can see all users and can edit, delete, give privileges from this screen
  # users: blocked
  # TODO:add a search or filter or something
  def index
    unless current_user.admin?
      redirect_to('/404')
    end

    @users = User.all

  end

  # GET /users/1
  # GET /users/1.json
  # main account page
  # admin: can edit, delete, give privileges from this screen
  # user: can edit, delete THEMSELVES ONLY
  def show
    unless current_user.admin?
      redirect_to('/404')
    end
    @user = User.find(params[:id])
  end

  # GET /users/new
  # users:blocked
  def new
    redirect_to('/404')
  end

  # GET /users/1/edit
  #   # admin: can edit, delete, give privileges
  #   # user: can edit, delete THEMSELVES ONLY
  def edit
    unless current_user.admin?
      redirect_to('/404')
    end
    @user = User.find(params[:id])
  end

  #TODO: investigate admin protection on the post and put

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: users_path }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  # //TODO: deleting seems to work but this should be monitered
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      #params.fetch(:user, {})
      params.require(:user).permit(:email,:admin, :password, :password_confirmation)
    end
end
