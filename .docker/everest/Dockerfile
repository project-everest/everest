FROM projecteverest/everest-chomolungma

# PARALLEL_OPT is either empty, or -j n, where n is
# the max number of parallel jobs when building the image
# (by default 1)
ARG PARALLEL_OPT

RUN ./everest --yes check pull $PARALLEL_OPT make
RUN ./everest --yes $PARALLEL_OPT test
RUN ./everest --yes $PARALLEL_OPT verify
