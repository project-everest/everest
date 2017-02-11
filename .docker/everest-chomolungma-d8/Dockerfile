# Note: building d8 on the Dockerhub takes a substantial amount of time, so we
# split up the image creation across a couple files.
FROM projecteverest/everest-chomolungma

WORKDIR ${MYHOME}

# The wasm backend of KreMLin is better tested from the command-line using d8,
# the debug shell of v8. https://github.com/v8/v8/wiki/Building%20from%20Source
# has all the instructions. This fetches Google's set of tools.
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
# Note: depot_tools has a bug in their latest version... revert to the last
# known good version.
RUN cd depot_tools && git reset --hard 6db8ac71
ENV DEPOT_TOOLS_UPDATE 0
RUN echo "export PATH=$(pwd)/depot_tools:\$PATH" >> ${MYHOME}/.profile
RUN gclient
RUN fetch v8

# Then, these are the instructions for building an x64 release of v8
WORKDIR ${MYHOME}/v8
RUN gclient sync
RUN tools/dev/v8gen.py x64.release
RUN ninja -C out.gn/x64.release d8
RUN echo "export PATH=$(pwd)/out.gn/x64.release:\$PATH" >> ${MYHOME}/.profile

WORKDIR ${MYHOME}/everest
