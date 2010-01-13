require 'spec_helper'

describe Members::AchievementsController, "routing" do
  it { should route(:get, '/members/1/achievements').to(:controller => 'members/achievements', :action => :index, :member_id => '1') }
end

describe Members::AchievementsController, "GET index" do
  before(:each) do
    login(:admin)
    mock_parent(:member)
    get :index, :member_id => @parent.id
  end
  
  it { should respond_with(:success) }
  it { should assign_to(:achievements).with_kind_of(Array) }
  it { should assign_to(:completed).with_kind_of(Array) }
  it { should render_template(:index) }
end