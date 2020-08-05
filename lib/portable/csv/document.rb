# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'options'

module Portable
  module Csv
    # Defines all the options for an export including static header rows, footer rows, and how
    # to draw the data table.
    class Document
      extend Forwardable
      acts_as_hashable

      attr_reader :data_table,
                  :footer_rows,
                  :header_rows,
                  :options

      def_delegators :data_table,
                     :columns,
                     :headers,
                     :include_headers?,
                     :headers,
                     :transform

      def_delegators :options,
                     :byte_order_mark,
                     :byte_order_mark?

      def initialize(data_table: {}, footer_rows: [], header_rows: [], options: {})
        @data_table  = Datagrid.make(data_table)
        @footer_rows = footer_rows || []
        @header_rows = header_rows || []
        @options = Options.make(options)

        freeze
      end
    end
  end
end
