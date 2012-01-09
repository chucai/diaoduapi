class Api::ServerController < ApplicationController
  layout false
  before_filter :flow_server_filter

  #return token for system
  def server_token
    respond_to do |format|
      format.json {
        result = {}
        result[:token] = SERVER_CONFIG["token"]
        render :json => result.to_json
      }
    end
  end

  #login for client
  def login
    challenge = params[:challenge]
    response = params[:response]
    username = params[:username]
    if User.authenticate_for_mobile?(username, challenge,response)
      render :status => 200, :json => {:result => "ok" }.to_json
    else
     render :status => 400, :json => {:result => "fail"}.to_json
    end
  end

  def save_archived
    respond_to do |format|
      format.json {
        archive = Video.find_by_tid(params[:video][:tid])
        if archive
          Video.transaction do
            archive.update_attributes(params[:video])
            archive.update_attribute(:vstate, 'archived')
          end
          user = archive.user
          if archive.private.eql?(2) && (channel = archive.channel)
            channel.update_attributes({ :cstate => "archived", :video_id => archive.id })
            @channel = "/#{channel.token}"
          else
            @channel = "/#{user.faye_token}"
          end
          BroadCast.push_message(@channel, archive.to_hash)
          render :json => {:result => I18n.t('application.archived.success')}.to_json
        else
          render :json => {:result => I18n.t('application.archived.fail')}.to_json , :status => 400
        end
      }
    end
  end

  def save_live
    respond_to do |format|
      format.json {
        user = User.find_by_login(params[:username])
        living = Video.new(params[:video])
        living.user = user
        if user and living.save!
          if living.private.eql?(2)
            channel = user.channels.created.first
            if channel
              channel.update_attributes({:cstate => "living", :video_id => living.id})
              @channel = "/#{channel.token}"
            else
              Rails.logger.info("no channel find ----------------------------------------------------------")
              @channel = "/default_error"
            end
          else
            @channel = "/#{user.faye_token}"
          end
          Rails.logger.info(living.to_hash.inspect)
          BroadCast.push_message(@channel, living.to_hash)
          render :json => {:result => I18n.t('application.live.success')}.to_json
        else
          render :json => {:result => I18n.t('application.live.fail')}.to_json , :status => 400
        end
       }
     end
   end

   #location for video
  def location
    respond_to do |wants|
      wants.json {
        tid = params[:video][:tid]
        video = Video.find_by_tid(tid)
        if video
          c = Channel.find(:first , :conditions => ["video_id = ?", video.id])
          if c
            @channel = "/#{c.token}"
          end
        end
        hash = {}
        status = 400
        result = {}
        if video and video.update_attributes(params[:video])
          data = {
            :lat => video.lat,
            :lng => video.lng,
            :type => "LOCATION",
          }
          BroadCast.push_message(@channel,data) if @channel
          status = 200
          hash = { :result => "修改成功"}
        else
          hash = { :result => "修改失败,视频不存在"}
        end
        render :json => hash.to_json, :status => status
      }
    end
  end

  #upload file
  def upload
    respond_to do |wants|
      wants.json {
        user = User.find_by_login(params["username"])
        result = {}
        if user
           video = user.videos.find_by_tid(params["video"]["tid"])
           if video
             video.update_attributes(params[:video])
           else
             video = Video.create!(params[:video])
           end
           result[:result] = "ok"
           render :json =>  result.to_json
        else
          result[:result] = "fail"
          render :json => result.to_json, :status => 400
        end
      }
    end
  end

  private
  #流媒体过滤器
  def flow_server_filter
    remote_ip = request.remote_ip
    access_ip = SERVER_CONFIG["server_ip"].split(" ").map { |ip|  ip.split(":").first  }
    unless access_ip.include?(remote_ip)
      respond_to do |wants|
        wants.json {
          render :json => {:result => "非法访问" }.to_json, :status => 400
        }
      end
    end
  end

end
