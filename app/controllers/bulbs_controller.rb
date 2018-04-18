require 'securerandom'

class BulbsController < ApplicationController
  before_action :choose_shard, only: [:show, :edit, :update, :destroy, :random, :set]
  before_action :set_bulb, only: [:show, :edit, :update, :destroy, :random, :set]

  # GET /bulbs
  # GET /bulbs.json
  def index
    # @bulbs = Bulb.all
  end

  # GET /bulbs/1
  # GET /bulbs/1.json
  def show
    if Rails.application.config.enable_bulb
        light = $hueclient.lights[@bulb.id - 1]
        light.refresh
        return Bulb.new({
          :id => @bulb.id,
          :hue => light.hue,
          :saturation => light.saturation,
          :brightness => light.brightness
        })
    end
    @bulb
  end


  # PATCH/PUT /bulbs/1
  # PATCH/PUT /bulbs/1.json
  def update
    @bulb.assign_attributes({ :request_id => request.request_id })
    if Rails.application.config.queue_changes
      ### this version pushes changes into a queue to be triggered when it can
      attrs = bulb_params
      if attrs[:error]
        head :bad_request
        return
      end
      @bulb.assign_attributes(attrs)
      bulb = {
        :id => @bulb.id,
        :hue => @bulb.hue,
        :brightness => @bulb.brightness,
        :saturation => @bulb.saturation,
        :request_id => request.request_id,
      }
      changelog = Changelog.new({
                :remote_ip => ip(),
                :request_id => request.request_id,
                :action => "update",
                :bulb_id => @bulb.id,
                :hue => @bulb.hue,
                :saturation => @bulb.saturation,
                :brightness => @bulb.brightness,
                :succeeded => false,
                :processed => false,
                :created_at => Time.current.to_s,
            })
      changelog.save!
      LightChangesJob.perform_later bulb, changelog

      # return either a request ID or just a 202 accepted
      if Rails.application.config.return_ids
        render :accepted, status: :accepted, location: @bulb
      else
        head :accepted
      end
    else
      ### this version makes changes to the bulb immediately and blocks until success
      attrs = bulb_params
      if attrs[:error]
        head :bad_request
        return
      end
      ok = @bulb.update(attrs)
      if ok
        # return either a request ID or just a 202 accepted
        if Rails.application.config.return_ids
          render :accepted, status: :accepted, location: @bulb
        else
          head :accepted
        end
      else
        render json: @bulb.errors, status: :unprocessable_entity
      end
      @changelog = Changelog.new({
        :remote_ip => ip(),
        :request_id => request.request_id,
        :action => "update",
        :bulb_id => @bulb.id,
        :hue => @bulb.hue,
        :saturation => @bulb.saturation,
        :brightness => @bulb.brightness,
        :processed => true,
        :succeeded => ok,
        })
      @changelog.save!
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def ip()
      request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    end

    # for the first part of the demo, allow_sharding will be false and we'll
    # always use the "odd" shard. Once sharding is enabled, we'll split on the
    # last digit of the IP address to choose whether you're hitting the even or
    # odd shard, and allow you to override it using the 'shard_override' flag
    def choose_shard
      unless Rails.application.config.allow_sharding
        logger.info "no sharding"
        # when allow_sharding is false, always return the odd shard
        @shard = "odd"
      else
        logger.info "sharded world"
        @shard = params[:shard_override]
        if ! @shard
          # take the last character of the IP address and sort evens and odds
          # logger.info "using #{ip()} as the IP and the last char is #{ip()[-1].to_i} and it is #{ip()[-1].to_i % 2 == 0}"
          # if ip()[-1].to_i % 2 == 0
          if rand(2) == 0
            @shard = "even"
          else
            @shard = "odd"
          end
        end
      end
      logger.info "set shard to >>#{@shard}<<"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_bulb
      if @shard == "odd"
        @bulb = Bulb.find(1)
      else
        @bulb = Bulb.find(2)
      end
      params.delete :shard_override
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bulb_params
      logger.info "color is >>#{request.parameters[:color]}<<"
      if request.parameters[:color] != nil
        logger.info "in color with #{request.parameters[:color]}"
        hsb = $colors[request.parameters[:color].to_sym]
        logger.info "hsb is >>#{hsb}<<"
        if hsb
          logger.info "in hsb"
          return {:hue => hsb[:hue], :saturation => hsb[:saturation], :brightness => hsb[:brightness]}
        else
          return {:error => "unknown color #{request.parameters[:color]}"}
        end
      end
      params.permit(:hue, :saturation, :brightness, :shard_override, :color)
    end
end

