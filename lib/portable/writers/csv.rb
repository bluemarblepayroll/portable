# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'base'

module Portable
  module Writers
    # Can write documents to a CSV file.
    class Csv < Base
      def write!(filename:, data_provider: Data::Provider.new, time: Time.now.utc)
        raise ArgumentError, 'filename is required' if filename.to_s.empty?

        ensure_directory_exists(filename)

        sheet_filenames = extrapolate_filenames(filename)

        document.sheets.each do |sheet|
          data_source    = data_provider.data_source(sheet.name)
          sheet_filename = sheet_filenames[sheet.name]

          write_sheet(sheet_filename, sheet, data_source, time)
        end

        sheet_filenames.values
      end

      private

      def write_sheet(sheet_filename, sheet, data_source, time)
        row_renderer = sheet_renderer.row_renderer(sheet.name, data_source.fields)

        CSV.open(sheet_filename, 'w') do |csv|
          csv.to_io.write(document.options.byte_order_mark) if document.options.byte_order_mark?

          write_head(csv, sheet, data_source)
          write_data_table(csv, sheet, data_source, row_renderer, time)
          write_foot(csv, sheet, data_source)
        end
      end

      def write_head(csv, sheet, data_source)
        sheet.header_rows.each { |row| csv << row }

        data_source.header_rows.each { |row| csv << row }
      end

      def write_data_table(csv, sheet, data_source, row_renderer, time)
        csv << row_renderer.headers if sheet.include_headers?

        data_source.data_rows.each do |row|
          csv << row_renderer.render(row, time).values
        end
      end

      def write_foot(csv, sheet, data_source)
        data_source.footer_rows.each { |row| csv << row }

        sheet.footer_rows.each { |row| csv << row }
      end

      def ensure_directory_exists(filename)
        path = File.dirname(filename)

        FileUtils.mkdir_p(path) unless File.exist?(path)
      end

      def extrapolate_filenames(filename)
        index    = 0
        dir      = File.dirname(filename)
        ext      = File.extname(filename)
        basename = File.basename(filename, ext)

        document.sheets.each_with_object({}) do |sheet, memo|
          memo[sheet.name] =
            if index.positive?
              File.join(dir, "#{basename}.#{index}#{ext}")
            else
              filename
            end

          index += 1
        end
      end
    end
  end
end
