# frozen_string_literal: true

module Sqlreport
  # ActiveRecordExtension
  # Extends ActiveRecord::Relation with SQLReport functionality
  module ActiveRecordExtension
    # Provides SQLReport functionality to ActiveRecord models
    module RelationMethods
      # Convert the relation to a SQLReport result
      def sqlreport
        # Get the SQL query from the relation
        sql = to_sql

        # Create a SQLReport result from the query
        ::Sqlreport::Result.new(sql)
      end
    end

    # Provides batch processing functionality to ActiveRecord models
    module BatchMethods
      # Convert the relation to a SQLReport batch manager
      def sqlreport_batch(batch_size: 1000)
        # Get the SQL query from the relation
        sql = to_sql

        # Create a SQLReport batch manager from the query
        ::Sqlreport::BatchManager.new(sql, batch_size: batch_size)
      end
    end
  end
end

# Extend ActiveRecord::Relation with SQLReport functionality
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Relation.include(Sqlreport::ActiveRecordExtension::RelationMethods)
  ActiveRecord::Relation.include(Sqlreport::ActiveRecordExtension::BatchMethods)
end
