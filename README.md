# Project Everest

Project Everest is made up of the following components.
- F\*, a verification language inspired by ML.
- miTLS, an implementation of the TLS protocol written in F*.
- hacl-star, a library of verified cryptography.
- KreMLin, a tool which extracts F\* programs to readable C.
- Spartan, a tool to generate verified assembly routines.
- Dafny, a verification language used by Spartan.

Furthermore, Project Everest depends on a variety of external projects.
- The Z3 theorem prover, an automated SMT solver.
- OCaml, a functional programming language, along with OPAM and a variety of
  associated packages.
- A working .NET setup (possibly with Mono).
- Currently, OpenSSL, to provide certain cryptographic routines needed by miTLS
  and no yet implemented by hacl-star.
- A working toolchain; currently, gcc (with the mingw port on Windows).
- Boogie, an intermediate verification language.

## The `everest` script

This repository contains a script, `everest`, and a known working set of
revisions for all the projects above. The script will check that you have a good
working setup, and will fetch or update the projects accordingly.

## Pre-setup (Windows)

If you don't have a 64-bit Cygwin installed already, please run the
`setup-cygwin.ps` PowerShell script, which will fetch Cygwin and ensure you have
the right set of packages to start with. Please click through the various steps
of the installer, then open a Cygwin terminal, and launch the Everest command
from there.

## Usage

- `./everest check`
- `./everest env`
- `./everest fetch`
- `./everest make`
- `./everest snapshot`
