require 'fileutils'
require 'rails/generators'
# require "rails/generators/rails/app/app_generator"
require_relative "rails_namespace_engine/version"

class NamespaceEngine
  # include Rails::Generators::Base

  attr_reader :help, :namespace, :engine_name

  def initialize(argv)
    argv[0] = '--help' if argv.size < 2

    if argv[0] == '--help'
      @help = true
    else
      @help = false
      @namespace = argv[0].underscore
      @engine_name = argv[1].underscore
    end
  end

  def call
    if help
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

  def create_directories
    Rails::Generators.invoke('plugin', [engine_name])
    FileUtils.cd('../../../')
    FileUtils.mkdir './engines', verbose: true unless Dir.exists?('./engines')
    FileUtils.mv "#{engine_name}", './engines', verbose: true
    FileUtils.mkdir "./engines/#{engine_name}/lib/#{namespace}", verbose: true
    FileUtils.mv "./engines/#{engine_name}/lib/#{engine_name}",
      "./engines/#{engine_name}/lib/#{namespace}",
      verbose: true
    FileUtils.mv "./engines/#{engine_name}/lib/#{engine_name}.rb",
      "./engines/#{engine_name}/lib/#{namespace}",
      verbose: true
  end
end
