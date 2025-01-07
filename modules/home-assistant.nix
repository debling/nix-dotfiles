{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
      "upnp"
      "google_assistant"
      "google"
      "cast"
      "bluetooth"
      "media_source"
      "ffmpeg"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      homeassistant = {


        media_dirs = {
          media = "/media";
          recormedia_sourceding = "/mnt/recordings";
        };
      };
      camera = [
        {
          platform = "ffmpeg";

          name = "webcam";
          input = "/dev/video1";
        }
      ];
    };
  };
}
