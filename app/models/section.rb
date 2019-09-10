class Section < ActiveRecord::Base
  searchkick callbacks: :async, highlight: [:content, :section_number, :section_name, :country], word_start: [:section_number, :article_paragraph],  merge_mappings: true

  belongs_to :document

  has_many :language_sections
  has_many :languages, through: :language_sections


  before_destroy {languages.clear}
  default_scope { order('section_number ASC') }

  validates :section_number, presence: true
  validates :section_name, presence: true
  validates :content, presence: true
  # the page_number can be blank, adding the validation here cause the program to get rid of the full content section

  # elasticsearch string length limit is 32766, take caution
  STRING_LEN_LIMIT = 30_000

  # dont forget the callbacks
  def search_data
    {
      #   the url is for the language parsing not the main search function
      url: document.url,
      content: content,
      section_number: section_number,
      section_name: section_name,
      country: document.country&.name,
      year: document.year,
      cycle: document.cycle,
      report_type: document.document_type,
      article_paragraph: article_paragraph,
      strong_language: language_sections.map { |relation|
        if relation.strength == 1 or relation.strength == 0
          Language.all[relation.language_id-1].name
        end
      },
      medium_language: language_sections.map { |relation|
        if relation.strength != 3
          Language.all[relation.language_id-1].name
        end
      },
      weak_language: language_sections.map { |relation|
          Language.all[relation.language_id-1].name
      },
      full_content: full_content?
    }
  end

  def self.add_section(chapter:, section_number:, section_name:, article_paragraph: ,content:, languages:, strengths:, page_number:)
    section_uid = chapter.to_s + '.' + section_number + '.' + article_paragraph
    ((content.length / STRING_LEN_LIMIT) + 1).times do |section_part|
      section_start = section_part * STRING_LEN_LIMIT
      section_end = (section_part + 1) * STRING_LEN_LIMIT
      part = self.create(section_uid: section_uid, chapter: chapter,section_number: section_number, section_name: section_name, article_paragraph: article_paragraph, content: content[section_start...section_end], section_part: section_part, page_number: page_number)
      relation_array = languages&.zip(strengths)
      relation_array&.each do |element|
        language = Language.find(element[0])
        part.languages << language
        relation = part.language_sections.where('language_id =' + element[0]).first
        relation.strength = element[1]
        relation.save
      end
    end
  end


  def full_content?
    self.section_number == '-' && self.section_name == 'Full Content'
  end
end
