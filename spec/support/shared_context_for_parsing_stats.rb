RSpec.shared_context "parsing stats" do
  before do
    ParsingStats::ParseAttempt.success("foo.com", "http://foo.com", :website, "a")
    ParsingStats::ParseAttempt.success("foo.com", "http://foo.com", :website, "a")
    ParsingStats::ParseAttempt.success("foo.com", "http://foo.com", :website, "a")
    ParsingStats::ParseAttempt.failure("foo.com", "http://foo.com", :website, "error x", "a")

    ParsingStats::ParseAttempt.success("bar.com", "http://bar.com", :website, "b")
    ParsingStats::ParseAttempt.failure("bar.com", "http://jobs.bar.com", :careers, "error y", "b")

    ParsingStats::ParseAttempt.failure("bazzz.com", "http://jobs.bazz.com", :careers, "error z")
  end
end
