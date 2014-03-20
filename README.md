# Missinglink

missinglink is a gem for interfacing with the [SurveyMonkey API](https://developer.surveymonkey.com/Home).

## How to install

    gem install ~/missinglink/missinglink-0.1.0.gem
    bundle exec rake missinglink:install:migrations
    bundle exec rake db:migrate

## How to use

    Missinglink::Connection.credential_hash = { api_key: API_KEY, token: TOKEN }
    Missinglink.poll_surveys
    Missinglink::Survey.each do |survey|
      Missinglink.fetch_respondents(survey)
    end

Other methods:

* `survey.load_survey_details` to pull down question structure for a
  specific structure, if it has not been updated yet

* `survey.load_respondents` to get the base respondent detail for a
  survey

* `survey.load_response_details(respondents)` to pull down all of the
  answers given for any set of respondents to a survey

## Coming Soon

  Survey responses should have more easily accessible answers, so
  that'll be next.

## Questions?

Contact Trey at <trey@mustwin.com> or find him on [github](https://www.github.com/umtrey).

### License

This project rocks and uses MIT-LICENSE.
