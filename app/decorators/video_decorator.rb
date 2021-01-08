# frozen_string_literal: true

class VideoDecorator < Draper::Decorator
  delegate_all

  def thumbnail_url
    "https://image.mux.com/#{object.mux_playback_id}/thumbnail.png"
  end

  def stream_type
    case state
    when "live"
      "live"
    when "pending", "starting"
      "upcoming"
    else
      "vod"
    end
  end

  def active_viewers_count
    helpers.number_to_social(video.video_views.connected.count)
  end

  def display_state
    case state
    when "live"
      "LIVE"
    when "finished"
      "REPLAY"
    else
      "UPCOMING"
    end
  end
end
