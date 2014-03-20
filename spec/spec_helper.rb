ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'vcr'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

ML_TEST_API_KEY = "9fakeapikeynumberinhereq"
ML_TEST_TOKEN = "UFHRfakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttoken-fakeaccounttokeniI="
ML_TEST_CREDS = { api_key: ML_TEST_API_KEY, token: ML_TEST_TOKEN }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.filter_run_excluding :vcr_init => true
  config.order = "random"
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
end
