# Everest build container
FROM everest-base-windows-nt:1

ARG BUILDLOGFILE
ARG MAXTHREADS
ARG TARGET
ARG BRANCHNAME

# Add ssh key
# We cannot copy directly to the .ssh folder, instead we copy to a temp folder
WORKDIR "everestsshkey"
COPY id_rsa .
WORKDIR ".."

# Now, using bash we copy the file, set the correct security and remove the previous folder
RUN Invoke-BashCmd '"cd .ssh && cp ../everestsshkey/id_rsa . && chmod 600 id_rsa && rm -rf ../everestsshkey"'

RUN Invoke-BashCmd rm -rf everest

# Copy source files
WORKDIR "everest"
COPY / .
WORKDIR ".."

# Do some cleanup
RUN Invoke-BashCmd rm everest/Dockerfile
RUN Invoke-BashCmd rm everest/build.sh
RUN Invoke-BashCmd rm everest/build_helper.sh
RUN Invoke-BashCmd rm everest/id_rsa
RUN Invoke-BashCmd rm everest/commitinfofilename.json

COPY build.sh build.sh
COPY build_helper.sh build_helper.sh

RUN Invoke-BashCmd ./build_helper.sh $Env:TARGET $Env:BUILDLOGFILE $Env:MAXTHREADS $Env:BRANCHNAME '||' true

# Remove ssh key.
RUN Invoke-BashCmd rm .ssh/id_rsa