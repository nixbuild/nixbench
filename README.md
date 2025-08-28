# Nix Benchmarks

This repository contains a collection of Nix library functions and packages
focused on benchmarking Nix build infrastructure. They are implemented to test
nixbuild.net, but can also be used for testing generic Nix build servers.

## Packages

### `write-one-file`

Writes a single file of random bytes to `$out`. The build is configured by
using the environment variables listed below, and must be run with the
`--impure` Nix option.

#### Parameters

`DRV_SEED`: [Mandatory, String] Sets a seed for the derivation, used for forcing
rebuild.

`FILE_SEED`: [Optional, Integer, default=0] Specifies a random seed used for
generating the file contents. If `FILE_SEED` and `FILE_SIZE` are the same
between builds, the output nar hash will be the same.

`FILE_SIZE`: [Optional, Integer, default=1] Specifies the size of the file,
in (Base 10) megabytes.

`COMPRESS_PERCENT`: [Optional, Integer, default=50] Specifies the percentage of
the file that is compressible. So if you specify 80, it is expected that the
resulting file can be compressed to 20% of its original size.

`ID`: [Optional, String, nixbuild.net] Sets the nixbuild.net tag `ID` of the
generated derivation.

`CPUS`: [Optional, Integer, default=2, nixbuild.net] Sets the number of CPUs
nixbuild.net should allocate for the build.

#### Examples

Run 4 builds concurrently, each one creating a 10 MB output file:

```
$ seq 1 4 | xargs -I '{}' -P0 \
    env DRV_SEED="$RANDOM{}" FILE_SIZE=10 ID="BENCH_A" \
      nix build .#write-one-file \
        --impure \
        --eval-store auto \
        --store ssh-ng://eu.nixbuild.net
```

We can now use the nixbuild.net API to query about the builds:

```
$ curl -s -H "Authorization: Bearer $NIXBUILDNET_TOKEN" \
    "https://api.nixbuild.net/builds?tags=ID:BENCH_A" \
      | jq '.[].duration_seconds'

0.474567
0.470182
0.474698
0.479252
```
