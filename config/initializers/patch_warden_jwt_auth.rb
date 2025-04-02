module Warden
  module JWTAuth
    class TokenRevoker
      def call(token)
        payload = TokenDecoder.new.call(token)
        scope = payload["scp"]

        scope = scope.to_sym unless scope.nil?

        if revocation_strategies[scope]
          user = PayloadUserHelper.find_user(payload)
          revocation_strategies[scope].revoke_jwt(payload, user)
        end

      rescue JWT::ExpiredSignature
      end
    end
  end
end
