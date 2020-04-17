class UserTicket < ActiveRecord::Base


  belongs_to :document
  # document has many user_ticket

  has_many :user_user_tickets
  has_many :users, through: :user_user_tickets

  before_destroy { users.clear }


  STATUS_TYPES = ['Unmanaged', 'Open', 'Resolved']
  STATUS_TYPES_ID = STATUS_TYPES.zip(0...STATUS_TYPES.length).to_h

  SUBJECT_TYPES = ['meta-data error', 'sectioning error', 'document request', 'other']


  # this helps to explain this code
  # # POST /user_tickets
  # # POST /user_tickets.json
  # def create
  #
  #   current_user.user_tickets << @user_ticket
  #   ticket_relation = current_user.user_user_tickets.where('user_ticket_id =' + @user_ticket.id.to_s).first
  #   ticket_relation.manages_owns = false
  #   ticket_relation.save


  def claim(user)

    #              unmanaged
    if self.status == 0
      #           open
      self.status = 1
      self.save
      user.user_tickets << self

      # manages_owns
      # false = owns
      # true = manages

      ticket_relations = user.user_user_tickets.where('user_ticket_id =' + self.id.to_s)
      ticket_relations[0].manages_owns = true
      ticket_relations[0].save

      # if the list is longer than one that means that this user is also the owner of the ticket
      if ticket_relations[1] != nil
        ticket_relations[1].manages_owns = false
        ticket_relations[1].save
      end

      user.reload


    end
  end

  def unclaim(user)

    if self.status == 1
      self.status = 0
      self.save

      ticket_relations = user.user_user_tickets.where('user_ticket_id =' + self.id.to_s)
      # if the list is longer than one that means that this user is the owner of the ticket
      # check both relationships, but only destroy the one that signifies management
      if ticket_relations[0].manages_owns
        ticket_relations[0].destroy
      elsif ticket_relations[1] != nil and ticket_relations[1].manages_owns
        ticket_relations[1].destroy
      end

      user.reload
    end
  end

  def resolve

    self.status = 2
    self.save

  end

end
