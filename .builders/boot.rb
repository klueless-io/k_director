# Boot Sequence

include KLog::Logging

CONFIG_KEY = :k_director

log.kv 'working folder', Dir.pwd

Handlebars::Helpers.configure do |config|
  config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_helpers.json')
  config.helper_config_file = config_file

  string_config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_string_formatters.json')
  config.string_formatter_config_file = string_config_file
end

def camel
  require 'handlebars/helpers/string_formatting/camel'
  Handlebars::Helpers::StringFormatting::Camel.new
end

def titleize
  require 'handlebars/helpers/string_formatting/titleize'
  Handlebars::Helpers::StringFormatting::Titleize.new
end

def pluralize
  require 'handlebars/helpers/inflection/pluralize'
  Handlebars::Helpers::Inflection::Pluralize.new
end

def singularize
  require 'handlebars/helpers/inflection/singularize'
  Handlebars::Helpers::Inflection::Singularize.new
end

def dasherize
  require 'handlebars/helpers/string_formatting/dasherize'
  Handlebars::Helpers::StringFormatting::Dasherize.new
end

def k_builder
  @k_builder ||= KBuilder::BaseBuilder.init(KBuilder.configuration(CONFIG_KEY))
end

KBuilder.configure(CONFIG_KEY) do |config|
  builder_folder    = Dir.pwd
  base_folder       = File.expand_path('../', builder_folder)
  global_template   = File.expand_path('~/dev/kgems/k_templates/templates')

  config.template_folders.add(:global_template    , global_template)
  config.template_folders.add(:template           , File.expand_path('.templates', Dir.pwd))

  config.target_folders.add(:app                  , base_folder)
  config.target_folders.add(:builder              , builder_folder)
  # config.target_folders.add(:tailwind_elements    , global_template, 'tailwind', 'elements')
  # config.target_folders.add(:data                 , :builder, 'data')
  # config.target_folders.add(:database             , :data, 'database')
end

KBuilder.configuration(CONFIG_KEY).debug

area = KManager.add_area(CONFIG_KEY)
resource_manager = area.resource_manager
resource_manager
  .fileset
  .glob('*.rb', exclude: ['boot.rb'])
  .glob('generators/**/*.rb')
resource_manager.add_resources

KManager.fire_actions(:load_content, :register_document, :load_document)
