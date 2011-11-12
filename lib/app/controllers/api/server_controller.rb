class Api::ServerController < ApplicationController
  layout false


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
        archive.update_attributes(params[:video]) if archive
        if archive and archive.save!
          if archive.private.eql?(3)
            user = archive.user
            channel = user.channels.living.last || user.channels.visited.last
            if channel
              Channel.transaction do 
               channel.update_attribute(:cstate, "archive")  
               channel.update_attribute(:video_id, archive.id)
              end
              @channel = "/#{channel.token}"
              BroadCast.push_message(@channel, archive.to_hash)
            end
          end
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
        user = User.find_by_username(params[:username])
        living = Video.new(params[:video])
        living.user = user
        if user and living.save!
          if living.private.eql?(2)
            channel = user.channels.created.first || user.channels.visited.first
            if channel
              Channel.transaction do
                channel.update_attribute(:cstate, "living")  
                channel.update_attribute(:video_id, living.id)
              end
              @channel = "/#{channel.token}"
              BroadCast.push_message(@channel, living.to_hash)
            else
              Rails.logger.info("no channel find ----------------------------------------------------------")
            end
          end
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
          c = Channel.find(:first , :conditions => ["cstate = 'living' and video_id = ?", video.id])
          @channel = "/location/#{c.token}" if c
        end 
        hash = {}
        status = 400
        result = {}
        if video and video.update_attributes(params[:video])
          hash = { :result => "修改成功"}
          status = 200
        else
          hash = { :result => "修改失败,视频不存在"}
        end
        render :json => hash.to_json, :status => status
      }
    end
  end


end
