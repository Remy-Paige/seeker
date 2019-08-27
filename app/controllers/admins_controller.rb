class AdminsController < ApplicationController
  before_action :set_admin, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  # GET /admins
  # GET /admins.json
  def index
    @users = User.all
    @admins = Admin.all
  end

  # GET /admins/1
  # GET /admins/1.json
  def show
    # TODO: ugly permissions thing
    @user = Admin.find(current_admin.id)
  end

  # cant make new admins

  # GET /admins/1
  # edit is dont thru devise - admin changed thru custom function button
  def convert_to_user
    admin = Admin.find(params[:id])
    admin.convert_to_user
    respond_to do |format|
      format.html { redirect_to admins_path, notice: 'Admin was successfully converted to user.' }
      format.json { head :no_content }
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    @admin.destroy
    respond_to do |format|
      format.html { redirect_to admins_path, notice: 'Admin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = Admin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_params
      params.fetch(:admin, {})
    end
end
