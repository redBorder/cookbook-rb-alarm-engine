require 'openssl'

module RbAlarmEngine
  module Helpers
    # Must match Api::V1::Internal::AlarmsController::INTERNAL_API_TOKEN_CONTEXT
    INTERNAL_API_TOKEN_CONTEXT = 'rb-internal-api-token'.freeze

    # Token for the webui internal API: HMAC-SHA256 of the per-installation
    # webui secret (data bag passwords/webui_secret). The webui derives the
    # same value from the secret chef writes into redborder_config.yml.
    def rb_internal_api_token
      secret = data_bag_item('passwords', 'webui_secret')['secret'].to_s
      return if secret.empty?

      OpenSSL::HMAC.hexdigest('SHA256', secret, INTERNAL_API_TOKEN_CONTEXT)
    rescue StandardError => e
      Chef::Log.warn("Cannot read data bag passwords/webui_secret: #{e.message}")
      nil
    end
  end
end
