# Request::Builder

Simple DSL wrapper for faraday gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request-builder'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install request-builder

## Usage

Include `Request::Builder` to your client class and describe your request using DSL

```ruby
class MyApiClient
  include Request::Builder

  option :my_option
  option :my_header_value

  configure do
    adapter :net_http
    response_middleware :json
    request_middleware :json
    method :get
    logger Logger.new(STDOUT)
    timeout 10

    host 'http://api.forismatic.com/'
    path '/api/1.0/'

    params do
      # you can pass a block or lambda to params
      # this allows you to use object variables or configuration variables 
      param 'param1', &:my_option
      param 'param2', -> { "#{my_option}" }
      param('param3') { my_option }
      param 'param4' 'string'
    end
  
    headers do
      header 'header1', &:my_header_value
    end

    # in body you can use object variables or configuration variables too
    body do
      {
        'hello' => lang,
        'path' => config.path
      }
    end

    # this callback executes after receiving the response
    before_validate do |body|
      body.delete('unnecessary_param')
      body.deep_symbolize_keys
      body
    end

    # you can use dry-schema to validate response
    schema do
      required(:status).value(eql?: 'success')
    end
  end
end
```

After you describe your request class you can use it:

```ruby
result = MyApiClient.call(my_option: 'some_value', my_header_value: 'header_value')

result.success? # true if status code == 200 and schema is valid 
result.failure?
result.status # result code - Integer
result.headers # hash of headers
result.body # raw body from request
result.schema_result # result of dry-schema
result.full_errors # array of errors from dry-schema
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/request-builder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/request-builder/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Request::Builder project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/request-builder/blob/master/CODE_OF_CONDUCT.md).
