require 'net/http'
require 'uri'
class BroadCast

  def self.push_message(channel, data)
    message = {:channel => channel, :data => data}
    uri = URI.parse(BroadCast.faye_url)
    Rails.logger.info(channel)
    Rails.logger.info(BroadCast.faye_url)
    Net::HTTP.post_form(uri, :message => message.to_json)
    Rails.logger.info("channel is #{channel} ------------------------------------")
  end

  def self.faye_url
    "http://#{CONFIG_APP[:leshi_server_ip]}:#{CONFIG_APP[:faye_port]}/#{CONFIG_APP[:faye_name]}"
  end

  #flag is 100...
  def self.push_message_to_apple(token, message, flag = 100)
    d = Object.new
    d.extend ApplePushNotification
    d.device_token = token
    d.send_notification :alert =>  message, :flag => flag
  end
end
