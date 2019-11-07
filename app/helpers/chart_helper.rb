require 'sinatra/base'
module ChartHelper

  CHART_COLOURS = [
    "rgba( 41,  97,  91, 1)", # eden 
    "rgba(255, 200,  10, 1)", # sunflower
    "rgba( 73, 174, 163, 1)", # jade
    "rgba(224,  95,  95, 1)", # flamingo
    "rgba( 60, 160, 150, 1)", # viridian
    "rgba(238, 184,  12, 1)", # cyber
    "rgba(200,  80,  80, 1)", # poppy
    # "rgba(230, 233, 237, 1)", # athens
    # "rgba(205, 207, 209, 1)", # steel
    "rgba(120, 120, 120, 1)", # graphite
  ]

  def get_colours(length)
    repeats = length / CHART_COLOURS.count.floor
    diff = length - (repeats * CHART_COLOURS.count)
    new_array = []
    repeats.times do |color|
      new_array.push(CHART_COLOURS).flatten
    end
    new_array.push(CHART_COLOURS[0...diff]).flatten
  end
end
