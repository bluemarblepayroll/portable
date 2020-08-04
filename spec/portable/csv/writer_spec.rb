# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'file_helper'
require 'spec_helper'

describe Portable::Csv::Writer do
  let(:filename) { File.join('tmp', "#{SecureRandom.uuid}.csv") }
  let(:document)   { nil }

  subject { described_class.new(document) }

  it 'raises AlreadyOpenError if #open is called twice without #close' do
    subject.open(filename)
    expect { subject.open(filename) }.to raise_error(Portable::Csv::Writer::AlreadyOpenError)
  end

  it 'raises NotOpenError if #write is called without calling #open' do
    expect { subject.write }.to raise_error(Portable::Csv::Writer::NotOpenError)
  end

  it 'raises NotOpenError if #close is called without calling #open' do
    expect { subject.write }.to raise_error(Portable::Csv::Writer::NotOpenError)
  end

  context 'when using object-based method' do
    specify '#open is true when open, false when closed' do
      expect(subject.open?).to be false

      subject.open(filename)

      expect(subject.open?).to be true

      subject.close

      expect(subject.open?).to be false
    end

    describe 'snapshots' do
      read_snapshots('csv').each do |snapshot|
        let(:document) { snapshot.document }

        specify snapshot.name do
          subject.open(filename)

          subject.write_all(snapshot.records)

          subject.close

          actual = read_file(filename)

          expect(actual).to eq(snapshot.expected)
        end
      end
    end
  end

  context 'when using block method' do
    specify '#open is true within open block, false when exited' do
      expect(subject.open?).to be false

      subject.open(filename) do |writer|
        expect(writer.open?).to be true
      end

      expect(subject.open?).to be false
    end

    describe 'snapshots' do
      read_snapshots('csv').each do |snapshot|
        let(:document) { snapshot.document }

        specify snapshot.name do
          subject.open(filename) do |writer|
            writer.write_all(snapshot.records)
          end

          actual = read_file(filename)

          expect(actual).to eq(snapshot.expected)
        end
      end
    end
  end

  describe 'README examples' do
    let(:patients) do
      [
        { first: 'Marky', last: 'Mark', dob: '2000-04-05' },
        { first: 'Frank', last: 'Rizzo', dob: '1930-09-22' }
      ]
    end

    describe 'Getting Started with Exports' do
      let(:document) do
        {
          data_table: {
            columns: [
              { header: :first },
              { header: :last },
              { header: :dob }
            ]
          }
        }
      end

      it 'produces correct output' do
        subject.open(filename) do |writer|
          writer.write_all(patients)
        end

        expected = <<~CSV
          first,last,dob
          Marky,Mark,2000-04-05
          Frank,Rizzo,1930-09-22
        CSV

        actual = read_file(filename)

        expect(actual).to eq(expected)
      end
    end

    describe 'Realize Transformation Pipelines' do
      let(:document) do
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
      end

      it 'produces correct output' do
        subject.open(filename) do |writer|
          writer.write_all(patients)
        end

        expected = <<~CSV
          First Name,Last Name,Date of Birth
          Marky,Mark,04/05/2000
          Frank,Rizzo,09/22/1930
        CSV

        actual = read_file(filename)

        expect(actual).to eq(expected)
      end
    end
  end
end
