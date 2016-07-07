class Section < ActiveRecord::Base
  searchkick callbacks: :async

  belongs_to :document
  belongs_to :language

  def search_data
    {
      content: content,
      section_name: section_name,
      country: document.country&.name,
      year: document.year,
      cycle: document.cycle,
      language: language&.name
    }
  end
end
