# frozen_string_literal: true

require "active_record"

# SQLreport
module Sqlreport
  def self.query(sql_query)
    ::Sqlreport::Result.new(sql_query)
  end

  def self.batch_query(sql_query, batch_size: 1000)
    ::Sqlreport::BatchManager.new(sql_query, batch_size: batch_size)
  end

  def self.database(db_config)
    # Return a DatabaseConnector instance
    DatabaseConnector.new(db_config)
  end

  # DatabaseConnector
  # Handles database connection switching
  class DatabaseConnector
    def initialize(db_config)
      @db_config = db_config
    end

    def query(sql_query)
      ::Sqlreport::Result.new(sql_query, db_config: @db_config)
    end

    def batch_query(sql_query, batch_size: 1000)
      ::Sqlreport::BatchManager.new(sql_query, batch_size: batch_size, db_config: @db_config)
    end
  end
end
