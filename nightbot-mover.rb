require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/json'
require 'sinatra/asset_pipeline'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require "active_support"
require 'date'
require 'fileutils'
require 'active_support/core_ext'


puts '-- Loading app.rb --'

class NightbotMover < Sinatra::Base
  register Sinatra::Initializers
  register Sinatra::ConfigFile
  register Sinatra::Flash
  register Sinatra::Namespace
  register Sinatra::CrossOrigin

  use Airbrake::Rack::Middleware

  # get ('/errortest') { Airbrake.notify('App crashed!') }
  
  config_file 'config/settings.yml'
  # Dir.mkdir('logs') unless File.exist?('logs')
  Dir.mkdir('tmp') unless File.exist?('tmp')
  require_relative './app/controllers/application_controller.rb'
  Dir.glob('./app/{models,modules,helpers,extensions,controllers}/*.rb').each {  |file| 
    puts file 
    require file 
  }

  configure do
    set :environment, ENV.fetch('RACK_ENV', 'development')
    set :environments, %w{development test production staging} # enable other environments
    
    set :root, File.dirname(__FILE__)
    set :server, :puma
    set :tmp_folder, 'tmp'

    # set :database_file, File.expand_path('../config/database.yml', (__FILE__))

    set :method_override, true
    set :public_folder, proc { File.join(root, '/public') }
    enable :cross_origin
    # enable :sessions #- use Rack::Session::Cookie instead
    # set :session_secret, ENV.fetch('RACK_SECRET', SecureRandom.hex(32))
    
    # set :protect_from_csrf, true
    # set :protection, origin_whitelist: [settings.application_host, settings.oauth_server]
    set :static_cache_control, [:public, :max_age => 60 * 60 * 24 * 365]
    
    # Setup Sprockets
    set :sprockets,          ( Sprockets::Environment.new(root) { |env| env.logger = Logger.new(STDOUT) } )
    set :assets_precompile,  %w(app.js app.css *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2)
    set :assets_path,        %w(assets)
    # set :assets_host,       ENV.fetch("ASSETS_HOST")
    set :assets_prefix,     assets_path
    set :digest_assets,     false
    # set :assets_css_compressor, :sassc
    # set :assets_js_compressor, :uglifier

    sprockets.append_path File.join(root, "assets", "stylesheets")
    sprockets.append_path File.join(root, "assets", "javascript")
    sprockets.append_path File.join(root, "assets", "images")
    sprockets.append_path File.join(root, "assets", "fonts")
    
    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix      = assets_prefix
      config.digest      = digest_assets
      config.public_path = public_folder
      config.debug       = true if development?
      if production?
        config.digest      = true
        config.manifest    = Sprockets::Manifest.new(sprockets, 
          File.join(assets_path, "manifest.json")
        )
      end
    end
  end

  configure :development do
    register Sinatra::Reloader
    set :show_exceptions, :after_handler
    # Bullet.enable = true
    # Bullet.alert = true
    # Bullet.bullet_logger = true
    # Bullet.console = true
    # use Bullet::Rack
  end

  configure :production, :development do
    enable :logging
  end

  configure :development do
    set :dump_errors, false
    set :raise_errors, false
    set :show_exceptions, true # set to true to display backtrace pages
  end


  configure :production do
    set :dump_errors, false
    set :raise_errors, false
    set :show_exceptions, false
  end

  helpers do
    include Sprockets::Helpers
    include ApplicationHelpers
    include UserHelpers
    include DateHelpers
    # Alternative method for telling Sprockets::Helpers which
    # Sprockets environment to use.
    # def assets_environment
    #   settings.sprockets
    # end
  end
  register Sinatra::AssetPipeline
  set :precompiled_environments, %i(staging production)
  
  use Rack::Static, urls: [ '/favicon.ico', '/.well-known', '/stylesheets', '/javascripts', '/images', '/fonts'], root: 'public'
  use Rack::MethodOverride
  use Rack::Session::Cookie, :key => 'rack.session',
                           # :domain => ENV['APPLICATION_HOST'],
                           # :path => '/',
                           :expire_after => 2592000, # 30 days in seconds
                           :secret => ENV['RACK_SECRET']
  # use Rack::Protection::HttpOrigin, origin_whitelist: [settings.application_host, settings.oauth_server]  
  # use Rack::Protection::AuthenticityToken
end
