# general enhuify configs

# choose whether to only interact with the DB or also with the bulb. This sholud
# be true before wes start the workshop
Rails.application.config.enable_bulb = false

# choose whether to block on changing the light as part of responding to the
# request or queue the change to be actually made on the light at a later time.
Rails.application.config.queue_changes = true

# Amount of time to sleep after processing a light change request off the queue
# to artificially slow down the rate at which the light changes state.
# Recommended values - somewhere between 200ms and 800ms. Value expressed as
# floating point seconds, so 0.2 to 0.8 is a good range.
Rails.application.config.queue_delay = 0.4

# disable sharding for the first part of the demo, enable it for the second
# change the value of this setting with calls to /admin/set_sharding and
# /admin/toggle_sharding
Rails.application.config.allow_sharding = false

# disable returning request IDs when we start up. Change this setting by poking
# /admin/toggle_return_ids or /admin/set_return_ids
Rails.application.config.return_ids = false

# default secret to confirm that access to the admin pages is allowed
Rails.application.config.admin_secret = "sofuzzysofuzzy"

$hueclient = nil
if Rails.application.config.enable_bulb
    $hueclient = Hue::Client.new
end

$logfh = open("/tmp/reqlog", 'a')

# color to HSB values TODO fill these in
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
