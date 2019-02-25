RSpec.describe Spiketime do
  let!(:redis) { MockRedis.new }

  before do
    allow_any_instance_of(Spiketime).to receive(:setup_redis) { redis }
    redis.flushdb
  end

  let(:holidays_berlin_2019) do
    [
      '2019-01-01', '2019-04-19', '2019-04-21', '2019-04-22',
      '2019-05-01', '2019-05-30', '2019-06-09', '2019-06-10',
      '2019-10-03', '2019-12-25', '2019-12-26'
    ]
  end

  describe '#get_holidays' do
    context 'when fetching from API' do
      let!(:holidays) { Spiketime.new(state: 'BE').get_holidays('2019') }

      it { expect(holidays).to contain_exactly(holidays_berlin_2019) }
      it { expect_any_instance_of(Spiketime).to receive(:get).once }
    end

    context 'when fetching from redis cache' do
      before do
        redis.set('spiketime:holidays:BE:2019', holidays_berlin_2019)
        Spiketime.new(state: 'BE').get_holidays('2019')
      end

      it { expect_any_instance_of(Spiketime).to receive(:setup_redis).once }
    end

    context 'when state code is wrong' do
      it do
        expect(Spiketime.new(state: 'Berlin').get_holidays('2019')).to raise_error
      end
    end
  end

  describe '#holiday?' do
    context 'when it is a holiday' do
      subject { Spiketime.new(state: 'BE').holiday?('2019-04-19') }
      it { expect(subject).to be_truthy }
    end

    context 'when it is not a holiday' do
      subject { Spiketime.new(state: 'BE').holiday?('2019-04-20') }
      it { expect(subject).to be_falsey }
    end
  end
end
