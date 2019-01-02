class Section < ActiveRecord::Base
  searchkick callbacks: :async, highlight: [:content, :section_number, :section_name, :country], word_start: [:section_number],  merge_mappings: true

  belongs_to :document
  belongs_to :language

  default_scope { order('section_number ASC') }

  validates :section_number, presence: true
  validates :section_name, presence: true
  validates :content, presence: true
  # the page_number can be blank, adding the validation here cause the program to get rid of the full content section
  # TODO: fix full content so that its given a page number and we can add the validation check back

  # elasticsearch string length limit is 32766, take caution
  STRING_LEN_LIMIT = 30_000

  def search_data
    {
      content: content,
      section_number: section_number,
      section_name: section_name,
      country: document.country&.name,
      year: document.year,
      cycle: document.cycle,
      language: language&.name,
      report_type: document.document_type,
      full_content: full_content?
    }
  end

  def self.add_section(section_number:, section_name:, content:, language_id: nil, page_number: nil)
    ((content.length / STRING_LEN_LIMIT) + 1).times do |section_part|
      section_start = section_part * STRING_LEN_LIMIT
      section_end = (section_part + 1) * STRING_LEN_LIMIT
      self.create(section_number: section_number, section_name: section_name, content: content[section_start...section_end], section_part: section_part, language_id: language_id, page_number: page_number)
    end
  end

  def full_content?
    self.section_number == '-' && self.section_name == 'Full Content'
  end
end
