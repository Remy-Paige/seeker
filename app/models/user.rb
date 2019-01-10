class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable ,
  #          :recoverable
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable

  has_many :ticket_relations
  has_many :user_tickets, through: :ticket_relations

  has_many :collections, dependent: :destroy

end
