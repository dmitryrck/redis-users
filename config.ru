require "rubygems"
require "bundler"

Bundler.require :default

require "json"
require File.dirname(__FILE__)+"/app"

run App::Application
