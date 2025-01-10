# frozen_string_literal: true

module Powerpoint
  module GoogleServices
    class Base
      def initialize
        raise "Configuration not set" unless Powerpoint.provider == :google
      end

      def drive
        Powerpoint.google.drive
      end

      def slides
        Powerpoint.google.slides
      end
    end
  end
end
