# frozen_string_literal: true

require "json"
require "net/http"

module CodeForCash
  ##
  # Code for Cash API client
  #

  class Client
    DEFAULT_ENDPOINT = "https://i.codefor.cash/api/metum"

    Error = Class.new(StandardError)

    # Server responses that indicate failure or a failure processing its response
    RequestError = Class.new(Error)

    # Connection issue
    ConnectionError = Class.new(Error)

    ##
    # === Arguments
    #
    # [apikey (String)]
    # [options (Hash)] - optional arguments
    #
    # === Options
    #
    # [:endpoint (String)] API's base URL, defaults to DEFAULT_ENDPOINT
    #
    # === Errors
    #
    # ArgumentError if API key is not provided
    #

    def initialize(apikey, options = nil)
      raise ArgumentError, "API key required" if apikey.to_s.strip.empty?
      @apikey = apikey

      options ||= {}
      @endpoint = URI(options[:endpoint] || DEFAULT_ENDPOINT)
    end

    ##
    # Create a job posting
    #
    #    client.create_posting(:title => "The Job's Title",
    #                         :description => "Job's description...",
    #                         :website => "https://example.com/jobs/13123",
    #                         :remote => true,
    #                         :part_time => false)
    #
    # +:remote+ and +:part_time+ default to +false+.
    #
    # === Errors
    #
    # ConnectionError, ResponseError, Error
    #
    # Error is raised if JSON parsing fails.
    #

    def create_posting(data)
      endpoint = @endpoint.dup
      endpoint.path += "/create"

      data = data.merge(:key => @apikey)
      data[:employment_type] = data.delete(:remote) == true ? "remote" : "onsite"
      data[:time_commitment] = data.delete(:part_time) == true ? "parttime" : "fulltime"

      begin
        response = Net::HTTP.post(endpoint, JSON.dump(data), "Content-Type" => "application/json")
      rescue => e
        raise ConnectionError, "failed to connect to #{endpoint}: #{e}"
      end

      request_failed("#{response.body} (HTTP #{response.code})") if response.code != "200"

      begin
        body = JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise RequestError, "failed to parse response: #{e}"
      end

      request_failed("#{body["message"]} (code #{body["code"]})") if body["status"] != "success"

      nil
    end

    private

    def request_failed(message)
      raise RequestError, "request failed with response: #{message}"
    end
  end
end
