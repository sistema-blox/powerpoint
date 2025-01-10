# frozen_string_literal: true

require "powerpoint/version"
require "powerpoint/util"
require "powerpoint/slide/intro"
require "powerpoint/slide/textual"
require "powerpoint/slide/pictorial"
require "powerpoint/slide/text_picture_split"
require "powerpoint/slide/picture_description"
require "powerpoint/compression"
require "powerpoint/presentation"
require "powerpoint/configuration"
require "powerpoint/google_services/api"
require "powerpoint/google_services/base"
require "powerpoint/google_services/template"

module Powerpoint
  ROOT_PATH = File.expand_path("../..", __FILE__)
  TEMPLATE_PATH = "#{ROOT_PATH}/template/"
  VIEW_PATH = "#{ROOT_PATH}/lib/powerpoint/views/"

  class << self
    attr_accessor :configuration, :google

    def configure
      self.configuration ||= Powerpoint::Configuration.new

      yield(configuration) if block_given?

      self.google ||= Powerpoint::GoogleServices::Api.new
    end

    def provider
      configuration.nil? ? :local : :google
    end
  end
end
