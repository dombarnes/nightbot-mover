class HomeController < ApplicationController  

  get '/welcome' do
    debug_log('Hit /welcome')
    redirect '/' if authenticated?
    erb :'home/welcome'
  end

  get '/index.json' do
    status 200
    json 'OK'
  end

  get '/' do
    debug_log('Hit /')
    redirect '/welcome' unless authenticated?
    response = HTTParty.get(settings.nightbot_oauth_server + "/1/commands", headers: { "Authorization" => "Bearer #{session[:access_token]}", "Cache-Control" => "no-cache", "Content-Type" => "application/json" })
    json_body = JSON.parse(response.body)
    @commands = Command.collection(json_body["commands"])
    set_title("Welcome")
    erb :'home/index'
  end

  get '/export' do 
    erb :'home/export'
  end

  post '/export' do
    response = HTTParty.get(settings.nightbot_oauth_server + "/1/commands", headers: { "Authorization" => "Bearer #{session[:access_token]}", "Cache-Control" => "no-cache", "Content-Type" => "application/json" })
    json_body = JSON.parse(response.body)
    path = Dir.pwd
    filename = SecureRandom.uuid
    full_path = "#{path}/#{settings.tmp_folder}/#{filename}"
    File.open(full_path, 'w') { |file| file.write(response.body)}
    return filename
  end

  get '/export/download/:id' do
    filename = "#{Time.now.strftime("%Y-%m-%d")} Nightbot Export for #{current_user.name}.json"
    local_file = "#{settings.root}/#{settings.tmp_folder}/#{params[:id]}"
    if File.exists?(local_file)      
      begin
        send_file local_file, :filename => filename, :type => 'application/json'
      ensure 
        FileUtils.rm local_file
      end
    else
      debug_log "File #{local_file} not found"
      return 404
    end
  end

  post '/import' do
    unless params[:file] &&
         (tmpfile = params[:file][:tempfile]) &&
         (name = params[:file][:filename])
      @error = "No file selected"
      return erb :'home/import'
    end
    debug_log "Uploading file, original name #{name.inspect}"
    while blk = tmpfile.read(65536)
      # here you would write it to its final location
      @commands_json = JSON.parse(blk)
      @commands = Command.collection(@commands_json["commands"])
      @processed = 0
      @results = []
      @commands.each do |command|
        @body = {
            message: command.message,
            name: command.name,
            userLevel: command.userlevel,
            coolDown: command.cooldown
        }
        response = HTTParty.post(settings.nightbot_oauth_server + "/1/commands", headers: { "Authorization" => "Bearer #{session[:access_token]}", "Cache-Control" => "no-cache", "Content-Type" => "application/json" }, body: @body.to_json)
        if response.code == 200
          debug_log "Command added"
          @processed += 1
        elsif response.code == 400
          @results << { 
            result: response.parsed_response["message"],
            command: command.to_hash
          }
        else
          debug_log "upload failed: " + response.body
        end
      end
    end
    erb :"home/results"
  end

end
