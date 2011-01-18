require 'test_helper'

class DossiersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    sign_in users(:editor)
    @dossier = dossiers(:city_history)
  end

  test "should get index" do
    sign_out users(:editor)
    
    get :index
    assert_response :success

    assert_same_set (Topic.group + Topic.main), assigns(:dossiers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dossier" do
    assert_difference('Dossier.count') do
      post :create, :dossier => @dossier.attributes
    end

    assert_redirected_to dossier_path(assigns(:dossier))
  end

  test "should show dossier" do
    get :show, :id => @dossier.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @dossier.to_param
    assert_response :success
  end

  test "should update dossier" do
    put :update, :id => @dossier.to_param, :dossier => @dossier.attributes
    assert_redirected_to dossier_path(assigns(:dossier))
  end

  test "should destroy dossier" do
    assert_difference('Dossier.count', -1) do
      delete :destroy, :id => @dossier.to_param
    end

    assert_redirected_to dossiers_path
  end

  test "should show search form" do
    get :search
    assert_response :success
  end
  
  test "index should list only topic groups and topics" do
    get :index

    assert_select 'tr.dossier', 0

    assert_select 'tr.topic.group', 2
    assert_select 'tr.topic.main', 2
  end
  
  test "should list by signature" do
    get :search, :search => {:signature => '77.0.100'}
    dossiers = Dossier.by_signature('77.0.100')

    # TODO: hack to get only Dossier, not Topic records
    assert_select 'tr.dossier', dossiers.dossier.count

    get :search, :search => {:signature => '77.0'}
    dossiers = Dossier.by_signature('77.0')

    # TODO: hack to get only Dossier, not Topic records
    assert_select 'tr.dossier', dossiers.dossier.count
  end
  
  test "should list by location" do
    get :search, :search => {:location => 'EG'}
    dossiers = Dossier.by_location('EG')

    # TODO: hack to get only Dossier, not Topic records
    assert_select 'tr.dossier', dossiers.dossier.count
  end

  test "dossier view should contain links to topics" do
    get :show, :id => @dossier.to_param
    
    assert_select '.dossier_topic_breadcrumb' do
      assert_select 'li a', 4
    end
  end

  test "should get overview" do
    get :overview
    assert_response :success

    assert_select 'th.year', Dossier.years(5).size
  end

  test "should get overview with collect_years_count" do
    get :overview, :collect_year_count => 10

    assert_response :success
    
    assert_select 'th.year', Dossier.years(10).size
  end

  test "should get report" do
    get :report
    assert_response :success
  end
end
