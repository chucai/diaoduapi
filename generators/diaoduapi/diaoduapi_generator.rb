class DiaoduapiGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "diaoduapi_create_tables"
    end
  end

end
