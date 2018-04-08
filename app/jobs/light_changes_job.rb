class LightChangesJob < ApplicationJob
  queue_as :default

  def perform(bulbmap, changelog)
    logger.info "processing queued change: #{bulbmap}"
    bulb = Bulb.find(bulbmap["id"])
    # bulb.assign_attributes({
    #     :hue => bulbmap["hue"],
    #     :brightness => bulbmap["brightness"],
    #     :saturation => bulbmap["saturation"],
    #     :request_id => bulbmap["request_id"],
    #     })
    bulb.assign_attributes(bulbmap)

    # changelog = Changelog.new({
    #     :remote_id => changelogmap["remote_id"],
    #     :guid => changelogmap["guid"],
    #     :action => changelogmap["action"],
    #     :bulb_id => changelogmap["bulb_id"],
    #     :hue => changelogmap["hue"],
    #     :saturation => changelogmap["saturation"],
    #     :brightness => changelogmap["brightness"],
    #     })

    bulb.save!
    changelog.succeeded = true
    # chmangelog.updated_at = Time.current.to_s
    changelog.save!
    # take a while to finish the job to limit the speed at which jobs are pulled
    # off the queue.  100ms per job seems like a good rate.
    sleep(0.8)
  end
end
