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

  def user_has_role(role)
    current_user.role.include?(role)
  end

  def session_expired?
    if Time.at(session[:access_token_expires_at]) <= Time.now
      session[:id_token] = nil
      session[:access_token] = nil
      session[:refresh_token] = nil
      session[:current_user] = nil
      return true
    end
    return false
  end

  def authorize!
    redirect '/login' unless authorized?
  end

  def authorized?
    current_user.role.include? 'Admin'
  end

  def authenticated?
    !session[:current_user].empty?
  end
end
