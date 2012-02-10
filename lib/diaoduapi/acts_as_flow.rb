module Didaoduapi
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def acts_as_flow(options = {})
      send :include , InstanceMethods

      has_many :videos, :dependent => :destroy
      has_many :channels

      def self.authenticate_for_mobile?(username, challenge,response)
        u = find_by_login(username)
        if u
          response == u.jiami_password(challenge)
        else
          false
        end
      end

      def self.mk_one_password(key)
        require 'md5'
        tmp = MD5.md5
        tmp.update([key].pack("H*"))
        tmp.update([Time.now.to_i.to_s].pack("H*"))
        return tmp.to_s
      end

      def self.login_from_client(username, password, ver, ext)
        hash = {}
        user = User.find_by_username(username)
        hash[:ss_ip] = CONFIG_APP[:leshi_server_ip]
        hash[:ss_port] = CONFIG_APP[:leshi_server_in_port]
        flow = FlowMedia.save_or_update({:user_id => user.id, :ss_key => self.mk_one_password(ext[:key]), :expire_time => 3600 })
        hash[:ss_key] = flow.ss_key
        hash[:key_duration] = flow.expire_time
        hash[:newversion] = false
        return hash
      end

      #save log file
      def save_log file
        name =  get_filename(file.original_filename)
        directory = CONFIG_APP[:client_log] || "client_log"
        path = File.join(directory, name)
        File.open(path, "wb") { |f| f.write(file.read) }
        return name
      end

      def get_filename(original_filename)
        if original_filename
          Time.now.strftime("%Y-%m-%d-%H-%M-%S") + original_filename
        else
          Time.now.strftime("%Y-%m-%d-%H-%M-%S") + Time.now.to_i.to_s + ".txt"
        end
      end

    end

  end

  module InstanceMethods
    def jiami_password(challenge)
      require 'md5'
      md = MD5.md5
      f = FlowMedia.find_by_user_id(self.id)
      return false unless f
      pwd = f.ss_key
      logger.info("password is : #{pwd}")
      pd = MD5.hexdigest(pwd)
      logger.info("pd is #{pd.to_s}")
      md.update([pd].pack("H*"))
      logger.info("md1 is #{md.to_s}")
      md.update([challenge].pack("H*"))
      logger.info("md5 response is #{md.to_s}")
      return md.to_s
    end

    def values_for_mobile(ver,ext)
      hash = {}
      # hash[:ss_ip] = CONFIG_APP[:leshi_server_ip]
      # hash[:ss_port] = CONFIG_APP[:leshi_server_in_port]
      # hash[:ss_ip] = %w(223.4.118.15 42.120.42.238)[rand(2)]
      # hash[:ss_port] = 30710
      ip_and_port = get_server_ip_and_port
      hash[:ss_ip], hash[:ss_port] = ip_and_port.first, ip_and_port.last
      flow = FlowMedia.save_or_update({:user_id => self.id, :ss_key => User.mk_one_password(ext[:key]), :expire_time => 3600 })
      hash[:ss_key] = flow.ss_key
      hash[:key_duration] = flow.expire_time
      hash[:ver] = 1 #tell client server version
      new_version = SoftVersion.find_new_version_by_ver(ver)
      if ver and new_version and new_version.is_a?(SoftVersion)
        hash[:newversion] = true
        if /i/.match(ver)
          hash[:url] = "itms-apps://itunes.com/app/酷拍视频聊天"
        else
          #hash[:url] = "http://#{ext[:host_with_port]}/welcome/download?soft=#{new_version.soft_name}&from=client&version=#{new_version.version}"
          hash[:url] = new_version.apk_url
        end

        #add for android
        hash[:new_version] = new_version.apk_full_version
        hash[:file_size] = new_version.apk_size
        hash[:feature] = new_version.apk_feature
      else
        hash[:newversion] = false
      end
      device = Device.find_by_device_and_rom_id(ext[:device], ext[:rom_id])
      hash[:encode_mode] = device.nil? ? 3 : device.encode_mode
      hash
    end

    def get_server_ip_and_port
      ip = FlowIPGetway::Getway.get_server_ip_and_port
      ip.split(":")
    end

  end

end

ActiveRecord::Base.send :include, Didaoduapi
