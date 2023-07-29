{ pkgs, lib, ... }:
let
  /**
  Zip two lists together to make an attrset.

  List 1 is names
  List 2 is values

  TODO: Put into pkgs.lib.attrsets
  */
  zip2Attr = left: right:
    builtins.foldl'
        (curr: next: curr // next )
        {}
        (lib.lists.zipListsWith (l: r: {${l}= r;}) left right);

  cwd = builtins.getEnv "PWD";

  # Decide whether to generate configuration for copying this repo to a target SSH mac host
  sshSync = builtins.getEnv "SYNC_SSH";
  sshAttr = zip2Attr ["host" "path"] (lib.optional (sshSync != "") (lib.strings.splitString ":" sshSync));

  /** Function to generate config for lazy call */
  genConfig = {host, path}: pkgs.writeText "config.lua" ''
settings {
    nodaemon = true,
    insist = true
}

sync {
   default.rsyncssh,
   source="${cwd}",
   host="${host}",
   targetdir="${path}",
   ssh = {
     _extra = {
       "-t"
     }
   }
}'';
  config = if sshAttr == {} then null else (genConfig sshAttr);

in
{
  env.NO_MESSAGE_FILE = ".nomessage";

  # https://devenv.sh/packages/
  packages = [
    pkgs.git
    pkgs.coreutils
  ];

  # https://devenv.sh/scripts/
  scripts.runExample.exec = "nix repl -f example.nix";
  scripts.enableMessage.exec = "rm -f $NO_MESSAGE_FILE";
  scripts.disableMessage.exec = "touch $NO_MESSAGE_FILE";

  enterShell = ''
    set -o pipefail
    if ! [[ -f $NO_MESSAGE_FILE ]] && ! (uname | grep -i mac) ; then
        echo You are not on a mac device
        echo Should you have an SHH mac host, you might want to checkout this project there
        echo  or set env var SYNC_SSH to "<host>:<path>" in order to sync this folder
        echo You will require nix and rsync from nix on the target device!
        echo
        echo To disable this message run "disableMessage"
    fi
  '';

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # See full reference at https://devenv.sh/reference/options/
} // (
  lib.attrsets.optionalAttrs (sshAttr != {}) {
    processes.watcher.exec = ''${pkgs.lsyncd}/bin/lsyncd ${config}'';
  }
)
