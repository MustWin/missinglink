# Missinglink

missinglink is a gem for interfacing with the [SurveyMonkey API](https://developer.surveymonkey.com/Home).

## How to install

    gem install ~/missinglink/missinglink-0.1.0.gem
    bundle exec rake missinglink:install:migrations
    bundle exec rake db:migrate

## How to use

    Missinglink.poll_surveys({ api_key: API_KEY, token: TOKEN })
    Missinglink::Survey.each do |s|
      Missinglink.fetch_respondents(s, { api_key: API_KEY, token: TOKEN })
    end

## Coming Soon

Yeah, credentials shouldn't need to be passed in a ton, so that'll
become a module eventually. But not yet.

## Questions?

Contact Trey at <trey@mustwin.com> or find him on [github](https://www.github.com/umtrey).

### License

This project rocks and uses MIT-LICENSE.
