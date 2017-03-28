require 'fileutils'
require_relative "rails_namespace_engine/version"


class RailsNamespaceEngine::CLI

  def call(argv)
    argv[0] = '--help' if argv.size < 2

    if argv[0] == '--help'
      puts instructions
    else
      @namespace = argv[0]
      @engine_name = argv[1]
    end
  end



  def instructions
    insts = <<-INSTS
      These are the instructions.
    INSTS

    insts
  end



  # FileUtils.mkdir 'engines'
  # Your code goes here...
end
