# nur-packages

Personal Nix packages and NixOS modules.

| Name | Kind | Notes |
|---|---|---|
| `yokoku` | package | Written to `pkgs/yokoku` by yokoku's GoReleaser on each release |
| `yokoku` | NixOS module | `services.yokoku`; its package defaults to `pkgs/yokoku` |

```nix
# flake.nix
inputs.nur-packages.url = "git+ssh://git@github.com/MrEhbr/nur-packages";

# configuration
imports = [ inputs.nur-packages.nixosModules.yokoku ];

services.yokoku = {
  enable = true;
  user = "media";
  group = "storage";
  settings.metadata.tmdb.token.file = config.age.secrets.tmdb-token.path;
};
```
