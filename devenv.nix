{ pkgs, lib, ... }:
let
  /**
  Zip two lists together to make an attrset.

  List 1 is names
  List 2 is values

  TODO: Put into
  */
  zip2Attr = left: right:
    builtins.foldl'
        (curr: next: curr // next )
        {}
        (lib.lists.zipListsWith (l: r: {${l}= r;}) left right);

  cwd = builtins.getEnv "PWD";
  sshSync = builtins.getEnv "SYNC_SSH";
  sshAttr = zip2Attr ["host" "path"] (lib.strings.splitString ":" sshSync);
  config = if sshAttr == {} then null else pkgs.writeText "config.lua" ''
settings {
    nodaemon = true,
    insist = true
}

sync {
   default.rsyncssh,
   source="${cwd}",
   host="${sshAttr.host}",
   targetdir="${sshAttr.path}",
   ssh = {
     _extra = {
       "-t"
     }
   }
}'';

in
{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
  ];

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo hello from ${./.}";

  enterShell = ''
    echo "SYNC_SSH=${sshSync}"
  '';

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  processes.ping.exec = "ping github.com";

  # See full reference at https://devenv.sh/reference/options/
} // (
  lib.attrsets.optionalAttrs (sshAttr != {}) {
    processes.watcher.exec = ''${pkgs.lsyncd}/bin/lsyncd ${config}'';
   #     -nodaemon -rsyncssh \
   #     "${cwd}" "${sshAttr.host}" "${sshAttr.path}"
   # '';
  }
)
