#  #for client interface
#  map.connect "/api/register.:format", :namespace => "api", :controller => "client", :action => "register"
#  map.connect "/api/get_channel.:format", :namespace => "api", :controller => "client", :action => "create_channel"
#  map.connect "/api/destroy_channel.:format",  :namespace => "api", :controller => "client", :action => "destroy_channel"
#  map.connect "/api/channel_notice.:format",  :namespace => "api", :controller => "client", :action => "notice_channel"
#  map.connect "/api/change_password.:format",  :namespace => "api", :controller => "client", :action => "password"
#  #for server interface
#  map.connect "api/archived.:format",:namespace => "api", :controller => "server", :action => "save_archived"
#  map.connect "api/live.:format",:namespace => "api", :controller => "server", :action => "save_live"
#  map.connect "api/location.:format",:namespace => "api", :controller => "server", :action => "location"
#  map.connect "api/server_token.:format",:namespace => "api", :controller => "server", :action => "server_token"
#  map.connect "api/login.:format",:namespace => "api", :controller => "server", :action => "login"
module Diaoduapi #nodoc
  module Routing #nodoc
    module MapperExtensions
      def diaodu_routes
        @set.add_route("/api/register.:format",{:namespace => "api", :controller => "client", :action => "register"})
        @set.add_route("/api/get_channel.:format",{:namespace => "api", :controller => "client", :action => "create_channel"})
        @set.add_route("/api/destroy_channel.:format",{:namespace => "api", :controller => "client", :action => "destroy_channel"})
        @set.add_route("/api/channel_notice.:format",{:namespace => "api", :controller => "client", :action => "notice_channel"})
        @set.add_route("/api/change_password.:format",{:namespace => "api", :controller => "client", :action => "password"})

        @set.add_route("/api/archived.:format", {:namespace => "api", :controller => "server", :action => "save_archived"})
        @set.add_route("/api/live.:format", {:namespace => "api", :controller => "server", :action => "save_live"})
        @set.add_route("/api/location.:format", {:namespace => "api", :controller => "server", :action => "location"})
        @set.add_route("/api/server_token.:format", {:namespace => "api", :controller => "server", :action => "server_token"})
        @set.add_route("/api/login.:format", {:namespace => "api", :controller => "server", :action => "login"})
      end
    end
  end
end

ActionController::Routing::RouteSet::Mapper.send :include, Diaoduapi::Routing::MapperExtensions
