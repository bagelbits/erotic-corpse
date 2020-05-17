# frozen_string_literal: true

class Prompt < ActiveRecord::Base
  self.table_name = 'prompts'

  class << self
    def last_prompt
      prompt = where(next_prompt: nil, reported: false).last

      # If there is no last prompt, get the last prompt that is not reported
      prompt ||= where(reported: false).last

      prompt
    end

    def full_story
      story = [find(1)]

      while story.last.next_prompt
        prompt = find(story.last.next_prompt)
        story << prompt
      end

      story.map { |p| { prompt: p.prompt, reported: p.reported } }
    end
  end

  validates :prompt, presence: true
  validate :validate_next_prompt

  def report!
    # TODO: Maybe convert these to errors instead.
    return if id == 1
    return if next_prompt

    self.reported = true
    save!
  end

  private

  def validate_next_prompt
    return unless next_prompt_changed?

    # validate next_prompt exists
    child_prompt = Prompt.find(next_prompt)

    # validate next_prompt is does not have a next_prompt
    errors.add(:next_prompt, 'is not a leaf') if child_prompt.next_prompt

    errors.add(:next_prompt, 'has been reported') if child_prompt.reported

    # validate next_prompt was nil or next_prompt was reported
    unless next_prompt_was.nil?
      previous_child_prompt = Prompt.find(next_prompt_was)
      if previous_child_prompt.reported == false
        errors.add(
          :next_prompt,
          'cannot be changed if already set and child prompt is not reported'
        )
      end
    end
  rescue ActiveRecord::RecordNotFound
    errors.add(:next_prompt, 'does not exist')
  end
end
