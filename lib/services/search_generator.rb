# This form:
#
# module Familiar
#   def ask_age
#     return "How old are you?"
#   end
# end
#
# defines #ask_age as an instance method on Familiar. However, you can't instantiate Modules, so you can't get to their instance methods directly; you mix them into other classes. Instance methods in modules are more or less unreachable directly.
#
# This form, by comparison:
#
# module Familiar
#   def self.ask_age
#     return "What's up?"
#   end
# end
#
# defines ::ask_age as a module function. It is directly callable, and does not appear on included classes when the module is mixed into another class.

module SearchGenerator

  class << self
    def generate_search_hash(params)

      numeric_queries = [:year, :cycle]
      logical_queries = [:country, :strong_language, :medium_language, :weak_language]

      must_arr = []
      must_not_text_arr = []
        # must_arr.push({dis_max:{queries: text_arr}})
      filter_arr = []
      must_not_arr = []
      text_arr = []

      text_search_present = false
      must_not_text_search_present = false

      params[:keyword]&.each_key do |key|
        #these are all arrays (so that the ID is constant) but there is only one element
        query_type = params[:query_type][key][0].parameterize.underscore.to_sym
        filter_type = params[:filter_type][key][0].parameterize.underscore.to_sym
        #variable number of elements so keep as an array
        keyword = params[:keyword][key]

        #first search for none_of filter type because the filter overrides the query in this case
        # both text_search and section_number do text searches - but section number has the word start option and has to be treated separatle
        # text searches need the dis_max skeleton - this is added only if its needed
        if filter_type == :none_of

          if query_type == :text_search
            #so that we know to append the dismax queries - if we include dis_max in the skeleton with an empty array es complains
            must_not_text_search_present = true
            keyword&.each do |word|
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search"}}})
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search2"}}})
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:1,operator:"and",analyzer:"searchkick_search",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
              must_not_text_arr.append({match:{"content.analyzed":{"query": word,boost:1,operator:"and",analyzer:"searchkick_search2",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
            end
          elsif query_type == :section_number

            must_not_text_search_present = true
            keyword&.each do |word|
              must_not_text_arr.append({match:{"section_number.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
            end
            #the numerical queries don't have a none_of option
          elsif logical_queries.include?(query_type)
            must_not_arr.append(logical_queries(query_type, filter_type, keyword))
          end

        elsif query_type == :text_search
          #so that we know to append the dismax queries - if we include dis_max in the skeleton with an empty array elastic search complains
          text_search_present = true
          keyword&.each do |word|
            # not good results
            text_arr.append({match:{"content":{query: word,boost:10,operator:"and"}}})
            # Manx Gaelic : Manx Gaelic, Scottish-Gaelic: Scottish Gaelic Socttish-Gaelic
            text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search"}}})
            # Scottish-Gaelic: Gaelic Scottish Socttish, Manx Gaelic: Gaelic scottish-gaelic socttish gaelic Manx
            text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search2"}}})
            text_arr.append({match:{"content.analyzed":{query: word,boost:1,operator:"and",analyzer:"searchkick_search",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
            text_arr.append({match:{"content.analyzed":{"query": word,boost:1,operator:"and",analyzer:"searchkick_search2",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
          end
        elsif query_type == :section_number
          keyword&.each do |word|
            if word != ""
              text_search_present = true
              text_arr.append({match:{"section_number.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
            end
          end
          # dont need to loop over words for these - keyword array just gets dumped into es
        elsif logical_queries.include?(query_type)
          filter_arr.append(SearchGenerator.logical_queries(query_type, filter_type, keyword))
        elsif numeric_queries.include?(query_type)
          filter_arr.append(numeric_queries(query_type,filter_type,keyword))
        end

      end
      if must_not_text_search_present
        must_not_arr.append(dis_max:{queries: must_not_text_arr})
      end
      if text_search_present
        must_arr.append(dis_max:{queries: text_arr})
      end

      return {
          body: {
          query:{
              function_score:{
                  functions:[{filter:{and:[{term:{full_content:false}}]},boost_factor:1000}],
                  query:{
                      bool:{
                          must: must_arr,
                          filter:filter_arr,
                          must_not: must_not_arr
                      }
                  },
                  "score_mode":"sum"
              }
          },
          "size":1000,
          "from":0,
          "highlight":{"fields":{"content.analyzed":{"type":"plain","fragment_size":1250}},"pre_tags":["\u003cstrong\u003e"],"post_tags":["\u003c/strong\u003e"]},"fields":[]}
      }

    end
  end


  def self.logical_queries(query_type, filter_type, keyword)
    #use the terms function in the elastic search DSL because we don't need to worry about the analysis of the text
    if filter_type == :all
      {}
    else
      # map! edits the og array
      keyword.map! do |word|
        if word.include? "_"
          word.gsub!('_', ' ')
        else
          word
        end
      end

      search = Hash.new
      search[query_type] = keyword
      {terms: search}
    end
  end

  def self.numeric_queries(query_type, filter_type, keyword)
    if filter_type == :all
      #do nothing
      return {}
    elsif filter_type == :only
      word = Integer(keyword[0])
      search_terms = Hash.new
      search_terms[:lt] = String(word+1)
      search_terms[:gt] = String(word-1)
      search = Hash.new
      search[query_type] = search_terms
      #{query_type: {"gt" : word-1, "lt" : word+1}}
      return {range: search}
    elsif filter_type == :less_than
      word = keyword[0]
      search_terms = {lt: word}
      search = Hash.new
      search[query_type] = search_terms
      #{query_type: {lt: word}}
      return {range: search}
    elsif filter_type == :greater_than
      word = keyword[0]
      search_terms = {gt: word}
      search = Hash.new
      search[query_type] = search_terms
      #{query_type: {gt: word}}
      return {range: search}
    elsif filter_type == :between

      if keyword[0] > keyword[1]
        big = keyword[0]
        small = keyword[1]
      else
        big = keyword[1]
        small = keyword[0]
      end
      search_terms = Hash.new
      search_terms[:lt] = big
      search_terms[:gt] = small
      search = Hash.new
      search[query_type] = search_terms
      #{query_type: {"gt" : small, "lt" : big}}
      return {range: search}
    end
  end

end
