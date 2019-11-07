require_relative './config/environment'
require 'dotenv/tasks'
require 'sinatra/asset_pipeline/task'
require 'bundler/audit/task'
require './nightbot-mover'

Bundler::Audit::Task.new
Sinatra::AssetPipeline::Task.define! NightbotMover

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

Dir['./lib/tasks/*.rake'].each { |f| load f }

task console: :environment do
  puts "Console Environment: #{ENV.fetch('RACK_ENV')}"
  Pry.config.add_hook(:before_session, :enable_sql_logger) do
  end
  Pry.start
end

task environment: :dotenv do
  Dotenv.load(".env.#{ENV.fetch('RACK_ENV')}")
  require File.expand_path('config/environment', File.dirname(__FILE__))
end

namespace :db do
  task load_config: :environment do
    require './config/environment'
    require './nightbot-mover'
  end
end

task default: ['spec']
