{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.adguard-exporter;
in
{
  options.services.adguard-exporter = {
    enable = lib.mkEnableOption "AdGuard Home Prometheus exporter";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/adguard-home-exporter { };
      defaultText = lib.literalExpression "nur-packages adguard-exporter";
      description = "The adguard-exporter package.";
    };

    adguardHost = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "AdGuard Home address.";
    };

    adguardPort = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "AdGuard Home web port.";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "-log_limit" "10000" ];
      description = "Extra command-line flags.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.adguard-exporter = {
      enable = true;
      description = "AdGuard metric exporter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = lib.concatStringsSep " " (
          [
            "${cfg.package}/bin/adguard-exporter"
            "-adguard_hostname"
            cfg.adguardHost
            "-adguard_port"
            (toString cfg.adguardPort)
          ]
          ++ cfg.extraFlags
        );
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        User = "root";
        Group = "root";
      };
    };
  };
}
