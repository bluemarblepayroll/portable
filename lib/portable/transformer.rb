# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'export'

module Portable
  # Internal intermediary class that knows how to combine columns specification instances with their
  # respective Realize pipelines.
  class Transformer # :nodoc: all
    attr_reader :column_pipelines

    def initialize(columns, resolver: Objectable.resolver)
      @column_pipelines = columns.each_with_object({}) do |column, memo|
        memo[column] = Realize::Pipeline.new(column.transformers, resolver: resolver)
      end

      freeze
    end

    def transform(object, time)
      column_pipelines.each_with_object({}) do |(column, pipeline), memo|
        memo[column.header] = pipeline.transform(object, time)
      end
    end
  end
end
