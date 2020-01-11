class Query < ActiveRecord::Base

  belongs_to :collection

  def self.save_query(params, current_user)
    collection = current_user.collections.where("name = '" + params[:collection].to_s + "'").first

    if collection == nil
      return 'nil collection'
    end

    existing_queries = collection.queries

    if existing_queries.length == 0
      @query = self.new(:collection_id => collection.id, :query => params[:query])
      @query.save
      return 'first submit'
    elsif existing_queries.length == 1
      hash1 = ActiveSupport::JSON.decode(existing_queries.first.query)
      hash2 = ActiveSupport::JSON.decode(params[:query])
      if hash1 == hash2
        return 'second submit'
      else
        return 'more than one'
      end

    end
  #   TODO: catch error
  end

  def self.replace_query(params, current_user)
    collection = current_user.collections.where("name = '" + params[:collection].to_s + "'").first

    if collection == nil
      return 'nil collection'
    end

    existing_query = collection.queries.first
    existing_query.destroy
    @query = self.new(:collection_id => collection.id, :query => params[:query])
    @query.save
    return 'second submit'
  end

end
