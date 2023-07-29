let
  darwinOverlay = import ./default.nix;
in (import <nixpkgs> {
    overlays = [
      darwinOverlay
    ];
})
