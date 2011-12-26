class Api::ClientController < ApplicationController
  protect_from_forgery :except => [:upload_file]
  before_filter :authenticate_user!,:except => [:register]

  def register
    respond_to do |format|
      format.json{
        u = User.new(params[:user])
        result = {}
        if u.save
	  result[:result] = I18n.t("application.register.success")
          Rails.logger.info("#{result.inspect}")
          render :json => result.to_json
        else
 	  result[:result] = u.errors.full_messages.join(",")
          Rails.logger.info("#{result.inspect}")
          render :json => result.to_json, :status => 400
        end
      }
    end
  end


  #创建channel,并于用户关联，返回给手机客户端channel号和URL地址
  #channel: user_id, token, cstate('created'-> default,'visited','living','archive'),number(default = 0), video_id:视频编号
  def create_channel
    respond_to do |format|
      format.json {
        result = {}
        current_user.channels.should_delete.destroy_all
        channel = Channel.create({
          :user_id => current_user.id
        })
        result[:channel] = channel.token
        result[:url] = channel.get_url
        result[:type] = "CHANNEL"
        BroadCast.push_message("/#{current_user.username}", result)
        render :json => result.to_json
      }
    end
  end

  #销毁channel
  def destroy_channel
    current_user.channels.should_delete.destroy_all
    result = {:result => "ok"}
    respond_to do |format|
      format.json {
        render :json => result.to_json
      }
    end
  end

  #手机客户端轮询接口，返回是否有人查看该频道channel
  def notice_channel
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

  #update password
  #/api/change_password.json
  def password
   respond_to do |format|
     format.json {
       @user = current_user
       result = {}
       if @user.update_with_password(params[:user])
         sign_in(@user)
         result[:result] = I18n.t('application.password.success')
         render :json => result.to_json
       else
         result[:result] = I18n.t('application.password.fail')
         render :json => result.to_json,  :status => 400
       end
     }
   end
  end

  #update video's title
  def update
    respond_to do |wants|
      wants.json{
        video = Video.find_by_tid(params[:tid])
        if(video.user == current_user and video.update_attributes(params[:video]))
          render :json => {:result => "update success!"}
        else
          render :json => {:result => "update failed!"}, :status => 400
        end
      }
    end
  end

  #upload log file to server
  def upload_file
    respond_to do |wants|
      wants.html {
        filename = User.save_log(params[:file])
        recipient = ["wen-hanyang@163.com", "hexudong08@gmail.com"]
        subject = "客户端日志bug文件"
        LoggerMailer.delay.deliver_contact(recipient, subject, filename)
        render :json => {:result => "ok"}.to_json
      }
    end
  end

end

