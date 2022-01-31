# frozen_string_literal: true

module KDirector
  module Builders
    # Actions document builder
    class ActionsBuilder
      attr_reader :actions
      attr_reader :dom
      attr_reader :last_action

      def initialize
        reset
      end

      def reset
        @actions = []
        @dom = {}
        @last_action = {}
      end

      def queue_action(action)
        @actions << action
        @last_action = action
      end

      # Set many key/value pairs gainst a group
      #
      # example:
      #   set_many(:github, repo_name: 'repo-name', organization: 'org-name')
      def group_set(group = nil, **opts)
        return if group.nil? && opts.empty?

        if group.nil?
          opts.each do |key, value|
            set(key, value)
          end
        else
          dom[group] = {} if opts.empty? # initialize the group name if no options are provided
          opts.each do |key, value|
            set(group, key, value)
          end
        end
      end

      # set key_set/value pair, can be used for
      #
      # - simple key/value pairs
      # - initialize key/array pairs
      #
      # example:
      #   set(:a, 1)
      #   set(:a, [])
      #   set(:a, [1, 2, 3])
      #   set(:a, some_value, default_value: 'use if not supplied')
      #   set(:a, :b, 'nested value')
      #   set(:a, :b, :c, 'deeply nested value')
      #   set(:a, :b, :c, :d, :e, :f, 'depth is no barrier')
      def set(*keyset_value, default_value: nil)
        size = keyset_value.size

        raise ArgumentError, 'set requires 2 or more arguments' if size < 2

        target = initialize_hierarchy(keyset_value)

        set_kv(target, keyset_value[size - 2], keyset_value[size - 1], default_value: default_value)
      end

      # add value to array
      #   set(:a, [])
      #   add(:a, 1])
      #   add(:a, 2])
      #   add(:a, 3])
      def add(*keyset_value, default_value: nil)
        size = keyset_value.size

        raise ArgumentError, 'add requires 2 or more arguments' if size < 2

        target = initialize_hierarchy(keyset_value)

        add_kv(target, keyset_value[size - 2], keyset_value[size - 1], default_value: default_value)
      end

      def debug
        puts JSON.pretty_generate(actions)
        # puts JSON.pretty_generate(dom)
        # log.structure(dom)

        self
      end

      def build
        # hook into the set, add and queue_action methods form memoization
        KUtil.data.to_open_struct(@dom)
      end

      private

      def initialize_hierarchy(keys_value)
        target = @dom

        return target unless keys_value.size > 2

        keys_value.slice(0..-3).each_with_index do |key, _index|
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
