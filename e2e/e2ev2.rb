#!/usr/bin/env ruby

##
## e2ev2 includes a request ID in the health check verification

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

    color = rand_color
    # color = get_state["color"]
    request_id = set_state(color)["request_id"]
    if request_id == ""
        puts "no reqid on put"
    end
    start = Time.now
    for iter in 1..120
        success = get_state["request_id"] == request_id
        break if success
        sleep(0.2)
    end
    dur = Time.now - start
    if success
        puts "took #{iter} times to get to request_id, total check time #{dur}"
    else
        puts "failed after #{iter} times"
    end
    hny.send_now({
        :durationSec => dur,
        :success => success,
        :iterations => iter,
        :request_id => request_id,
        :color => color,
    })
    hny.close
end

main
