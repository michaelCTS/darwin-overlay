An overlay for [nixpkgs].

All override packages are in [default.nix](default.nix)

For an example of usage, see [example.nix].


# Development

Development requires [`devenv`][devenv].


## Common

Regardless of which platform you're on, you can always enter a shell

```sh
devenv shell
```

When in a shell, it's possible to run the example of using the overlay in a REPL.
In a devenv shell run `runExample`.
This will drop you into a nix REPL with an active overlay.


## Linux

None of the packages can be built under linux, but the example REPL can come in handy
 for some simple syntax checks.

Should your main dev machine be a linux one but you have a mac machine here prerequisites
of the mac machine for syncing your changes over:

 - nix installed on the mac
 - `rsync` from nix available in a non-interactive SSH session
   * test this with `ssh $user@$mac which rsync`
     the binary should **not** be in `/usr/bin/`

You can then set the `SYNC_SSH` env var to `$host:$path` where `path` is a path on the mac
where you would like this folder synced to.

[devenv]: https://devenv.sh/
[nixpkgs]: https://github.com/NixOS/nixpkgs
