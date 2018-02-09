require 'data_mapper' unless defined?DataMapper::Resource

module Yito
  module Model
    module SalesChannel
      class SalesChannel
        include DataMapper::Resource

        storage_names[:default] = 'saleschannelsds_channels' # stored in salechannelds_salechannels in default storage

        property :id, Serial
        property :code, String, length: 50
        property :name, String, length: 256
        
        # ------------------------------- Hooks -------------------------------------------
        # 
        after :create do
          
          SalesChannelBooking.create(sales_channel: self)
        
        end

      end
    end
  end
end