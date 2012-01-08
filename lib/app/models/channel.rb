class Channel < ActiveRecord::Base
  validates_presence_of :token, :user_id
  validates_uniqueness_of :token
  validates_inclusion_of :cstate, :in => %w(living created archived destroy)
  belongs_to :user
  belongs_to :video

  named_scope :last, :order => "created_at DESC", :limit => 1
  named_scope :living, :conditions => ["cstate = 'living'"]
  named_scope :should_delete, :conditions => ["cstate = 'created'"]
#  named_scope :visited, :conditions => "cstate = 'visited'"
  named_scope :created, :conditions => "cstate = 'created'"

  def get_url
    result = "http://#{CONFIG_APP[:web_server]}/#{self.token}"
    result
  end

  #Publish message to apple or android client
  def publish
    self.push_message_to_client
    update_attribute(:number, self.number+1)
  end

  def push_message_to_client
    BroadCast.push_message_to_apple(self.user.apple_token,
      I18n.t("application.apple.visited_success")) if self.can_push_message?
  end

  def can_push_message?
    self.user.is_apple_client? && self.number == 0 && self.cstate != 'destroy'
  end

  def up_visited
    self.update_attribute(:visited, self.visited+1) if self.video_id != 0 && self.video_id != nil
  end

  def access?
    #self.visited <= CONFIG_APP[:channel_limit_visited].to_i && self.cstate != 'destroy'
    self.visited <= CONFIG_APP[:channel_limit_visited].to_i
  end

  def destroy_channel
    self.update_attribute(:cstate, "destroy") if self.cstate == 'created'
  end

  def cstate_value_for_client
    (self.number != 0 && self.cstate != 'destroy') ? "visited" : "novisited"
  end

  protected
  def before_validation_on_create
    #self.token = Rufus::Mnemo::from_integer(rand(8**5))  if self.new_record? and self.token.nil?
    self.token = rand(36**6).to_s(36)  if self.new_record? and self.token.nil?
  end
end
