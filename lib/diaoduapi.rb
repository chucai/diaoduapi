require 'diaoduapi/array_ext'
require 'diaoduapi/route'
require 'diaoduapi/acts_as_flow'

%w{ controllers models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end
