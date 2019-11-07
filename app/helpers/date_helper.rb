require 'sinatra/base'
module DateHelpers
  
  def date_to_pretty_format(date)
    return "" if date == nil
    date.strftime("%e %B %y")
  end

  def date_to_sortable(date)
    return "" if date == nil
    date.strftime("%Y%m%d")
  end

  def days_to_yeardays(days)
    years = (days / 365).round(0)
    day = days - (years * 365)
    case years
    when 0
      return "#{day} days"
    when 1..2
      return "#{years} year #{day} days"
    when 2..Float::INFINITY
      "#{(days / 365).round(2)} years"
    else 
      return "#{years} years #{day} days"
    end
  end
end
