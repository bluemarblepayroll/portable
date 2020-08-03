# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'export'
require_relative 'transformer'

module Portable
  # Main API for writing files.  There are two main patterns to choose from:
  #   1. calling #open, #write, and #close manually.
  #   2. calling #open and passing a block and having #close automatically called.
  class Writer
    class AlreadyOpenError < StandardError; end
    class NotOpenError < StandardError; end

    attr_reader :csv, :export, :transformer

    def initialize(export, resolver: Objectable.resolver)
      @export      = Export.make(export, nullable: false)
      @transformer = Transformer.new(@export.columns, resolver: resolver)
    end

    def open?
      !csv.nil?
    end

    # Will raise a AlreadyOpenError exception if a writer has already been opened but
    # not yet closed.
    def open(filename)
      raise AlreadyOpenError, 'writer is already open' if open?

      initialize_csv(filename)

      if block_given?
        yield self
        close
      end

      self
    end

    # Will raise a NotOpenError exception if a writer has not yet been opened.
    def write(object: {}, time: Time.now.utc)
      raise NotOpenError, 'writer is not open' unless open?

      csv << transformer.transform(object, time).values

      self
    end

    # Will raise a NotOpenError exception if a writer has not yet been opened.
    def close
      raise NotOpenError, 'writer is not open' unless open?

      @csv.close
      @csv = nil
      self
    end

    private

    def ensure_directory_exists(filename)
      path = File.dirname(filename)

      FileUtils.mkdir_p(path) unless File.exist?(path)
    end

    def initialize_csv(filename)
      ensure_directory_exists(filename)

      @csv = CSV.open(filename, 'w')

      csv.to_io.write(export.bom) if export.bom
      csv << export.headers       if export.include_headers?
    end
  end
end
