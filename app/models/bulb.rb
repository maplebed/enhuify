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
    client = Hue::Client.new
    logger.info "Processing the request..."
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
    self.save!
end

end
