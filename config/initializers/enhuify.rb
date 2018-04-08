# general enhuify configs

# choose whether to only interact with the DB or also with the bulb. This sholud
# be true before wes start the workshop
Rails.application.config.enable_bulb = false

# choose whether to block on changing the light as part of responding to the
# request or queue the change to be actually made on the light at a later time.
Rails.application.config.queue_changes = true

# disable sharding for the first part of the demo, enable it for the second
# change the value of this setting with calls to /admin/set_sharding and
# /admin/toggle_sharding
Rails.application.config.allow_sharding = false
print "initializing sharding, set to #{Rails.application.config.allow_sharding}\n"

# disable returning request IDs when we start up. Change this setting by poking
# /admin/toggle_return_ids or /admin/set_return_ids
Rails.application.config.return_ids = false
print "initializing return_ids, set to #{Rails.application.config.return_ids}\n"

# default secret to confirm that access to the admin pages is allowed
Rails.application.config.admin_secret = "puppies4eva"
