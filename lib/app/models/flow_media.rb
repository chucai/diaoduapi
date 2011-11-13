class FlowMedia < ActiveRecord::Base
  validates_presence_of :user_id, :ss_key

  def before_update
    self.up_times = (self.up_times || 0) + 1
  end
  class << self
    def save_or_update(args)
      if args.kind_of?Hash
        model = FlowMedia.find :first, :conditions => {:user_id => args[:user_id]}
        if model and (model.expire_time+model.updated_at.to_i < Time.now.to_i+100)
          model.update_attributes!(args)
        elsif model.nil?
          model = FlowMedia.create(args)
        end
        return model
      else
        raise "args should will be hash"
      end
    end
  end

end
