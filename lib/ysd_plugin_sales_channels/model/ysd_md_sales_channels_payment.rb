require 'data_mapper' unless defined?DataMapper::Resource

module Yito
  module Model
    module SalesChannel
      class SalesChannelPayment
        include DataMapper::Resource

        storage_names[:default] = 'saleschannelsds_channels_payment'

        belongs_to :sales_channel, child_key: [:sales_channel_id], parent_key: [:id], key: true
        property :override_payment, Boolean, default: false

      end
    end
  end
end