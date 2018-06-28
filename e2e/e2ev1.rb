#!/usr/bin/env ruby

require 'httparty'
require 'libhoney'

$url = 'http://localhost/bulb'

# color to HSB values
$colors = {
    :red => {:hue => 0, :saturation => 254, :brightness => 254},
    :orange => {:hue => 4915, :saturation => 254, :brightness => 254},
    :yellow => {:hue => 9830, :saturation => 254, :brightness => 254},
    :lime => {:hue => 13289, :saturation => 254, :brightness => 254},
    :green => {:hue => 25500, :saturation => 254, :brightness => 254},
    :cyan => {:hue => 32585, :saturation => 254, :brightness => 254},
    :blue => {:hue => 47000, :saturation => 254, :brightness => 254},
    :purple => {:hue => 50608, :saturation => 254, :brightness => 254},
    :pink => {:hue => 57344, :saturation => 254, :brightness => 254},
    :white => {:hue => 0, :saturation => 0, :brightness => 254},
}

def rand_color
    [$colors[:red], $colors[:orange], $colors[:yellow], $colors[:lime],
      $colors[:green], $colors[:cyan], $colors[:blue], $colors[:purple],
      $colors[:pink], $colors[:white]].sample
end

def get_state
    HTTParty.get($url).parsed_response
end

def set_state(color)
    puts "setting color to #{color}"
    response = HTTParty.put($url,
        :body => color.to_json,
        :headers => { 'Content-Type' => 'application/json' }
    )
    response.parsed_response
end

def init_libhoney
    Libhoney::Client.new(
        # Use an environment variable to set your write key with something like
        #   `:writekey => ENV["HONEYCOMB_WRITEKEY"]`
        :writekey =>  ENV["HONEYCOMB_WRITEKEY"],
        :dataset => "enhuify_e2e"
    )
end

def main
    hny = init_libhoney()
    success = false

    color = rand_color
    # colorname = get_state["color"]
    # color = $colors[colorname]

    set_state(color)
    start = Time.now
    for iter in 1..30
        success = get_state["hue"] == color[:hue]
        break if success
        sleep(0.1)
    end
    dur = Time.now - start
    if success
        puts "took #{iter} times to get to color, total check time #{dur}"
    else
        puts "failed after #{iter} times"
    end
    hny.send_now({
        :durationSec => dur,
        :success => success,
        :iterations => iter,
        :color => color,
    })
    hny.close
end

main
