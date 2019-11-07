env = ENV.fetch('RACK_ENV', 'development')
require 'bundler'
require_relative './config/environment'
require 'rack/protection'

Bundler.require(:default, env)

map '/' do
  run HomeController
end

map '/oauth/' do 
  run OAuthController
end

run NightbotMover
