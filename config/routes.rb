Rails.application.routes.draw do
  post "companies/scrape_website"

  namespace :dashboard do
    get "/", :action => "index"
    get "website/:id", :action => "website", :as => "website"
    get "provider/:id", :action => "provider", :as => "provider"
    get "parse_errors", :action => "parse_errors", :as => "parse_errors"
  end

  root "dashboard#index"
end
