class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable ,
  #          :recoverable
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable



  has_many :user_user_tickets
  has_many :user_tickets, :through => :user_user_tickets

  has_many :collections, dependent: :destroy

  def save_recent_query(query, user)
    user.recent_url = query
    user.save
  end

  def convert_to_admin
    self.admin = true
    self.save
  end

  def convert_to_user
    self.admin = false
    self.save
  end

end
