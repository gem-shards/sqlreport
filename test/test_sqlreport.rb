# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "test_helper"
require "sqlreport"

# Mock ActiveRecord::Relation for testing
class MockRelation
  def to_sql
    "SELECT * FROM test_table"
  end
end

# Mock DatabaseConnector for testing
class MockDatabaseConnector
  def query(sql_query)
    ::Sqlreport::Result.new(sql_query)
  end
end

class TestSqlreport < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Sqlreport::VERSION
  end

  def test_can_it_retrieve_columns
    result = ::Sqlreport.query("SELECT * FROM test_table").result
    assert_equal %w[id user_id name json_object], result.columns
  end

  def test_can_it_retrieve_rows
    result = ::Sqlreport.query("SELECT * FROM test_table").result
    assert_equal 10, result.rows.count
  end

  def test_can_it_generate_csv
    result = ::Sqlreport.query("SELECT * FROM test_table").result
    assert result.to_csv.index("id,user_id,name,json_object")
  end

  def test_can_it_write_csv
    result = ::Sqlreport.query("SELECT * FROM test_table").result
    assert result.write_csv("test_table.csv")
    assert File.file?("test_table.csv")
    FileUtils.rm("test_table.csv")
  end

  def test_validations_on_query
    result = ::Sqlreport.query("DROP TABLE test_table").result
    assert result.is_a?(String)
  end

  # Batch processing tests
  def test_batch_query_creation
    batch_manager = ::Sqlreport.batch_query("SELECT * FROM test_table")
    assert_instance_of ::Sqlreport::BatchManager, batch_manager
  end

  def test_batch_query_with_custom_size
    batch_manager = ::Sqlreport.batch_query("SELECT * FROM test_table", batch_size: 5)
    assert_equal 5, batch_manager.batch_size
  end

  def test_batch_next_batch
    batch_manager = ::Sqlreport.batch_query("SELECT * FROM test_table", batch_size: 5)
    batch = batch_manager.next_batch
    assert_instance_of ::Sqlreport::Result, batch
    assert_equal 5, batch.rows.count
  end

  def test_batch_process_all
    batch_manager = ::Sqlreport.batch_query("SELECT * FROM test_table", batch_size: 5)
    results = batch_manager.process_all
    assert_equal 3, results.size # 10 rows total, 5 per batch = 2 full batches + 1 empty batch
    assert_equal 10, batch_manager.processed_rows
  end

  def test_batch_stream_to_csv
    batch_manager = ::Sqlreport.batch_query("SELECT * FROM test_table", batch_size: 5)
    assert batch_manager.stream_to_csv("batch_test_table.csv")
    assert File.file?("batch_test_table.csv")

    # Verify file content
    content = File.read("batch_test_table.csv")
    assert content.include?("id,user_id,name,json_object")

    # Clean up
    FileUtils.rm("batch_test_table.csv")
  end

  # rubocop:disable Metrics/MethodLength
  def test_batch_progress_tracking
    # Create a mock batch manager that returns a fixed total_rows value
    batch_manager = ::Sqlreport.batch_query("SELECT * FROM test_table", batch_size: 3)

    # Mock the count_total_rows method to return 5
    def batch_manager.count_total_rows
      @total_rows = 5
      5
    end

    batch_manager.count_total_rows
    assert_equal 5, batch_manager.total_rows

    batch_manager.next_batch
    assert_equal 3, batch_manager.processed_rows
    assert_equal 60.0, batch_manager.progress_percentage

    batch_manager.next_batch
    assert_equal 6, batch_manager.processed_rows
    assert_equal 120.0, batch_manager.progress_percentage
  end
  # rubocop:enable Metrics/MethodLength

  # ActiveRecord extension tests
  def test_activerecord_extension_sqlreport
    # Include the extension in our mock class
    MockRelation.include(Sqlreport::ActiveRecordExtension::RelationMethods)

    # Create a mock relation
    relation = MockRelation.new

    # Test the sqlreport method
    result = relation.sqlreport.result
    assert_instance_of Sqlreport::Result, result
    assert_equal 10, result.rows.count
  end

  def test_activerecord_extension_sqlreport_batch
    # Include the extension in our mock class
    MockRelation.include(Sqlreport::ActiveRecordExtension::BatchMethods)

    # Create a mock relation
    relation = MockRelation.new

    # Test the sqlreport_batch method
    batch_manager = relation.sqlreport_batch(batch_size: 5)
    assert_instance_of Sqlreport::BatchManager, batch_manager

    # Test that the batch manager works correctly
    batch = batch_manager.next_batch
    assert_equal 5, batch.rows.count
  end

  def test_activerecord_extension_write_csv
    # Include the extension in our mock class
    MockRelation.include(Sqlreport::ActiveRecordExtension::RelationMethods)

    # Create a mock relation
    relation = MockRelation.new

    # Test the write_csv method
    assert relation.sqlreport.result.write_csv("ar_test_table.csv")
    assert File.file?("ar_test_table.csv")

    # Clean up
    FileUtils.rm("ar_test_table.csv")
  end
end
