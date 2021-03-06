require 'active_record'
require 'activerecord-jdbc-adapter' if RUBY_PLATFORM == 'java'

module RareMap
  # RareMap::SchemaReader dumps database schema by using ActiveRecord::SchemaDumper.
  # @author Wei-Ming Wu
  module SchemaReader
    # Returns the content of schema.rb which is created by ActiveRecord::SchemaDumper.
    #
    # @return [String] the content of schema.rb which is created by ActiveRecord::SchemaDumper
    def read_schema(db_profile)
      conn = db_profile.connection.map { |k, v| v.kind_of?(Integer) ? "'#{k}'=>#{v}" : "'#{k}'=>'#{v}'" }.join(', ')
      schema = if RUBY_PLATFORM == 'java'
        %x[jruby -e "require 'active_record'; require 'activerecord-jdbc-adapter'; ActiveRecord::Base.establish_connection(#{conn}); ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection);" 2>&1]
      else
        %x[ruby -e "require 'active_record'; ActiveRecord::Base.establish_connection(#{conn}); ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection);" 2>&1]
      end
      detect_errors schema
      schema
=begin
      schema = StringIO.new
      ActiveRecord::Base.establish_connection db_profile.connection
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, schema)
      schema.close
      schema.string
=end
    end
    
    private
    
    def detect_errors(schema)
      if $? != 0
        puts schema
        schema = ''
      end
    end
  end
end