class CareersPageParser
  Posting = Struct.new(:title, :description, :url, :part_time, :remote) do
    def part_time?
      @part_time = false if @part_time.nil?
      @part_time
    end

    def remote?
      @remote = false if @remote.nil?
      @remote
    end
  end

  def parse(url)
    begin
      page_source = Down.open(url).read
      get_job_counts_from_page_source(page_source, url)
    rescue Down::ClientError => e
      puts "Webpage #{url} not available: #{e.inspect}"
    end
  end

  def get_job_counts_from_page_source(page_source, url)
    if page_source.include?('boards.greenhouse.io') || page_source.include?('grnh.se') || page_source.include?('greenhouse-job-board')
      puts "Greenhouse"
      job_counts = extract_greenhouse(page_source, url)
    elsif page_source.include?('hire.withgoogle.com')
      puts "HireWithGoogle"
      job_counts = extract_hirewithgoogle_url(page_source)
    elsif page_source.include?('app.jazz.co') || page_source.include?('applytojob.com')
      puts "JazzHR"
      job_counts = extract_jazzhr(page_source)
    elsif page_source.include?('workable')
      puts "Workable"
      job_counts = extract_workable(page_source)
    elsif page_source.include?('bamboohr')
      puts "BambooHR"
      job_counts = extract_bamboo(page_source)
    elsif page_source.include?('jobs.lever.co')
      puts "Lever"
      job_counts = extract_lever(page_source)
    elsif page_source.include?('angellist_embed')
      puts "Angel.co"
      job_counts = extract_angelco(page_source)
    elsif page_source.include?('/jobs/feed/')
      puts "WordPress JobBoard"
      job_counts = extract_jobboard_wordpress(page_source)
    elsif page_source.include?('jobplanet')
      puts "JobPlanet"
      job_counts = extract_jobplanet(page_source)
    elsif page_source.include?('nextwavehire')
      puts "NextWaveHire"
      job_counts = extract_nextwavehire(page_source)
    else
      puts "No known job board detected.."
    end

    puts job_counts
  end

  def extract_greenhouse_js(url)
    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.get(url)
    ghjs = driver.execute_script('return ghjb_jobs')
    ghjs.count
  end


  def extract_greenhouse(page_source, url)
    gh_token = extract_greenhouse_token(page_source)
    unless gh_token.nil?
      puts "Found greenhouse token: #{gh_token}"
      job_counts = JSON.parse(Down.open("https://boards-api.greenhouse.io/v1/boards/#{gh_token}/jobs").read)['jobs'].count
    else
      job_counts = extract_greenhouse_js(url)
    end
  end


  ## CURRENTLY BROKEN / NOT IMPLEMENTED
  def extract_nextwavehire(page_source)
    nok = Nokogiri(page_source)
    api_key = nok.css('#nwh-html').first.attributes['data-api-key'].value
    s3_url = 'https://assets.nextwavehire.com/' + api_key + '/templates/rendered/production/main.txt'
    extract_greenhouse(Down.open(s3_url).read)
  end

  def extract_jobplanet(page_source)
    job_list_page = Nokogiri::HTML(page_source).css('a').map{|x|x.attr('href')}.select{|x|x.match(/^.+\/job-list/)}.first
    Nokogiri::HTML(Down.open(job_list_page).read).css('h3 > a').count
  end

  def extract_jobboard_wordpress(page_source)
    job_feed_url = Nokogiri(page_source).css('link').map{|x|x.attributes['href'].value}.select{|x|x.include?('/jobs/feed')}.first
    Nokogiri(Down.open(job_feed_url).read).css('channel item').count
  end

  def extract_angelco(page_source)
    startup_slug = Nokogiri(page_source).css('script#angellist_embed').first.attributes['data-startup'].value
    Nokogiri::HTML(Down.open("https://angel.co/job_profiles/embed?startup=#{startup_slug}").read).css('a').count
  end


  def extract_lever(page_source)
    begin
      lever_name = Nokogiri(page_source).css('meta[property="og:url"]').attr('content').value.split('jobs.lever.co/').last
    rescue
      lever_name = page_source.match(/jobs.lever.co\/(.+)("|')/)[1]
    end

    skip = 0
    postings = []

    loop do
      results = LeverPostings.postings(lever_name, :skip => skip, :limit => 10)
      break if results.empty?

      results.each do |posting|
        postings << Posting.new(:title => posting.text,
                                :description => posting.description,
                                :url => posting.hostedUrl)
      end

      skip += results.size
    end

    postings
  end

  def extract_bamboo(page_source)
    nok = Nokogiri::HTML(page_source)
    bamboo_script_url = nok.css('script').map{|x|x.attr('src')}.reject(&:nil?).select{|x|x.include?('bamboo')}.first
    bamboo_page_url = bamboo_script_url.split('/js').first + '/jobs/embed2.php'
    Nokogiri::HTML(Down.open(bamboo_page_url).read).css("ul li a").count
  end

  def extract_workable(page_source)
    Nokogiri::HTML(page_source).css("ul.jobs li.job").count
  end



  def extract_jazzhr(page_source)

    begin
      # They embed a Jazz HR widget
      jazz_widget_url = Nokogiri::HTML(page_source).css('script').map{|x|x.attr('src')}.reject(&:nil?).select{|x|x.include?('app.jazz.co/widgets')}.first
      Nokogiri::HTML(Down.open(jazz_widget_url).read).css('.resumator-job-title').count
    rescue
      # They use Jazz HR but embed links directly on page
      Nokogiri::HTML(page_source).css('a').map{|x|x.attr('href')}.select{|x|x.match(/applytojob.com\/apply\/.+/)}.count
    end

  end

  def extract_hirewithgoogle_url(page_source)
    nok = Nokogiri::HTML(page_source)
    script_tags = nok.css('script').map{ |x|
      x.attr('src')
    }.reject(&:nil?).select{ |x|
      x.include?('hire.withgoogle.com')
    }
    if script_tags.count >= 1
      begin
        hirewithgoogle_coname = script_tags.first.match(/https:\/\/hire.withgoogle.com\/s\/embed\/hire-jobs.js\?company=(.+)/)[1]
        hirewithgoogle_url = "https://hire.withgoogle.com/public/jobs/#{hirewithgoogle_coname}"
        content = Down.open(hirewithgoogle_url).read
      rescue
        content = page_source
      end
      job_counts = Nokogiri::HTML(content).css('li a').count
    else
      hirewithgoogle_coname = nok.css('a').map{|x|x.attr('href')}.reject(&:nil?).select{|x|x.include?('hire.withgoogle.com')}.first.match(/hire.withgoogle.com\/public\/jobs\/([^\/]+)\/.+/)[1]
      job_counts = nok.css('h5.career-job').count
    end

  end

  def extract_greenhouse_token(page_source)
    nok = Nokogiri::HTML(page_source)

    greenhouse_links = nok.css('a').map{|x|x.attr('href')}.select{|x|x.include?('greenhouse.io')}
    greenhouse_iframes = nok.css('iframe').map{|x|x.attributes['src'].value}.select{|x|x.include?('grnh.se')}

    if greenhouse_links.count > 0
      token = greenhouse_links.first.match(/greenhouse.io\/([^\/]+)\//)[1]
    elsif greenhouse_iframes.count > 0
      parsed = URI.parse(FinalRedirectUrl.final_redirect_url(greenhouse_iframes.first))
      parsed.fragment = parsed.query = nil # get rid of the query string parameters
      token = parsed.to_s.split('boards.greenhouse.io/').last
    else
      begin
        token = nok.css('meta[property="og:url"]').attr('content').value.split('boards.greenhouse.io/').last
        if token.match(/https?:/)
          token = get_greenhouse_from_script_tag(nok)
        end
      rescue
        token = get_greenhouse_from_script_tag(nok)
      end
    end
    token
  end

  def get_greenhouse_from_script_tag(nok)
    greenhouse_js_urls = nok.css('script').map { |x|
      x.attr('src')
    }.reject(&:nil?).select{ |x|
      x.include?('boards.greenhouse.io/embed/job_board/js')
    }
    if greenhouse_js_urls.count > 0
      greenhouse_js_urls.first.split('job_board/js?for=').last
    else
      nil
    end
  end
end
