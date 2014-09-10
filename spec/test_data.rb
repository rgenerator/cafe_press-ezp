module TestData
  def order(attrs = {})
    hash = { 
      :id              => '1234',
      :product_total   => 25.99,
      :shipping_total  => 2.99,
      :tax_total       => 0.55,
      :shipping_method => 'FC' 
    }.merge(attrs)

    hash[:total] = hash[:product_total] + hash[:shipping_total] + hash[:tax_total]
    hash
  end

  def order_items(n = 1)
    n.times.each_with_object do |i, c|
      c << { 
        :product_id => sprintf('%04d', i),
        :quantity   => rand(5) + 1,
        :price      => (rand(0.5)*100).round(2),
        :name       => "Product #{i+1}"
      }
    end
  end

  def vendor(attrs = {})
    { :name => 'relentlessGENERATOR', :url => 'rgenerator.com' }.merge(contact_info(attrs))
  end

  def customer(attrs = {})
    { :first_name => 's', :last_name => 'shaw' }.merge(contact_info(attrs))
  end

  protected
  def contact_info(attrs = {})
    { :address1 => '400 Lafayette Street',
      :address2 => '2R',
      :city     => 'New York City',
      :state    => 'NY',
      :zip      => '10003',
      :country  => 'USA',
      :email    => 'dev@rgenerator.com',
      :phone    => '212 555 1212' }.merge(attrs)
  end
end
