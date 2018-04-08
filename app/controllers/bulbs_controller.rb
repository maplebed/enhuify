require 'securerandom'

class BulbsController < ApplicationController
  before_action :choose_shard, only: [:show, :edit, :update, :destroy, :random, :set]
  before_action :set_bulb, only: [:show, :edit, :update, :destroy, :random, :set]

#   # GET /bulbs
#   # GET /bulbs.json
#   def index
#     @bulbs = Bulb.all
#   end

  # GET /bulbs/1
  # GET /bulbs/1.json
  def show
  end

#   # GET /bulbs/new
#   def new
#     @bulb = Bulb.new
#   end

#   # GET /bulbs/1/edit
#   def edit
#   end

#   # POST /bulbs
#   # POST /bulbs.json
#   def create
#     @bulb = Bulb.new(bulb_params)
#     @changelog = Changelog.new({
#       :remote_id => request.remote_ip,
#       :guid => SecureRandom.uuid,
#       :action => "create",
#       })
#     @changelog.save!

#     respond_to do |format|
#       if @bulb.save
#         format.html { redirect_to @bulb, notice: 'Bulb was successfully created.' }
#         format.json { render :show, status: :created, location: @bulb }
#       else
#         format.html { render :new }
#         format.json { render json: @bulb.errors, status: :unprocessable_entity }
#       end
#     end
#   end

  # PATCH/PUT /bulbs/1
  # PATCH/PUT /bulbs/1.json
  def update
    guid=SecureRandom.uuid
    @bulb.assign_attributes({ :request_id => guid })
    if Rails.application.config.queue_changes
      ### this version pushes changes into a queue to be triggered when it can
      @bulb.assign_attributes(bulb_params)
      bulb = {
        "id" => @bulb.id,
        "hue" => @bulb.hue,
        "brightness" => @bulb.brightness,
        "saturation" => @bulb.saturation,
        "request_id" => guid,
      }
      changelog = Changelog.new({
                "remote_id" => request.remote_ip,
                "guid" => guid,
                "action" => "update",
                "bulb_id" => @bulb.id,
                "hue" => @bulb.hue,
                "saturation" => @bulb.saturation,
                "brightness" => @bulb.brightness,
                "succeeded" => false,
                "created_at" => Time.current.to_s,
            })
      changelog.save!
      LightChangesJob.perform_later bulb, changelog
      if Rails.application.config.return_ids
        render :accepted, status: :accepted, location: @bulb
      else
        head :accepted
      end
    else
      ### this version makes changes to the bulb immediately and blocks until success
      ok = @bulb.update(bulb_params)
      if ok
        # render :show, status: :ok, location: @bulb
        if Rails.application.config.return_ids
          render :accepted, status: :accepted, location: @bulb
        else
          head :accepted
        end
      else
        render json: @bulb.errors, status: :unprocessable_entity
      end
      @changelog = Changelog.new({
        :remote_id => request.remote_ip,
        :guid => guid,
        :action => "update",
        :bulb_id => @bulb.id,
        :hue => @bulb.hue,
        :saturation => @bulb.saturation,
        :brightness => @bulb.brightness,
        :succeeded => ok,
        })
      @changelog.save!
    end
  end

#   # DELETE /bulbs/1
#   # DELETE /bulbs/1.json
#   def destroy
#     @changelog = Changelog.new({
#       :remote_id => request.remote_ip,
#       :guid => SecureRandom.uuid,
#       :action => "destroy",
#       })
#     @changelog.save!
#     @bulb.destroy
#     respond_to do |format|
#       format.html { redirect_to bulbs_url, notice: 'Bulb was successfully destroyed.' }
#       format.json { head :no_content }
#     end
#   end

#   # GET /bulbs/1/random
#   def random
#     prng = Random.new
#     hue = prng.rand(65536)
#     @bulb.hue = hue
#     respond_to do |format|
#       if @bulb.save!
#         format.html { redirect_to @bulb, notice: 'Bulb was successfully updated.' }
#         format.json { render :show, status: :ok, location: @bulb }
#       else
#         format.html { render :edit }
#         format.json { render json: @bulb.errors, status: :unprocessable_entity }
#       end
#     end
#   end

#   # GET /bulbs/1/set/12345/255/255
#   # GET /bulbs/:id/set/:hue/:sat/:bri
#   def set
#     @changelog = Changelog.new({
#       :remote_id => request.remote_ip,
#       :guid => SecureRandom.uuid,
#       :action => "set",
#       })
#     @changelog.save!
#     hue = Integer(params[:hue])
#     sat = Integer(params[:sat])
#     bri = Integer(params[:bri])
#     @bulb.hue = hue
#     @bulb.saturation = sat
#     @bulb.brightness = bri
#     respond_to do |format|
#       if @bulb.save!
#         format.html { redirect_to @bulb, notice: 'Bulb was successfully updated.' }
#       end
#     end
#   end

  private
    # Use callbacks to share common setup or constraints between actions.

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
        if @shard == ""
          # take the last character of the IP address and sort evens and odds
          if request.remote_ip[-1].to_i % 2 == 0
            @shard = "even"
          else
            @shard = "odd"
          end
        end
      end
      logger.info "set shard to #{@shard}"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_bulb
      if @shard == "odd"
        @bulb = Bulb.find(1)
      else
        @bulb = Bulb.find(2)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bulb_params
      params.permit(:hue, :saturation, :brightness, :shard_override)
    end
end



# # TODO generate a UUID to identify the request and hand it back to the requester
# # require 'SecureRandom'
# # SecureRandom.uuid # => "96b0a57c-d9ae-453f-b56f-3b154eb10cda"
