class DashboardController < ApplicationController
  before_action :authenticate

  def index
    @stats = ParsingStats::Website.calculate_statistics
  end

  def parse_errors
    @q = ParsingStats::ParseAttempt.includes(:website => %w[provider]).where.not(:error => nil).page(params[:page]).ransack(params[:q])
    @attempts = @q.result
  end

  def provider
    # Bit of a hack to find stats for sites with no provider
    @provider = params[:id] != "-1" ? ParsingStats::Provider.find(params[:id]) :
    	          	              ParsingStats::Provider.new(:name => "Unknown")
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
