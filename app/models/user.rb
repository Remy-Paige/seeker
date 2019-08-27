class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable ,
  #          :recoverable
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable, :recoverable


  has_many :user_tickets

  has_many :collections, dependent: :destroy

  def convert_to_admin
    admin = Admin.new(self.attributes)
    admin.save!(validate: false)


    collections = self.collections
    user_tickets = self.user_tickets

    # doesnt work?
    collections.each do |collection|
      collection.admin_id = admin.id
      collection.user_id = nil
      collection.save
    end

    # works just fine
    user_tickets.each do |user_ticket|
      user_ticket.user_id = nil
      # TODO: make sure the views dont fail
      if user_ticket.admin_id == nil
        user_ticket.admin_id = admin.id
      end
      # open
      user_ticket.status = 1
      user_ticket.save
    end

    self.delete
    return admin
  end

end
