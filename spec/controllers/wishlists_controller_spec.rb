require 'spec_helper'

describe WishlistsController, "routing" do
  it { should route(:get, '/wishlists').to(:controller => :wishlists, :action => :index) }
end

describe WishlistsController, "GET index" do
  context "without boss param" do
    before(:each) do
      get :index
    end

    it { should respond_with(:success) }
    it { should assign_to(:root) }
    it { should_not assign_to(:zone) }
    it { should_not assign_to(:boss) }
    it { should assign_to(:items).with([]) }
    it { should render_template(:index) }
  end

  context "with boss param" do
    # We got a boss param that exists, and it has items associated
    context "having items" do
      before(:each) do
        @resource = Factory(:loot_table)
        get :index, :boss => @resource.parent.id
      end

      it { should respond_with(:success) }
      it { should assign_to(:root) }
      it { should assign_to(:boss).with(@resource.parent) }
      it { should assign_to(:zone).with(@resource.parent.parent) }
      it { should assign_to(:recent_loots) }
      it { should assign_to(:items) }
      it { should render_template(:index) }
    end

    context "without items" do
      # We got a boss param that exists, but that boss has no items listed
      before(:each) do
        @resource = Factory(:loot_table_boss)
        get :index, :boss => @resource
      end

      it { should respond_with(:success) }
      it { should assign_to(:root) }
      it { should assign_to(:boss).with(@resource) }
      it { should assign_to(:zone).with(@resource.parent) }
      it { should_not assign_to(:recent_loots) }
      it { should assign_to(:items) }
      it { should render_template(:index) }
    end
  end
end
