require 'rails_helper'

RSpec.describe "queries/new", type: :view do
  before(:each) do
    assign(:query, Query.new())
  end

  it "renders new query form" do
    render

    assert_select "form[action=?][method=?]", queries_path, "post" do
    end
  end
end
