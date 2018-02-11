module YSDPluginSalesChannels
  module Sinatra
    module SalesChannelsManagement

      def self.registered(app)

        #
        # Sales channel booking configuration
        #
        app.get '/admin/sales-channels/sales-channels/:id/booking-setup', :allowed_usergroups => ['booking_manager','staff'] do

          if @sales_channel_booking = ::Yito::Model::SalesChannel::SalesChannelBooking.get(params[:id])
            if @show_translations = settings.multilanguage_site
              @tmpl_request = ContentManagerSystem::Template.first({:name => "booking_customer_req_notification.sc.#{@sales_channel_booking.sales_channel.code}"})
              @tmpl_request_pay_now = ContentManagerSystem::Template.first({:name => "booking_customer_req_pay_now_notification.sc.#{@sales_channel_booking.sales_channel.code}"})
              @tmpl_confirmation = ContentManagerSystem::Template.first({:name => "booking_customer_notification.sc.#{@sales_channel_booking.sales_channel.code}"})
              @tmpl_payment_enabled = ContentManagerSystem::Template.first({:name => "booking_customer_notification_payment_enabled.sc.#{@sales_channel_booking.sales_channel.code}"})
            end
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