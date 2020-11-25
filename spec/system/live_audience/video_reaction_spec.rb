# frozen_string_literal: true

require "system_helper"
require_relative("../../support/audience_spec_helpers")

describe "Video Reaction Event" do
  include AudienceSpecHelpers

  let(:user) { create(:user) }
  let(:video) { create(:live_video) }

  before :example do
    resize_window_desktop
  end

  describe "user reaction" do
    before do
      visit videos_path
      login_as user
      visit video_path(video)
    end

    it "should display a video heart notification" do
      find(".button-holder").click
      expect(page).to have_css(".user-reaction")
      expect(page).to have_css("div.messages > .user-reaction", wait: 4)
    end
  end
end
