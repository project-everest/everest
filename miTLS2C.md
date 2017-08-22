# Porting miTLS to C

This document is the working set of notes for the effort to port miTLS to Kremlin so it
can be extracted to C.

Currently there are changes to F*, Kremlin, and miTLS tracked by this Everest snapshot. We
will also mostly likely require a branch of HACL* as well due to changes introduced to Kremlin.

Currently the snapshot does not fully build or verify. This is by design, we hope to first
get all the projects in sync with a modified version of Kremlin and F*, then begin porting
miTLS, finally re-verifying and merging it.

Once you have the snapshot pulled, you should make the F* snapshot, and Kremlin by hand.

```
cd FStar; make -C src/ocaml-output; cd ..
cd Kremlin; make; cd ..
```

Once you have both Kremlin and F* you can try to extract miTLS. There is a new target for Kremlin 
output which can be invoked with the following command.

```
cd mitls-fstar
make -C src/tls kremlin
```

After this target succeeds (if it does) you should have the `$EVEREST_HOME/mitls-fstar/src/tls/krml_output` 
output directory populated with generated C code, `$EVEREST_HOME/mitls-fstar/src/tls/krml_output`. 
The generate code is not yet correct, and will not compile when passed to a C compiler.

The forward path is to categorize remaining issues, fixing F*, Kremlin and miTLS as needed.
Hopefully in a few weeks the generated code can at be compiled, and we can begin testing it and improving it.

These instructions will serve as the home for tips and tricks for hacking on the miTLS2c porting effort.
