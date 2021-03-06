# frozen_string_literal: true

require 'logger'

module ElasticAPM
  # @api private
  class Config
    DEFAULTS = {
      server_url: 'http://localhost:8200',
      secret_token: nil,

      app_name: nil,
      environment: nil,
      framework_name: nil,
      framework_version: nil,

      log_path: '-',
      log_level: Logger::INFO,

      timeout: 10,
      open_timeout: 10,
      transaction_send_interval: 10,
      debug_transactions: false,
      debug_http: false,

      enabled_injectors: %w[net_http],

      current_user_id_method: :id,
      current_user_email_method: :email,
      current_user_username_method: :username,

      view_paths: []
    }.freeze

    LOCK = Mutex.new

    def initialize(options = nil)
      options = {} if options.nil?

      DEFAULTS.merge(options).each do |key, value|
        send("#{key}=", value)
      end

      return unless block_given?

      yield self
    end

    attr_accessor :server_url
    attr_accessor :secret_token

    attr_accessor :app_name
    attr_writer :environment
    attr_accessor :framework_name
    attr_accessor :framework_version

    attr_accessor :log_path
    attr_accessor :log_level

    attr_accessor :timeout
    attr_accessor :open_timeout
    attr_accessor :transaction_send_interval
    attr_accessor :debug_transactions
    attr_accessor :debug_http

    attr_accessor :enabled_injectors

    attr_accessor :view_paths

    attr_accessor :current_user_method
    attr_accessor :current_user_id_method
    attr_accessor :current_user_email_method
    attr_accessor :current_user_username_method

    attr_writer :logger

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def app=(app)
      case app_type?(app)
      when :sinatra
        self.app_name = format_name(app_name || app.to_s)
        self.framework_name = 'Sinatra'
        self.framework_version = Sinatra::VERSION
      when :rails
        self.app_name = format_name(app_name || app.class.parent_name)
        self.framework_name = 'Ruby on Rails'
        self.framework_version = Rails::VERSION::STRING
        self.logger = Rails.logger
        self.view_paths = app.config.paths['app/views'].existent
      else
        # TODO: define custom?
        self.app_name = 'ruby'
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def app_type?(app)
      if defined?(::Rails) && app.is_a?(Rails::Application)
        return :rails
      end

      if app.is_a?(Class) && app.superclass.to_s == 'Sinatra::Base'
        return :sinatra
      end

      nil
    end

    def environment
      @environment ||= ENV['RAILS_ENV'] || ENV['RACK_ENV']
    end

    def logger
      @logger ||=
        LOCK.synchronize do
          build_logger(log_path, log_level)
        end
    end

    def use_ssl?
      server_url.start_with?('https')
    end

    private

    def build_logger(path, level)
      logger = Logger.new(path == '-' ? STDOUT : path)
      logger.level = level
      logger
    end

    def format_name(str)
      str.gsub('::', '_')
    end
  end
end
