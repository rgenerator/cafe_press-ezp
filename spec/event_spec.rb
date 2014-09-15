require 'spec_helper'

include CafePress::EZP::Event

RSpec.describe Notification do
  describe '#parse' do
    it 'parses failure events' do
      notice = described_class.parse(fixture('event/failure'))

      expect(notice).to be_failure
      expect(notice.id).to be_nil
      expect(notice.events.size).to eq 1

      event = notice.events.first
      expect(event).to be_a Failed
      expect(event.order.id).to eq '2'
      expect(event.order.reference_number).to eq '0001-0001-0001'
      expect(event.data[:message]).to eq 'some message'
      expect(event.data[:affiliate_id]).to eq '1'
    end

    it 'parses accepted events' do
      notice = described_class.parse(fixture('event/accepted'))

      expect(notice).to_not be_failure
      expect(notice.id).to eq '1'
      expect(notice.events.size).to eq 1

      event = notice.events.first
      expect(event).to be_a Accepted
      expect(event.order.id).to eq '2'
      expect(event.order.reference_number).to eq '0001-0001-0001'
      expect(event.data[:date_time]).to eq '2008-06-13T13:00:50.0000000'
    end

    it 'parses shipment events' do
      notice = described_class.parse(fixture('event/shipment'))

      expect(notice).to_not be_failure
      expect(notice.id).to eq '1'
      expect(notice.events.size).to eq 1

      event = notice.events.first
      expect(event).to be_a Shipment
      expect(event.order.id).to eq '2'
      expect(event.order.reference_number).to eq '0001-0001-0001'
      expect(event.data[:date_time]).to eq '2008-06-20T13:00:00.0000000'
      expect(event.data[:carrier]).to eq 'USPS'
      expect(event.data[:service]).to eq 'Priority Mail'

      expect(event.items.size).to eq 1
      expect(event.items.first.id).to eq '99'
    end
  end
end
