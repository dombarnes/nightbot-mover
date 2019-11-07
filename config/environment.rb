puts "-- Loading config/environment.rb --"
env = ENV.fetch('RACK_ENV', 'development')
require 'dotenv'
Dotenv.load(".env.#{env}.local", ".env")
require 'bundler/setup'
Bundler.require(:default, env)

puts "Environment: #{env}"
require './nightbot-mover'
