class NamespaceEngineGenerator < Rails::Generators::NamedBase
  # source_root File.expand_path('../templates', __FILE__)

  class_option :dummy_path,   type: :string, default: "test/dummy",
                              desc: "Create dummy application at given path"

  class_option :full,         type: :boolean, default: false,
                              desc: "Generate a rails engine with bundled Rails application for testing"

  class_option :mountable,    type: :boolean, default: false,
                              desc: "Generate mountable isolated application"

  class_option :skip_gemspec, type: :boolean, default: false,
                              desc: "Skip gemspec file"

  class_option :skip_gemfile_entry, type: :boolean, default: false,
                                    desc: "If creating plugin in application's directory " \
                                             "skip adding entry to Gemfile"

  class_option :api,          type: :boolean, default: false,
                              desc: "Generate a smaller stack for API application plugins"

  def initialize(*args)
    @dummy_path = nil
    super
  end

  public_task :set_default_accessors!
  public_task :create_root

  def create_root_files
    build(:readme)
    build(:rakefile)
    build(:gemspec)   unless options[:skip_gemspec]
    build(:license)
    build(:gitignore) unless options[:skip_git]
    build(:gemfile)   unless options[:skip_gemfile]
  end

  def create_app_files
    build(:app)
  end

  def create_config_files
    build(:config)
  end

  def create_lib_files
    build(:lib)
  end

  def create_assets_manifest_file
    build(:assets_manifest) if !api? && engine?
  end

  def create_public_stylesheets_files
    build(:stylesheets) unless api?
  end

  def create_javascript_files
    build(:javascripts) unless api?
  end

  def create_bin_files
    build(:bin)
  end

  def create_test_files
    build(:test) unless options[:skip_test]
  end

  def create_test_dummy_files
    return unless with_dummy_app?
    create_dummy_app
  end

  def update_gemfile
    build(:gemfile_entry) unless options[:skip_gemfile_entry]
  end

  def finish_template
    build(:leftovers)
  end

  public_task :apply_rails_template

  def run_after_bundle_callbacks
    @after_bundle_callbacks.each do |callback|
      callback.call
    end
  end

  def name
    @name ||= begin
      # same as ActiveSupport::Inflector#underscore except not replacing '-'
      underscored = original_name.dup
      underscored.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      underscored.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      underscored.downcase!

      underscored
    end
  end

  def underscored_name
    @underscored_name ||= original_name.underscore
  end

  def namespaced_name
    @namespaced_name ||= name.tr("-", "/")
  end

  private

  def create_dummy_app(path = nil)
    dummy_path(path) if path

    say_status :vendor_app, dummy_path
    mute do
      build(:generate_test_dummy)
      store_application_definition!
      build(:test_dummy_config)
      build(:test_dummy_assets)
      build(:test_dummy_clean)
      # ensure that bin/rails has proper dummy_path
      build(:bin, true)
    end
  end

  def engine?
    full? || mountable? || options[:engine]
  end

  def full?
    options[:full]
  end

  def mountable?
    options[:mountable]
  end

  def skip_git?
    options[:skip_git]
  end

  def with_dummy_app?
    options[:skip_test].blank? || options[:dummy_path] != "test/dummy"
  end

  def api?
    options[:api]
  end

  def self.banner
    "rails plugin new #{arguments.map(&:usage).join(' ')} [options]"
  end

  def original_name
    @original_name ||= File.basename(destination_root)
  end

  def modules
    @modules ||= namespaced_name.camelize.split("::")
  end

  def wrap_in_modules(unwrapped_code)
    unwrapped_code = "#{unwrapped_code}".strip.gsub(/\s$\n/, "")
    modules.reverse.inject(unwrapped_code) do |content, mod|
      str = "module #{mod}\n"
      str += content.lines.map { |line| "  #{line}" }.join
      str += content.present? ? "\nend" : "end"
    end
  end

  def camelized_modules
    @camelized_modules ||= namespaced_name.camelize
  end

  def humanized
    @humanized ||= original_name.underscore.humanize
  end

  def camelized
    @camelized ||= name.gsub(/\W/, "_").squeeze("_").camelize
  end

  def author
    default = "TODO: Write your name"
    if skip_git?
      @author = default
    else
      @author = `git config user.name`.chomp rescue default
    end
  end

  def email
    default = "TODO: Write your email address"
    if skip_git?
      @email = default
    else
      @email = `git config user.email`.chomp rescue default
    end
  end

  def valid_const?
    if original_name =~ /-\d/
      raise Error, "Invalid plugin name #{original_name}. Please give a name which does not contain a namespace starting with numeric characters."
    elsif original_name =~ /[^\w-]+/
      raise Error, "Invalid plugin name #{original_name}. Please give a name which uses only alphabetic, numeric, \"_\" or \"-\" characters."
    elsif camelized =~ /^\d/
      raise Error, "Invalid plugin name #{original_name}. Please give a name which does not start with numbers."
    elsif RESERVED_NAMES.include?(name)
      raise Error, "Invalid plugin name #{original_name}. Please give a " \
                   "name which does not match one of the reserved rails " \
                   "words: #{RESERVED_NAMES.join(", ")}"
    elsif Object.const_defined?(camelized)
      raise Error, "Invalid plugin name #{original_name}, constant #{camelized} is already in use. Please choose another plugin name."
    end
  end

  def application_definition
    @application_definition ||= begin

      dummy_application_path = File.expand_path("#{dummy_path}/config/application.rb", destination_root)
      unless options[:pretend] || !File.exist?(dummy_application_path)
        contents = File.read(dummy_application_path)
        contents[(contents.index(/module ([\w]+)\n(.*)class Application/m))..-1]
      end
    end
  end
  alias :store_application_definition! :application_definition

  def get_builder_class
    defined?(::PluginBuilder) ? ::PluginBuilder : Rails::PluginBuilder
  end

  def rakefile_test_tasks
    <<-RUBY
  require 'rake/testtask'

  Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
  end
    RUBY
  end

  def dummy_path(path = nil)
    @dummy_path = path if path
    @dummy_path || options[:dummy_path]
  end

  def mute(&block)
    shell.mute(&block)
  end

  def rails_app_path
    APP_PATH.sub("/config/application", "") if defined?(APP_PATH)
  end

  def inside_application?
    rails_app_path && destination_root.start_with?(rails_app_path.to_s)
  end

  def relative_path
    return unless inside_application?
    app_path.sub(/^#{rails_app_path}\//, "")
  end


end
