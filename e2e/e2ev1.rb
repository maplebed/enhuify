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
    response = HTTParty.get($url)
    response.parsed_response
end

def set_state(color)
    print "#{color}\n"
    response = HTTParty.put($url,
        :body => color.to_json,
        :headers => { 'Content-Type' => 'application/json' } )
    response.parsed_response
end

def report(hny, fields)
    hny.send_now(fields)
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
    set_state(hue: color)
    start = Time.now
    for iter in 0..30
        currently = get_state["hue"]
        if currently == color
            break
        end
        sleep(0.1)
    end
    dur = Time.now - start
    if currently == color
        print "took #{iter} times to get to color, total check time #{dur}\n"
    else
        print "failed after #{iter} times\n"
    end
    report(hny, {
        :durationSec => dur,
        :success => currently == color,
        :iterations => iter,
        })
    hny.close
end

main
