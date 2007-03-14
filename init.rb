require 'proto_cool/resource_fu'
require 'proto_cool/resource_fu/method_definition'
require 'proto_cool/resource_fu/named_route_collection_methods'

# add url_helper inferencing code to NamedRouteCollection
ActionController::Routing::RouteSet::NamedRouteCollection.send(:include, ProtoCool::ResourceFu::NamedRouteCollectionMethods)
