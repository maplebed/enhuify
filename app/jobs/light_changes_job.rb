require 'libhoney'

class LightChangesJob < ApplicationJob
  queue_as :default

  class << self
    def queues
      @queues ||= [0, 1].map do |_shard|
        queue = Queue.new

        Thread.new do
          loop do
            job = queue.pop
            break if job.blank?

            bulbmap, changelog = job
            begin
              # don't let job panics kill the thread
              perform_shard(bulbmap, changelog, queue.length)
            rescue StandardError => e
              logger.error "caught exception: #{e}, #{e.backtrace}"
            end
          end
        end

        queue
      end
    end

    def clear
      logger.info 'clearing queue for both shards'
      LightChangesJob.queues[0].clear
      LightChangesJob.queues[1].clear
    end

    def honeycomb
      @honeycomb ||= Libhoney::Client.new(
        # Use an environment variable to set your write key with something like
        #   `writekey: ENV["HONEYCOMB_WRITEKEY"]`
        writekey: ENV['HONEYCOMB_WRITEKEY'],
        dataset: 'enhuify'
      )
    end

    def perform_shard(bulbmap, changelog, qlen)
      ev = honeycomb.event
      ev.timestamp = changelog.created_at
      ev.add(bulbmap)
      ev.add_field('queue_length', qlen)

      # mark this job as having been processed, no longer pending
      changelog.processed = true
      logger.info "processing queued change: #{bulbmap}"
      bulb = Bulb.find(bulbmap[:id])
      bulb.assign_attributes(bulbmap)
      begin
        start = Time.now
        ok = bulb.save
        dur = Time.now - start
        ev.add_field('saveSec', dur)
        if ok == true
          changelog.succeeded = true
        else
          logger.error 'failed to save bulb for unknown reason'
        end
      rescue StandardError => e
        logger.error "bulb save blew up: #{e}, #{e.backtrace}"
      end
      changelog.save!

      ev.add(changelog.attributes)
      ev.add_field('delaySec', changelog.updated_at - changelog.created_at)
      ev.send

      # take a while to finish the job to limit the speed at which jobs are
      # pulled off the queue. Rate set via config
      sleep(Rails.application.config.queue_delay)
    end
  end

  def perform(bulbmap, changelog)
    shard = bulbmap[:id].to_i - 1
    logger.info "bulbmap shard is #{shard}"
    LightChangesJob.queues[shard] << [bulbmap, changelog]
  end
end
