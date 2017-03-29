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
    elsif invalid?
      puts error_message
      puts instructions
    else
      create_directories
    end
  end

  def instructions
    insts = <<-INSTS
    
      These are the instructions.
    INSTS

    insts
  end

  def error_message
    error = <<-ERR

      There is no engine with the name of #{engine_name}.
    ERR
  end

  def invalid?
    invalid = false
    invalid = true unless Dir.exists?("./#{engine_name}")

    invalid
  end

  def create_directories
    FileUtils.mkdir './engines' unless Dir.exists?('./engines')
  end
end
