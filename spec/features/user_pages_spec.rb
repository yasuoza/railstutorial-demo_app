require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }

    it "have title full_title('Sign up')" do
      expect(page.title).to eql full_title('Sign up')
    end
  end
end
