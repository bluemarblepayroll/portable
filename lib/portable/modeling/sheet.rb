# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'data_table'

module Portable
  module Modeling
    # Abstract concept modeling for the notion of a "sheet" in a "document".  This means different
    # things given the writer.  For example, all writers should support multiple sheets but
    # there is no internal representation of a "sheet" within a CSV, so each sheet will emit
    # one file.
    class Sheet
      acts_as_hashable

      attr_reader :data_table,
                  :footer_rows,
                  :header_rows,
                  :name,
                  :include_headers

      def initialize(
        data_table: nil,
        footer_rows: [],
        header_rows: [],
        name: '',
        include_headers: true
      )
        @name            = name.to_s
        @data_table      = DataTable.make(data_table)
        @footer_rows     = footer_rows || []
        @header_rows     = header_rows || []
        @include_headers = include_headers || false

        freeze
      end

      def include_headers?
        include_headers
      end
    end
  end
end
