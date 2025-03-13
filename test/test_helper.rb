# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "active_record"
require "active_record/fixtures"
require "active_support/test_case"
require "active_support/testing/autorun"
require "rake"
require "logger"
require "fileutils"

ENV["RAILS_ENV"] = "test"

FileUtils.mkdir_p "log"
ActiveRecord::Base.logger = Logger.new("log/test.log")
ActiveRecord::Base.logger.level = Logger::DEBUG

if ActiveRecord.respond_to?(:use_yaml_unsafe_load)
  ActiveRecord.use_yaml_unsafe_load = true
elsif ActiveRecord::Base.respond_to?(:use_yaml_unsafe_load)
  ActiveRecord::Base.use_yaml_unsafe_load = true
end

if ActiveRecord.respond_to?(:default_timezone)
  ActiveRecord.default_timezone = :utc
else
  ActiveRecord::Base.default_timezone = :utc
end

CONNECTION_PARAMS = {
  adapter: "sqlite3",
  database: "sqlreport_test"
}.freeze

require "sqlreport"

ActiveRecord::Base.establish_connection(
  CONNECTION_PARAMS
)

connection = ActiveRecord::Base.connection
connection.execute("DROP TABLE IF EXISTS test_table;")
connection.create_table(:test_table, force: true) do |t|
  t.column :user_id, :integer
  t.column :name, :string
  t.column :json_object, :json
end

10.times do
  connection.execute("INSERT INTO test_table (user_id, name) VALUES (1, 'test name');")
end

require "minitest/autorun"
