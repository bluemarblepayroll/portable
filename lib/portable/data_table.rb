# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'column'

module Portable
  # Defines all the options for the data grid within an export like columns, whether or not
  # you want to include headers, and more.
  class Datagrid
    acts_as_hashable

    attr_reader :columns

    def initialize(columns: [], include_headers: true)
      @columns         = Column.array(columns)
      @include_headers = include_headers || false

      freeze
    end

    def include_headers?
      include_headers
    end

    def headers
      columns.map(&:header)
    end

    private

    attr_reader :include_headers
  end
end
