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

# red hue = 0
# green hue = 25500
# blue hue = 47000
# yellow hue = 17500
# gold hue = 12100
# pink hue = 55000
# white hue = 40500, sat = 0

# def self.find(id)
#     logger.info "Getting bulb state..."
#     if Rails.application.config.enable_bulb
#         light = $hueclient.lights[id - 1]
#         light.refresh
#         logger.info light.brightness
#         b = Bulb.new()
#         b.id = id
#         b.hue = light.hue
#         b.saturation = light.saturation
#         b.brightness = light.brightness
#         logger.info "found hue bulb #{b.attributes}"
#     else
#         logger.info "digging b out of the db"
#         b = super.find(id)
#     end
#     logger.info "done with find, b has brightness #{b.brightness}"
#     return b
# end

def save
    logger.info "Processing the request..."

    # if we're doing it for real and using a bulb
    if Rails.application.config.enable_bulb
        light = $hueclient.lights[self.id - 1]
        # $hueclient.lights.each { |light| light.hue = rand(Hue::Light::HUE_RANGE) }
        # no dilly-dallying around this time
        transition_time = 0
        light.set_state({
            # :color_temperature => 400,
            :hue => self.hue,
            :saturation => self.saturation,
            :brightness => self.brightness,
            }, transition_time)
    end
    # fail some of the time, cuz why not.
    if rand(10) != 0
        return self.save!
    end
    return false
end

end
