# initialize the libhoney gem

require 'libhoney'

$honeycomb = Libhoney::Client.new(
  # Use an environment variable to set your write key with something like
  #   `:writekey => ENV["HONEYCOMB_WRITEKEY"]`
  :writekey =>  ENV["cf80cea35c40752b299755ad23d2082e"],
  :dataset => "enhuify"
)
