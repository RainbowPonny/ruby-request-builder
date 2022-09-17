RSpec.describe Request::Builder::Result do
  class TestApiResult
    include Request::Builder

    configure do
      adapter :test

      host 'http://api.com/'
      path '/api/'

      schema do
        required(:hello).value(eql?: 'world')
      end

      before_validate do |body|
        body.delete(:unnecessary_flag)
        body
      end
    end
  end

  it 'has a version number' do
    expect(Request::Builder::VERSION).not_to be nil
  end

  describe '.new' do
    let!(:response_body) { { hello: 'world', unnecessary_flag: false, not_in_schema: 123 } }
    let!(:response_status) { 200 }
    let!(:response) { double('response', body: response_body, status: response_status, headers: { 'Content-Type' => 'application/json'}) }

    subject { Request::Builder::Result.new(response, TestApiResult.new) }

    it 'applies before_validate callback to body' do
      expect(subject.body).to eq({ hello: 'world', not_in_schema: 123 })
    end

    it { expect(subject.schema_result.to_h).to eq({ hello: 'world' }) }
    it { expect(subject.success?).to be true }
    it { expect(subject.failure?).to be false }
    it { expect(subject.status).to be response_status }

    context 'when schema invalid' do
      let!(:response_body) { { hello: 'invalid', unnecessary_flag: false, not_in_schema: 123 } }

      it { expect(subject.success?).to be false }
      it { expect(subject.failure?).to be true }
      it { expect(subject.errors.count).not_to be 0 }
    end

    context 'when status invalid' do
      let!(:response_status) { 404 }

      it { expect(subject.success?).to be false }
      it { expect(subject.failure?).to be true }
    end
  end
end
