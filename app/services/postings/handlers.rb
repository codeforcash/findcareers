require "nokogiri"
require "down"
#require "postings"

module Postings
  module Handlers
    Error = Class.new(Postings::Error)

    class Handler
      def name
        self.class.name.demodulize
      end
    end

    class WebPageSourceHandler < Handler
      attr_reader :page
      protected :page

      def initialize(page)
        @page = page
      end

      def find(options = nil)
        raise NotImplementedError
      end

      protected

      def parse(doc)
        raise ArgumentError, "cannot parse a #{doc.class}; document must be given as a String" unless doc.is_a?(String)
        Nokogiri::HTML(doc)
      end

      def download(url)
        io = Down.open(url)
        io.read
      rescue Down::Error => e
        raise Error, "download failed for #{url}: #{e}"
      ensure
        io.close if io
      end

      def download_and_parse(url)
        parse(download(url))
      end
    end

    # Keep in alphabetical order, please
    autoload :Angel, "postings/handlers/angel"
    autoload :Greenhouse, "postings/handlers/greenhouse"
    autoload :HireWithGoogle, "postings/handlers/hire_with_google"
    autoload :JazzHR,  "postings/handlers/jazz_hr"
    autoload :Lever,  "postings/handlers/lever"
    autoload :Workable,  "postings/handlers/workable"
  end
end
