# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require_relative 'source'

module Portable
  module Data
    # Container of data sources that is inputted into a writer alongside a document.
    # It contains all the data sources the writer will use to render a document.
    class Provider
      include Uniqueness
      acts_as_hashable

      DEFAULT_NAME = ''

      def initialize(data_sources: [])
        sources               = Source.array(data_sources)
        @data_sources_by_name = pivot_by_name(sources)

        assert_no_duplicate_names(sources)

        freeze
      end

      # Use exact name if possible, if not then use the "default" one (noted by a blank name).
      # Fail hard if we cannot identify which data source to use.  This should help prevent
      # possible configuration issues (i.e. typos.)
      def data_source(name)
        data_sources_by_name[name.to_s] ||
          data_sources_by_name[DEFAULT_NAME] ||
          raise(ArgumentError, "data source: '#{name}' cannot be found.")
      end

      private

      attr_reader :data_sources_by_name

      def pivot_by_name(data_sources)
        data_sources.each_with_object({}) do |data_source, memo|
          memo[data_source.name] = data_source
        end
      end
    end
  end
end
