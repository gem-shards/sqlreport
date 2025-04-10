#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "sqlreport"
require "active_record"

# Set up a test database
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Create a test table
ActiveRecord::Base.connection.create_table(:test_table, force: true) do |t|
  t.column :user_id, :integer
  t.column :name, :string
  t.column :json_object, :json
end

# Insert test data
10.times do |i|
  ActiveRecord::Base.connection.execute("INSERT INTO test_table (user_id, name) VALUES (#{i}, 'test name #{i}');")
end

# Create a model for the test table
class TestTable < ActiveRecord::Base
  self.table_name = "test_table" # Use the singular table name
end

puts "=== Basic Query ==="
result = Sqlreport.query("SELECT * FROM test_table").result
puts "Columns: #{result.columns.join(", ")}"
puts "Rows: #{result.rows.count}"
puts "CSV: #{result.to_csv.lines.first}"

puts "\n=== Batch Query ==="
batch_manager = Sqlreport.batch_query("SELECT * FROM test_table", batch_size: 3)
batch_manager.count_total_rows
puts "Total rows: #{batch_manager.total_rows}"

batch = batch_manager.next_batch
puts "First batch rows: #{batch.rows.count}"
puts "Processed rows: #{batch_manager.processed_rows}"
puts "Progress: #{batch_manager.progress_percentage}%"

batch = batch_manager.next_batch
puts "Second batch rows: #{batch.rows.count}"
puts "Processed rows: #{batch_manager.processed_rows}"
puts "Progress: #{batch_manager.progress_percentage}%"

puts "\n=== ActiveRecord Integration ==="
# The extensions are automatically included in ActiveRecord::Relation
# by the ActiveSupport.on_load(:active_record) hook

# Test the sqlreport method
result = TestTable.where(user_id: 1..5).sqlreport.result
puts "ActiveRecord query rows: #{result.rows.count}"

# Test the sqlreport_batch method
batch_manager = TestTable.where(user_id: 1..5).sqlreport_batch(batch_size: 2)
batch = batch_manager.next_batch
puts "ActiveRecord batch rows: #{batch.rows.count}"
puts "Processed rows: #{batch_manager.processed_rows}"

puts "\n=== CSV Export ==="
# Write to CSV
csv_file = "test_table.csv"
result.write_csv(csv_file)
puts "CSV file created: #{File.exist?(csv_file)}"
puts "CSV content: #{File.read(csv_file).lines.first}"
FileUtils.rm_f(csv_file)

# Stream to CSV
batch_csv_file = "batch_test_table.csv"
batch_manager = TestTable.where(user_id: 1..5).sqlreport_batch(batch_size: 3)
batch_manager.stream_to_csv(batch_csv_file)
puts "Batch CSV file created: #{File.exist?(batch_csv_file)}"
puts "Batch CSV content: #{File.read(batch_csv_file).lines.first}"
FileUtils.rm_f(batch_csv_file)

puts "\nAll examples completed successfully!"
