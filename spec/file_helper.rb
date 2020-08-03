# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'ostruct'
require 'yaml'

def read_snapshots
  Dir[File.join(snapshot_path, '*')].map do |path|
    name = File.basename(path)

    OpenStruct.new(
      expected: read_snapshot_file(name, 'expected.csv'),
      export: read_snapshot_yaml_file(name, 'export.yaml'),
      records: read_snapshot_yaml_file(name, 'records.yaml'),
      name: name,
      path: path
    )
  end
end

def read_snapshot_yaml_file(*filename)
  read_yaml_file(snapshot_path, *filename)
end

def read_snapshot_file(*filename)
  read_file(snapshot_path, *filename)
end

def snapshot_path
  File.join('spec', 'fixtures', 'snapshots')
end

def read_yaml_file(*filename)
  YAML.safe_load(read_file(*filename))
end

def read_file(*filename)
  File.open(File.join(*filename), 'r:bom|utf-8').read
end
