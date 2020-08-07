# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'modeling/options'
require_relative 'modeling/sheet'

module Portable
  # Top-level object model for a renderable document.
  class Document
    acts_as_hashable

    attr_reader :sheets, :options

    def initialize(sheets: [], options: {})
      @sheets = Modeling::Sheet.array(sheets)
      @sheets << Modeling::Sheet.new if @sheets.empty?
      @options = Modeling::Options.make(options)

      freeze
    end
  end
end
