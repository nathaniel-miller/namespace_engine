require 'test_helper'
require 'generators/namespace_engine/namespace_engine_generator'

class NamespaceEngineGeneratorTest < Rails::Generators::TestCase
  tests NamespaceEngineGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
