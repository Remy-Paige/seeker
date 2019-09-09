class LanguageParserJob 
  include SuckerPunch::Job
  
  def perform(id)
    # Jobs interacting with ActiveRecord should take special precaution not to exhaust connections in the pool
    # .connection_pool.with_connection ensures the connection is returned back to the pool when completed.
    # ActiveRecord::Base.connection_pool.with_connection do
    #   user = User.find(user_id)
    #   user.update(is_awesome: true)
    # end
    #
    document = Document.find(id)

    parse_log = Logger.new('log/parse_log.txt')
    parse_log.debug "Log file created"


    # languages_test_1 = ['Albanian', 'Beás','Crimean Tatar', 'Cypriot Maronite Arabic','Istro-Romanian','Kven/Finnish','Meänkieli','Scottish-Gaelic','Yiddish']
    # languages_test_2 = ['Beás','Cornish','Irish','Manx Gaelic','Scots','Scottish-Gaelic','Ulster Scots','Welsh','Inari Sami','North Sami','South Sami','Tatar']
    # languages_test_3 = ['Beás','Manx Gaelic']
    # languages = []
    #     languages_test_1.each do |language_string|
    #       language = Language.find_by_name(language_string)
    #       languages << language
    #     end
    # beas is matching on 'be a' and 'be'

    languages = Language.all

    # strip existing language associations
    document.sections.each do |section|
      section.languages.clear
    end


    strengths = [3,2,1]

    # this will do each part
    document.sections.each do |section|
      parse_log.info section.section_uid.to_s
      languages.each do |language|
        parse_log.info '  ' + language.name.to_s
        strengths.each do |strength|
          parse_log.info '    strength' + strength.to_s

          if strength == 1
            search_results = strong_search(document, language, section)
            parse_log.info '      length' + search_results.length.to_s
            # if the language is in the section part
            if search_results.length > 0
              # parse_log.info search_results.to_s
              if section.languages.include? language
                relation = section.language_sections.where('language_id =' + language.id.to_s).first
                relation.strength = 1
                relation.save
                parse_log.info '      post save relation.strength' + relation.strength.to_s
                parse_log.info '      include'
              else
                section.languages << language
                relation = section.language_sections.where('language_id =' + language.id.to_s).first
                relation.strength = 1
                relation.save
                parse_log.info '      not include'
              end
            end

          elsif strength == 2
            search_results = medium_search(document, language, section)
            parse_log.info '      length' + search_results.length.to_s
            if search_results.length > 0

              if section.languages.include? language
                relation = section.language_sections.where('language_id =' + language.id.to_s).first
                relation.strength = 2
                relation.save
                parse_log.info '      include'
              else
                section.languages << language
                relation = section.language_sections.where('language_id =' + language.id.to_s).first
                relation.strength = 2
                relation.save
                parse_log.info '      not include'
              end
            end

          elsif strength == 3
            search_results = weak_search(document, language, section)
            parse_log.info '      length' + search_results.length.to_s
            if search_results.length > 0

              if section.languages.include? language
                  relation = section.language_sections.where('language_id =' + language.id.to_s).first
                  relation.strength = 3
                  relation.save
                  parse_log.info '      include'
              else
                  section.languages << language
                  relation = section.language_sections.where('language_id =' + language.id.to_s).first
                  relation.strength = 3
                  relation.save
                  parse_log.info '      not include'
               end
            end

          end

        end

      end


    end

    Section.reindex
    parse_log.info 'parsing finished'
    document.finish_parsing!
  rescue StandardError => e
    logger.info 'Failure'
    document.status = 1
    document.save
    raise e
  end
end

# detect single exact words - 1
def strong_search(document, language, section)

  if section.content.include? language.name
    return [true]
  else
    return []
  end
  # beas as be a is a strong search match for 'be a' for some god forsaken reason
  end

# detect multiple exact words - 2
def medium_search(document, language, section)
  Section.search(body: {
      "query":{
          "bool":{
              "must":{
                  "dis_max":{
                      "queries":[
                          {"match":{"content.analyzed":{"query":language.name,"boost":10,"operator":"and","analyzer":"searchkick_search"}}},
                          {"match":{"content.analyzed":{"query":language.name,"boost":10,"operator":"and","analyzer":"searchkick_search2"}}}
                      ]
                  }
              },
              "filter":[
                  {"term":{"url":document.url.to_s}},
                  {"term":{"section_number":section.section_number}}
              ]
          }
      },
      "size":1000,
      "from":0}).with_details
end

# detect multiple inexact words and word starts - 3
def weak_search(document, language, section)
  Section.search(body: {
      "query":{
          "bool":{
              "must":{
                  "dis_max":{
                      "queries":[
                          {"match":{"content.analyzed":{"query":language.name,"boost":10,"operator":"and","analyzer":"searchkick_search"}}},
                          {"match":{"content.analyzed":{"query":language.name,"boost":10,"operator":"and","analyzer":"searchkick_search2"}}},
                          {"match":{"content.analyzed":{"query":language.name,"boost":1,"operator":"and","analyzer":"searchkick_search","fuzziness":1,"prefix_length":0,"max_expansions":3,"fuzzy_transpositions":true}}},
                          {"match":{"content.analyzed":{"query":language.name,"boost":1,"operator":"and","analyzer":"searchkick_search2","fuzziness":1,"prefix_length":0,"max_expansions":3,"fuzzy_transpositions":true}}},
                          {"match":{"content.word_start":{"query":language.name,"boost":10,"operator":"and","analyzer":"searchkick_word_search"}}}
                      ]
                  }
              },
              "filter":[
                  {"term":{"url":document.url.to_s}},
                  {"term":{"section_number":section.section_number}}
              ]
          }
      },
      "size":1000,
      "from":0}).with_details
end
