# rbs_config

rbs_config is a RBS generator for Rails configuration.

Now supports the following configuration:

* Rails configuration (`Rails.configuration`)
* [config gem](https://github.com/rubyconfig/config)

## Installation

Add a new entry to your Gemfile and run `bundle install`:

    group :development do
      gem 'rbs_config', require: false
    end

After the installation, please run rake task generator:

    bundle exec rails g rbs_config:install

And then, please modify `lib/tasks/rbs_config.rake` to fit your application.
For example, set it up like this if you're using Rails configuration:

    RbsConfig::RakeTask.new do |task|
      task.type = :rails
      task.mapping = { conf_name: Rails.application.config_for(:conf_name) }
    end

Then, rbs_config will generate RBS file for `Rails.application.conf_name` from your
configuration file.

## Usage

Run `rbs:config:setup` task:

    bundle exec rake rbs:config:setup

Then rbs_config will scan your source code and generate RBS file into `sig/config` directory.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also
run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, and then put
a git tag (ex. `git tag v1.0.0`) and push it to the GitHub. Then GitHub Actions
will release a new package to [rubygems.org](https://rubygems.org) automatically.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tk0miya/rbs_config.
This project is intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [code of conduct](https://github.com/tk0miya/rbs_config/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RbsConfig project's codebases and issue trackers is expected to
follow the [code of conduct](https://github.com/tk0miya/rbs_config/blob/main/CODE_OF_CONDUCT.md).
