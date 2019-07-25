class Query < ActiveRecord::Base

  belongs_to :collection

  def self.save_query(params, current_user)
    collection = current_user.collections.where("name = '" + params[:collection].to_s + "'").first

    if collection == nil
      return 'nil collection'
    end

    existing_queries = collection.queries
    query_list = existing_queries.where("query = '" + params[:query] + "'")

    if query_list.length == 0
      @query = self.new(:collection_id => collection.id, :query => params[:query])
      @query.save
      return 'first submit'
    else
      return 'second submit'
    end
  #   TODO: catch error
  end

end
