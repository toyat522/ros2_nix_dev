{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
  };
  outputs = { self, nix-ros-overlay, nixpkgs }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.colcon
            # ... other non-ROS packages
            (with pkgs.rosPackages.jazzy; buildEnv {
              paths = [
                ros-core
                desktop-full
                # ... other ROS packages
              ];
            })
          ];
          shellHook = ''
            # Setup ROS 2 shell completion
            eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete ros2)"
            eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete colcon)"
          '';
        };
      }
    );
}
