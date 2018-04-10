# initialize the libhoney gem

require 'libhoney'

$honeycomb = Libhoney::Client.new(
  # Use an environment variable to set your write key with something like
  #   `:writekey => ENV["HONEYCOMB_WRITEKEY"]`
  :writekey =>  ENV["HONEYCOMB_WRITEKEY"]`,
  :dataset => "enhuify"
)
