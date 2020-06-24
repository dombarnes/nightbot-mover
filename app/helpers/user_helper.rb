require 'sinatra/base'
module UserHelpers
  
  def set_current_user(user)
    @user = OAuth::User.new(
      user["_id"], 
      user["name"], 
      user["displayName"],
      user["provider"],
      user["providerId"],
      user["avatar"],
      user["admin"]
    )
    session[:current_user] = @user
  end

  def current_user
    # session[:current_user] || nil
    if session[:current_user] && session[:current_user][:_id].nil?
      return nil
    else 
      @_current_user ||= session[:current_user] #&& User.find_by(id: session[:current_user_id])
    end
  end

  def session_expired?
    if session[:access_token_expires_at].nil? || Time.at(session[:access_token_expires_at]) <= Time.now
      session.clear
      return true
    end
    return false
  end

  def authorize!
    redirect '/oauth/authorize' unless authorized?
  end

  def authorized?
    current_user[:admin]
  end

  def authenticated?
    return true if session[:current_user].present?
    return false if session_expired?
  end
  
end
