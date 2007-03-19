require File.join(File.dirname(__FILE__), 'test_helper')
require 'test/unit'

class InferencingHelpersTest < Test::Unit::TestCase
  class InferencingHelpersController < ActionController::Base
    self.template_root = "#{File.dirname(__FILE__)}/../fixtures/"

    def self.controller_path; 'inferencing_helpers' end

    def show_specified_positional_path
      render :inline => "<%= flange_path('a_widget', 'a_flange') %>"
    end

    def show_inferred_positional_path
      @widget = 'a_widget'
      render :inline => "<%= flange_path('a_flange') %>"
    end

    def show_instance_id_inference
      @widget_id = 'a_widget'
      render :inline => "<%= flange_path('a_flange') %>"
    end

    def show_inference_precedence
      @widget_id = 'bogus_widget'
      @widget = 'a_widget'
      render :inline => "<%= flange_path('a_flange') %>"
    end

    def show_deep_inferred_positional_path
      @widget = 'a_widget'
      render :inline => "<%= grommet_path('a_flange','a_grommet') %>"
    end

    def show_positionals_always_overrides_instance_variables
      @widget = 'bogus_widget'
      @flange = 'bogus_flange'
      render :inline => "<%= grommet_path('a_widget', 'a_flange', 'a_grommet') %>"
    end

    def show_options_always_overrides_instance_variables
      @widget = 'bogus_widget'
      @flange = 'bogus_flange'
      render :inline => "<%= grommet_path('a_grommet', :widget_id => 'a_widget', :flange_id => 'a_flange') %>"
    end

    def show_positionals_always_overrides_options
      render :inline => "<%= grommet_path('a_widget', 'a_flange', 'a_grommet', :widget_id => 'bogus_widget', :flange_id => 'bogus_flange') %>"
    end

    def show_collection_helpers_need_no_arguments
      @widget = 'a_widget'
      @flange = 'a_flange'
      render :inline => "<%= grommets_path() %>"
    end

    def show_explosion_because_terminating_member_is_never_inferred
      @widget = 'a_widget'
      @flange = 'a_flange'
      @grommet = @id = @grommet_id = 'a_grommet'
      render :inline => "<%= grommet_path() %>"
    end

    def show_explosion_on_too_many_positionals
      render :inline => "<%= grommet_path('a_widget', 'a_flange', 'a_grommet', 'extra_positional') %>"
    end

    def rescue_action(e) raise e end
    end

    include ActionView::Helpers::UrlHelper

    def setup
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      @controller = InferencingHelpersController.new
    end

    def test_specified_positional_path
      with_nested_resource_routing do
        get :show_specified_positional_path
      end
      assert_equal '/widgets/a_widget/flanges/a_flange', @response.body
    end

    def test_inferred_positional_path
      with_nested_resource_routing do
        get :show_inferred_positional_path
      end
      assert_equal '/widgets/a_widget/flanges/a_flange', @response.body
    end

    def test_instance_id_inference
      with_nested_resource_routing do
        get :show_instance_id_inference
      end
      assert_equal '/widgets/a_widget/flanges/a_flange', @response.body
    end

    def test_inference_precedence
      with_nested_resource_routing do
        get :show_inference_precedence
      end
      assert_equal '/widgets/a_widget/flanges/a_flange', @response.body
    end

    def test_deep_inferred_positional_path
      with_nested_resource_routing do
        get :show_deep_inferred_positional_path
      end
      assert_equal '/widgets/a_widget/flanges/a_flange/grommets/a_grommet', @response.body
    end

    def test_positionals_always_overrides_instance_variables
      with_nested_resource_routing do
        get :show_positionals_always_overrides_instance_variables
      end
      assert_equal '/widgets/a_widget/flanges/a_flange/grommets/a_grommet', @response.body
    end

    def test_options_always_overrides_instance_variables
      with_nested_resource_routing do
        get :show_options_always_overrides_instance_variables
      end
      assert_equal '/widgets/a_widget/flanges/a_flange/grommets/a_grommet', @response.body
    end

    def test_positionals_always_overrides_options
      with_nested_resource_routing do
        get :show_positionals_always_overrides_options
      end
      assert_equal '/widgets/a_widget/flanges/a_flange/grommets/a_grommet', @response.body
    end

    def test_collection_helpers_need_no_arguments
      with_nested_resource_routing do
        get :show_collection_helpers_need_no_arguments
      end
      assert_equal '/widgets/a_widget/flanges/a_flange/grommets', @response.body
    end
    
    def test_explosion_because_terminating_member_is_never_inferred
      with_nested_resource_routing do
        assert_raises ActionController::RoutingError do
          get :show_explosion_because_terminating_member_is_never_inferred
        end
      end
    end

    def test_explosion_on_too_many_positionals
      with_nested_resource_routing do
        assert_raises ArgumentError do
          get :show_explosion_on_too_many_positionals
        end
      end
    end

    protected
    def with_nested_resource_routing
      with_routing do |set|
        set.draw do |map|
          map.resources :widgets do |widget|
            widget.resources :flanges do |flange|
              flange.resources :grommets
            end
          end
          map.inferencing_helpers 'inferencing_helpers/:action', :controller => 'inferencing_helpers'
        end
        yield
      end
    end
  end
