#!/usr/bin/env ruby

require 'httparty'
require 'libhoney'

$url = 'http://localhost/bulb'


$red = 0
$green = 25500
$blue = 47000
$yellow = 17500
$gold = 12100
$pink = 55000
$white = 40500 # sat = 0

def rand_color
    [$red, $green, $blue, $yellow, $gold, $pink, $white].sample
end

def get_state
    HTTParty.get($url).parsed_response
end

def set_state(color)
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
        :writekey =>  ENV["cf80cea35c40752b299755ad23d2082e"],
        :dataset => "enhuify_e2e"
    )
end

def main
    hny = init_libhoney()
    color = rand_color
    set_state(:hue => color)
    start = Time.now
    for iter in 1..30
        currently = get_state["hue"]
        break if currently == color
        sleep(0.1)
    end
    dur = Time.now - start
    if currently == color
        puts "took #{iter} times to get to color, total check time #{dur}"
    else
        puts "failed after #{iter} times"
    end
    hny.send_now({
        :durationSec => dur,
        :success => currently == color,
        :iterations => iter,
    })
    hny.close
end

main
