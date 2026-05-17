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

    localProxyWith = port: options:
      let
        baseProxy = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
        };
        locationConfig = if options ? extraLocationConfig && options.extraLocationConfig != null
                        then baseProxy // options.extraLocationConfig
                        else baseProxy;
        extraConfigAttr = if options ? extraConfig && options.extraConfig != null && options.extraConfig != ""
                          then { extraConfig = options.extraConfig; }
                          else {};
      in
      (makeNginxLocalProxy port) // {
        locations."/" = locationConfig;
      } // extraConfigAttr;
  };
}