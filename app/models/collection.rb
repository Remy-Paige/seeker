class Collection < ActiveRecord::Base

  has_many :collection_documents
  has_many :documents, through: :collection_documents

  has_many :queries, dependent: :destroy

  belongs_to :user

  before_destroy {documents.clear}

  validates :name, presence: true



  def self.save_section(params, user)

    collection = user.collections.where("name = '" + params[:collection].to_s + "'").first

    if collection == nil
      # caught by controller and creates a flash message
      return 'nil collection'
    end

    document = Document.find(params[:document_id])
    section_list = collection.collection_documents.where("section_uid = '" + params[:section_uid].to_s + "'")

    #if the section is not already in the collection
    if section_list.length == 0
      # add a new relation
      collection.documents << document
      # this is why the section number validation doesnt work

      # edit the new relation to include the section number
      relation = collection.collection_documents.where("section_uid IS ?", nil).first
      relation.section_uid = params[:section_uid]
      relation.save
      return 'first submit'
    else
      return 'second submit'
    end
  end

  def remove_section(params)
    relation = self.collection_documents.where("document_id =" + params[:document_id] + "AND section_uid = '" + params[:section_uid] + "'").first
    relation&.destroy
  end

  # maybe these should go in a service, or in the 2 separate controllers
  def export_collection
    # cant delete the file - so create new at beginning every time

    File.open('export.txt', 'w') {
        |file|
    }

    # cant each or map over a active record association
    # section name has a \n at the end of it
    for index in 0..self.collection_documents.length - 1
      relation = self.collection_documents[index]
      document = Document.find(relation.document_id)
      country = Country.find(document.country_id)
      section = document.sections.where("section_uid = '" + relation.section_uid.to_s + "'").first
      File.open('export.txt', 'a') {
          |file| file.write('URL: ' + document.url.to_s + "\n" + 'type: ' + Document::DOCUMENT_TYPES[document.document_type].to_s + "\n" + 'year: ' + document.year.to_s + "\n" + 'cycle: ' + document.cycle.to_s + "\n" + 'country: ' + country.name.to_s + "\n" + 'section name: ' + section.section_name.to_s + 'section number: ' + section.section_number.to_s + "\n" + "\n")
      }
    end

  end

  def self.export_section(params)
    document = Document.find(params[:document_id])
    section = document.sections.where("section_uid = '" + params[:section_uid].to_s + "'").first
    country = Country.find(document.country_id)

    File.open('export.txt', 'w') {
        |file| file.write('URL: ' + document.url.to_s + "\n" + 'type: ' + Document::DOCUMENT_TYPES[document.document_type].to_s + "\n" + 'year: ' + document.year.to_s + "\n" + 'cycle: ' + document.cycle.to_s + "\n" + 'country: ' + country.name.to_s + "\n" + 'section name: ' + section.section_name.to_s + 'section number: ' + section.section_number.to_s + "\n" + "\n")
    }
  end

  def construct_sections_from_parts
    section_list = []

    # patch together section parts
    self.collection_documents.each do |relation|
      document = Document.find(relation.document_id)
      document.sections.group_by(&:section_uid).map do |section_uid, sections|
        document_id = sections.first.document_id
        chapter = sections.first.chapter
        section_number = sections.first.section_number
        section_name = sections.first.section_name
        article_paragraph = sections.first.article_paragraph
        page_number = sections.first.page_number
        language_sections = sections.first.language_sections
        id = sections.first.id
        # reconstruct content
        content = sections.sort_by(&:section_part).map(&:content).join
        sec = Section.new(id: id, section_uid: section_uid, document_id: document_id, chapter: chapter, section_number: section_number, section_name: section_name,article_paragraph: article_paragraph ,content: content, page_number: page_number)
        # reconstruct language relations
        if relation.section_uid == section_uid
          language_sections&.each do |relation2|
            sec.language_sections << relation2
          end
          section_list.push(sec)
        end
      end

    end
    return section_list
  end

  def self.check_exists(collection_params, user)
    collections = user.collections
    collections.each do |collect|
      if collection_params[:name] == collect.name
        return true
      end
    end
    return false
  end
end
