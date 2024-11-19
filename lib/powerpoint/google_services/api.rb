# frozen_string_literal: true

require "googleauth"
require "google/apis/slides_v1"
require "google/apis/drive_v3"
require "powerpoint/google_services/presentation"

module Powerpoint
  module GoogleServices
    class Api
      attr_accessor :current_presentation

      def initialize
        raise "Configuration not set" unless Powerpoint.provider == :google
      end

      def slides
        return @slides if defined?(@slides)

        @slides = Google::Apis::SlidesV1::SlidesService.new
        @slides.authorization = authorizer

        @slides
      end

      def drive
        return @drive if defined?(@drive)

        @drive = Google::Apis::DriveV3::DriveService.new
        @drive.authorization = authorizer

        @drive
      end

      private

      def authorizer
        return @authorizer if defined?(@authorizer)

        @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(Powerpoint.configuration.google_credentials_path),
          scope:,
        )
        @authorizer.fetch_access_token!

        @authorizer
      rescue FileNotFoundError => e
        raise "Google credentials file not found: #{e}"
      rescue StandardError => e
        raise "Google credentials error: #{e}"
      end

      def scope
        [
          Google::Apis::SlidesV1::AUTH_PRESENTATIONS,
          Google::Apis::DriveV3::AUTH_DRIVE,
        ]
      end
    end
  end
end
