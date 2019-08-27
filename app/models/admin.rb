class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_tickets

  has_many :collections, dependent: :destroy

  # admin and user should have the same columns

  def convert_to_user

    user = User.new(self.attributes)
    user.save!(validate: false)

    users = User.all
    users.each do |user|
    end


    collections = self.collections
    user_tickets = self.user_tickets

    collections.each do |collection|
      collection.user_id = user.id
      collection.admin_id = nil
      collection.save
    end

    user_tickets.each do |user_ticket|
      user_ticket.admin_id = nil
      # unmanaged
      user_ticket.status = 0
      user_ticket.save
    end

    self.delete
    return user

  end
end
