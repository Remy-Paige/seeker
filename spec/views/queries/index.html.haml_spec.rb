require 'rails_helper'

RSpec.describe "queries/index", type: :view do
  before(:each) do
    assign(:queries, [
      Query.create!(),
      Query.create!()
    ])
  end

  it "renders a list of queries" do
    render
  end
end
