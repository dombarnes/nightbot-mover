puts "-- Loading config/environment.rb --"
env = ENV.fetch('RACK_ENV', 'development')
require 'dotenv'
Dotenv.load(".env.#{env}.local", ".env")
require 'bundler/setup'
Bundler.require(:default, env)

puts "Environment: #{env}"
Airbrake.configure do |c|
  c.project_id = ENV['AIRBRAKE_PROJECT'].to_i
  c.project_key = ENV['AIRBRAKE_KEY']

  # Display debug output.
  c.logger.level = Logger::DEBUG
  c.performance_stats = true
end
require './nightbot-mover'
