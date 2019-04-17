require "rack/utils"

class ApplicationController < ActionController::API
  rescue_from StandardError do |e|
    error 500, e.message
  end

  protected

  def error(status = 500, message = Rack::Utils::HTTP_STATUS_CODES[status])
    logger.error(message)
    render :status => status, :json => { :message => message }
  end
end
