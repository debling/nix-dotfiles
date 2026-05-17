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
  };
}