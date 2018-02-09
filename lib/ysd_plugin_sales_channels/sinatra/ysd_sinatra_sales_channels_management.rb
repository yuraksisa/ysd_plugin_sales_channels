module YSDPluginSalesChannels
  module Sinatra
    module SalesChannelsManagement

      def self.registered(app)

        #
        # Sales channel booking configuration
        #
        app.get '/admin/sales-channels/sales-channels/:id/booking-setup', :allowed_usergroups => ['booking_manager','staff'] do

          if @sales_channel_booking = ::Yito::Model::SalesChannel::SalesChannelBooking.get(params[:id])
            load_page :sales_channel_booking_configuration
          else
            status 404
          end

        end


        #
        # Sales channel management
        #
        app.get '/admin/sales-channels/sales-channels/?*', :allowed_usergroups => ['booking_manager','staff'] do

          locals = {:sales_channels => 20}
          load_em_page :sales_channels_management,
                       :sales_channels, false, :locals => locals

        end


      end

    end
  end
end