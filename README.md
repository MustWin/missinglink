# Missinglink

missinglink is a gem for interfacing with the [SurveyMonkey API](https://developer.surveymonkey.com/Home).

[![Build
Status](https://travis-ci.org/MustWin/missinglink.svg?branch=master)](https://travis-ci.org/MustWin/missinglink)

## How to install

    gem install missinglink
    bundle exec rake missinglink:install:migrations
    bundle exec rake db:migrate

## How to use

    Missinglink::Connection.credential_hash = { api_key: API_KEY, token: TOKEN }
    Missinglink.poll_surveys
    Missinglink::Survey.all.each do |survey|
      Missinglink.fetch_respondents(survey)
    end

Other methods:

* `survey.load_survey_details` to pull down question structure for a
  specific structure, if it has not been updated yet

* `survey.load_respondents` to get the base respondent detail for a
  survey

* `survey.load_response_details(respondents)` to pull down all of the
  answers given for any set of respondents to a survey

* `survey_question.possible_responses` to list all response answers for
  a given question in the form of a hash, with the key as the text of
  the answer and the value as a representative survey response answer
  object

* `survey_question.similar_response_answers(response_answer)` to find
  all answers that are similar to a given answer, based on the qustion
  type. for instance, a single text field type question will find all
  answers that have the same text, but a matrix will find those that
  have the same row and column value.

## Questions?

Contact Trey at <trey@mustwin.com> or find him on [github](https://www.github.com/umtrey).

### License

This project rocks and uses MIT-LICENSE.
