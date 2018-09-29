# Everest build container
FROM everest-base-linux:1

ARG BUILDLOGFILE
ARG MAXTHREADS
ARG TARGET
ARG BRANCHNAME

WORKDIR ${MYHOME}

# ADD SSH KEY
RUN mkdir -p ${MYHOME}/.ssh
RUN chown everest ${MYHOME}/.ssh
RUN chmod 700 ${MYHOME}/.ssh
COPY --chown=everest id_rsa ${MYHOME}/.ssh/id_rsa
RUN chmod 600 ${MYHOME}/.ssh/id_rsa

RUN rm -rf ${MYHOME}/everest

# Copy Everest source code.
RUN mkdir ${MYHOME}/everest
COPY --chown=everest / ${MYHOME}/everest/

# Do another cleanup
RUN rm ${MYHOME}/everest/Dockerfile
RUN rm ${MYHOME}/everest/build.sh
RUN rm ${MYHOME}/everest/build_helper.sh
RUN rm ${MYHOME}/everest/id_rsa
RUN rm ${MYHOME}/everest/commitinfofilename.json

COPY --chown=everest build.sh ${MYHOME}/build.sh
RUN chmod +x build.sh
COPY --chown=everest build_helper.sh ${MYHOME}/build_helper.sh
RUN chmod +x build_helper.sh

RUN ./build_helper.sh ${TARGET} ${BUILDLOGFILE} ${MAXTHREADS} ${BRANCHNAME} || true

# Remove ssh key
RUN rm .ssh/id_rsa