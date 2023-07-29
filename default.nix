self: super:
let
  inherit (self) callPackage lib makeSetupHook;
in {
  chromium-bin = callPackage ./pkgs/chromium-bin {};

  extractDarwinApp = callPackage ./build-support/extract-darwin-app {};

  patchDylib = makeSetupHook {
    name = "patch-dylib";
    meta.platforms = lib.platforms.darwin;
  } ../build-support/setup-hooks/patch-dylib.sh;

  unixODBCDrivers = super.unixODBCDrivers // (callPackage ./pkgs/unixODBCDrivers {});
}
