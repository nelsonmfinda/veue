# frozen_string_literal: true

class VideoEvent < ApplicationRecord
  belongs_to :user
  belongs_to :video

  before_save :set_payload
  before_create :set_timecode
  after_create :broadcast_message

  validates :video, presence: true
  validates :input, presence: true, json: {schema: -> { input_schema.to_json }}
  validates :payload, presence: true, unless: :new_record?

  def set_payload
    self.payload = input_to_payload
  end

  # For "live" events like Chat, that need to happen relative to
  # the ACTUAL timecode that the streamer is using and should be instant during live
  # the client won't/can't give us a timecode, so we will see how long it's been since
  # the video started and use that as our timecode
  def set_timecode
    return if timecode_ms
    return unless video.started_at_ms

    self.timecode_ms = Time.now.utc.to_ms - video.started_at_ms
  end

  def broadcast_message
    ActionCable.server.broadcast(
      "live_video_#{video.to_param}",
      to_json(channel_timecode_ms),
    )
  end

  def to_json(override_timecode=nil)
    {
      type: type,
      timecodeMs: override_timecode || timecode_ms,
      data: payload,
    }
  end

  def channel_timecode_ms
    timecode_ms
  end

  def input_schema
    {
      properties: {},
      required: [],
    }
  end
end
