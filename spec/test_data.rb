module TestData
  def fixture(name)
    path = File.join(File.dirname(__FILE__), 'fixtures', name)
    path << '.xml' unless path.end_with?('.xml')
    File.read(path)
  end

  def order_item
    {
      :name => 'Mean Mug',
      :product_id => 1,
      :quantity => 1,
      :price => '1.95'
    }
  end

  def order(attrs = {})
    hash = { 
      :id              => '1',
      :product_total   => '1.95',
      :shipping_total  => '5.95',
      :tax_total       => '0.00',
      :shipping_method => 'FC' 
    }.merge(attrs)

    hash[:total] = sprintf "%.02f", hash[:product_total].to_f + hash[:shipping_total].to_f + hash[:tax_total].to_f
    hash
  end

  def order_lines(n = 1)
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
    attrs[:email] ||= 'sshaw@rgenerator.com'
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
