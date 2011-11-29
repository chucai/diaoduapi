require 'net/http'
require 'uri'
class BroadCast

  def self.push_message(channel, data)
    message = {:channel => channel, :data => data}
    uri = URI.parse(BroadCast.faye_url)
    Net::HTTP.post_form(uri, :message => message.to_json) 
  end

  def self.faye_url
    "http://#{CONFIG_APP[:leshi_server_ip]}:#{CONFIG_APP[:faye_port]}/#{CONFIG_APP[:faye_name]}"
  end

  def self.push_message_to_apple(token, message)
    d = Object.new
    d.extend ApplePushNotification
    d.device_token = token
    d.send_notification :alert => message 
  end
end
