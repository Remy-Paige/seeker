require 'open-uri'

class Document < ActiveRecord::Base

  has_many :sections, dependent: :destroy
  belongs_to :country

  has_many :user_tickets

  has_many :collection_documents
  has_many :collections, through: :collection_documents

  after_create :download_and_set_url_local
  before_destroy :delete_local_documents
  before_destroy {collections.clear}


  DOCUMENT_TYPES = ['State Report', 'Committee of Experts Report', 'Committee of Ministers Recommendation']
  DOCUMENT_TYPES_ID = DOCUMENT_TYPES.zip(0...DOCUMENT_TYPES.length).to_h


  DOCUMENT_STATUS = ['Parsing', 'Failed', 'Finished Parsing']
  DOCUMENT_STATUS_ID = DOCUMENT_STATUS.zip(0...DOCUMENT_STATUS.length).to_h

  validates :url, presence: true
  validates :country_id, presence: true
  validates :document_type, presence: true, numericality: true, inclusion: { in: (0...DOCUMENT_TYPES.length).to_a }
  validates :year, presence: true, numericality: true
  validates :cycle, presence: true, numericality: true

  # url_local substitution before document is saved
  # Returns a copy of str with the all occurrences of pattern substituted for the second argument
  def clean_url
    "public/storage/#{self.url.gsub(/https?:\/\//, '')}"
  end

  def url_text
    if self.url.include?('.pdf')
      self.url_local&.gsub(/\.pdf$/i, '.txt') || self.clean_url&.gsub(/\.pdf$/i, '.txt')
    else
      first = self.url_local&.gsub(/\.pdf$/i, '.txt') || self.clean_url&.gsub(/\.pdf$/i, '.txt')
      second = first + '.txt'
      return second
    end


  end

  def finish_parsing!
    self.update_attributes(status: 2)
  end

  private

  # TODO: check what is at the url. for now, assume is pdf
  # TODO: add support for downloading html
  def download_and_set_url_local
    return if Rails.env.test?
    dir = self.clean_url.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(dir)

    begin
      IO.copy_stream(open(self.url), self.clean_url)
    rescue StandardError => e
      raise "There is nothing at the supplied URL"
    end

    self.update_attributes(url_local: self.clean_url)
  end

  def delete_local_documents
    return if Rails.env.test?
    FileUtils.rm(self.url_local)
    FileUtils.rm(self.url_text)
  rescue

  end

  def self.language_parse(id)
    record = self.find(id)
    LanguageParserJob.perform_async(record)
    logger.info 'language parsing'
  end

  def self.resection_document(id)
    record = self.find(id)
    content = nil
    record.sections.group_by(&:section_number).map do |section_number, sections|
      if section_number == "-"
        content = sections.sort_by(&:section_part).map(&:content).join
      end
    end
    SectionDocumentJob.perform_async(record, content)
    logger.info 'resectioning'
  end

  def self.remove_sections(id)
    # destroy sections except full section
    #
    # If foo is an object with a to_proc method,
    # then you can pass it to a method as &foo,
    # which will call foo.to_proc and use that as the method's block.
    record = self.find(id)
    record.sections.group_by(&:section_number).map do |section_number, sections|
      unless section_number == "-"
        sections.map(&:destroy)
      end
    end
  end

  def self.reconstruct_sections(params)
    # create new sections with custom method
    # each section created new - split into section parts in the sections model


    record = self.find(params[:id])

    params[:section_number]&.each_key do |key|
      if params[:language_id].present?
        record.sections.add_section(
            section_number: params[:section_number][key][0],
            section_name: params[:section_name][key][0],
            content: params[:content][key][0],
            languages: params[:language_id][key],
            strengths: params[:strength][key],
            page_number: params[:page_number][key][0]
        )
      else
        record.sections.add_section(
            section_number: params[:section_number][key][0],
            section_name: params[:section_name][key][0],
            content: params[:content][key][0],
            languages: nil,
            strengths: nil,
            page_number: params[:page_number][key][0]
        )
      end

    end
    # TODO: users could overload server with many requests - rate limit
    SectionReindexJob.perform_async
  end

end
