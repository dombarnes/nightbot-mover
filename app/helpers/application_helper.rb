require 'sinatra/base'
module ApplicationHelpers
  
  def current?(path = '/')
    request.path_info == path ? 'current' : nil
  end

  def link_to(text, url, opts = {})
    attributes = ''
    opts.each do |k, v|
      attributes << k.to_s << '="' << v << '" ' if k && v
    end
    %(<a href="#{url}" #{attributes}>#{text}</a>)
  end

  def check_box_for(field, id, value)
    checked = "checked" if value == true
    %(<input id="#{id}" type="checkbox" name="#{field}" #{checked} />)
  end

  def partial(template, opts={})
    parts = template.split('/')
    last = "_#{parts.pop}"

    erb([parts, last].flatten.join('/').to_sym, {layout: false}.merge(opts))
  end

  def yes_no(bool)
    if bool == true
      'Yes'
    else
      'No'
    end
  end

  def debug_log(message)
    STDOUT.puts message unless ENV['RACK_ENV'] == "production"
  end

end
