# frozen_string_literal: true

describe 'Prompt' do
  let!(:root_prompt) { create(:prompt, id: 1, prompt: 'This is a test') }

  describe ':last_prompt' do
    let(:first_prompt) { create(:prompt, prompt: 'This is a test') }
    let(:second_prompt) { create(:prompt, prompt: 'This is a test') }
    let(:third_prompt) { create(:prompt, prompt: 'This is a test') }

    it 'gives the last Prompt without a next_prompt' do
      root_prompt.next_prompt = first_prompt.id
      root_prompt.save!
      first_prompt.next_prompt = second_prompt.id
      first_prompt.save!
      second_prompt.next_prompt = third_prompt.id
      second_prompt.save!
      expect(Prompt.last_prompt.id).to eq(third_prompt.id)
    end

    context 'if prompted is reported' do
      it 'is ignored' do
        root_prompt.next_prompt = first_prompt.id
        root_prompt.save!
        first_prompt.next_prompt = second_prompt.id
        first_prompt.save!
        third_prompt.report!
        expect(Prompt.last_prompt.id).to eq(second_prompt.id)
      end
    end

    context 'when there is no last prompt' do
      it 'returns the last non-reported prompt' do
        root_prompt.next_prompt = first_prompt.id
        root_prompt.save!
        first_prompt.next_prompt = second_prompt.id
        first_prompt.save!
        second_prompt.next_prompt = third_prompt.id
        second_prompt.save!
        third_prompt.report!
        expect(Prompt.last_prompt.id).to eq(second_prompt.id)
      end
    end
  end

  describe ':full_story' do
    let(:first_prompt) { create(:prompt, prompt: 'This is a test 1') }
    let(:second_prompt) { Prompt.create(prompt: 'This is a test 2') }
    let(:third_prompt) { Prompt.create(prompt: 'This is a test 3') }
    let(:expected_full_story) do
      [root_prompt.prompt, first_prompt.prompt, second_prompt.prompt, third_prompt.prompt]
    end

    it 'gives the full story' do
      root_prompt.next_prompt = first_prompt.id
      root_prompt.save!
      first_prompt.next_prompt = second_prompt.id
      first_prompt.save!
      second_prompt.next_prompt = third_prompt.id
      second_prompt.save!
      expect(Prompt.full_story.pluck(:prompt)).to eq(
        expected_full_story
      )
    end

    context 'when prompt is reported' do
      it 'still returns' do
        root_prompt.next_prompt = first_prompt.id
        root_prompt.save!
        first_prompt.next_prompt = second_prompt.id
        first_prompt.save!
        second_prompt.next_prompt = third_prompt.id
        second_prompt.save!
        third_prompt.report!

        full_story = Prompt.full_story
        expect(full_story.pluck(:prompt)).to eq(
          expected_full_story
        )
        expect(full_story.last[:reported]).to eq(true)
      end
    end
  end

  describe '#valid?' do
    describe '.prompt' do
      let(:prompt) { build(:prompt, prompt: nil) }

      it 'must have a prompt' do
        expect(prompt.valid?).to eq(false)
        expect(prompt.errors.messages[:prompt]).to eq(['can\'t be blank'])
      end
    end

    describe '.next_prompt' do
      let(:first_prompt) { create(:prompt, prompt: 'This is a test') }
      let(:second_prompt) { create(:prompt, prompt: 'This is a test') }

      context 'when next_prompt does not change' do
        it 'is valid' do
          expect(first_prompt.valid?).to eq(true)
        end
      end

      context 'when next_prompt does not exist' do
        it 'is invalid' do
          expect(first_prompt.valid?).to eq(true)

          last_prompt = Prompt.last
          first_prompt.next_prompt = last_prompt.id + 1

          expect(first_prompt.valid?).to eq(false)
          expect(first_prompt.errors.messages[:next_prompt]).to eq(['does not exist'])
        end
      end

      context 'when child prompt has child prompt' do
        let(:third_prompt) { create(:prompt, prompt: 'This is a test') }

        it 'is invalid' do
          second_prompt.next_prompt = third_prompt.id
          second_prompt.save!
          first_prompt.next_prompt = second_prompt.id
          expect(first_prompt.valid?).to eq(false)
          expect(first_prompt.errors.messages[:next_prompt]).to eq(['is not a leaf'])
        end
      end

      context 'when child prompt is reported' do
        it 'is invalid' do
          first_prompt
          second_prompt.report!
          first_prompt.next_prompt = second_prompt.id
          expect(first_prompt.valid?).to eq(false)
          expect(first_prompt.errors.messages[:next_prompt]).to eq(['has been reported'])
        end
      end

      context 'when next_prompt was already set' do
        let(:third_prompt) { create(:prompt, prompt: 'This is a test') }

        it 'is invalid' do
          first_prompt.next_prompt = second_prompt.id
          first_prompt.save!
          first_prompt.next_prompt = third_prompt.id
          expect(first_prompt.valid?).to eq(false)
          expect(first_prompt.errors.messages[:next_prompt]).to eq(
            ['cannot be changed if already set and child prompt is not reported']
          )
        end
      end

      context 'when next_prompt was already set and previous child prompt was reported' do
        let(:third_prompt) { create(:prompt, prompt: 'This is a test') }

        it 'is valid' do
          first_prompt.next_prompt = second_prompt.id
          first_prompt.save!
          second_prompt.report!
          first_prompt.next_prompt = third_prompt.id
          expect(first_prompt.valid?).to eq(true)
        end
      end
    end

    describe '.reported' do
      context 'with the first prompt' do
        it 'is invalid' do
          expect(root_prompt.reported).to eq(false)

          root_prompt.reported = true
          expect(root_prompt.valid?).to eq(false)
          expect(root_prompt.errors.messages[:reported]).to eq(['can not be set for story root'])
        end
      end

      context 'with next_prompt set' do
        let(:first_prompt) { create(:prompt, prompt: 'This is a test') }
        let(:second_prompt) { create(:prompt, prompt: 'This is a test') }

        it 'is invalid' do
          first_prompt.next_prompt = second_prompt.id
          first_prompt.save!

          first_prompt.reported = true
          expect(first_prompt.valid?).to eq(false)
          expect(first_prompt.errors.messages[:reported]).to eq(['can not be set for locked in story'])
        end
      end
    end
  end

  describe '#report' do
    it 'marks prompt as reported' do
      prompt = create(:prompt, id: 2, prompt: 'This is a test')
      expect(prompt.reported).to eq(false)

      prompt.report!
      prompt = Prompt.find(prompt.id)
      expect(prompt.reported).to eq(true)
    end
  end
end
