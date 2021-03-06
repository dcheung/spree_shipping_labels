require 'spec_helper'

# Purposely not testing `possible_package_types`, `finalize_with_label!` and the
# green code path on `generate_label!` as the complexity of the tests would
# exceed the complexity of the code being tested. Perhaps we can get them on
# a later refactor.
describe Spree::Shipment do

  it 'can return the total weight of a shipment' do
    order = create :order_with_line_items, line_items_count: 5
    for line_item in order.line_items
      line_item.variant.update_attribute :weight, 5
    end
    shipment = create :shipment, order: order
    expect( shipment.weight ).to eq 25
  end

  describe 'label generation' do
    let(:provider) do
      Spree::ShipmentProvider.create! do |provider|
        provider.name = 'Bogus'
        provider.package_types.build name: 'Test', provider_type: 'test', width: 5, length: 5, height: 2
      end
    end
    let(:package_type) { provider.package_types.first }
    let(:shipment) { create :shipment }

    it 'will error if no selected package type' do
      expect { shipment.generate_label! }.to raise_error Spree::ShippingLabels::Error, 'Cannot generate a label without a package type'
    end

    it 'will error if shipping type not selected or cannot be labeled' do
      shipment.update_attribute :package_type, package_type
      expect { shipment.generate_label! }.to raise_error Spree::ShippingLabels::Error, 'Cannot generate a label without a label-able selected shipping method'
    end
  end

end
