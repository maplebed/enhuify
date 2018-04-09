class LightChangesJob < ApplicationJob
  queue_as :default

  def self.queues
    @queues ||= [0, 1].map do |shard|
      q = SizedQueue.new
      Thread.new do
        while job = q.pop
          bulbmap, changelog = job
          perform_shard(bulbmap, changelog)
        end
      end
      q
    end
  end

  def perform(bulbmap, changelog)
    shard = bulbmap.id
    self.queues[shard] << [bulbmap, changelog]
  end

  def perform_shard(bulbmap, changelog)
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
    sleep(Rails.application.config.queue_delay)
  end
end
