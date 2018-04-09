class Bulb < ApplicationRecord
    validates :hue, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0,
                                    less_than: 65536 }
    validates :saturation, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0,
                                    less_than: 256 }
    validates :brightness, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0,
                                    less_than: 256 }

def save
    logger.info "Processing the request..."

    # if we're doing it for real and using a bulb
    if Rails.application.config.enable_bulb
        client = Hue::Client.new
        logger.info client
        light = client.lights.first
        # no dilly-dallying around this time
        transition_time = 0
        light.set_state({
            :color_temperature => 400,
            :hue => self.hue,
            :saturation => self.saturation,
            :brightness => self.brightness,
            }, transition_time)
    end
    self.save!
    # fail some of the time, cuz why not.
    return rand(10) == 0
end

end
