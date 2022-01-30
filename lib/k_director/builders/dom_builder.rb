# frozen_string_literal: true

module KDirector
  module Builders
    # Base document builder
    class DomBuilder
      attr_reader :dom
      attr_reader :last

      def initialize
        reset
      end

      # def current_value(value)
      #   @value = value
      # end

      # alias last_value value

      def reset
        @dom = {}
        @last = {}

        initialize_dom
      end

      def initialize_dom
        # implement in subclasses
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

        set_kv(target, keyset_value[size-2], keyset_value[size-1], default_value: default_value)
      end

      # add value to array
      def add(*keyset_value, default_value: nil)
        size = keyset_value.size
        
        raise ArgumentError, 'add requires 2 or more arguments' if size < 2

        target = initialize_hierarchy(keyset_value)

        add_kv(target, keyset_value[size-2], keyset_value[size-1], default_value: default_value)
      end

      def last_key
        @last[:key]
      end

      def last_value
        @last[:value]
      end

      def debug
        puts JSON.pretty_generate(dom)
        # log.structure(dom)

        self
      end

      def build # (**opts)
        KUtil.data.to_open_struct(@dom)
      end
      # alias data build

      private

      def initialize_hierarchy(keys_value)
        target = @dom

        return target unless keys_value.size > 2
        keys_value.slice(0..-3).each_with_index do |key, index|
          target[key] = {} unless target.key?(key)
          target = target[key]
        end
        target
      end

      def set_kv(target, key, value, default_value: nil)
        set_value = value.nil? ? default_value : value
        target[key] = set_value
        @last = { key: key, value: set_value }
      end

      def add_kv(target, key, value, default_value: nil)
        add_value = value.nil? ? default_value : value
        target[key] = [] unless target.key?(key)
        target[key] << add_value
        @last = { key: key, value: target[key] }
      end

      # def dig_set(*key_set_and_value, default_value_container:, default_value: nil, &block)
      #   value = key_set_and_value.pop
      #   key_set = key_set_and_value.flatten

      #   value = value.nil? ? default_value : value
      #   last_key = nil
      #   target = @dom

      #   key_set.each_with_index do |key, index|
      #     last_key = key

      #     if index == key_set.size - 2
      #       block.call(target, container_key, key, value)
      #     else
      #       container = key_set.size - 2 == index ? {} : default_container
      #       target[key] ||= {} # container # default_container
      #       target = target[key]
      #     end
      #   end

      #   @last = { key: last_key, value: value }
      # end
    end
  end
end
