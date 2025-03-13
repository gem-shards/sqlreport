# frozen_string_literal: true

require "test_helper"

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
end
