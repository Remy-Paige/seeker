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


  def finish_parsing!
    self.update_attributes(status: 2)
  end

  def construct_sections_from_parts
    # if you change this, also change the one in collections. I'm not sure where to refactor the common code to
    self.sections.group_by(&:section_uid).map do |section_uid, sections|
      document_id = sections.first.document_id
      chapter = sections.first.chapter
      section_number = sections.first.section_number
      section_name = sections.first.section_name
      article_paragraph = sections.first.article_paragraph
      page_number = sections.first.page_number
      language_sections = sections.first.language_sections
      content = sections.sort_by(&:section_part).map(&:content).join
      sec = Section.new(section_uid: section_uid, document_id: document_id, chapter: chapter, section_number: section_number, section_name: section_name,article_paragraph: article_paragraph ,content: content, page_number: page_number)
      language_sections&.each do |relation|
        sec.language_sections << relation
      end
      # this line avoids an undefined method for [] array error
      sec
    end.sort_by(&:section_uid)

  end

  def language_parse
    LanguageParserJob.perform_async(self)
  end

  def test_pdf
    TestJob.perform_async(self)
  end

  def resection_document
    SectionDocumentJob.perform_async(self)
  end

  def remove_sections
    # destroy sections except full section
    #
    # If foo is an object with a to_proc method,
    # then you can pass it to a method as &foo,
    # which will call foo.to_proc and use that as the method's block.
    # TODO: change to uid?
    self.sections.group_by(&:section_number).map do |section_number, sections|
      puts section_number
      unless section_number == "-"
        puts 'destroy'
        sections.map(&:destroy)
      end
    end
  end

  def reconstruct_sections(params)
    # create new sections with custom method
    # each section created new - split into section parts in the sections model

    # TODO: validate input

    # section uid is created by add section
    params[:section_uid]&.each_key do |key|
      if params[:language_id].present?
        self.sections.add_section(
            chapter: params[:chapter][key][0],
            section_number: params[:section_number][key][0],
            section_name: params[:section_name][key][0],
            article_paragraph: params[:article_paragraph][key][0],
            content: params[:content][key][0],
            languages: params[:language_id][key],
            strengths: params[:strength][key],
            page_number: params[:page_number][key][0]
        )
      else
        self.sections.add_section(
            chapter: params[:chapter][key][0],
            section_number: params[:section_number][key][0],
            section_name: params[:section_name][key][0],
            article_paragraph: params[:article_paragraph][key][0],
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

  def clean_url

    if self.url.include?('.pdf')
      "public/storage/#{self.url.gsub(/https?:\/\//, '')}"
    else
      "public/storage/#{self.url.gsub(/https?:\/\//, '')}" + '.pdf'
    end

  end

  def url_text
    self.url_local&.gsub(/\.pdf$/i, '.txt') || self.clean_url&.gsub(/\.pdf$/i, '.txt')
  end


  private

  # TODO: check what is at the url. for now, assume is pdf - see also url/file path handling
  def download_and_set_url_local
    return if Rails.env.test?
    dir = self.clean_url.split('/')[0...-1].join('/')
    FileUtils.mkdir_p(dir)

    begin
      uri = URI(self.url)
      res = Net::HTTP.get_response(uri)

      text = 'Only authorised users may access this document.'

      if res.code[0] == '2'
        if res.body.include?(text)
          raise 'unauthorised'
        else
          IO.copy_stream(open(self.url), 'file')
          fm = FileMagic.new
          filetype = fm.file('file')

          if filetype.include?('PDF')
            FileUtils.rm('file')
            File.open(self.clean_url, "wb") do |file|
              file.write open(url).read
            end
          else
            raise 'not PDF'
          end
        end
      else
        raise 'http response failure'
      end
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



end
