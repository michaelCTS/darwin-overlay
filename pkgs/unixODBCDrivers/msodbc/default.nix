{
  callPackage,
  stdenv,
}:
{
  msodbcsql17 = callPackage ./17.nix {};
}
