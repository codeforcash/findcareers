namespace :company_website do
  desc "Find the careers page for the website given by WEBSITE"
  task :find_careers_page => :environment do
    abort "WEBSITE required" unless ENV["WEBSITE"]

    page = CompanyWebsite.find_careers_page(ENV["WEBSITE"])
    puts page ? page : "Careers page not found"
  end

  desc "Extract jobs from the careers page given by PAGE"
  task :extract_job_postings => :environment do
    abort "PAGE required" unless ENV["PAGE"]

    postings = CompanyWebsite.extract_job_postings(ENV["PAGE"])
    puts "#{postings.size} posting(s) imported"
    postings.each_with_index { |posting, index| sprintf("%-3d: %s\n", index + 1, posting.title) }
  end
end
