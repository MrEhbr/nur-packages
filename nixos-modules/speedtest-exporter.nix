{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.speedtest-exporter;
in
{
  options.services.speedtest-exporter = {
    enable = lib.mkEnableOption "Speedtest Prometheus exporter";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/speedtest-exporter { };
      defaultText = lib.literalExpression "nur-packages speedtest-exporter";
      description = "The speedtest-exporter package.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Port the metrics endpoint listens on.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.speedtest-exporter = {
      enable = true;
      description = "Speedtest Prometheus Exporter";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/speedtest_exporter -port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        User = "root";
        Group = "root";
      };
    };
  };
}
