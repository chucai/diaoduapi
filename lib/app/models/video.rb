class Video < ActiveRecord::Base
  validates_presence_of :user_id, :encoding, :size, :tid, :server_url 
  validates_uniqueness_of :tid

  belongs_to :user

  named_scope :recently_resource, :order => "created_at DESC"
  named_scope :living, :conditions => ["vstate = 'living'"]
  named_scope :archived, :conditions => ["vstate = 'archived'"]


  def living?
    return self.vstate == 'living'
  end

  def archived?
   return self.vstate == 'archived'
  end

  #display data for client with hash to json 
  def to_hash
    hash = Hash.new
    if self.living?
      hash[:type] = "LIVE"
      hash[:title] = params[:title]
      hash[:url] = "http://"+CONFIG_APP[:leshi_server_ip] + ":" + CONFIG_APP[:leshi_server_out_port].to_s  + "/" + params[:url]
      hash[:tid] =  params[:id]
      hash[:header] = user.header
      hash[:privacy] = living.private
    else
      hash[:type] = "ARCHIVED"
      hash[:id] = self.id
      hash[:title] = self.title
      hash[:url] = self.preview
      hash[:created] =  Time.at(self.created.to_i).strftime("%Y年%m月%d日 %H:%M:%S")
      hash[:tid] = self.tid
      hash[:privacy] = self.private
    end
    hash
  end

  def change_living_to_archived 
    self.update_attribute(:vstate, "archived")  
  end
 
end
