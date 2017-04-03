require 'fileutils'
require 'rails/generators'
# require "rails/generators/rails/app/app_generator"
require_relative "rails_namespace_engine/version"

class NamespaceEngine
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
      invoke_generator
      structure_files_and_directories
      file_contents
    end
  end

  def instructions
    insts = <<-INSTS

      These are the instructions.
    INSTS

    insts
  end

  def invoke_generator
    Rails::Generators.invoke('plugin', [engine_name])
    FileUtils.cd('../../../')
  end

  def structure_files_and_directories
    FileUtils.mkdir './engines', verbose: true unless Dir.exists?('./engines')
    FileUtils.mv "#{engine_name}", './engines', verbose: true
    FileUtils.mkdir "./engines/#{engine_name}/lib/#{namespace}", verbose: true
    FileUtils.mv "./engines/#{engine_name}/lib/#{engine_name}",
      "./engines/#{engine_name}/lib/#{namespace}",
      verbose: true
    FileUtils.mv "./engines/#{engine_name}/lib/#{engine_name}.rb",
      "./engines/#{engine_name}/lib/#{namespace}",
      verbose: true
    FileUtils.touch "./engines/#{engine_name}/lib/#{namespace}_#{engine_name}.rb",
      verbose: true
    FileUtils.mv "./engines/#{engine_name}/#{engine_name}.gemspec",
      "./engines/#{engine_name}/#{namespace}_#{engine_name}.gemspec",
      verbose: true
  end

  def file_contents
    files = []
    files[0] = {}
    files[0][:file] = "./engines/#{engine_name}/lib/#{namespace}_#{engine_name}.rb"
    files[0][:contents] = <<-EOF.strip_heredoc
      require "#{namespace}/#{engine_name}/engine"
      require "#{namespace}/#{engine_name}"
    EOF

    files[1] = {}
    files[1][:file] = "./engines/#{engine_name}/lib/#{namespace}/#{engine_name}.rb"
    files[1][:contents] = <<-EOF.strip_heredoc
      module #{namespace.camelize}
        module #{engine_name.camelize}
          # Your code goes here...
        end
      end
    EOF

    files[2] = {}
    files[2][:file] = "./engines/#{engine_name}/lib/#{namespace}/#{engine_name}/version.rb"
    files[2][:contents] = <<-EOF.strip_heredoc
      module #{namespace.camelize}
        module #{engine_name.camelize}
          VERSION = '0.1.0'
        end
      end
    EOF

    write_to(files)

  end

  def write_to(files)
    files.each do |f|
      File.open(f[:file], 'w') do |file|
        file.write f[:contents]
      end
    end
  end

end
