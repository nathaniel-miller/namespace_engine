require 'fileutils'
require 'rails/generators'
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
    Rails::Generators.invoke('plugin', [engine_name, '--mountable'])
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

    files[3] = {}
    files[3][:file] = "./engines/#{engine_name}/lib/#{namespace}/#{engine_name}/engine.rb"
    files[3][:contents] = <<-EOF.strip_heredoc
      module #{namespace.camelize}
        module #{engine_name.camelize}
          class Engine < ::Rails::Engine
            isolate_namespace #{namespace.camelize}
          end
        end
      end
    EOF

    files[4] = {}
    files[4][:file] = "./engines/#{engine_name}/#{namespace}_#{engine_name}.gemspec"
    contents = File.read(files[4][:file])

    patterns = [{},{},{}]
    patterns[0][:original] = %Q'#{engine_name}/version'
    patterns[0][:update] = %Q'#{namespace}/#{engine_name}/version'
    patterns[1][:original] = %Q'= "#{engine_name}"'
    patterns[1][:update] = %Q'= "#{namespace}_#{engine_name}"'
    patterns[2][:original] = %'#{engine_name.camelize}::VERSION'
    patterns[2][:update] = %'#{namespace.camelize}::#{engine_name.camelize}::VERSION'

    patterns.each do |pattern|
      files[4][:contents] = contents.gsub!(pattern[:original], pattern[:update])
    end

    files[5] = {}
    files[5][:file] = "./engines/#{engine_name}/bin/rails"
    contents = File.read(files[5][:file])
    old_path = "../../lib/#{engine_name}"
    updated_path = "../../lib/#{namespace}/#{engine_name}"
    files[5][:contents] = contents.gsub(old_path, updated_path)

    files[6] = {}
    files[6][:file] = "./engines/#{engine_name}/config/routes.rb"
    files[6][:contents] = <<-EOF.strip_heredoc
      #{namespace.camelize}::#{engine_name.camelize}::Engine.routes.draw do
      end
    EOF

    add_gem_to_gemfile = <<-GEM.strip_heredoc

      #Add unpacked gem directly from file system
      gem '#{namespace}_#{engine_name}', path: 'engines/#{engine_name}'
    GEM

    File.open('Gemfile', 'a') do |file|
      file.write add_gem_to_gemfile
    end



    tempfile = File.open("config/routes.tmp", 'w')
    f = File.new("config/routes.rb")

    f.each do |line|
      tempfile << line
      if line =~ /Rails.application.routes.draw do/
        tempfile << "  mount #{namespace.camelize}::#{engine_name.camelize}::Engine => '/#{engine_name}', as: '#{engine_name}' \n"
      end
    end

    f.close
    tempfile.close

    FileUtils.mv("config/routes.tmp", "config/routes.rb")




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
