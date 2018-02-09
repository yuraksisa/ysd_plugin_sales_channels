require 'data_mapper' unless defined?DataMapper::Resource

module Yito
  module Model
    module SalesChannel
      class SalesChannelBooking
        include DataMapper::Resource

        storage_names[:default] = 'saleschannelsds_channels_booking'
        
        belongs_to :sales_channel, child_key: [:sales_channel_id], parent_key: [:id], key: true
        property :override_notifications, Boolean, default: false

        #
        # Get the smtp configuration
        #
        def smtp_configuration

          return nil unless override_notifications

          from = SystemConfiguration::SecureVariable.get_value("smtp.from.sc.#{self.sales_channel.code}",'.')
          host = SystemConfiguration::SecureVariable.get_value("smtp.host.sc.#{self.sales_channel.code}",'.')
          port = SystemConfiguration::SecureVariable.get_value("smtp.port.sc.#{self.sales_channel.code}",'.')
          username = SystemConfiguration::SecureVariable.get_value("smtp.username.sc.#{self.sales_channel.code}",'.')
          password = SystemConfiguration::SecureVariable.get_value("smtp.password.sc.#{self.sales_channel.code}",'.')
          domain = SystemConfiguration::SecureVariable.get_value("smtp.domain.sc.#{self.sales_channel.code}",'.')
          authentication = SystemConfiguration::SecureVariable.get_value("smtp.authentication.sc.#{self.sales_channel.code}",'login')
          starttls_auto = SystemConfiguration::SecureVariable.get_value("smtp.starttls_auto.sc.#{self.sales_channel.code}",'yes').to_bool

          {:from => from,
           :via => :smtp,
           :via_options => {
               :address => host,
               :port => port,
               :user_name => username,
               :password => password,
               :enable_starttls_auto => starttls_auto,
               :domain => domain,
               :authentication => authentication.to_sym }}
        end
        
        def customer_notification_booking_request_template
          return nil unless override_notifications
          ContentManagerSystem::Template.first(:name => "booking_customer_req_notification.sc.#{self.sales_channel.code}")
        end
        
        def customer_notification_request_pay_now_template
          return nil unless override_notifications
          ContentManagerSystem::Template.first(:name => "booking_customer_req_pay_now_notification.sc.#{self.sales_channel.code}")
        end
        
        def customer_notification_booking_confirmed_template
          return nil unless override_notifications
          ContentManagerSystem::Template.first(:name => "booking_customer_notification.sc.#{self.sales_channel.code}")
        end
        
        def customer_notification_payment_enabled_template
          return nil unless override_notifications
          ContentManagerSystem::Template.first(:name => "booking_customer_notification_payment_enabled.sc.#{self.sales_channel.code}")
        end

        # ---------------------------- Hooks ----------------------------------

        after :create do
          create_configuration
        end

        after :destroy do
          destroy_configuration
        end

        #
        # Create the configuration
        #
        def create_configuration

          # Create the SMTP configuration for the channel
          #
          SystemConfiguration::SecureVariable.first_or_create(
              {:name => "smtp.from.sc.#{self.sales_channel.code}"},
              {:value => '.',
               :description => "smtp settings : from address (sales channel #{self.sales_channel.code})",
               :module => :service_postal})

          SystemConfiguration::SecureVariable.first_or_create(
              {:name => "smtp.host.sc.#{self.sales_channel.code}"},
              {:value => '.',
               :description => "smtp settings : host (sales channel #{self.sales_channel.code})",
               :module => :service_postal})

          SystemConfiguration::SecureVariable.first_or_create(
              {:name => "smtp.port.sc.#{self.sales_channel.code}"},
              {:value => '.',
               :description => "smtp settings : port (sales channel #{self.sales_channel.code})",
               :module => :service_postal})

          SystemConfiguration::SecureVariable.first_or_create(
              {:name => "smtp.username.sc.#{self.sales_channel.code}"},
              {:value => '.',
               :description => "smtp settings : username (sales channel #{self.sales_channel.code})",
               :module => :service_postal})

          SystemConfiguration::SecureVariable.first_or_create(
              {:name => "smtp.password.sc.#{self.sales_channel.code}"},
              {:value => '.',
               :description => "smtp settings : password (sales channel #{self.sales_channel.code})",
               :module => :service_postal})

          SystemConfiguration::SecureVariable.first_or_create(
              {:name => "smtp.domain.sc.#{self.sales_channel.code}"},
              {:value => 'localhost@localdomain',
               :description => "smtp settings : domain  (sales channel #{self.sales_channel.code})",
               :module => :service_postal})

          SystemConfiguration::SecureVariable.first_or_create(
              {:name => "smtp.authentication.sc.#{self.sales_channel.code}"},
              {:value => 'login',
               :description => "smtp settings : login (sales channel #{self.sales_channel.code})",
               :module => :service_postal})

          SystemConfiguration::SecureVariable.first_or_create(
              {:name => "smtp.starttls_auto.sc.#{self.sales_channel.code}"},
              {:value => 'true',
               :description => "smtp settings : startls auto (sales channel #{self.sales_channel.code})",
               :module => :service_postal})

          # Create the templates

          ContentManagerSystem::Template.first_or_create({:name => "booking_customer_req_notification.sc.#{self.sales_channel.code}"},
                                                         {:description=>"Mensaje que se envía al cliente cuando realiza solicitud de reserva (sin pago)  (sales channel #{self.sales_channel.code})",
                                                          :text => BookingDataSystem::Booking.customer_notification_booking_request_template})

          ContentManagerSystem::Template.first_or_create({:name => "booking_customer_req_pay_now_notification.sc.#{self.sales_channel.code}"},
                                                         {:description=>"Mensaje que se envía al cliente cuando realiza solicitud de reserva (con pago)  (sales channel #{self.sales_channel.code})",
                                                          :text => BookingDataSystem::Booking.customer_notification_request_pay_now_template})

          ContentManagerSystem::Template.first_or_create({:name => "booking_customer_notification.sc.#{self.sales_channel.code}"},
                                                         {:description=>"Mensaje que se envía al cliente cuando se confirma la solicitud de reserva  (sales channel #{self.sales_channel.code})",
                                                          :text => BookingDataSystem::Booking.customer_notification_booking_confirmed_template})

          ContentManagerSystem::Template.first_or_create({:name => "booking_customer_notification_payment_enabled.sc.#{self.sales_channel.code}"},
                                                         {:description=>"Mensaje que se envía al cliente cuando se habilita el pago reserva  (sales channel #{self.sales_channel.code})",
                                                          :text => BookingDataSystem::Booking.customer_notification_payment_enabled_template})

        end

        #
        # Destroy the configuration
        #
        def destroy_configuration

          if item = SystemConfiguration::SecureVariable.first({:name => "smtp.from.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = SystemConfiguration::SecureVariable.first({:name => "smtp.host.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = SystemConfiguration::SecureVariable.first({:name => "smtp.port.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = SystemConfiguration::SecureVariable.first({:name => "smtp.username.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = SystemConfiguration::SecureVariable.first({:name => "smtp.password.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = SystemConfiguration::SecureVariable.first({:name => "smtp.domain.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = SystemConfiguration::SecureVariable.first({:name => "smtp.authentication.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = SystemConfiguration::SecureVariable.first({:name => "smtp.starttls_auto.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = ContentManagerSystem::Template.first({:name => "booking_customer_req_notification.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = ContentManagerSystem::Template.first({:name => "booking_customer_req_pay_now_notification.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = ContentManagerSystem::Template.first({:name => "booking_customer_notification.sc.#{self.sales_channel.code}"})
            item.destroy
          end

          if item = ContentManagerSystem::Template.first({:name => "booking_customer_notification_payment_enabled.sc.#{self.sales_channel.code}"})
            item.destroy
          end

        end

      end
    end
  end
end