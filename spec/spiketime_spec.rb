# rubocop:disable Metrics/BlockLength
RSpec.describe Spiketime do
  let!(:redis) { MockRedis.new }
  let!(:response) do
    OpenStruct.new(body: File.read(__dir__ + '/fixtures/holidays_berlin_2019.json'),
                   status: 200)
  end

  before do
    allow_any_instance_of(Spiketime).to receive(:setup_redis) { redis }
    allow_any_instance_of(Spiketime).to receive(:get) { response }
    redis.flushdb
  end

  let!(:holidays_berlin_2019) do
    [
      '2019-01-01', '2019-04-19', '2019-04-21', '2019-04-22',
      '2019-05-01', '2019-05-30', '2019-06-09', '2019-06-10',
      '2019-10-03', '2019-12-25', '2019-12-26'
    ]
  end

  let!(:cached_holidays) do
    [
      '2018-01-01', '2018-04-19', '2018-04-21', '2018-04-22',
      '2018-05-01', '2018-05-30', '2018-06-09', '2018-06-10',
      '2018-10-03', '2018-12-25', '2018-12-26'
    ]
  end

  describe '#get_holidays' do
    context 'when fetching from API' do
      let!(:holidays) { Spiketime.new(state: 'BE').get_holidays('2019') }

      it { expect(holidays).to contain_exactly(*holidays_berlin_2019) }
    end

    context 'when fetching from redis cache' do
      before { redis.set('spiketime:holidays:BE:2018', cached_holidays) }
      let!(:holidays) { Spiketime.new(state: 'BE').get_holidays('2018') }

      it { expect(holidays).to contain_exactly(*cached_holidays) }
    end

    context 'when state code is wrong' do
      it do
        expect { Spiketime.new(state: 'Berlin').get_holidays('2019') }.to raise_error(SpiketimeUnsupportedStateError)
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
# rubocop:enable Metrics/BlockLength
