require 'spec_helper'

include CafePress::EZP::Event

RSpec.describe Notification do
  describe '#parse' do

    # TODO: can one notification contain multiple orders?
    # Need to clairify with CafePress, docs aren't clear.
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
      expect(event.items.first.project_id).to eq '123-456-789'
    end

    describe "cancel events" do
      it 'parses a cancellation for the whole order' do
        notice = described_class.parse(fixture('event/full_cancel'))

        expect(notice).to_not be_failure
        expect(notice.id).to eq '1'
        expect(notice.events.size).to eq 1

        event = notice.events.first
        expect(event).to be_a Canceled
        expect(event.order.id).to eq '2'
        expect(event.order.reference_number).to eq '0001-0001-0001'
        expect(event.data[:date_time]).to eq '2008-06-12T00:00:00.0000000'
        expect(event.items.size).to eq 0
      end

      it 'parses a cancellation for part of the order' do
        notice = described_class.parse(fixture('event/partial_cancel'))

        expect(notice).to_not be_failure
        expect(notice.id).to eq '1'
        expect(notice.events.size).to eq 1

        event = notice.events.first
        expect(event).to be_a Canceled
        expect(event.order.id).to eq '2'
        expect(event.order.reference_number).to eq '0001-0001-0001'
        expect(event.data[:date_time]).to eq '2008-06-12T00:00:00.0000000'
        expect(event.items.size).to eq 2

        event.items.each_with_index do |item, i|
          i = (i + 1).to_s
          expect(item.id).to eq i
          expect(item.sku).to eq sprintf('%04d', i)
          expect(item.partner_sku).to eq "X#{i}"
          expect(item.quantity).to eq(i)
        end
      end
    end
  end
end
