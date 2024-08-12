require 'rails_helper'

RSpec.describe "Admin::OceanCarriers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/ocean_carriers/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/ocean_carriers/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/admin/ocean_carriers/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/ocean_carriers/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/admin/ocean_carriers/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/ocean_carriers/show"
      expect(response).to have_http_status(:success)
    end
  end

end
