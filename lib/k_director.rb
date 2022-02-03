# frozen_string_literal: true

require 'k_log'
require 'k_util'
require 'k_builder'
require 'k_ext/github'

require_relative 'k_director/version'
require_relative 'k_director/builders/actions_builder'
require_relative 'k_director/directors/base_director'
require_relative 'k_director/directors/child_director'
require_relative 'k_director/directors/data'
require_relative 'k_director/dsls/children/blueprint'
require_relative 'k_director/dsls/children/github'
require_relative 'k_director/dsls/nuxt3_dsl'

module KDirector
  # raise KDirector::Error, 'Sample message'
  Error = Class.new(StandardError)

  # Your code goes here...
end

if ENV['KLUE_DEBUG']&.to_s&.downcase == 'true'
  namespace = 'KDirector::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_director/version') }
  version   = KDirector::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
