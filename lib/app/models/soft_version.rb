class SoftVersion < ActiveRecord::Base
  validates_inclusion_of :soft, :in => %w(a s o), :message => "软件操作系统选择错误"

  #should be has one assoution
  belongs_to :upgrade, :class_name => "SoftVersion", :foreign_key => :upgrade_to

  def soft_name
    case self.soft.to_s
    when "a"
      "android"
    when "s"
      "symbian"
    when "i"
      "iphone"
    else
      "web"
    end
  end


  class << self
    def find_new_version_by_ver(ver)
      if (ver =~ /^(a|s|i)(\d{4})(\d*)$/) == 0
        old_version = SoftVersion.find :first, :conditions => {:soft => $1, :company => $2, :version => $3}
        return old_version.nil?  ? nil : old_version.upgrade
      else
        logger.error("#{ver}")
        return {:reason => "您输入的参数有误"}
      end
    end

    def find_for_download(name)
      SoftVersion.find_by_version(name) || SoftVersion.find(:first, :conditions => ["soft = ?", soft_names(name) ],:order => "id DESC")
    end

    private
    def soft_names(name)
      hash = {
       :android => "a",
       :symbian => "s",
       :iphone => "0"
      }
      hash[name.to_sym]
    end
  end
  
end
