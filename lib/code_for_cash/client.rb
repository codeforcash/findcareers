# frozen_string_literal: true

require "json"
require "net/http"

module CodeForCash
  Error = Class.new(StandardError)

  # Server responses that indicate failure
  RequestError = Class.new(Error)

  # Connection issue
  ConnectionError = Class.new(Error)

  ##
  # Code for Cash API client
  #

  class Client
    DEFAULT_ENDPOINT = "https://i.codefor.cash/api/metum"

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
      endpoint.path = "create"

      data = data.merge(:key => @apikey)
      data[:employment_type] = data.delete(:remote) == true ? "remote" : "onsite"
      data[:time_commitment] = data.delete(:part_time) == true ? "parttime" : "fulltime"

      begin
        response = Net::HTTP.post(endpoint, JSON.dump(data), "Content-Type" => "application/json")
      rescue => e
        raise ConnectionError, "failed to connect to #{endpoint}: #{e}"
      end

      request_error("#{response.body} (HTTP #{response.status})") if response.status != "200"

      body = parse_json(response.body)
      request_error("#{body["message"]} (code #{body["code"]})") if body["status"] == "error"

      body
    end

    private

    def request_error(message)
      raise RequestError, "request failed with response: %s", message
    end

    def parse_json(s)
      JSON.parse(s)
    rescue JSON::ParserError => e
      raise Error, "failed to parse response: #{e}"
    end
  end
end
