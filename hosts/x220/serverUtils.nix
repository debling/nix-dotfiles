{ ... }:
{
  _module.args.serverUtils = rec {
    makeNginxLocalProxy = port: {
      forceSSL = true;
      http3 = true;
      quic = true;
      useACMEHost = "home.debling.com.br";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
      };
    };

    makeNginxAuthProxy =
      port:
      let
        base = makeNginxLocalProxy port;
      in
      base
      // {
        extraConfig = ''
          auth_request /internal/authelia/authz;
          auth_request_set $authelia_redirect $upstream_http_location;
          error_page 401 =302 $authelia_redirect;
        '';
        locations = base.locations // {
          "/internal/authelia/authz" = {
            proxyPass = "http://127.0.0.1:9991/api/authz/auth-request";
            extraConfig = ''
              internal;
              proxy_set_header X-Original-Method $request_method;
              proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
              proxy_set_header Content-Length "";
              proxy_pass_request_body off;
            '';
          };
        };
      };
  };
}
