# Cafepress::Ezp::Client

CafePress EZ Prints API Client

## Overview

	require 'cafepress/ezp/client'

    include CafePress::EZP

	Client.config do
	  secure = true
	  partner_id = 92343212
	  vendor.name = 'MyPlay'
	  vendor.address1 = '400 Lafayette St. 2R'
	  # ...
	end

	client = Client.new
	order = client.place_order(customer, order, order_items)


## Installation

Add this line to your application's Gemfile:

    gem 'cafepress-ezp-client', :git => ''

And then execute:

    $ bundle
