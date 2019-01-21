class Collection < ActiveRecord::Base

  has_many :collection_documents
  has_many :documents, through: :collection_documents

  has_many :queries, dependent: :destroy

  belongs_to :user

  before_destroy {documents.clear}

  validates :name, presence: true

end
