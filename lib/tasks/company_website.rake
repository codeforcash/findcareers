namespace :company_website do
  desc "Find the careers page for the website given by WEBSITE"
  task :find_careers_page => :environment do
    CompanyWebsite.find_careers_page(ENV["WEBSITE"])
  end

  desc "Extract jobs from the careers page given by PAGE"
  task :extract_job_postings => :environment do
    CompanyWebsite.extract_job_postings(ENV["PAGE"])
  end
end
