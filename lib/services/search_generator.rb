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

# query: {
#    "id": NIL,
#    "options": [{
#        "label_select": 'label',
#        "field": 'Article',
#        "filter": 'includes',
#        "keywords": []
#    },{
#        "label_select": 'label',
#        "field": 'Language',
#        "filter": 'includes',
#        "keywords": []
#    }, {
#        "label_select": 'label',
#        "field": 'Country',
#        "filter": 'includes',
#        "keywords": []
#    }]
#}
#
#
# full tree of what you can get from the form:
#
# fields:
# :text_search
# :section_number
# :article_paragraph
# :country
# :report_type
# :language
# :year
# :cycle
#
# filters:
# includes
# excludes
# all
# only
# less than
# greater than
#
# keywords:
# []
# one thing
# multiple things
#


module SearchGenerator
  # this makes it work in the controller
  # opens up self's singleton class
  # I have no idea why this helps
  class << self
    # logical queries are the ones with a set list of options
    # we simply need to weed them in or out, instead of scoring them
    # use the terms function in the elastic search DSL because we don't need to worry about the analysis of the text
    #
    # the _ to ' ' is there because of dropdowns - they were only sending the first word.
    # But this changed with the upgrade to vue so thats no longer needed
    def logical_queries(query_type, filter_type, keyword)
      field_report_type_sym = :report_type
      # from document model
      document_types = ['State Report', 'Committee of Experts Report', 'Committee of Ministers Recommendation']
      if filter_type == :all or keyword == []
        return {}
      elsif query_type == field_report_type_sym
      #   report type
        keyword.map! do |word|
          document_types.index(word)
        end
        search = Hash.new
        search[query_type] = keyword
        output = {terms: search}
        return output
      else
        # country and language
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
        output = {terms: search}
        return output
      end
    end

    def numeric_queries(query_type, filter_type, keyword)
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

    def generate_search_hash(query)
      # TODO: tidy up variable name conventions - query type vs field, filter etc
      # these are here so they're easier to change if things change.
      # Fuck. Gotta map database fields to front end fields
      filter_include_sym = :includes
      filter_exclude_sym = :excludes
      # database fields - see section model
      field_text_search_sym = :section_text
      field_section_number_sym = :section_number
      field_article_paragraph_sym = :article_paragraph
      field_country_sym = :country
      field_report_type_sym = :report_type

      field_language_sym = :language
      field_year_sym = :year
      field_cycle_sym = :cycle

      numeric_queries = [field_year_sym, field_cycle_sym]
      # hiding language strengths from users, but keeping it in the backend because I'm lazy
      # :language from front end will be changed to :medium_language if its seen
      logical_queries = [field_country_sym, field_report_type_sym, :medium_language]

      include_filter_type = [filter_include_sym, :between, :greater_than, :less_than, :only]
      # these arrays contain the text_search, section_number, article_paragraph queries
      # they need to be surrounded by a dis_max thing, like this # must_arr.push({dis_max:{queries: text_arr}})
      # includes (text) and excludes (must not text) arrays are separate
      text_arr = []
      must_not_text_arr = []

      # these arrays contain logical queries and numeric queries
      # numeric queries don't have a excludes option, so they are handled only in the includes section
      filter_arr = []
      must_not_arr = []

      # this array is what the text arr gets folded into with the dismax
      must_arr = []
      # text queries are handled differently to the filter queries and must_not and must_not_text queries
      # must_not and must_not_text both get folded into must_not


      # mark whether to add dis_max
      text_search_present = false
      must_not_text_search_present = false

      # process the front end input to match the backend symbols
      query['options'].each do |option|
        option['field'] = option['field'].parameterize.underscore.to_sym
        option['filter'] = option['filter'].parameterize.underscore.to_sym
        # hiding language strengths from users, but keeping it in the backend because I'm lazy
        if option['field'] == field_language_sym
          option['field'] = :medium_language
        end
        if option['field'] == :article
          option['field'] = field_article_paragraph_sym
        end
      end

      query['options'].each do |option|
        query_type = option['field']
        filter_type = option['filter']
        keyword = option['keywords']

        # first handle for excludes filter type, as it has special cases
        # text searches need the dis_max skeleton - this is added only if its needed
        if filter_type == filter_exclude_sym

          if query_type == field_text_search_sym
            #so that we know to append the dismax queries - if we include dis_max in the skeleton with an empty array es complains
            must_not_text_search_present = true
            keyword&.each do |word|
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search"}}})
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:10,operator:"and",analyzer:"searchkick_search2"}}})
              must_not_text_arr.append({match:{"content.analyzed":{query: word,boost:1,operator:"and",analyzer:"searchkick_search",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
              must_not_text_arr.append({match:{"content.analyzed":{"query": word,boost:1,operator:"and",analyzer:"searchkick_search2",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
            end
          elsif query_type == field_section_number_sym
            must_not_text_search_present = true
            keyword&.each do |word|
              must_not_text_arr.append({match:{"section_number.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
            end
          elsif query_type == field_article_paragraph_sym
            must_not_text_search_present = true
            keyword&.each do |word|
              must_not_text_arr.append({match:{"article_paragraph.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
            end
          #the numerical queries don't have a none_of option
          elsif logical_queries.include?(query_type)
            must_not_arr.append(logical_queries(query_type, filter_type, keyword))
          end

        elsif  include_filter_type.include?(filter_type)

          if query_type == field_text_search_sym
            #so that we know to append the dismax queries - if we include dis_max in the skeleton with an empty array elastic search complains
            text_search_present = true
              # not good results
            text_arr.append({match:{"content":{query: keyword,boost:10,operator:"and"}}})
            text_arr.append({match:{"content.analyzed":{query: keyword,boost:10,operator:"and",analyzer:"searchkick_search"}}})
            text_arr.append({match:{"content.analyzed":{query: keyword,boost:10,operator:"and",analyzer:"searchkick_search2"}}})
            text_arr.append({match:{"content.analyzed":{query: keyword,boost:1,operator:"and",analyzer:"searchkick_search",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
            text_arr.append({match:{"content.analyzed":{"query": keyword,boost:1,operator:"and",analyzer:"searchkick_search2",fuzziness:1,prefix_length:0,max_expansions:3,fuzzy_transpositions:true}}})
          elsif query_type == field_section_number_sym
            keyword&.each do |word|
              if word != ""
                text_search_present = true
                text_arr.append({match:{"section_number.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
              end
            end
          elsif query_type == field_article_paragraph_sym
            subparagraph_search_regex = /^.*[\.].*[\.][a-zA-Z]/
            keyword&.each do |word|
              word = word.strip! || word
              # resiliancy for if the sectioning process didn't pick up the subparagraphs
              if word =~ subparagraph_search_regex
                text_search_present = true
                pattern = /[a-zA-Z][\.]/
                new_word = word.reverse.sub(pattern, '').reverse
                text_arr.append({match:{"article_paragraph.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
                text_arr.append({match:{"article_paragraph.word_start":{query:new_word,operator:"and",analyzer:"searchkick_word_search"}}})
              elsif word != ""
                text_search_present = true
                text_arr.append({match:{"article_paragraph.word_start":{query:word,boost:10,operator:"and",analyzer:"searchkick_word_search"}}})
              end
            end
            # dont need to loop over words for these - keyword array just gets dumped into es
          elsif logical_queries.include?(query_type)
            filter_arr.append(logical_queries(query_type, filter_type, keyword))
          elsif numeric_queries.include?(query_type)
            filter_arr.append(numeric_queries(query_type,filter_type,keyword))
          end
        end

      end

      if must_not_text_search_present
        must_not_arr.append(dis_max:{queries: must_not_text_arr})
      end
      if text_search_present
        must_arr.append(dis_max:{queries: text_arr})
      end

      output = {
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
      return output
    end




  end
end
