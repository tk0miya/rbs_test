# frozen_string_literal: true

require "rbs"
require "active_support/ordered_options"
require "active_support/core_ext/string/inflections"

module RbsConfig
  module RailsConfig
    def self.generate(mapping:)
      Generator.new(mapping: mapping).generate
    end

    class Generator
      attr_reader :mapping

      def initialize(mapping:)
        @mapping = mapping
      end

      def generate
        classes = generate_classes(mapping)
        methods = mapping.map do |key, value|
          "def #{key}: () -> #{stringify_type(key, value)}"
        end

        format <<~RBS
          module Rails
            class Application
              class Configuration
                #{classes.join("\n")}
                #{methods.join("\n")}
              end
            end

            def self.configuration: () -> Application::Configuration | ...
          end
        RBS
      end

      private

      def format(rbs)
        parsed = RBS::Parser.parse_signature(rbs)
        StringIO.new.tap do |out|
          RBS::Writer.new(out: out).write(parsed[1] + parsed[2])
        end.string
      end

      def generate_classes(config)
        config.filter_map do |key, value|
          next unless value.is_a?(ActiveSupport::OrderedOptions)

          classes = generate_classes(value)
          methods = generate_methods(value)

          <<~RBS
            class #{key.to_s.camelize}
              #{classes.join("\n")}
              #{methods.join("\n")}
            end
          RBS
        end
      end

      def generate_methods(config)
        case config
        when ActiveSupport::OrderedOptions
          generate_ordered_options_methods(config)
        when Hash
          generate_hash_methods(config)
        end
      end

      def generate_ordered_options_methods(config)
        methods = config.map do |key, value|
          type = stringify_type(key, value)
          <<~RBS
            def #{key}: () -> #{type}
            def #{key}!: () -> #{type}
          RBS
        end

        brace_method_type = config.map do |key, value|
          "(:#{key}) -> #{stringify_type(key, value)}"
        end.join(" | ")

        methods + ["def []: #{brace_method_type}"]
      end

      def generate_hash_methods(config)
        method_type = config.map do |key, value|
          "(:#{key} | \"#{key}\") -> #{stringify_type(key, value)}"
        end.join(" | ")
        ["def []: #{method_type}"]
      end

      def stringify_type(name, value) # rubocop:disable Metrics/CyclomaticComplexity
        case value
        when ActiveSupport::OrderedOptions
          name.to_s.camelize
        when Hash
          pairs = value.map do |k, v|
            "#{k}: #{stringify_type(k, v)}"
          end
          "{ #{pairs.join(", ")} }"
        when Array
          types = value.map { |v| stringify_type(name, v) }.uniq
          "Array[#{types.join(" | ")}]"
        when NilClass
          "nil"
        when TrueClass, FalseClass
          "bool"
        else
          value.class.to_s
        end
      end
    end
  end
end
