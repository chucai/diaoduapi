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

  #Publish message to apple or android client
  def publish
    if self.number == 0
      update_attributes({
        :number => 1,
	    :cstate => "visited"
      })
      self.push_message_to_client
    end
  end

  def push_message_to_client
    BroadCast.push_message_to_apple(self.user.apple_token,
      I18n.t("application.apple.visited_success")) if self.user.is_apple_client?
  end

  protected
  def before_validation_on_create
    #self.token = Rufus::Mnemo::from_integer(rand(8**5))  if self.new_record? and self.token.nil?
    self.token = rand(36**6).to_s(36)  if self.new_record? and self.token.nil?
  end
end
