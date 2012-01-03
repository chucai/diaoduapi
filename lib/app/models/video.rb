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
      hash[:id] = self.id
      hash[:url] = self.url
      hash[:tid] =  self.tid
      hash[:header] = self.user.header
      hash[:rtmp_url] = "rtmp://#{CONFIG_APP[:leshi_server_ip]}/#{self.tid}&live=1"
      hash[:created] = self.created_at.to_s(:db)
      hash[:visited] = self.visited
      hash[:comments_count] = self.comments.count()
    else
      hash[:type] = "ARCHIVED"
      hash[:id] = self.id
      hash[:header] = self.user.header
      hash[:title] = self.title
      hash[:url] = self.url
      hash[:preview_url] = self.preview
      hash[:tid] = self.tid
      hash[:created] = self.created_at.to_s(:db)
      hash[:visited] = self.visited
      hash[:comments_count] = self.comments.count()
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

  def up_visited
    self.update_attribute(:visited, self.visited+1)
  end

  #begin convert_3gp_to_flv
  #convert 3gp to flv
  #@command : ffmpeg -i lib/176-1.3gp -ar 22050 lib/176-1.flv
  def convert_3gp_to_flv
    path = File.join("#{RAILS_ROOT}",CONFIG_APP[:leshi_server_dir])
    filename = "#{self.tid}.flv"
    ext_name = File.extname(filename)
    pure_name = File.basename(filename, ext_name)
    gp_file = "#{self.tid}.3gp"
    new_name = "#{pure_name}_tmp.flv"
    tmp_name = "#{pure_name}.flv"
    new_file_path = File.join(path, new_name)
    tmp_file_path = File.join(path, tmp_name)
    size = self.size || "176x144"
    #convert
    begin
      result_cmd = system("ffmpeg -i #{File.join(path,gp_file)} -ar 22050 #{new_file_path}")
      if result_cmd && File.exist?(new_file_path)
        self.update_attribute(:file_size, File.size?(new_file_path))
        if File.exist?(tmp_file_path)
          File.delete(tmp_file_path)
          File.rename(new_file_path, tmp_file_path)
        else
          File.rename(new_file_path, tmp_file_path)
        end
        #image
        jpg_path = File.join(path,"#{pure_name}.jpg")
        puts jpg_path
        puts "ffmpeg -i #{File.join(path,gp_file)} -y -f image2 -t 0.01 -s #{size} #{jpg_path}"
        unless File.exist?(jpg_path)
          puts "come here-------------------------------------------------"
          system("ffmpeg -i #{File.join(path,gp_file)} -y -f image2 -t 0.01 -s #{size} #{jpg_path}")
        end
      end
    rescue Exception => e
      Rails.logger.info(e)
    end
  end
  #end convert_3gp_to_flv

  def absolute_destroy?
    path = File.join(RAILS_ROOT,"public","video",self.tid)
    system("rm -rf #{path}.*")
    self.destroy
    return true
  end


end
