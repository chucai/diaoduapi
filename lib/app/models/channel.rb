class Channel < ActiveRecord::Base
validates_presence_of :token, :user_id
validates_uniqueness_of :token

belongs_to :user
belongs_to :video

named_scope :last, :order => "created_at DESC", :limit => 1
named_scope :living, :conditions => ["cstate = 'living'"]
named_scope :should_delete, :conditions => ["video_id IS NULL OR video_id = 0"]
named_scope :visited, :conditions => "cstate = 'visited'"
named_scope :created, :conditions => "cstate = 'created'"

def get_url
result = "http://#{CONFIG_APP[:web_server]}/#{self.token}"
result
end

# def video
#   if self.cstate == "living" or self.cstate == 'visited'
#     video = Living.find_by_id(self.video_id) if(self.video_id and self.video_id != 0)
#   else
#     video = Archive.find_by_id(self.video_id) if(self.video_id and self.video_id != 0)
#   end
#   video
# end

protected
def before_validation_on_create
self.token = Rufus::Mnemo::from_integer(rand(8**5))  if self.new_record? and self.token.nil?
end
end
