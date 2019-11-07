workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV.fetch('RACK_ENV', 'development')

# before_fork do
#   if defined?(ActiveRecord::Base)
#     ActiveRecord::Base.connection.disconnect!
#   end
# end

# on_worker_boot do
#   env = ENV.fetch('RACK_ENV', 'development')
#   if defined?(ActiveRecord::Base)
#        ActiveRecord::Base.establish_connection(YAML.load_file(File.expand_path('../database.yml', (__FILE__)))[env])
#   end
# end
