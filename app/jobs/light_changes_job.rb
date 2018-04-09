class LightChangesJob < ApplicationJob
  queue_as :default

  def self.queues
    @queues ||= [0,1].map do |shard|
      q = Queue.new
      Thread.new do
        while job = q.pop
          bulbmap, changelog = job
          begin
            # don't let job panics kill the thread
            perform_shard(bulbmap, changelog)
          rescue => e
            print "caught exception: #{e}, #{e.backtrace}\n"
          end
        end
      end
      q
    end
  end

  def perform(bulbmap, changelog)
    shard = bulbmap["id"].to_i - 1
    print "bulbmap shard is #{shard}\n"
    LightChangesJob.queues[shard] << [bulbmap, changelog]
  end

  def self.perform_shard(bulbmap, changelog)
    ev = $honeycomb.event()
    ev.add(bulbmap)
    # mark this job as having been processed, no longer pending
    changelog.processed = true
    logger.info "processing queued change: #{bulbmap}"
    bulb = Bulb.find(bulbmap["id"])
    bulb.assign_attributes(bulbmap)
    begin
      start = Time.now
      ok = bulb.save
      dur = Time.now - start
      ev.add_field("saveSec", dur)
      if ok == true
        changelog.succeeded = true
      else
        logger.info "failed to save bulb for unknown reason"
      end
    rescue => e
      logger.info "bulb save blew up: #{e}, #{e.backtrace}"
    end
    changelog.save!
    # take a while to finish the job to limit the speed at which jobs are pulled
    # off the queue.  Rate set via config
    ev.add(changelog.attributes)
    ev.add_field("delaySec", changelog.updated_at - changelog.created_at )
    ev.send()
    sleep(Rails.application.config.queue_delay)
  end
end
