require 'will_paginate/array'

class Array

  def intersect_nested_search_result!(other_ary)
    hash = self.to_h
    other_hash = other_ary.to_h
    self[0..-1] = (hash.keys & other_hash.keys).map do |k|
      new_hash = other_hash[k][:highlight].merge(hash[k][:highlight] || {})
      [k, { highlight: new_hash }]
    end
  end

end
