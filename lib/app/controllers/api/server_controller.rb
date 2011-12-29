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
        Video.transaction do
          archive.update_attributes(params[:video])
          archive.update_attribute(:vstate, 'archived')
        end if archive
        if archive and archive.save!
          user = archive.user
          if archive.private.eql?(2)
            channel = archive.channel || user.channels.living.last || user.channels.visited.last
            if channel
              channel.update_attributes({ :cstate => "archive", :video_id => archive.id })
              # Channel.transaction do
              #   channel.update_attribute(:cstate, "archive")
              #   channel.update_attribute(:video_id, archive.id)
              # end
              @channel = "/#{channel.token}"
            end
          else
            @channel = "/#{user.username}"
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
            channel = user.channels.created.first || user.channels.visited.first
            if channel
              channel.update_attributes({:cstate => "living", :video_id => living.id})
              @channel = "/#{channel.token}"
            else
              Rails.logger.info("no channel find ----------------------------------------------------------")
              @channel = "/default_error"
            end
          else
            @channel = "/#{user.username}"
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
            @channel = "/location/#{c.token}"
            c.update_attribute(:cstate, "archived")
          end
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

  #upload file
  def upload
    respond_to do |wants|
      wants.json {
        user = User.find_by_login(params["username"])
        if user and params and !params.empty? and params.has_key?(:id)
           video = Video.find_by_tid(params["id"])
           p = {
             :title => params["title"] || "无题",
             :tid => params["id"],
             :private => 1 - params[:share].to_i,
             :encoding => "flv/mp3/h263",
             :user_id => user.id,
             :length => params[:length] || 100 ,
             :size => params[:size] || "176x144",
             :vstate => "archived",
             :server_url => params[:server_url] || "http://192.168.1.92:24537/",
             :file_size => 0
           }
           unless video
             video = Video.create!(p)
           else
             video.update_attributes(p)
           end
           video.convert_3gp_to_flv
           render :text => "ok", :layout => false
        else
          render :text => "fail", :layout => false, :status => 400
        end
      }
    end
  end


end
