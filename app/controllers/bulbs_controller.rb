class BulbsController < ApplicationController
  before_action :set_bulb, only: [:show, :edit, :update, :destroy, :random, :set]

  # GET /bulbs
  # GET /bulbs.json
  def index
    @bulbs = Bulb.all
  end

  # GET /bulbs/1
  # GET /bulbs/1.json
  def show
  end

  # GET /bulbs/new
  def new
    @bulb = Bulb.new
  end

  # GET /bulbs/1/edit
  def edit
  end

  # POST /bulbs
  # POST /bulbs.json
  def create
    @bulb = Bulb.new(bulb_params)

    respond_to do |format|
      if @bulb.save
        format.html { redirect_to @bulb, notice: 'Bulb was successfully created.' }
        format.json { render :show, status: :created, location: @bulb }
      else
        format.html { render :new }
        format.json { render json: @bulb.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bulbs/1
  # PATCH/PUT /bulbs/1.json
  def update
    respond_to do |format|
      if @bulb.update(bulb_params)
        format.html { redirect_to @bulb, notice: 'Bulb was successfully updated.' }
        format.json { render :show, status: :ok, location: @bulb }
      else
        format.html { render :edit }
        format.json { render json: @bulb.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bulbs/1
  # DELETE /bulbs/1.json
  def destroy
    @bulb.destroy
    respond_to do |format|
      format.html { redirect_to bulbs_url, notice: 'Bulb was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /bulbs/1/random
  def random
    prng = Random.new
    hue = prng.rand(65536)
    @bulb.hue = hue
    respond_to do |format|
      if @bulb.save!
        format.html { redirect_to @bulb, notice: 'Bulb was successfully updated.' }
        format.json { render :show, status: :ok, location: @bulb }
      else
        format.html { render :edit }
        format.json { render json: @bulb.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /bulbs/1/set/12345/255/255
  # GET /bulbs/:id/set/:hue/:sat/:bri
  def set
    hue = Integer(params[:hue])
    sat = Integer(params[:sat])
    bri = Integer(params[:bri])
    @bulb.hue = hue
    @bulb.saturation = sat
    @bulb.brightness = bri
    respond_to do |format|
      if @bulb.save!
        format.html { redirect_to @bulb, notice: 'Bulb was successfully updated.' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bulb
      @bulb = Bulb.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bulb_params
      params.require(:bulb).permit(:hue, :saturation, :brightness)
    end
end
