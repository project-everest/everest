FROM projecteverest/everest-chomolungma

# Switch to the ICFP 2017 branch
WORKDIR ${MYHOME}/everest
RUN git fetch
RUN git checkout icfp2017
RUN ./everest pull

# Remove Vale, to avoid spurious dependencies
RUN rm -rf vale

# Install all HACL* prerequisites
# (see INSTALL.md on the HACL* jk_snap branch)

WORKDIR hacl-star/other_providers
RUN git submodule update --init
WORKDIR openssl
RUN ./config no-asm
RUN make
WORKDIR ../libsodium
RUN ./autogen.sh
RUN ./configure --disable-asm --enable-opt
RUN make
RUN sudo make install
ENV LD_LIBRARY_PATH "/usr/local/lib"

# Set final working directory
WORKDIR ${MYHOME}/everest
