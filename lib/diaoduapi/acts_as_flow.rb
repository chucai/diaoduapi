module Didaoduapi
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def acts_as_flow(options = {})
      send :include , InstanceMethods 
   
      def self.authenticate_for_mobile?(username, challenge,response)
        return true
        u = find_by_username(username)
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
    end

  end

  module InstanceMethods
    def jiami_password(challenge)
      require 'md5'
      md = MD5.md5
      pwd = self["pwd"]
      pd = MD5.hexdigest(pwd)
      md.update([pd].pack("H*"))
      md.update([challenge].pack("H*"))
      return md.to_s
    end

    def values_for_mobile(ver,ext)
      hash = {}
      hash[:ss_ip] = CONFIG_APP[:leshi_server_ip]
      hash[:ss_port] = CONFIG_APP[:leshi_server_in_port]
      flow = FlowMedia.save_or_update({:user_id => self.id, :ss_key => User.mk_one_password(ext[:key]), :expire_time => 3600 })
      hash[:ss_key] = flow.ss_key
      hash[:key_duration] = flow.expire_time
      new_version = SoftVersion.find_new_version_by_ver(ver)
      if ver and new_version and new_version.is_a?(SoftVersion)
        hash[:newversion] = true
        hash[:url] = "http://#{ext[:host_with_port]}/welcome/download?soft=#{new_version.soft_name}&from=client&version=#{new_version.version}"
      else
        hash[:newversion] = false
      end
      hash
    end
  end

end

ActiveRecord::Base.send :include, Didaoduapi
