namespace :postings do
  desc "Import job postings from WEBSITE"
  task :import => :environment do
    abort "WEBSITE required" unless ENV["WEBSITE"]
    postings = Postings.import(ENV["WEBSITE"])
    print_postings(postings)
  end

  desc "Find job postings on WEBSITE"
  task :find => :environment do
    abort "WEBSITE required" unless ENV["WEBSITE"]
    postings = Postings.find(ENV["WEBSITE"])
    print_postings(postings)
  end

  def print_postings(postings)
    printf "%s %s found\n", postings.size, "posting".pluralize(postings.size)
    postings.each_with_index do |posting, index|
      printf("%-3d: %s\n", index + 1, posting.title)
    end
  end
end
