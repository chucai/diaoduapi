desc '生成启动脚本'
task :create_start_sh do
  CONFIG_APP = YAML.load_file(File.join(RAILS_ROOT,"config", "app_config.yml"))[RAILS_ENV]
  opera_cmd = "./lib/leshi-daemon -d #{CONFIG_APP[:leshi_server_dir]} -u #{CONFIG_APP[:leshi_server_url]} -f #{CONFIG_APP[:leshi_server_format]} -n #{CONFIG_APP[:leshi_server_ip]} -i #{CONFIG_APP[:leshi_server_in_port]} -o #{CONFIG_APP[:leshi_server_out_port]} -l leshi_dameo.log -w http://#{CONFIG_APP[:web_server]}/api"
  faye_cmd = "rackup faye.ru -s thin -E production"

  File.open(File.join(RAILS_ROOT,"start.sh"),"w") do |f|
    f.write("nohup "+opera_cmd+" & \n")
    f.write("nohup " + faye_cmd + " & \n")
  end

  puts "请运行./start.sh启动leshi-dameo服务器,faye服务器"
end
