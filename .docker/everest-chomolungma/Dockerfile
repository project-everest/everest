# The image built from this file is to be named everest-chomolungma, as the "Holy Mother" (Tibetan) of all everest images.

FROM ubuntu:xenial

LABEL maintainer "Irina Spiridonova <irinasp@microsoft.com>; Darren Gehring <darrenge@microsoft.com>; Tahina Ramananandro <taramana@microsoft.com>"
# created based on original script from fstar branch writen by Benjamin Beurdouche and Daniel Fabian

# Add a new mirror, maybe more stable than Docker's
RUN echo 'deb http://mirror.pnl.gov/ubuntu/ xenial main' >> /etc/apt/sources.list
RUN echo "deb http://mirror.math.ucdavis.edu/ubuntu/ xenial main" >> /etc/apt/sources.list

# Try to overcome the "Hash Sum Mismatch" failure by retrying if failed
RUN echo "Acquire::Retries \"16\";" > /etc/apt/apt.conf.d/99acquire-retries

# Commit changes
RUN apt-get --yes update

# Configure new PPA for gcc-6
RUN apt-get install --no-install-recommends --yes software-properties-common curl
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get --yes update

# Configure repository for node.js 6.x LTS
# from: https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# Install required packages
# Do not install recommended packages, so as not to install OCaml here, thus guaranteeing that the only OCaml will be the one compiled by opam init later
# Loop until success (hash sum mismatches will often entail failure)
# ca-certificates-mono: needed to build Vale
# pkg-config: needed by ocamlfind
# git: needed by opam (if not specified, then opam will install without any way to retrieve packages)
# python, python3: Vale needs 2.7, others need 3.5
# pandoc: needed by F* documentation
# cmake, libtool, automake: needed by hacl-star
# gcc-6 instead of gcc-5: needed by hacl-star
# tzdata needed by nuget, or more exactly by mono HTTPS support (cf. https://github.com/tianon/docker-brew-ubuntu-core/issues/86#issuecomment-310269818 )
# nodejs needed by madoko
RUN until apt-get install --no-install-recommends --yes \
  libssl-dev \
  libsqlite3-dev \
  g++-6 \
  gcc-6 \
  build-essential \
  m4 \
  make \
  opam \
  pkg-config \
  python \
  libgmp-dev \
  automake \
  git \
  ca-certificates-mono \
  fsharp \
  libunwind8 \
  libcurl3 \
  scons \
  curl \
  sudo \
  libicu55 \
  python3 \
  wget \
  zip \
  nuget \
  pandoc \
  ca-certificates \
  cmake \
  libtool \
  autoconf \
  tzdata \
  nodejs \
 ; do apt-get --yes update ; done

# Install madoko (for the F* tutorial)
RUN npm install madoko -g

# Create user everest.
# We define a home directory by ourselves, because there is no way to have the HOME variable caught by WORKDIR.
# So, to make it consistent, we explicitly make this directory home when creating the user.
ENV MYHOME /home/everest
RUN useradd --shell /bin/bash --create-home --home-dir ${MYHOME} everest
RUN echo "everest ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# --login: Ensure that the .profile is read at each subsequent RUN (to take all the settings and environment that opam will write there).
# Other options to bash may be added here, but -c MUST BE the last one (it introduces the actual command to be RUN)
SHELL ["/bin/bash", "--login", "-c"]

# Switch to user mode
USER everest
WORKDIR ${MYHOME}

# We no longer install z3 and rely on the everest script to do so

# Enable --yes option for opam
ENV OPAMYES 1

# Install OCaml
ENV ocamlv 4.05.0
RUN opam init --auto-setup --compiler=${ocamlv}

# Prepare everest repository
WORKDIR ${MYHOME}
RUN git clone https://github.com/project-everest/everest.git everest

# Install opam packages required by everest (to avoid duplicating the list of opam packages here),
# then retrieve the latest version
# Through EVEREST_ENV_DEST_FILE, we make environment changes to .profile
# (consistently with `opam init --auto-setup` above) instead of .bashrc,
# so that those changes are always taken into account
# in login shells, whether they are interactive or not.
WORKDIR ${MYHOME}/everest
ENV EVEREST_ENV_DEST_FILE ${MYHOME}/.profile
RUN ./everest --yes check pull

# Install all HACL* prerequisites
# (see INSTALL.md on the HACL* jk_snap branch)
WORKDIR hacl-star/other_providers
RUN git submodule update --init
WORKDIR openssl
RUN ./config no-asm
RUN make
ENV OPENSSL_HOME ${MYHOME}/everest/hacl-star/other_providers/openssl
WORKDIR ../libsodium
RUN ./autogen.sh
RUN ./configure --disable-asm --enable-opt
RUN make
RUN sudo make install
ENV LD_LIBRARY_PATH "/usr/local/lib"
ENV LIBSODIUM_HOME /usr/local

# Install Coq
ENV coqv 8.6
RUN opam repo add coq-released http://coq.inria.fr/opam/released
RUN opam install coq.${coqv} && opam pin add coq ${coqv}

# Set the final directory entrypoint
WORKDIR ${MYHOME}/everest

# Provide the default command prefix when a container is created from this image, by `docker run`
ENTRYPOINT ["/bin/bash", "--login", "-c"]

# Provide the default command when a container is created from this image, by `docker attach`
CMD ["/bin/bash", "--login"]

# Kitematic GUI does not seem to honor ENTRYPOINT/CMD above, and instead relies on the SHELL environment variable:
ENV SHELL "/bin/bash --login"
