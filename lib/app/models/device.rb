class Device < ActiveRecord::Base
  validates_presence_of :device, :rom_id, :encode_mode
  validates_uniqueness_of :device, :scope => :rom_id
  validates_inclusion_of :encode_mode, :in => [0,1]
end
