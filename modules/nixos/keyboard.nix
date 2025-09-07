{
  services.kanata = {
    enable = true;
    keyboards.common = {
      extraDefCfg = "process-unmapped-keys yes";
      config = # lisp
        ''
          (defsrc
            caps
            lsft
          )

          (defalias
            sl (one-shot 300 lsft)
           caps (tap-hold 200 200 esc lctl)
          )

          (deflayer base
            @caps
            @sl
          )
        '';
    };
  };
}
