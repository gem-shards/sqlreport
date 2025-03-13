# frozen_string_literal: true

require "active_record"

# SQLreport
module Sqlreport
  def self.query(sql_query)
    ::Sqlreport::Result.new(sql_query)
  end
end
