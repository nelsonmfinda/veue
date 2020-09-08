# frozen_string_literal: true

module VideosHelper
  def current_video_id
    return current_video.id if controller_name == "videos" && action_name == "show" && current_video.present?

    nil
  end
end
