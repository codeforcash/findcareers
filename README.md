# FindCareers

## Installation

1. `gem install bundler`
1. `cd findcareers && bundle install`

You will encounter this error if you don't have PostgreSQL installed. 
```
ERROR:  Error installing pg:
ERROR: Failed to build gem native extension.
```
* Ubuntu: `sudo apt-get install postgresql libpq-dev`
* Mac: `brew install postgresql`

Chrome is used via selenium-webdriver. This depends on [installing the ChromeDriver](https://github.com/SeleniumHQ/selenium/wiki/ChromeDriver).

## Environment Variables

* `BROWSERLESS_API_KEY` - Must be set to scrape websites
* `CODE_FOR_CASH_API_KEY` - Used by the Code for Cash API client to create jobs
* `FIND_CAREERS_USERNAME`/`FIND_CAREERS_PASSWORD` - Username/password used by HTTP auth to access parsing stats dashboard.
  **If these are not set dashboard access will be unavailable**

## API Endpoint

### `companies/scrape_website`

Find a website's careers page, extract job postings, and send to CodeForCash.

```
curl -H 'content-type: application/json' -d'{"url":"http://harbor.com"}' https://findcareers.herokuapp.com/companies/scrape_website
```
On success return an HTTP 202.

On error a non-200 is returned with the following structure:


```json
{ "message": "Description of the problem..." }
```

## SQL For Retrieving Failures

### Careers Page Not Supported

```sql
select w.domain,
       p.url,
       case when p.url_type = 0
            then 'careers'
            else 'website'
       end
       from parsing_stats_websites w
       join parsing_stats_parse_attempts p on p.website_id = w.id
where p.error = 'Postings::CareersPageNotSupported'
order by w.domain
```

### Careers Page Not Found

```sql
select w.domain,
       p.url,
       case when p.url_type = 0
            then 'careers'
            else 'website'
       end
       from parsing_stats_websites w
       join parsing_stats_parse_attempts p on p.website_id = w.id
where p.error = 'Postings::CareersPageNotFound'
order by w.domain
```
