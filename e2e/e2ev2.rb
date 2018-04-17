#!/usr/bin/env ruby

##
## e2ev2 includes a request ID in the health check verification

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
    rand(65536)
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
        :writekey =>  ENV["HONEYCOMB_WRITEKEY"],
        :dataset => "enhuify_e2e"
    )
end

def main
    hny = init_libhoney()
    color = rand_color
    request_id = set_state(:hue => color)["request_id"]
    start = Time.now
    for iter in 1..120
        currently = get_state["request_id"]
        # puts "checking original #{request_id} against current state #{currently}"
        break if currently == request_id
        sleep(0.2)
    end
    dur = Time.now - start
    if currently == request_id
        puts "took #{iter} times to get to request_id, total check time #{dur}"
    else
        puts "failed after #{iter} times"
    end
    hny.send_now({
        :durationSec => dur,
        :success => currently == request_id,
        :iterations => iter,
    })
    hny.close
end

main
