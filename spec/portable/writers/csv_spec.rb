# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'snapshot_helper'
require 'spec_helper'

describe Portable::Writers::Csv do
  let(:filename) { File.join('tmp', "#{SecureRandom.uuid}.csv") }
  let(:document) { nil }
  let(:resolver) { Objectable.resolver(separator: '') }
  let(:time)     { Time.now.utc }

  subject { described_class.new(document, resolver: resolver) }

  context 'csv provider' do
    describe 'snapshots' do
      snapshots.each do |snapshot|
        let(:document) { snapshot.document }

        specify snapshot.name do
          actual_filenames = subject.write!(
            filename: filename,
            data_provider: snapshot.data_provider,
            time: time
          )

          actual_files   = actual_filenames.map { |f| read_file(f) }
          expected_files = snapshot.expected.values

          expect(actual_files).to eq(expected_files)

          actual_filenames.each { |f| FileUtils.rm(f, force: true) }
        end
      end
    end
  end

  context 'README examples' do
    let(:patients) do
      [
        { first: 'Marky', last: 'Mark', dob: '2000-04-05' },
        { first: 'Frank', last: 'Rizzo', dob: '1930-09-22' }
      ]
    end

    let(:fields) { %i[first last dob] }

    let(:data_provider) do
      Portable::Data::Provider.new(
        data_sources: {
          data_rows: patients,
          fields: fields
        }
      )
    end

    describe 'Getting Started Writing CSV Files' do
      let(:document) { nil }

      it 'renders' do
        writer  = Portable::Writers::Csv.new(document)
        written = writer.write!(filename: filename, data_provider: data_provider)

        expect(written).to eq([filename])

        actual_files = written.map { |f| read_file(f) }

        expected_files = [
          <<~CSV
            first,last,dob
            Marky,Mark,2000-04-05
            Frank,Rizzo,1930-09-22
          CSV
        ]

        expect(actual_files).to eq(expected_files)

        written.each { |f| FileUtils.rm(f, force: true) }
      end
    end

    describe 'Realize Transformation Pipelines' do
      let(:document) do
        {
          sheets: [
            {
              data_table: {
                columns: [
                  {
                    header: 'First Name',
                    transformers: [
                      { type: 'r/value/resolve', key: :first }
                    ]
                  },
                  {
                    header: 'Last Name',
                    transformers: [
                      { type: 'r/value/resolve', key: :last }
                    ]
                  },
                  {
                    header: 'Date of Birth',
                    transformers: [
                      { type: 'r/value/resolve', key: :dob },
                      { type: 'r/format/date', output_format: '%m/%d/%Y' },
                    ]
                  }
                ]
              }
            }
          ]
        }
      end

      it 'renders' do
        writer  = Portable::Writers::Csv.new(document)
        written = writer.write!(filename: filename, data_provider: data_provider)

        expect(written).to eq([filename])

        actual_files = written.map { |f| read_file(f) }

        expected_files = [
          <<~CSV
            First Name,Last Name,Date of Birth
            Marky,Mark,04/05/2000
            Frank,Rizzo,09/22/1930
          CSV
        ]

        expect(actual_files).to eq(expected_files)

        written.each { |f| FileUtils.rm(f, force: true) }
      end
    end
  end
end
