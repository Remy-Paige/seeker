class UsersController < ApplicationController
  before_action :set_user, only: [:show, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin, except: [:show]

  def index
    @users = User.where("admin is false")
    @admins = User.where("admin is true")

  end

  # GET /users/1
  # GET /users/1.json
  # main account page
  # admin: can edit, delete, give privileges from this screen
  # user: can edit, delete THEMSELVES ONLY
  def show
    @user = User.find(current_user.id)
  end

  # DELETE /users/1
  # DELETE /users/1.json
  # ONLY for admin from index - user self deleteing handled thru devise
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def convert_to_user
    user = User.find(params[:id])
    user.convert_to_user

    if current_user.admin?
      redirect_to :controller => 'users', :action => 'index'
    else
      redirect_to :controller => 'documents', :action => 'advanced_search'
    end
  end

  def convert_to_admin
    user = User.find(params[:id])
    user.convert_to_admin

    redirect_to :controller => 'users', :action => 'index'
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

    def authenticate_admin
      redirect_to new_user_session_path unless current_user && current_user.admin?
    end
end
