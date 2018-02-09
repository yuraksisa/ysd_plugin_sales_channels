require 'ysd-plugins' unless defined?Plugins::Plugin

Plugins::SinatraAppPlugin.register :sales_channels do

  name=        'sales_channels'
  author=      'yurak sisa'
  description= 'Sales Channels'
  version=     '0.1'
  hooker YsdPluginSalesChannels::SalesChannelsExtension
  sinatra_extension YSDPluginSalesChannels::Sinatra::SalesChannels
  sinatra_extension YSDPluginSalesChannels::Sinatra::SalesChannelsManagement
  sinatra_extension YSDPluginSalesChannels::Sinatra::SalesChannelsManagementRESTApi

end