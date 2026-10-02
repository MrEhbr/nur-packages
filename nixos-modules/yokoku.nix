# services.yokoku: settings are written to /etc/yokoku/app.toml, which the CLI reads too, e.g.
# `sudo -u <user> yokoku --config /etc/yokoku/app.toml root add <path>`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.yokoku;
  toml = pkgs.formats.toml { };
  configFile = toml.generate "yokoku.toml" cfg.settings;
in
{
  options.services.yokoku = {
    enable = lib.mkEnableOption "Yokoku";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/yokoku { };
      defaultText = lib.literalExpression "nur-packages yokoku";
      description = "The yokoku package.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "yokoku";
      description = "User the service runs as; it needs write access to the library and download folders.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "yokoku";
      description = "Group the service runs as.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/yokoku";
      description = "Folder for the database and artwork.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the web port in the firewall.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = toml.type;
        options.web = {
          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "Address the web interface listens on.";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 8080;
            description = "Port the web interface listens on.";
          };
        };
      };
      default = { };
      example = lib.literalExpression ''
        {
          metadata.tmdb.token.file = config.age.secrets.tmdb-token.path;
          transmission.url = "http://127.0.0.1:9091/transmission/rpc";
          jellyfin = {
            url = "http://127.0.0.1:8096";
            api_key.file = config.age.secrets.jellyfin-api-key.path;
            user = "admin";
          };
        }
      '';
      description = ''
        Configuration written to /etc/yokoku/app.toml; see config/app.toml in the yokoku
        repository for every setting. Secrets take `{ file = "/run/agenix/name"; }`, which keeps
        them out of the Nix store.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.yokoku.settings.database.path = lib.mkDefault "${cfg.dataDir}/yokoku.db";

    environment.etc."yokoku/app.toml".source = configFile;
    environment.systemPackages = [ cfg.package ];

    users.users = lib.mkIf (cfg.user == "yokoku") {
      yokoku = {
        isSystemUser = true;
        inherit (cfg) group;
        home = cfg.dataDir;
      };
    };
    users.groups = lib.mkIf (cfg.group == "yokoku") { yokoku = { }; };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -" ];

    systemd.services.yokoku = {
      description = "Yokoku";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      restartTriggers = [ configFile ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --config /etc/yokoku/app.toml";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";
        UMask = "0002";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.web.port ];
  };
}
