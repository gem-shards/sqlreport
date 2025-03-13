# frozen_string_literal: true

require_relative "sqlreport/version"
require "active_support/lazy_load_hooks"

ActiveSupport.on_load(:active_record) do
  require "sqlreport/base"
  require "sqlreport/result"
end
