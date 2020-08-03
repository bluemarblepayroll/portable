# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

require 'file_helper'
require 'spec_helper'

describe Portable::Writer do
  let(:filename) { File.join('tmp', "#{SecureRandom.uuid}.csv") }
  let(:export)   { nil }

  subject { described_class.new(export) }

  it 'raises AlreadyOpenError if #open is called twice without #close' do
    subject.open(filename)
    expect { subject.open(filename) }.to raise_error(Portable::Writer::AlreadyOpenError)
  end

  it 'raises NotOpenError if #write is called without calling #open' do
    expect { subject.write }.to raise_error(Portable::Writer::NotOpenError)
  end

  it 'raises NotOpenError if #close is called without calling #open' do
    expect { subject.write }.to raise_error(Portable::Writer::NotOpenError)
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
      read_snapshots.each do |snapshot|
        let(:export) { snapshot.export }

        specify snapshot.name do
          subject.open(filename)

          snapshot.records.each do |record|
            subject.write(object: record)
          end

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
      read_snapshots.each do |snapshot|
        let(:export) { snapshot.export }

        specify snapshot.name do
          subject.open(filename) do |writer|
            snapshot.records.each do |record|
              writer.write(object: record)
            end
          end

          actual = read_file(filename)

          expect(actual).to eq(snapshot.expected)
        end
      end
    end
  end
end
