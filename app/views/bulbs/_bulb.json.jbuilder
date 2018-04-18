json.extract! bulb, :hue, :saturation, :brightness, :color
# json.url bulb_url(bulb, format: :json)
if Rails.application.config.return_ids
    json.extract! bulb, :request_id
end
