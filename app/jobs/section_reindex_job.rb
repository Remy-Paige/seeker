class SectionReindexJob 
  include SuckerPunch::Job
  
  def perform
    Section.reindex
  end
end
