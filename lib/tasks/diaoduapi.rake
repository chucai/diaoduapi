# desc "Explaining what the task does"
# task :diaoduapi do
#   # Task goes here
# end
#
namespace :db do
  desc "数据库备份任务，备份数据"
  task :backup => :environment do
	backup_folder = File.join(ENV['DIR'] || "db", "backup")
	FileUtils.mkdir_p(backup_folder)
	magic_date = (Date.parse(ENV["DATE"]) if ENV["DATE"]) || Time.now
	backup_file = File.join(backup_folder,"#{magic_date.strftime("%Y%m%d%H%M%S")}.sql")
	db_config = ActiveRecord::Base.configurations[RAILS_ENV]
	system "mysqldump -u #{db_config['username']} #{'-p' if db_config['password']}#{db_config['password']} --opt #{db_config['database']} > #{backup_file}"
  end

  desc "数据库恢复任务,useage: rake data:restore FILE=20120109043714.sql"
  task :restore => :environment do
	backup_folder = File.join(ENV["DIR"] || "db", 'backup')
    FileUtils.mkdir_p(backup_folder)
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
	bakfile = ENV['FILE']
	(Dir.new(backup_folder).entries - ['.', '..']).sort.reverse.each do |backup|
	    (bakfile = backup and break) if backup.starts_with?(RAILS_ENV)
	end unless bakfile
	raise 'could not find the backup file!' unless bakfile
	ActiveRecord::Base.establish_connection(RAILS_ENV)
	ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0')
    puts "rebuild database #{db_config['database']} from #{bakfile}"
	system "mysql -u #{db_config['username']} #{'-p' if db_config['password']}#{db_config['password']} #{db_config['database']} < #{backup_folder}/#{bakfile}"
  end

end
