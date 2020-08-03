# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'column'

module Portable
  # Defines all the options for an export like columns, whether or not you want to include
  # headers, and more.
  class Export
    acts_as_hashable

    module Bom
      UTF8 = "\uFEFF"
    end
    include Bom

    attr_reader :bom, :columns, :include_headers

    alias include_headers? include_headers

    def initialize(bom: nil, columns: [], include_headers: true)
      @bom             = bom ? Bom.const_get(bom.to_s.upcase.to_sym) : nil
      @columns         = Column.array(columns)
      @include_headers = include_headers || false

      freeze
    end

    def headers
      columns.map(&:header)
    end
  end
end
