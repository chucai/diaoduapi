class Video < ActiveRecord::Base
  validates_presence_of :user_id, :encoding, :size, :tid, :server_url
  validates_uniqueness_of :tid

  belongs_to :user
  has_one :channel
  has_many :comments, :include => :user

  named_scope :recently_resource, :order => "created_at DESC"
  named_scope :living, :conditions => ["vstate = 'living'"]
  named_scope :archived, :conditions => ["vstate = 'archived'"]


  #should install geocoder, see: https://github.com/alexreisner/geocoder
  #geocoded_by :address, :latitude  => :lat, :longitude => :lng

  def vstate_value
    self.living? ? 1 : 0
  end

  def living?
    self.vstate == 'living'
  end

  def archived?
    self.vstate == 'archived'
  end

  #display data for client with hash to json
  def to_hash
    hash = Hash.new
    if self.living?
      hash[:type] = "LIVING"
      hash[:title] = self.title
      hash[:url] = self.url
      hash[:tid] =  self.tid
      hash[:header] = self.user.header
      hash[:rtmp_url] = "rtmp://#{CONFIG_APP[:leshi_server_ip]}/#{self.tid}&live=1"
    else
      hash[:type] = "ARCHIVED"
      hash[:id] = self.id
      hash[:header] = self.user.header
      hash[:title] = self.title
      hash[:url] = self.url
      hash[:preview_url] = self.preview
      hash[:tid] = self.tid
      hash[:rtmp_url] = "rtmp://#{CONFIG_APP[:leshi_server_ip]}/#{self.tid}&live=0"
    end
    hash
  end

  def change_living_to_archived
    self.update_attribute(:vstate, "archived")
  end

  def url
    "#{self.server_url}#{self.tid}.flv"
  end

  def preview
    "#{self.server_url}#{self.tid}.jpg"
  end

end
