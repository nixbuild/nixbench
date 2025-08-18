{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05-small";
    flakelight.url = "github:nix-community/flakelight";
  };

  outputs = inputs: inputs.flakelight ./. {
    inherit inputs;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
