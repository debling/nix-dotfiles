{
  services.kanata = {
    enable = true;
    keyboards.common = {
      extraArgs = [ "--nodelay" ];
      extraDefCfg = "process-unmapped-keys yes";
      config = # lisp
        ''
          (defsrc
            caps
            lsft
          )

          (defalias
            sl (one-shot 300 lsft)
            caps (tap-hold-press 150 150 esc lctl)
          )

          (deflayer base
            @caps
            @sl
          )
        '';
    };
  };
}
