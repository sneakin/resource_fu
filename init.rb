require 'resource_fu'
ActionController::Routing::RouteSet::NamedRouteCollection.send(:include, ResourceFu::NamedRouteCollectionMethods)
