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

    def save
        logger.info "Processing the request..."
        # fail some of the time, cuz why not.
        if bulb_color == :green and rand(5) == 0
            return false
        end


        # if we're doing it for real and using a bulb
        if Rails.application.config.enable_bulb
            light = $hueclient.lights[self.id - 1]
            # $hueclient.lights.each { |light| light.hue = rand(Hue::Light::HUE_RANGE) }
            # no dilly-dallying around this time
            transition_time = 0
            ok = light.set_state({
                # :color_temperature => 400,
                :hue => self.hue,
                :saturation => self.saturation,
                :brightness => self.brightness,
                }, transition_time)
            logger.info "light returned #{ok}"
        end
        return self.save!
    end

    # allow color to be an object of a bulb when the hsb values match a known color
    def color
        bulb_color
    end

    private

    def bulb_color()
        color_from_hsb({:hue => self.hue, :saturation => self.saturation, :brightness => self.brightness})
    end

    # exect hsb to be a hash of {:hue, :saturation, :brightness}. will be nil if
    # the hsb value doesn't have a color
    def color_from_hsb(hsb)
      $colors.key(hsb)
    end

    # expect color to be a "red" or :red. returns nil if the color doesn't exist
    def hsb_from_color(color)
      $colors[color.to_sym]
    end


end
