
#!/bin/bash

set -e
WD=$(pwd)
REPO="https://github.com/eclipse-zenoh/zenoh-flow"
BRANCH="master"

REPO="https://github.com/atolab/zenoh-flow"
BRANCH="feat/meta-package"

IMAGE="eclipse/zenoh-flow-f35-build"
OUTPUT_DIRECTORY="$WD/target/fedora-35"
mkdir -p ${OUTPUT_DIRECTORY}

case "$ARCH" in
        amd64)

        RPM_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/amd64/rpm"
        BIN_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/amd64/bin"
        TARGET="x86_64-unknown-linux-gnu"
        CONTAINER="build-f35-amd64"
        IMAGE="$IMAGE:amd64"

        mkdir -p ${RPM_OUTPUT_DIRECTORY}
        printf "Building on image $IMAGE\n"


        # preparing the container
        #docker pull ${IMAGE}
        docker run -it -d --name ${CONTAINER} ${IMAGE} bash

        # install rust
        docker exec -u root ${CONTAINER} bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y'

        # installing cargo deb
        docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cargo install cargo-rpm'

        ;;
    arm64)

        printf "Not yet $ARCH\n"
        exit 1
        ;;

        # RPM_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/aarch64/rpm"
        # BIN_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/aarch64/bin"
        # TARGET="aarch64-unknown-linux-gnu"
        # CONTAINER="build-f35-arm64"
        # IMAGE="$IMAGE:arm64"

        # mkdir -p ${RPM_OUTPUT_DIRECTORY}
        # printf "Building on image $IMAGE\n"


        # # preparing the container
        # #docker pull ${IMAGE}
        # docker run -it -d --name ${CONTAINER} ${IMAGE} bash

        # # install rust
        # docker exec -u root ${CONTAINER} bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y'

        # # adding aarch64 target
        # docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && rustup target add aarch64-unknown-linux-gnu'
        # docker exec -u root ${CONTAINER} bash -c 'echo [target.aarch64-unknown-linux-gnu] >> ${HOME}/.cargo/config'
        # docker exec -u root ${CONTAINER} bash -c 'echo linker = \"aarch64-linux-gnu-gcc\" >> ${HOME}/.cargo/config'
        # docker exec -u root ${CONTAINER} bash -c 'echo strip = { path = \"aarch64-linux-gnu-strip\" } >> ${HOME}/.cargo/config'
        # docker exec -u root ${CONTAINER} bash -c 'echo objcopy = { path = \"aarch64-linux-gnu-objcopy\" } >> ${HOME}/.cargo/config'

        # # installing cargo deb
        # docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cargo install cargo-rpm'
        # ;;

    armhf)

        printf "Not yet $ARCH\n"
        exit 1
        ;;

        # RPM_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/armhf/rpm"
        # BIN_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/armhf/bin"
        # TARGET="armv7-unknown-linux-gnueabihf"
        # CONTAINER="build-f35-armhf"
        # IMAGE="$IMAGE:armhf"

        # mkdir -p ${RPM_OUTPUT_DIRECTORY}
        # printf "Building on image $IMAGE\n"


        # # preparing the container
        # #docker pull ${IMAGE}
        # docker run -it -d --name ${CONTAINER} ${IMAGE} bash

        # # install rust
        # docker exec -u root ${CONTAINER} bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y'

        # # adding armhf target
        # docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && rustup target add armv7-unknown-linux-gnueabihf'
        # docker exec -u root ${CONTAINER} bash -c 'echo [target.armv7-unknown-linux-gnueabihf] >> ${HOME}/.cargo/config'
        # docker exec -u root ${CONTAINER} bash -c 'echo linker = \"arm-linux-gnueabihf-gcc\" >> ${HOME}/.cargo/config'
        # docker exec -u root ${CONTAINER} bash -c 'echo strip = { path = \"arm-linux-gnueabihf-strip\" } >> ${HOME}/.cargo/config'
        # docker exec -u root ${CONTAINER} bash -c 'echo objcopy = { path = \"arm-linux-gnueabihf-objcopy\" } >> ${HOME}/.cargo/config'

        # # installing cargo deb
        # docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cargo install cargo-rpm'
        # ;;

    musl)

        printf "Not yet $ARCH\n"
        exit 1
        ;;

        # RPM_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/amd64-musl/rpm"
        # BIN_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/amd64-musl/bin"
        # TARGET="x86_64-unknown-linux-musl"
        # CONTAINER="build-f35-amd64-musl"
        # IMAGE="$IMAGE:amd64"

        # mkdir -p ${RPM_OUTPUT_DIRECTORY}
        # printf "Building on image $IMAGE\n"


        # # preparing the container
        # #docker pull ${IMAGE}
        # docker run -it -d --name ${CONTAINER} ${IMAGE} bash

        # # install rust
        # docker exec -u root ${CONTAINER} bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y'

        # # adding musl target
        # docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && rustup target add x86_64-unknown-linux-musl'
        # docker exec -u root ${CONTAINER} bash -c 'echo [target.x86_64-unknown-linux-musl] >> ${HOME}/.cargo/config'
        # docker exec -u root ${CONTAINER} bash -c 'echo rustflags = \"-Ctarget-feature=-crt-static\" >> ${HOME}/.cargo/config'

        # # installing cargo deb
        # docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cargo install cargo-rpm'

        # ;;

    *)
        printf "Unrecognized architecture $ARCH\n"
        exit 1
        ;;
esac





# cloning repos inside container
docker exec -u root ${CONTAINER} bash -c "cd /root && git clone $REPO -b $BRANCH"
# build zenoh-flow
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow/ && cargo build --target=${TARGET} --release --all-targets'

# generate rpm packages for zenoh-flow-daemon, zenoh-flow-ctl and zenoh-flow meta-pacakge
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow/zenoh-flow-daemon && cargo rpm init && cp resources/rpm/template.hbs .rpm/zenoh-flow-daemon.spec && cargo rpm build'
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow/zenoh-flow-ctl && cargo rpm init && cargo rpm build'
docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow/zenoh-flow/resources/rpm/ && rpmbuild -ba zenoh-flow.spec'

# copy-out generated rpm files
docker exec -u root ${CONTAINER} bash -c "mkdir /tmp/amd64 && cp /root/zenoh-flow/target/release/rpmbuild/RPMS/x86_64/*.rpm /tmp/amd64"
docker exec -u root ${CONTAINER} bash -c "cp /root/rpmbuild/SRPMS/*.rpm /tmp/amd64"
docker cp  "$CONTAINER:/tmp/amd64" ${RPM_OUTPUT_DIRECTORY}

# copy-out generated binaries
docker exec -u root ${CONTAINER} bash -c "mkdir /tmp/bin && cp /root/zenoh-flow/target/$TARGET/release/zenoh-flow-daemon /tmp/bin"
docker exec -u root ${CONTAINER} bash -c "cp /root/zenoh-flow/target/$TARGET/release/zenoh-flow-ctl /tmp/bin"
docker exec -u root ${CONTAINER} bash -c "cp /root/zenoh-flow/target/$TARGET/release/cargo-zenoh-flow /tmp/bin"
docker cp  "$CONTAINER:/tmp/bin" ${BIN_OUTPUT_DIRECTORY}

docker container rm --force ${CONTAINER}

echo "Fedora 35 $ARCH done!"
