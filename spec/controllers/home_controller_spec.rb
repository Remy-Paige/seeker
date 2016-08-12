require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'home access' do
    it 'allows non logged-in users to access search' do
      login_with nil
      get :index
      expect(response).to redirect_to(search_path)
    end

    it 'allows logged-in users to access search' do
      login_with create(:user)
      get :index
      expect(response).to redirect_to(search_path)
    end
  end
end
