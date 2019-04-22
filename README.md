# FindCareers

## Installation

1. `gem install bundler`
1. `cd findcareers && bundle install`

Chrome is used via selenium-webdriver. This depends on [installing the ChromeDriver](https://github.com/SeleniumHQ/selenium/wiki/ChromeDriver).

## Environment Variables

* `CODE_FOR_CASH_API_KEY` - Used by the Code for Cash API client to create jobs

## API Endpoint

### ~companies/scrape_website~

Find a website's careers page, extract job postings, and send to CodeForCash.

```
curl -H 'content-type: application/json' -d'{"url":"http://harbor.com"}' https://findcareers.herokuapp.com/companies/scrape_website
```
On success return an HTTP 202.

On error a non-200 is returned with the following structure:


```json
{ "message": "Description of the problem..." }
``
