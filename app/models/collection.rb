class Collection < ActiveRecord::Base

  has_many :collection_documents
  has_many :documents, through: :collection_documents

  has_many :queries

  belongs_to :user

end
