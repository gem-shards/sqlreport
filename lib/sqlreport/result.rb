# frozen_string_literal: true

require "csv"

module Sqlreport
  # Result
  class Result
    def initialize(query)
      @query = query
      @connection = ActiveRecord::Base.connection
      @response = nil
    end

    def result
      @response = @connection.exec_query(@query)
      self
    end

    def columns
      @response.columns
    end

    def rows
      @response.rows
    end

    def to_csv(include_headers: true)
      CSV.generate do |csv|
        csv << @response.columns if include_headers
        @response.rows.each { |row| csv << row }
      end
    end
  end
end
