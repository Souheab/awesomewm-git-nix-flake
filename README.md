# AwesomeWM Git Flake

This flake provides the latest git version of [AwesomeWM](https://awesomewm.org/), built directly from the [repository's master branch](https://github.com/awesomeWM/awesome/tree/master).

## Installing on NixOS

To use this flake in your NixOS configuration, add it to your `flake.nix` inputs and apply the overlay.

### 1. Add Input

Add the following to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Add awesome-flake
    awesome-flake.url = "github:Souheab/awesomewm-git-nix-flake";
    # Or if using locally:
    # awesome-flake.url = "path:/path/to/awesome-flake";
  };

  outputs = { self, nixpkgs, awesome-flake, ... }: {
    # ...
  };
}
```

### 2. Configure NixOS

Add the overlay and enable AwesomeWM in your configuration (e.g., `configuration.nix` or inside the flake output):

```nix
{
  nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({ pkgs, ... }: {
        # Apply the overlay to make 'pkgs.awesome-git' available
        nixpkgs.overlays = [ awesome-flake.overlays.default ];

        services.xserver = {
          enable = true;
          windowManager.awesome = {
            enable = true;
            # Use the package from the overlay
            package = pkgs.awesome-git;
            
            # Optional: Use the lua modules provided by the flake if needed
            # luaModules = [ pkgs.luaPackages.lgi pkgs.luaPackages.ldoc ];
          };
        };
      })
    ];
  };
}
```

### Alternative: Without Overlay

If you prefer not to use an overlay, you can reference the package directly from the flake input.

```nix
{
  nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    # Pass inputs to modules
    specialArgs = { inherit awesome-flake; };
    modules = [
      ({ pkgs, awesome-flake, ... }: {
        services.xserver = {
          enable = true;
          windowManager.awesome = {
            enable = true;
            # Use the package directly from the flake input
            package = awesome-flake.packages.${pkgs.system}.default;
          };
        };
      })
    ];
  };
}
```

## Testing with Xephyr

You can test the build and your configuration in a nested X server (Xephyr).

1.  Build the flake:
    ```bash
    nix build
    ```

2.  Run the test script:
    ```bash
    ./run-xephyr.sh
    ```

This will launch a window running the built version of AwesomeWM. If you have an `rc.lua` file in the current directory, it will be used as the configuration.