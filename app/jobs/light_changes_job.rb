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
            print "caught exception: #{e.backtrace}\n"
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
    # mark this job as having been processed, no longer pending
    changelog.processed = true
    logger.info "processing queued change: #{bulbmap}"
    bulb = Bulb.find(bulbmap["id"])
    bulb.assign_attributes(bulbmap)
    begin
      ok = bulb.save
      if ok == true
        changelog.succeeded = true
      else
        logger.info "failed to save bulb for unknown reason"
      end
    rescue => e
      logger.info "bulb save blew up: #{e.backtrace}"
    end
    changelog.save!
    # take a while to finish the job to limit the speed at which jobs are pulled
    # off the queue.  Rate set via config
    sleep(Rails.application.config.queue_delay)
  end
end
