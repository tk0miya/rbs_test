# frozen_string_literal: true

require "rails"

module RbsConfig
  class InstallGenerator < Rails::Generators::Base
    def create_raketask
      create_file "lib/tasks/rbs_config.rake", <<~RUBY
        begin
          # frozen_string_literal: true

          require "rbs_config/rake_task"

          RbsConfig::RakeTask.new do |task|
            # The type of configuration (default: :config)
            # task.type = :config | :rails

            # The class name of configuration object (for :config type)
            # task.class_name = "Settings"

            # The files to be loaded (for :config type)
            # task.files = [Pathname(Rails.root / "config/settings.yml")]

            # The mapping of configuration (for :rails type)
            # task.mapping = { foo: Rails.application.config_for(:foo) }
          end
        rescue LoadError
          # failed to load rbs_config. Skip to load rbs_config tasks.
        end
      RUBY
    end
  end
end
