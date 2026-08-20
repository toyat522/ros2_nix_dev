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
          ] ++ (with pkgs.rosPackages.jazzy; [
            ros-core
            desktop-full
            # ... other ROS packages
          ]);
          shellHook = ''
            # Set up ROS 2 shell completion
            _zdotdir=$(mktemp -d)
            echo '[[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc"' > "$_zdotdir/.zshrc"
            echo 'eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete --shell zsh ros2)"' >> "$_zdotdir/.zshrc"
            echo 'eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete --shell zsh colcon)"' >> "$_zdotdir/.zshrc"
            echo "trap 'rm -rf $_zdotdir' EXIT" >> "$_zdotdir/.zshrc"
            export ZDOTDIR="$_zdotdir"
            export COLCON_LOG_LEVEL=ERROR
          '';
        };
      }
    );
}
