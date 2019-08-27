class UsersController < ApplicationController
  before_action :set_user, only: [:show, :destroy]
  before_action :authenticate_admin!, except: [:show]
  before_action :authenticate_user!, except: [:convert_to_admin, :destroy]

  # TODO: simply routes from a resource for clarity - only need show and delete

  # move index functionality to admin screen


  # GET /users/1
  # GET /users/1.json
  # main account page
  # admin: can edit, delete, give privileges from this screen
  # user: can edit, delete THEMSELVES ONLY
  def show
    # TODO: ugly permissions thing
    @user = User.find(current_user.id)
  end

  # cant make new users

  # edit is dont thru devise - admin changed thru custom function button

  def convert_to_admin
    user = User.find(params[:id])
    user.convert_to_admin
    respond_to do |format|
      format.html { redirect_to admins_path, notice: 'User was successfully converted to admin.' }
      format.json { head :no_content }
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  # ONLY for admin from index - user self deleteing handled thru devise
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admins_path, notice: 'User was successfully destroyed.' }
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
