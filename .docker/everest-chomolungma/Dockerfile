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

# Install required packages
# Do not install recommended packages, so as not to install OCaml here, thus guaranteeing that the only OCaml will be the one compiled by opam init later
# Loop until success (hash sum mismatches will often entail failure)
# ca-certificates-mono: needed to build Vale
# pkg-config: needed by ocamlfind
# git: needed by opam (if not specified, then opam will install without any way to retrieve packages)
# python, python3: Vale needs 2.7, others need 3.5
# pandoc: needed by F* documentation
RUN until apt-get install --no-install-recommends --yes \
  libssl-dev \
  libsqlite3-dev \
  g++-5 \
  gcc-5 \
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
 ; do apt-get --yes update ; done

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

# Install Z3 (do it here for better caching)
ENV z3v z3-4.5.0
ENV z3platform x64-ubuntu-14.04
ENV z3full ${z3v}-${z3platform}
RUN wget -O z3.zip https://github.com/Z3Prover/z3/releases/download/${z3v}/${z3full}.zip
RUN mkdir z3
RUN unzip -uo z3.zip -d z3
ENV PATH ${MYHOME}/z3/${z3full}/bin:$PATH

# Enable --yes option for opam
ENV OPAMYES 1

# Install OCaml
ENV ocamlv 4.04.0
RUN opam init --auto-setup --compiler=${ocamlv}


# Prepare everest repository
RUN git clone https://github.com/project-everest/everest.git everest

# Install opam packages required by everest (to avoid duplicating the list of opam packages here),
# then retrieve the latest version
WORKDIR ${MYHOME}/everest
RUN ./everest --yes check pull

# Provide the default command when a container is created from this image
CMD /bin/bash --login
