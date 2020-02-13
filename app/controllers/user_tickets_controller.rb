class UserTicketsController < ApplicationController
  before_action :set_user_ticket, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  # ONLY needs new - admin cant make new - has to be in the controller
  before_action :authenticate_admin, only: [:claim, :resolve]

  # GET /user_tickets
  # GET /user_tickets.json
  def index
    if current_user.admin?
      @my_user_tickets = current_user.user_tickets.where('manages_owns = false')
      @unmanaged_user_tickets = UserTicket.where('status = 0').uniq
      @open_user_tickets = current_user.user_tickets.where('status = 1 and manages_owns = true').uniq
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

    # can be nil
    @document_id = params[:document_id]
    @section_uid = params[:section_uid]
  end

  # GET /user_tickets/1/edit
  def edit
    @subject_types = UserTicket::SUBJECT_TYPES
  end

  # GET /user_tickets/1/claim
  def claim
    user_ticket = UserTicket.find(params[:id])
    user_ticket.claim(current_user)

    redirect_to user_tickets_path
  end

  # GET /user_tickets/1/claim
  def unclaim
    user_ticket = UserTicket.find(params[:id])
    user_ticket.unclaim(current_user)

    redirect_to user_tickets_path
  end

  def resolve
    user_ticket = UserTicket.find(params[:id])
    user_ticket.resolve

    redirect_to user_tickets_path

  end

  # POST /user_tickets
  # POST /user_tickets.json
  def create

    @user_ticket = UserTicket.new(:user_id => current_user.id,:email => current_user.email,:link => user_ticket_params[:link],
                                  :comment => user_ticket_params[:comment], :subject => user_ticket_params[:subject], :status => 0,
                                  :section_uid => user_ticket_params[:section_uid], :document_id => user_ticket_params[:document_id])

    current_user.user_tickets << @user_ticket
    ticket_relation = current_user.user_user_tickets.where('user_ticket_id =' + @user_ticket.id.to_s).first
    ticket_relation.manages_owns = false
    ticket_relation.save
    respond_to do |format|
      if @user_ticket.save
        format.html { redirect_to @user_ticket, notice: 'User ticket was successfully created.' }
        format.json { render :show, status: :created, location: @user_ticket }
      else
        format.html { render :new }
        format.json { render json: @user_ticket.errors, status: :unprocessable_entity }
      end
    end

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
      format.html { redirect_to user_tickets_url, notice: 'User ticket was successfully deleted.' }
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
      params.require(:user_ticket).permit(:comment, :subject, :link, :section_uid, :document_id)
    end

    def authenticate_admin
      redirect_to new_user_session_path unless current_user && current_user.admin?
    end

end
