class LanguageParserJob 
  include SuckerPunch::Job
  
  def perform(document)
    # Jobs interacting with ActiveRecord should take special precaution not to exhaust connections in the pool
    # .connection_pool.with_connection ensures the connection is returned back to the pool when completed.
    # ActiveRecord::Base.connection_pool.with_connection do
    #   user = User.find(user_id)
    #   user.update(is_awesome: true)
    # end
    #

    languages = Language.all

    strengths = [3,2,1]

    # this will do each part
    # but the search will work on the entire section - split into parts
    # so if its anywhere in the section it will turn up for all section parts
    # and because length > 0 it'll work (probably)
    # HOWEVER
    # associating it with only one of the sections wont work
    # but itll turn up for every part because of the above so itll all work out
    document.sections.each do |section|

      languages.each do |language|

        strengths.each do |strength|

          if strength == 1
            search_results = strong_search(document, language, section)

            if search_results.length > 0

              if section.languages.include? language
                relation = section.language_sections.where('language_id =' + language.id.to_s).first
                relation.strength = 1
                relation.save
              else
                section.languages << language
                relation = section.language_sections.where('language_id =' + language.id.to_s).first
                relation.strength = 1
                relation.save
              end
            end

          elsif strength == 2
            search_results = medium_search(document, language, section)

            if search_results.length > 0

              if section.languages.include? language
                relation = section.language_sections.where('language_id =' + language.id.to_s).first
                relation.strength = 2
                relation.save
              else
                section.languages << language
                relation = section.language_sections.where('language_id =' + language.id.to_s).first
                relation.strength = 2
                relation.save
              end
            end

          elsif strength == 3
            search_results = weak_search(document, language, section)

            if search_results.length > 0

              if section.languages.include? language
                  relation = section.language_sections.where('language_id =' + language.id.to_s).first
                  relation.strength = 3
                  relation.save
              else
                  section.languages << language
                  relation = section.language_sections.where('language_id =' + language.id.to_s).first
                  relation.strength = 3
                  relation.save
               end
            end

          end

        end

      end


    end

    Section.reindex
    logger.info 'parsing finished'
    document.finish_parsing!
  rescue StandardError => e
    logger.info 'Failure'
    document.status = 1
    document.save
    raise e
  end
end


def strong_search(document, language, section)
  Section.search(body: {
      "query":{
          "bool":{
              "must":{
                  "dis_max":{
                      "queries":[
                          {"match":{"content.analyzed":{"query":language.name,"boost":10,"operator":"and","analyzer":"searchkick_search"}}}
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
                          {"match":{"content.analyzed":{"query":language.name,"boost":1,"operator":"and","analyzer":"searchkick_search2","fuzziness":1,"prefix_length":0,"max_expansions":3,"fuzzy_transpositions":true}}}
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
