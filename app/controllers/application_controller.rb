class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  before_action :activity_start
  after_action :activity_end

  private
  def activity_start
    ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    id = request.request_id
    mthd = request.request_method
    path = request.fullpath
    hsb = "#{request.parameters["hue"]}/#{request.parameters["saturation"]}/#{request.parameters["brightness"]}"
    cna = "#{request.parameters["controller"]}/#{request.parameters["action"]}"
    color = request.parameters["color"]

    if request.headers["content-type"] == "application/x-www-form-urlencoded"
      content_type = "urlencoded"
    elsif request.headers["content-type"] == "application/json"
      content_type = "json"
    else
      content_type = request.headers["content-type"]
    end
    # route = request.route
    # args = request.params
    # logger.info "request #{ip} #{route} #{args}"
    bits = {
      :path => request.fullpath,
      :parameters => request.parameters,
      :id => request.request_id,
      :user_agent => request.user_agent,
    }
    # entry = "#{Time.now.strftime("%H:%M:%S")} #{ip} #{id} #{mthd} #{path} hsb=#{hsb} c=#{color} #{cna} #{content_type} #{request.body.read} #{request.parameters}\n"
    entry = "#{Time.now.strftime("%H:%M:%S")} #{ip} #{id} #{mthd} #{path} hsb=#{hsb} c=#{color} #{cna} #{content_type} #{request.body.read}\n"
    $logfh.write(entry)
    $logfh.flush
  end
  def activity_end
    ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    id = request.request_id
    entry = "#{Time.now.strftime("%H:%M:%S")} #{ip} #{id} #{response.status}\n"
    $logfh.write(entry)
    $logfh.flush
  end
end
