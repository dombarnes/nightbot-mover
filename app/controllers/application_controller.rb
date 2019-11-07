require 'sinatra/base'

class ApplicationController < NightbotMover

  set :views, 'app/views'
  set :erb, escape_html: true
  
  before do
    pass if %w[assets oauth .well-known].include? request.path.split('/')[1]
    if (current_user.nil? || session_expired?)
      debug_log "no current user or active session"
      debug_log session.inspect
      session[:return_url] = request.fullpath
      redirect "/oauth/authorize"
    end
  end

  def set_title(page_title = "")
    @page_title = page_title
    !@page_title.blank? ? @title_tag = "#{@page_title} : #{settings.site_title}" : @title_tag = "#{settings.site_title}"
  end

  not_found do
    error_404("Page not found")
  end

  def error_404(message = "", error = nil)
    status 404
    set_title("Page Not Found")
    erb :error_404, error: message, layout: :layout_error 
  end

  error 401 do
    status 401
    set_title("Unauthorised Access")
    erb :error_401, layout: :layout_error 
  end

  error 500 do |err|
    @error = request.env['sinatra.error'].message
    status 500
    set_title("Application Error")
    erb :error_500, layout: :layout_error
  end
end
