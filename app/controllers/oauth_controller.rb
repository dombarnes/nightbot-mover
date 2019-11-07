require 'securerandom'
class OAuthController < ApplicationController  
  set :oauth_scope,   settings.nightbot_oauth_scope
  set :oauth_server,  settings.nightbot_oauth_server
  set :client_id,     settings.nightbot_client_id
  set :client_secret, settings.nightbot_client_secret
    
    
  get "/authorize" do
    # TODO: Session State not persisting between calls for some reason. Maybe puma server related
    if session[:state] == nil
      session[:state] = SecureRandom.hex
      # puts "Set Session state as #{session[:state]}"
    end
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
    # puts "Trying to log in
    debug_log "Callback - Params: #{params.inspect}"
    # TODO: Figure out why the session is reset when we get redirected back
    if !params["error"].nil?
      debug_log params["error"]
    end
    if params["state"] != session[:state]
      debug_log "Incorrect State, possible fake oauth: params: #{params["state"]}, session: #{session[:state]}"
      debug_log session.inspect
      session.delete(:state)
      redirect '/auth/authorize'
    end
    session[:id_token] = params["code"]
    debug_log "Callback - Session: #{session.inspect}"

    # byebug
    access_token = client.auth_code.get_token(session[:id_token], {:token_method => :post}, redirect_uri: callback_url, grant_type: 'authorization_code', code:session[:id_token] )
    
    session[:access_token] = access_token.token
    session[:access_token_expires_at] = access_token.expires_at
    session[:refresh_token] = access_token.refresh_token
    session[:scope] = access_token.params["scope"]

    # parsed is a handy method on an OAuth2::Response object that will 
    # intelligently try and parse the response.body
    response = access_token.get('/1/me').parsed
    set_current_user(response["user"])
    redirect "/welcome"
  end

  post '/logout' do
    return_url = settings.application_host + '/auth/oauth2callback-signout'
    session[:current_user] = nil
    id_token = session[:id_token]
    session.clear
    # Send user to auth server for logout and auth cookie clear
    redirect settings.oauth_server + "/1/logout/endsession?id_token_hint=#{session[:id_token]}&post_logout_redirect_uri=#{callback_url}"
  end

  get '/oauth2callback-signout' do        
    redirect '/auth/oauth2callback-signout'    
    redirect '/'
  end

private
  def callback_url
    settings.application_host + '/oauth/oauth2callback'
  end

  def client
    client ||= OAuth2::Client.new(settings.client_id, settings.client_secret, 
        {
          :site => settings.oauth_server,
          :authorize_url => "/oauth2/authorize", 
          :token_url => "/oauth2/token"
        }
      )
  end

  def refresh_token
    access_token = client.auth_code.get_token(session[:refresh_token], grant_type: 'refresh_token', refresh_token: session[:refresh_token])
    session[:refresh_token] = access_token.refresh_token
    session[:access_token_expires] = access_token.expires_at
  end

  def nonce
    # Array.new( 5 ) { rand(256) }.pack('C*').unpack('H*').first
    SecureRandom.hex
  end

end
  
