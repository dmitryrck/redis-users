require "rubygems"
require "bundler"

Bundler.require :default, :test

ENV["RACK_ENV"] = "test"

require "capybara/rspec"
require File.dirname(__FILE__)+"/../app"

Capybara.app = App::Application

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    App::Application
  end
end
