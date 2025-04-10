# frozen_string_literal: true

require "csv"
require "yaml"

module Sqlreport
  # Result
  class Result
    def initialize(query, db_config: false)
      @query = query
      @db_config = db_config
      @response = nil
    end

    def connection
      @connection ||= if @db_config
                        ActiveRecord::Base.establish_connection(@db_config)
                      else
                        ActiveRecord::Base.connection
                      end
    end

    def result(validate: true)
      connection
      validations = validate_input if validate
      return validations if validations

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

    private

    def validate_input
      return "DELETE, UPDATE, DROP, RENAME, ALTER cannot be used in queries" \
        if %w[DELETE UPDATE DROP RENAME ALTER].any? { |needle| @query.include? needle }

      false
    end
  end
end
