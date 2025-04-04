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

    def to_csv(include_headers: true, separator: ",", quote_char: '"')
      CSV.generate(col_sep: separator, quote_char: quote_char) do |csv|
        csv << @response.columns if include_headers
        @response.rows.each { |row| csv << row }
      end
    end

    def write_csv(path, include_headers: true, separator: ",", quote_char: '"')
      data = to_csv(include_headers: include_headers, separator: separator, quote_char: quote_char)
      File.write(path, data)
      true
    end
  end
end
