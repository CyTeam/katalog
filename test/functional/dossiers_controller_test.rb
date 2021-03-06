require 'test_helper'

class DossiersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in users(:editor)
    @dossier = dossiers(:city_history)
  end

  test 'should get index' do
    sign_out users(:editor)

    get :index
    assert_response :success

    assert_same_set (Topic.group + Topic.main), assigns(:dossiers)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create dossier' do
    assert_difference('Dossier.count') do
      post :create, dossier: @dossier.attributes
    end

    assert_redirected_to new_dossier_path
  end

  test 'should show dossier' do
    get :show, id: @dossier.to_param
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @dossier.to_param
    assert_response :success
  end

  test 'should update dossier' do
    put :update, id: @dossier.to_param, dossier: []
    assert_redirected_to dossier_path(assigns(:dossier))
  end

  test 'should destroy dossier' do
    assert_difference('Dossier.count', -1) do
      delete :destroy, id: @dossier.to_param
    end

    assert_redirected_to dossiers_path
  end

  test 'should show search form' do
    get :search
    assert_response :success
  end

  test 'index should list only topic groups and topics' do
    get :index

    assert_select 'tr.dossier', 0

    assert_select 'tr.topic.group', 2
    assert_select 'tr.topic.main', 2
  end

  test 'should list by signature' do
    get :search, search: { signature: '77.0.100' }
    dossiers = Dossier.by_signature('77.0.100')

    # TODO: hack to get only Dossier, not Topic records
    assert_select 'tr.dossier', dossiers.dossier.count

    get :search, search: { signature: '77.0' }
    dossiers = Dossier.by_signature('77.0')

    # TODO: hack to get only Dossier, not Topic records
    assert_select 'tr.dossier', dossiers.dossier.count
  end

  test 'should list by location' do
    get :search, search: { location: 'EG' }
    dossiers = Dossier.by_location('EG')

    # TODO: hack to get only Dossier, not Topic records
    assert_select 'tr.dossier', dossiers.dossier.count
  end

  test 'should get named report' do
    FactoryGirl.build(:report)
    get :report, report_name: 'simple'
    assert_response :success
  end

  context 'show' do
    should 'include description if present' do
      @dossier = FactoryGirl.create(:dossier, description: 'Simple text')
      get :show, id: @dossier.to_param

      assert_select '#description', text: 'Simple text'
    end

    should 'hide description title if description is blank' do
      @dossier = FactoryGirl.create(:dossier, description: '')
      get :show, id: @dossier.to_param

      assert_select '#description', false
    end

    should 'hide description title description is nil' do
      @dossier = FactoryGirl.create(:dossier, description: nil)
      get :show, id: @dossier.to_param

      assert_select '#description', false
    end

    should 'not quote description' do
      @dossier = FactoryGirl.create(:dossier, description: '<p>Single paragraph</p>')
      get :show, id: @dossier.to_param

      assert_select '#description p', text: 'Single paragraph'
    end

    should 'create links for http and email ' do
      @dossier = FactoryGirl.create(:dossier, description: '<p>Visit http://www.cyt.ch or mail info@cyt.ch</p>')
      get :show, id: @dossier.to_param

      assert_select "#description a[href='http://www.cyt.ch'][target='_blank']", text: 'http://www.cyt.ch'
      assert_select "#description a[href='mailto:info@cyt.ch']", text: 'info@cyt.ch'
    end
  end

  context 'create' do
    should 'redirect to new dossier' do
      post :create, dossier: FactoryGirl.attributes_for(:dossier)

      assert_redirected_to new_dossier_path
    end

    should 'show form again on validation errors' do
      post :create, dossier: FactoryGirl.attributes_for(:dossier, signature: '')

      assert assigns(:dossier)
      assert_select '#dossier_signature_input.error'
    end

    should 'create associated containers' do
      attributes = FactoryGirl.attributes_for(:dossier,
                                              containers_attributes: { 1 => { container_type: ContainerType.first, location: Location.first } }
      )

      assert_difference('Dossier.count', 1) do
        post :create, dossier: attributes
      end

      assert_redirected_to new_dossier_path
    end
  end

  context 'edit_report' do
    should 'show report title' do
      get :edit_report

      assert_select 'h1', text: I18n.t('katalog.main_navigation.edit_year')
    end
  end
end
