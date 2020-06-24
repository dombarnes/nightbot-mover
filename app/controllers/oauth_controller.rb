require 'securerandom'
class OAuthController < ApplicationController  
  include ERB::Util

  set :oauth_scope,   settings.nightbot_oauth_scope
  set :oauth_server,  settings.nightbot_oauth_server
  set :client_id,     settings.nightbot_client_id
  set :client_secret, settings.nightbot_client_secret
    
    
  get "/authorize" do
    # TODO: Session State not persisting between calls for some reason. Maybe puma server related
    if session[:state] == nil
      session[:state] = SecureRandom.hex
      # debug_log "Set Session state as #{session[:state]}"
    end
    session[:return_url] = request.referrer
    session[:nonce] = SecureRandom.hex
    debug_log "Auth - Session: #{session.inspect}"
    redirect client.auth_code.authorize_url(
      redirect_uri: callback_url,
      scope: settings.oauth_scope, 
      response_type: 'code', 
      # response_mode: 'form_post',
      # nonce: session[:nonce], 
      state: session[:state]
    )
  end

  get '/oauth2callback' do
    # debug_log "Trying to log in
    debug_log "Callback - Params: #{params.inspect}"
    # TODO: Figure out why the session is reset when we get redirected back
    if !params["error"].nil?
      debug_log params["error"]
      session.clear
      flash[:notice] = "Unable to authenticate. Please try again. Nightbot Error: " + params["error"]
      redirect '/welcome'
    end
    if params["state"] != session[:state]
      debug_log "Incorrect State, possible fake oauth: params: #{params["state"]}, session: #{session[:state]}"
      debug_log session.inspect
      session.delete(:state)
      redirect '/oauth/authorize'
    end
    session[:id_token] = params["code"]

    debug_log "Callback - Session: #{session.inspect}"

    access_token = client.auth_code.get_token(
      params["code"],
      redirect_uri: callback_url,
      # { grant_type: 'authorization_code' }
    )
    session[:access_token] = access_token.token
    session[:access_token_expires_at] = Time.now + access_token.expires_in
    session[:refresh_token] = access_token.refresh_token
    session[:token_type] = access_token.params["token_type"]
    session[:scope] = access_token.params["scope"]

    # parsed is a handy method on an OAuth2::Response object that will 
    # intelligently try and parse the response.body
    response = access_token.get('/1/me').parsed
    set_current_user(response["user"])
    redirect session[:return_url]
  end

  get '/refresh' do 
    debug_log "Callback - Params: #{params.inspect}"
    # TODO: Figure out why the session is reset when we get redirected back
    if !params["error"].nil?
      debug_log params["error"]
    end
    if params["state"] != session[:state]
      debug_log "Incorrect State, possible fake oauth: params: #{params["state"]}, session: #{session[:state]}"
      debug_log session.inspect
      session.delete(:state)
      redirect '/oauth/authorize'
    end
    put response.body
  end

  post '/logout' do
    redirect '/' unless !session[:current_user].nil?
    if authenticated?
      access_token = OAuth2::AccessToken.new(client, session[:refresh_token], redirect_uri: refresh_url) #client.auth_code.get_token(session[:refresh_token], redirect_uri: callback_url, grant_type: 'refresh_token')
      response = access_token.post('/oauth2/token/revoke', :params => { 'token' => session[:refresh_token]})
      puts response
    end
    session.clear
    # Send user to auth server for logout and auth cookie clear
    redirect '/'
  end

  get '/oauth2callback-signout' do        
    # redirect callback_url
    session.clear
    redirect '/'
  end

  def refresh_token
    debug_log "Refreshing access token"
    access_token = client.auth_code.get_token(
      session[:refresh_token], 
      grant_type: 'authorization_code', 
      refresh_token: session[:refresh_token],
      redirect_uri: refresh_url
    )
    session[:access_token] = access_token.access_token
    session[:refresh_token] = access_token.refresh_token
    session[:access_token_expires] = access_token.expires_at
  end

private
  def callback_url
    settings.application_host + '/oauth/oauth2callback'
  end

  def refresh_url
    settings.application_host + '/oauth/refresh'
  end

  def client
    client ||= OAuth2::Client.new(settings.client_id, settings.client_secret, 
        {
          :site => settings.oauth_server,
          :authorize_url => "/oauth2/authorize", 
          :token_url => "/oauth2/token",
          :logger => Logger.new('oauth.log', 'weekly')
        }
      )
  end

  def nonce
    # Array.new( 5 ) { rand(256) }.pack('C*').unpack('H*').first
    SecureRandom.hex
  end

end
  
