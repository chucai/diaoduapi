class DiaoduapiCreateTables < ActiveRecord::Migration
  def self.up
    create_table "videos", :force => true do |t|
      t.integer  "user_id"
      t.string   "title"
      t.string   "size"
      t.integer  "length"
      t.string   "encoding"
      t.string   "tid"
      t.integer  "private",    :default => 0
      t.integer  "visited",    :default => 1
      t.string   "vstate",     :default => "living"
      t.float    "lat",        :default => 0.0
      t.float    "lng",        :default => 0.0
      t.string   "server_url",                       :null => false
      t.float    "file_size",  :default => 0.0
      t.timestamps
    end
    create_table "soft_versions", :force => true do |t|
      t.string   "soft",       :limit => 4,  :default => "a"
      t.integer  "version",                  :default => 0
      t.string   "company",    :limit => 4,  :default => "0000"
      t.string   "filename",   :limit => 50
      t.integer  "upgrade_to"
      t.integer  "dtimes",                   :default => 0
      t.timestamps
    end
    create_table "flow_medias", :force => true do |t|
      t.integer  "user_id"
      t.string   "ss_key"
      t.integer  "expire_time"
      t.integer  "up_times"
      t.timestamps
    end
    create_table "channels", :force => true do |t|
      t.integer  "user_id"
      t.string   "token",                                           :null => false
      t.string   "cstate",     :limit => 20, :default => "created"
      t.integer  "number",                   :default => 0
      t.integer  "video_id"
      t.integer  "visited",                  :default => 1
      t.string   "mobile"
      t.string   "email"
      t.timestamps
    end

    create_table "devices", :force => true do |t|
      t.string   "device"
      t.string   "rom_id"
      t.string   "client",      :default => "ANDROID"
      t.integer  "encode_mode", :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "devices", ["device", "rom_id"], :name => "index_devices_on_device_and_rom_id", :unique => true
  end

  def self.down
    drop_table :channels
    drop_table :flow_medias
    drop_table :soft_versions
    drop_table :videos
    drop_table :devices
  end
end
