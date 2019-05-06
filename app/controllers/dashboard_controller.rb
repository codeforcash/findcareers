class DashboardController < ApplicationController
  before_action :authenticate

  def index
    @stats = ParsingStats::Website.calculate_statistics
  end

  def provider
    @provider = ParsingStats::Provider.find(params[:id])
    @stats = @provider.calculate_statistics
  end

  def website
    @website = ParsingStats::Website.includes(:provider).find(params[:id])
    @attempts = @website.parse_attempts.page(params[:page]).per(params[:per_page])
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      ENV["FIND_CAREERS_USERNAME"].present? && ENV["FIND_CAREERS_PASSWORD"].present? &&
        username == ENV["FIND_CAREERS_USERNAME"] && password == ENV["FIND_CAREERS_PASSWORD"]
    end
  end
end
