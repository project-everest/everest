FROM projecteverest/everest-chomolungma

# parallel_opt is either empty, or -j n, where n is
# the max number of parallel jobs when building the image
# (by default 1)
ARG parallel_opt

RUN ./everest --yes $parallel_opt check pull make test verify
