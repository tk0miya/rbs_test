# frozen_string_literal: true

require "rbs_config"
require "tempfile"

RSpec.describe RbsConfig::RailsConfig do
  describe ".generate" do
    subject { described_class.generate(mapping: mapping) }

    let(:mapping) do
      {
        foo: {
          bar: 1,
          baz: true
        },
        qux: ActiveSupport::OrderedOptions[:bar, 1, :baz, { quux: 2 }]
      }
    end
    let(:expected) do
      <<~RBS
        module Rails
          class Application
            class Configuration
              class Qux
                def bar: () -> Integer
                def bar!: () -> Integer

                def baz: () -> { quux: Integer }
                def baz!: () -> { quux: Integer }

                def []: (:bar) -> Integer
                      | (:baz) -> { quux: Integer }
              end

              def foo: () -> { bar: Integer, baz: bool }
              def qux: () -> Qux
            end
          end

          def self.configuration: () -> Application::Configuration
                                | ...
        end
      RBS
    end

    it { is_expected.to eq(expected) }
  end
end
