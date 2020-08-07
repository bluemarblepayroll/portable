# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'row'

module Portable
  module Rendering
    # Understands the connection between a document's sheets and the internal row renderer
    # necessary to render each sheet's data table.
    class Sheet # :nodoc: all
      attr_reader :document, :resolver

      def initialize(document, resolver: Objectable.resolver)
        @document = Document.make(document, nullable: false)
        @resolver = resolver

        @row_renderers = @document.sheets.each_with_object({}) do |sheet, memo|
          next unless sheet.data_table

          memo[sheet.name] = Row.new(sheet.data_table.columns, resolver: resolver)
        end

        freeze
      end

      def row_renderer(sheet_name, fields)
        row_renderers.fetch(sheet_name, dynamic_row_renderer(fields))
      end

      private

      attr_reader :row_renderers

      def dynamic_row_renderer(fields)
        fields  = (fields || []).map { |f| { header: f.to_s } }
        columns = Modeling::Column.array(fields)

        Row.new(columns, resolver: resolver)
      end
    end
  end
end
