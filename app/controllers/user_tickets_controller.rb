class UserTicketsController < ApplicationController
  before_action :set_user_ticket, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /user_tickets
  # GET /user_tickets.json
  def index
    if current_user.admin?
      @unmanaged_user_tickets = UserTicket.where('status = 0')
      # should admins be able to make tickets? the where defends against admins unmanaged tickets
      # appearing in their list of open tickets in any case
      # todo: do over terminology
      @open_user_tickets = current_user.user_tickets.where('status = 1')
      render 'user_tickets/index_admin'
    else
      @user_tickets = current_user.user_tickets
    end
  end

  # GET /user_tickets/1
  # GET /user_tickets/1.json
  def show
  end

  # GET /user_tickets/new
  def new
    @user_ticket = UserTicket.new
  end

  # GET /user_tickets/1/edit
  def edit
    @subject_types = Document::SUBJECT_TYPES
  end

  # GET /user_tickets/1/claim
  def claim
    @user_ticket = UserTicket.find(params[:id])

    if @user_ticket.status == 0
      @user_ticket.status = 1
      @user_ticket.save
      current_user.user_tickets << @user_ticket

      ticket_relation = current_user.ticket_relations.where('user_ticket_id =' + params[:id]).first
      ticket_relation.manages = true
      ticket_relation.save
    end

    # TODO: json check?
    # TODO: improve the error/redirect

    redirect_to user_tickets_path
  end

  # POST /user_tickets
  # POST /user_tickets.json
  def create
    @user_ticket = UserTicket.new(:name => current_user.name, :email => current_user.email, :comment => user_ticket_params[:comment], :subject => user_ticket_params[:subject], :status => 0)

    respond_to do |format|
      if @user_ticket.save
        format.html { redirect_to @user_ticket, notice: 'User ticket was successfully created.' }
        format.json { render :show, status: :created, location: @user_ticket }
      else
        format.html { render :new }
        format.json { render json: @user_ticket.errors, status: :unprocessable_entity }
      end
    end

    current_user.user_tickets << @user_ticket
  end

  # PATCH/PUT /user_tickets/1
  # PATCH/PUT /user_tickets/1.json
  def update
    respond_to do |format|
      if @user_ticket.update(user_ticket_params)
        format.html { redirect_to @user_ticket, notice: 'User ticket was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_ticket }
      else
        format.html { render :edit }
        format.json { render json: @user_ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_tickets/1
  # DELETE /user_tickets/1.json
  def destroy
    @user_ticket.destroy
    respond_to do |format|
      format.html { redirect_to user_tickets_url, notice: 'User ticket was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_ticket
      @user_ticket = UserTicket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_ticket_params
      params.require(:user_ticket).permit(:comment, :subject)
    end
end
