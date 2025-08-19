{ lib, fio, writeText, runCommand }:

let

  seed = lib.maybeEnv "SEED" (throw "Undefined SEED");
  fileSeed = lib.toInt (lib.maybeEnv "FILE_SEED" (throw "Undefined FILE_SEED"));
  sizeMegabytes = lib.toInt (lib.maybeEnv "FILE_SIZE" (throw "Undefined FILE_SIZE"));
  compressPercentage = lib.toInt (lib.maybeEnv "COMPRESS_PERCENT" "50");
  id = builtins.getEnv "ID";
  cpus = lib.toInt (lib.maybeEnv "CPUS" "2");

  fioJobs = writeText "fio.ini" ''
    [global]
    bs=1M
    buffer_compress_chunk=4096
    buffer_compress_percentage=${toString compressPercentage}
    direct=0
    iodepth=16
    ioengine=libaio
    random_distribution=zipf:1.2
    refill_buffers=1
    rw=write
    kb_base=1000

    [file1]
    size=${toString sizeMegabytes}M
  '';


in runCommand "write-one-file" {
  buildInputs = [ fio ];
  seed = builtins.getEnv "SEED";
  inherit fioJobs fileSeed;
  NIXBUILDNET_MIN_MEM = sizeMegabytes + 500;
  NIXBUILDNET_TAG_ID = id;
  NIXBUILDNET_MIN_CPU = cpus;
  NIXBUILDNET_MAX_CPU = cpus;
} ''
  mkdir "$out"
  fio --directory "$out" --randseed="$fileSeed" "$fioJobs"
''
