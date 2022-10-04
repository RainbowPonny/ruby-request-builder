RSpec.describe Request::Builder do
  class TestApi
    include Request::Builder

    option :option1
    option :option2
    option :option3
    option :option4
    option :option5

    configure do
      adapter :test
      response_middleware :json
      request_middleware :json
      method :get
      logger Logger.new(nil)
      timeout 10

      host 'http://api.com/'
      path { "/api/#{option1}/" }

      headers do
        header 'header1', -> { option1 }
      end

      header 'header2', &:option2

      params do
        param 'param1', -> { config.body[:hello] }
        param 'param2', &:option2
        param 'param3' do option3 end
      end

      param 'param4', -> { option4 }

      body do
        {
          hello: option1,
          world: option5
        }
      end

      before_validate do |body|
        body.deep_symbolize_keys
      end
    end
  end

  it "has a version number" do
    expect(Request::Builder::VERSION).not_to be nil
  end

  describe ".configure" do
    let!(:option1) { '2.0' }
    let!(:option2) { FFaker::Lorem.word }
    let!(:option3) { FFaker::Lorem.word }
    let!(:option4) { FFaker::Lorem.word }
    let!(:option5) { FFaker::Lorem.word }

    subject { TestApi.new(option1: option1, option2: option2, option3: option3, option4: option4, option5: option5) }

    it 'sets right body conf' do
      aggregate_failures do
        expect(subject.config.body).to include(hello: option1, world: option5)
        expect(subject.config.body).to be_a_kind_of(Hash)
      end
    end

    it 'sets right host and path' do
      aggregate_failures do
        expect(subject.config.path).to eq("/api/#{option1}/")
        expect(subject.config.host).to eq('http://api.com/')
      end
    end

    it 'sets right params' do
      aggregate_failures do
        expect(subject.config.params[:param1]).to eq(option1)
        expect(subject.config.params[:param2]).to eq(option2)
        expect(subject.config.params[:param3]).to eq(option3)
        expect(subject.config.params[:param4]).to eq(option4)
      end
    end

    it 'sets right headers' do
      aggregate_failures do
        expect(subject.config.headers[:header1]).to eq(option1)
        expect(subject.config.headers[:header2]).to eq(option2)
      end
    end

    it 'sets right timeout' do
      expect(subject.config.timeout).to eq(10)
    end

    it 'sets logger' do
      aggregate_failures do
        expect(subject.config.logger).not_to be(nil)
        expect(subject.config.logger).to be_a_kind_of(Logger)
      end
    end

    it 'sets schema' do
      aggregate_failures do
        expect(subject.config.schema).not_to be(nil)
        expect(subject.config.schema).to be_a_kind_of(Dry::Schema::Params)
      end
    end

    it 'sets before_validate callback' do
      aggregate_failures do
        expect(subject.config.callbacks[:before_validate]).not_to be(nil)
        expect(subject.config.callbacks[:before_validate]).to be_a_kind_of(Proc)
      end
    end
  end

  describe '.perform' do
    let!(:option1) { '2.0' }
    let!(:option2) { FFaker::Lorem.word }
    let!(:option3) { FFaker::Lorem.word }
    let!(:option4) { FFaker::Lorem.word }
    let!(:option5) { FFaker::Lorem.word }

    subject { TestApi.new(option1: option1, option2: option2, option3: option3, option4: option4, option5: option5) }

    it 'sends right params' do
      TestApi.config.stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/#{option1}/") { |env| [ 200, {}, env.params ]}
      end

      expect(subject.call.body).to include(param1: option1, param2: option2, param3: option3, param4: option4)
    end

    it 'sends right body' do
      TestApi.config.stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/#{option1}/") { |env| [ 200, {}, env.body ]}
      end

      expect(subject.call.body).to include(hello: option1, world: option5)
    end

    it 'sends right headers' do
      TestApi.config.stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/#{option1}/") { |env| [ 200, env.request_headers, {} ]}
      end

      expect(subject.call.headers).to include(header1: option1, header2: option2)
    end

    it 'returns Request::Builder::Result object' do
      TestApi.config.stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/#{option1}/") { |env| [ 200, {}, {} ]}
      end

      expect(subject.call).to be_a_kind_of(Request::Builder::Result)
    end
  end

  describe '.default_adapter' do
    class TestApiAdapter
      include Request::Builder
    end

    it 'sets default faraday adapter' do
      Request::Builder.default_adapter(:httpclient)

      expect(TestApiAdapter.config.adapter).to eq(:httpclient)
    end
  end
end
