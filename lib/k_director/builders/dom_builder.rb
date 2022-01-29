# frozen_string_literal: true

module KDirector
  module Builders
    # Base document builder
    class DomBuilder
      attr_reader :dom

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

      # set key/value pair, can be used for
      #
      # - simple key/value pairs
      # - initialize key/array pairs
      def set(key, value)
        @dom[key] = value
        @last = { key: key, value: value }
      end

      # add value to array
      def add(key, value)
        @dom[key] << value
        @last = { key: key, value: value }
      end

      attr_reader :last

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

      def data
        KUtil.data.to_open_struct(@dom)
      end
    end
  end
end
