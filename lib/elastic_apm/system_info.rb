# frozen_string_literal: true

module ElasticAPM
  # @api private
  class SystemInfo
    def initialize(config)
      @config = config
    end

    attr_reader :config

    def build
      {
        hostname: `hostname`,
        architecture: platform.cpu,
        platform: platform.os
      }
    end

    def self.build(config)
      new(config).build
    end

    private

    def platform
      @platform ||= Gem::Platform.local
    end
  end
end
