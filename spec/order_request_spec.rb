require 'spec_helper'

class TestOrderRequest < CafePress::EZP::Client::OrderRequest
  def send
    build
  end
end

RSpec.describe CafePress::EZP::Client::OrderRequest do
  it 'builds a request that includes all the elements and attributes' do
    req = TestOrderRequest.new(:partner_id => 1,
                               :vendor => vendor,
                               :order => order,
                               :order_items => order_lines,
                               :customer => customer,
                               :shipping_address => customer)

    expect(req.send).to equal_xml(fixture('orders/one_line_item'))
  end

  context 'when given multiple order lines' do
    it 'builds a request that includes all the order lines' do
      req = TestOrderRequest.new(:partner_id => 1,
                                 :vendor => vendor,
                                 :order => order,
                                 :order_items => order_lines(2),
                                 :customer => customer,
                                 :shipping_address => customer)

      expect(req.send).to equal_xml(fixture('orders/two_line_items'))
    end
  end
end
