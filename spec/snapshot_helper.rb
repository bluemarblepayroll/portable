# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'file_helper'

class Snapshot
  DOCUMENT_FILENAME      = 'document.yaml'
  DATA_PROVIDER_FILENAME = 'data_provider.yaml'

  attr_reader :expected,
              :document,
              :data_provider,
              :name,
              :path

  def initialize(path, writer_type)
    @path          = path
    @name          = File.basename(path)
    @expected      = read_expected_files(writer_type)
    @document      = read_document
    @data_provider = Portable::Data::Provider.make(read_data_provider)

    freeze
  end

  private

  def read_document
    read_yaml_file(path, DOCUMENT_FILENAME)
  end

  def read_data_provider
    read_yaml_file(path, DATA_PROVIDER_FILENAME)
  end

  def read_expected_files(writer_type)
    expected_files_path = File.join(*path, writer_type, '*')

    Dir[expected_files_path].each_with_object({}) do |filename, memo|
      expected_filename = File.basename(filename)

      memo[expected_filename] = read_file(*filename)
    end
  end

  def read_snapshot_yaml_file(*filename)
    read_yaml_file(SNAPSHOT_PATH, *filename)
  end
end

def snapshots
  snapshot_paths.map { |path| Snapshot.new(path, 'csv') }
end

def snapshot_paths
  Dir[File.join('spec', 'fixtures', 'snapshots', '*')]
end
