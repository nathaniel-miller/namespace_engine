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
      Simply provide two arguments.
      The first is the name of the namespace you wish to use.
      The second is the name used for the generated engine.

      Ex. rne my_namespace my_engine.

      This script will run 'rails plugin new engine_name --mountable'.
      It then uses the provided namespace argument to restructure the file
      directory and alter the appropriate files.

      The precise nature of these alterations can be viewed in this gems README
      file or at 'http://m.ller.io/namespacing-for-rails-engines/'.
    INSTS

    insts
  end

  def invoke_generator
    Rails::Generators.invoke('plugin', [engine_name, '--mountable'])
    FileUtils.cd('../../../')
  end

  def structure_files_and_directories
    root = "./engines/#{engine_name}"
    path_one = "#{root}/lib/#{namespace}"
    path_two = "#{root}/lib/#{engine_name}"


    FileUtils.mkdir './engines', verbose: true unless Dir.exists?('./engines')
    FileUtils.mv "#{engine_name}", './engines', verbose: true
    FileUtils.mkdir path_one, verbose: true
    FileUtils.mv path_two, path_one, verbose: true
    FileUtils.mv "#{path_two}.rb", path_one, verbose: true
    FileUtils.touch "#{path_one}_#{engine_name}.rb", verbose: true
    FileUtils.mv "#{root}/#{engine_name}.gemspec",
      "#{root}/#{namespace}_#{engine_name}.gemspec",
      verbose: true
  end

  def file_contents
    root = "./engines/#{engine_name}"
    namespace_path = "#{root}/lib/#{namespace}"

    files = []
    files[0] = {}
    files[0][:file] = "#{namespace_path}_#{engine_name}.rb"
    files[0][:contents] = <<-EOF.strip_heredoc
      require "#{namespace}/#{engine_name}/engine"
      require "#{namespace}/#{engine_name}"
    EOF

    files[1] = {}
    files[1][:file] = "#{namespace_path}/#{engine_name}.rb"
    files[1][:contents] = <<-EOF.strip_heredoc
      module #{namespace.camelize}
        module #{engine_name.camelize}
          # Your code goes here...
        end
      end
    EOF

    files[2] = {}
    files[2][:file] = "#{namespace_path}/#{engine_name}/version.rb"
    files[2][:contents] = <<-EOF.strip_heredoc
      module #{namespace.camelize}
        module #{engine_name.camelize}
          VERSION = '0.1.0'
        end
      end
    EOF

    files[3] = {}
    files[3][:file] = "#{namespace_path}/#{engine_name}/engine.rb"
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
    files[4][:file] = "#{root}/#{namespace}_#{engine_name}.gemspec"
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
    files[5][:file] = "#{root}/bin/rails"
    contents = File.read(files[5][:file])
    old_path = "../../lib/#{engine_name}"
    updated_path = "../../lib/#{namespace}/#{engine_name}"
    files[5][:contents] = contents.gsub(old_path, updated_path)

    files[6] = {}
    files[6][:file] = "#{root}/config/routes.rb"
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
