require 'fileutils'
require_relative "rails_namespace_engine/version"


class RailsNamespaceEngine::CLI
  attr_reader :help, :namespace, :engine_name

  def initialize(argv)
    argv[0] = '--help' if argv.size < 2

    if argv[0] == '--help'
      @help = true
    else
      @help = false
      @namespace = argv[0]
      @engine_name = argv[1]
    end
  end

  def call
    if help
      puts instructions
    else
      generate
    end
  end

  def instructions
    insts = <<-INSTS
      These are the instructions.
    INSTS

    insts
  end

  def generate
    puts "#{namespace} and #{engine_name}"
    # create_engines_dir
    puts Dir.pwd
  end

  def create_engines_dir
    # FileUtils.mkdir '~/engines'

  end
end
