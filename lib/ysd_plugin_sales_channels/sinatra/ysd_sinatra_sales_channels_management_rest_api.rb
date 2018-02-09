module YSDPluginSalesChannels
  module Sinatra
    module SalesChannelsManagementRESTApi

      def self.registered(app)

        #                    
        # Query sales-channels
        #
        ["/api/sales-channels","/api/sales-channels/page/:page"].each do |path|
          
          app.post path, :allowed_usergroups => ['bookings_manager','staff'] do

            page = [params[:page].to_i, 1].max
            page_size = 20
            offset_order_query = {:offset => (page - 1)  * page_size, :limit => page_size, :order => [:name.asc]}

            if request.media_type == "application/json"
              request.body.rewind
              search_request = JSON.parse(URI.unescape(request.body.read))
              search_text = search_request['search']
              conditions = Conditions::Comparison.new(:name, '$like', "%#{search_text}%")

              total = conditions.build_datamapper(::Yito::Model::SalesChannel::SalesChannel).all.count
              data = conditions.build_datamapper(::Yito::Model::SalesChannel::SalesChannel).all(offset_order_query)
            else
              data,total  = ::Yito::Model::SalesChannel::SalesChannel.all_and_count(offset_order_query)
            end

            content_type :json
            {:data => data, :summary => {:total => total}}.to_json
          
          end
        
        end
        
        #
        # Get all sales-channel
        #
        app.get "/api/sales-channels", :allowed_usergroups => ['bookings_manager','staff'] do

          data = ::Yito::Model::SalesChannel::SalesChannel.all()

          status 200
          content_type :json
          data.to_json

        end

        #
        # Get a sales-channel
        #
        app.get "/api/sales-channel/:id", :allowed_usergroups => ['bookings_manager','staff'] do
        
          data = ::Yito::Model::SalesChannel::SalesChannel.get(params[:id].to_i)
          
          status 200
          content_type :json
          data.to_json
        
        end
        
        #
        # Create a sales-channel
        #
        app.post "/api/sales-channel", :allowed_usergroups => ['bookings_manager','staff'] do
        
          data_request = body_as_json(::Yito::Model::SalesChannel::SalesChannel)
          data = ::Yito::Model::SalesChannel::SalesChannel.create(data_request)
         
          status 200
          content_type :json
          data.to_json          
        
        end
        
        #
        # Updates a sales-channel
        #
        app.put "/api/sales-channel", :allowed_usergroups => ['bookings_manager','staff'] do
          
          data_request = body_as_json(::Yito::Model::SalesChannel::SalesChannel)
                              
          if data = ::Yito::Model::SalesChannel::SalesChannel.get(data_request.delete(:id))
            data.attributes=data_request  
            data.save
          end
      
          content_type :json
          data.to_json        
        
        end
        
        #
        # Deletes a sales-channel
        #
        app.delete "/api/sales-channel", :allowed_usergroups => ['bookings_manager','staff'] do
        
          data_request = body_as_json(::Yito::Model::SalesChannel::SalesChannel)
          
          key = data_request.delete(:id).to_i
          
          if data = ::Yito::Model::SalesChannel::SalesChannel.get(key)
            data.destroy
          end
          
          content_type :json
          true.to_json
        
        end

      end
    end
  end
end