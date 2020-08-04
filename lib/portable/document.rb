# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module Portable
  # Base document object model defining what all documents should include.
  class Document
    acts_as_hashable
    extend Forwardable

    attr_reader :data_table,
                :footer_rows,
                :header_rows

    def_delegators :data_table,
                   :columns,
                   :headers,
                   :include_headers?,
                   :headers,
                   :transform

    def initialize(data_table: {}, footer_rows: [], header_rows: [])
      @data_table  = Datagrid.make(data_table)
      @footer_rows = footer_rows || []
      @header_rows = header_rows || []

      freeze
    end
  end
end
