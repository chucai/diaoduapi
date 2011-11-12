class ChannelsController < ApplicationController
  before_filter :authenticate_user!
  
  #创建channel,并于用户关联，返回给手机客户端channel号和URL地址
  #channel: user_id, token, cstate('created'-> default,'visited','living','archive'),number(default = 0), video_id:视频编号
  def create
    respond_to do |format|
      format.json {
        result = {}
        current_user.channels.should_delete.destroy_all
        channel = Channel.create({
          :user_id => current_user.id
        })
        result[:channel] = channel.token
        result[:url] = channel.get_url
        render :json => result.to_json
      }
    end
  end

  #销毁channel
  def destroy
    current_user.channels.should_delete.destroy_all
    result = {:result => "ok"}
    respond_to do |format|
      format.json {
        render :json => result.to_json
      }
    end
  end

  #手机客户端轮询接口，返回是否有人查看该频道channel
  def notice
    channel = params[:channel]
    visited = current_user.channels.visited.find(:first, :conditions => ["token = ?",channel])
    respond_to do |format|
      format.json {
        result = {}
        result[:state] = visited.nil? ? "novisited" : "visited"
        result[:numbers] = visited.nil? ? 0 : visited.number  
        render :json => result.to_json
      }
    end
  end
end
