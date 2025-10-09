# frozen_string_literal: true

module Sqlreport
  # BatchManager
  # Handles batch processing of SQL queries for large datasets
  class BatchManager
    attr_reader :total_rows, :processed_rows, :batch_size, :current_offset

    def initialize(query, batch_size: 1000, db_config: false)
      @query = query
      @batch_size = batch_size
      @db_config = db_config
      @total_rows = nil
      @processed_rows = 0
      @current_offset = 0
      @complete = false
    end

    def connection
      @connection ||= if @db_config
                        ActiveRecord::Base.establish_connection(@db_config)
                      else
                        ActiveRecord::Base.connection
                      end
    end

    def count_total_rows
      return @total_rows if @total_rows

      # Extract the FROM clause and any WHERE conditions to count total rows
      from_clause = @query.match(/FROM\s+([^\s;]+)(\s+WHERE\s+(.+?))?(\s+ORDER BY|\s+GROUP BY|\s+LIMIT|\s*;|\s*$)/i)
      return nil unless from_clause

      table = from_clause[1]
      where_clause = from_clause[3]

      count_query = "SELECT COUNT(*) FROM #{table}"
      count_query += " WHERE #{where_clause}" if where_clause

      result = connection.exec_query(count_query)
      @total_rows = result.rows.first.first.to_i
    end

    # rubocop:disable Metrics/MethodLength
    def next_batch
      return nil if @complete

      # Add LIMIT and OFFSET to the query
      paginated_query = if @query.include?("LIMIT")
                          # If query already has LIMIT, we need to handle differently
                          raise "Batch processing not supported for queries with LIMIT clause"
                        else
                          "#{@query.chomp(";")} LIMIT #{@batch_size} OFFSET #{@current_offset}"
                        end

      result = Sqlreport::Result.new(paginated_query, db_config: @db_config).result

      # Update state
      rows_in_batch = result.rows.count
      @processed_rows += rows_in_batch
      @current_offset += @batch_size
      @complete = rows_in_batch < @batch_size

      result
    end
    # rubocop:enable Metrics/MethodLength

    def process_all
      results = []
      while (batch = next_batch)
        results << batch
        yield batch if block_given?
      end
      results
    end

    # rubocop:disable Metrics/MethodLength
    def stream_to_csv(path, include_headers: true, separator: ",", quote_char: '"')
      first_batch = true

      File.open(path, "w") do |file|
        process_all do |batch|
          if first_batch && include_headers
            headers = batch.columns.join(separator)
            file.puts headers
            first_batch = false
          elsif first_batch
            first_batch = false
          end

          # Write rows without loading all into memory
          batch.rows.each do |row|
            csv_row = CSV.generate_line(row, col_sep: separator, quote_char: quote_char)
            file.write(csv_row)
          end
        end
      end

      true
    end
    # rubocop:enable Metrics/MethodLength

    def progress_percentage
      return 0 unless @total_rows && @total_rows.positive?

      (@processed_rows.to_f / @total_rows * 100).round(2)
    end
  end
end
