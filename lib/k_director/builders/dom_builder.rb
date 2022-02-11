# frozen_string_literal: true

module KDirector
  module Builders
    # Dom builder
    class DomBuilder
      attr_reader :dom

      def initialize
        reset
      end

      def reset
        @dom = {}
      end

      # Set many key/value pairs gainst a group
      #
      # example:
      #   group_set(:github, repo_name: 'repo-name', organization: 'org-name')
      def group_set(group = nil, **opts)
        return if group.nil? && opts.empty?

        if group.nil?
          opts.each do |key, value|
            set(key, value: value)
          end
        else
          dom[group] = {} if opts.empty? # initialize the group name if no options are provided
          opts.each do |key, value|
            set(group, key, value: value)
          end
        end
      end

      # set key_set/value pair, can be used for
      #
      # - simple key/value pairs
      # - initialize key/array pairs
      #
      # example:
      #   set(:a, value: 1)
      #   set(:a, value: [])
      #   set(:a, value: [1, 2, 3])
      #   set(:a, value: { a: 1, b: 2 })
      #   set(:a, value: some_value, default_value: 'use if not supplied')
      #   set(:a, value: :b, 'nested value')
      #   set(:a, value: :b, :c, 'deeply nested value')
      #   set(:a, value: :b, :c, :d, :e, :f, 'depth is no barrier')
      def set(*keys, value: nil, default_value: nil)
        size = keys.size

        raise ArgumentError, 'set requires 1 or more keys' if size < 1

        target = initialize_hierarchy(keys)

        set_kv(target, keys[size - 1], value, default_value: default_value)
      end

      # add value to array
      #   add(:a, 1)
      #   add(:a, 2)
      #   add(:a, 3)
      #   add(:a, {key: 1})
      #   add(:a, {key: 2})
      #   add(:a, {key: 3})
      def add(*keys, value: nil, default_value: nil)
        size = keys.size

        raise ArgumentError, 'add requires 1 or more keys' if size < 1

        target = initialize_hierarchy(keys)

        add_kv(target, keys[size - 1], value, default_value: default_value)
      end

      def debug
        puts JSON.pretty_generate(dom)
        # log.structure(dom)

        self
      end

      def build
        # hook into the set, add and queue_action methods form memoization
        KUtil.data.to_open_struct(@dom)
      end

      private

      def initialize_hierarchy(keys)
        target = @dom

        return target unless keys.size > 1

        keys.slice(0..-2).each_with_index do |key, _index|
          target[key] = {} unless target.key?(key)
          target = target[key]
        end
        target
      end

      def set_kv(target, key, value, default_value: nil)
        set_value = value.nil? ? default_value : value
        target[key] = set_value
      end

      def add_kv(target, key, value, default_value: nil)
        add_value = value.nil? ? default_value : value
        target[key] = [] unless target.key?(key)
        target[key] << add_value
      end
    end
  end
end
