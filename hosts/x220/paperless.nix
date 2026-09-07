{
  config,
  pkgs,
  serverUtils,
  ...
}:
{
  age.secrets.paperless-oidc.file = ../../secrets/paperless-oidc.age;

  services.paperless = {
    enable = true;
    domain = "paperless.home.debling.com.br";
    database.createLocally = true;
    environmentFile = config.age.secrets.paperless-oidc.path;
    settings = {
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
      PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = true;
      PAPERLESS_SOCIAL_AUTO_SIGNUP = true;
      PAPERLESS_DISABLE_REGULAR_LOGIN = true;
      PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
      PAPERLESS_LOGOUT_REDIRECT_URL = "https://authelia.home.debling.com.br/logout";
    };
  };

  services.nginx.virtualHosts."paperless.home.debling.com.br" =
    serverUtils.makeNginxLocalProxy config.services.paperless.port
    // {
      extraConfig = "client_max_body_size 100M;";
    };
}
