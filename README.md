# CCS2017 Artefact for: HACL*, a verified modern cryptographic library


## This Docker Image

The present image was generated after a successful verification, extraction,
compilation and test run of:
- F\*, the programming language we use for all our proofs
- KreMLin, the tool that extracts Low\* programs to C
- miTLS, the in-progress, verified implementation of the TLS protocol
- HACL\*, the High Assurance Cryptographic Library

To run this Docker image, first install Docker on your machine
following platform-specific instructions at https://docs.docker.com/engine/installation/

Then, just run:
```
docker run -t -i ccs2017s558/image
```

to open a Docker container based on this Docker image with a
command-line prompt. From now one, the commands proposed in this file
are assumed run from within such a Docker container (except for the
*Regenerating this artifact* section, of course.)

## Finding the proofs

The directory structure is relatively straightforward:
- the `specs` directory contains specifications, some of which are under the
  `experimental` directory
- the `code` directory contains the Low* implementations of the high-level
  specifications; the subdirectory names are self-explanatory.

In order of appearance in the paper:
- Figure 1: specs/Spec.SHA2_256.fst:126
- Figure 2: code/hash/Hacl.Hash.SHA2_256.fst:438
- Figure 3: test/ccs-benchmarks/snapshot/SHA2_256.c:173, inlined in the body of
  the enclosing function for maximum performance
- Figure 4: specs/Spec.Chacha20.fst
- Figure 5: test/ccs-benchmarks/snapshot/vec128.h
- Figure 6: code/salsa-family/Spec.Chacha20_vec.fst
- Figure 7: code/salsa-family/Hacl.Impl.Chacha20.Vec128.fst
- Figure 8: code/poly1305/Hacl.Bignum.Constants.fst
- Figure 9: code/poly1305/Hacl.Bignum.AddAndMultiply.fst
- Figure 10: specs/Spec.Curve25519.fst

## Source code for our tools

- **4, the KreMLin tool:**
  the source of KreMLin are included in `kremlin`; of notable
  interest are the files
  `kremlin/src/Simplify.ml` (many rewriting passes),
  `kremlin/src/Inlining.ml` (inlining of the `StackInline` effect),
  `kremlin/src/DataTypes.ml` (compilation of data types and pattern
  matches),
  `kremlin/src/AstToCStar.ml` (the transformation from λow\* to C\*)
- **F\*:**
  the sources of F\* are in `FStar/src`


## Running functional tests

The tests that best showcase our methodology are run via `make -C
hacl-star/test extract-c`. This targets extracts to C code our AEAD development,
along with a variety of cryptographic algorithms (x25519, poly1305, chacha20,
xsalsa20); this target also compiles and runs test executables such as
`secure_api/krml-test-{vale,hacl}.exe`.

Additional test targets not covered by `make -C hacl-star/test extract-c`
include:
- `make -C hacl-star/code/poly1305 poly1305.exe`: unit test for the Poly1305
  algorithm
- `make -C hacl-star/code/salsa-family chacha20.exe salsa20.exe`: unit test for
  the Chacha20 and Salsa20 algorithms.


## Running performance tests

### With GCC

One can extract HACL\* to a releasable set of C files, then run a
performance benchmark using GCC, then show the performance results,
via:

```
make -C hacl-star/test snapshot-gcc
make -C hacl-star/test perf-gcc
cat hacl-star/test/benchmark-gcc.txt
```

In the above sequence, `gcc` can be replaced with `gcc-unrolled` to have
KreMLin unroll some loops when extracting the C code.

### With CompCert

Due to licensing reasons, we do not believe we can safely redistribute CompCert
in this artefact evaluation image. However, one can easily install
CompCert via:

```
wget http://compcert.inria.fr/release/compcert-3.0.1.tgz
tar xzvf compcert-3.0.1.tgz
cd CompCert-3.0.1
./configure x86_64-linux
make -j 8
sudo make install
cd ..
```

One this is done, the following series of commands will run performance
benchmarks for CompCert:

```
make -C hacl-star/test snapshot-ccomp
make -C hacl-star/test perf-ccomp
cat hacl-star/test/benchmark-compcert.txt
```

### Via the OpenSSL engine

A popular benchmarking tool is the OpenSSL "speed" command, which measures how
many operations of a given kind may be performed over a span of 3 seconds, for
different input sizes.

We wrote a new OpenSSL engine that packages some of our algorithms, meaning we
can measure their performance using the aforementioned testing framework. Right
now, the engine is set up so that our algorithms perform as many computations as
the OpenSSL ones, but due to some minor API differences, there remains some work
to ensure we compute the right result (e.g. detect when to perform the call to
Poly1305_Finalize according to the state machine of OpenSSL).

After regenerating the GCC snapshot by `make -C hacl-star/test snapshot-gcc`,
these OpenSSL engine tests can be run via `make -C hacl-star/test/openssl-engine test`.


## Replaying the proofs

One can replay the proofs by running the high-level command: `./everest verify
-j 8` where `8` is a suggested number of cores to use. One may want to allocate
more cores and more memory to their Docker instance.


# Regenerating this artefact

One can easily reconstruct this artefact from scratch, by running the
following sequence of commands from a machine with Docker installed:

```
git clone https://github.com/project-everest/everest.git everest
cd everest
git checkout ccs2017
docker build --tag ccs2017s558/image .docker/everest-chomolungma
```

This takes a couple hours on a powerful machine. To speed up this process, the
last command can be replaced with:
```
docker build --build-arg PARALLEL_OPT='-j 4' --tag ccs2017s558/image .docker/everest-chomolungma
```
to build and verify everything using `4` cores.
