
#!/bin/bash

set -e
WD=$(pwd)
REPO="https://github.com/eclipse-zenoh/zenoh-flow"
PYREPO="https://github.com/eclipse-zenoh/zenoh-flow-python"
BRANCH="master"

IMAGE="gabrik91/ubuntu-build"
OUTPUT_DIRECTORY="$WD/target/jammy"
mkdir -p ${OUTPUT_DIRECTORY}

case "$ARCH" in
        amd64)

        DEB_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/amd64/debian"
        BIN_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/amd64/bin"
        TARGET="x86_64-unknown-linux-gnu"
        CONTAINER="build-jammy-amd64"
        IMAGE="$IMAGE:jammy-amd64"

        mkdir -p ${DEB_OUTPUT_DIRECTORY}
        printf "Building on image $IMAGE\n"


        # preparing the container
        #docker pull ${IMAGE}
        docker run -it -d --name ${CONTAINER} ${IMAGE} bash

        # install rust
        docker exec -u root ${CONTAINER} bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y'

        # installing cargo deb
        docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cargo install cargo-deb'

        ;;
    arm64)

        DEB_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/aarch64/debian"
        BIN_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/aarch64/bin"
        TARGET="aarch64-unknown-linux-gnu"
        CONTAINER="build-jammy-arm64"
        IMAGE="$IMAGE:jammy-arm64"

        mkdir -p ${DEB_OUTPUT_DIRECTORY}
        printf "Building on image $IMAGE\n"


        # preparing the container
        #docker pull ${IMAGE}
        docker run -it -d --name ${CONTAINER} ${IMAGE} bash

        # install rust
        docker exec -u root ${CONTAINER} bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y'

        # adding aarch64 target
        docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && rustup target add aarch64-unknown-linux-gnu'
        docker exec -u root ${CONTAINER} bash -c 'echo [target.aarch64-unknown-linux-gnu] >> ${HOME}/.cargo/config'
        docker exec -u root ${CONTAINER} bash -c 'echo linker = \"aarch64-linux-gnu-gcc\" >> ${HOME}/.cargo/config'
        docker exec -u root ${CONTAINER} bash -c 'echo strip = { path = \"aarch64-linux-gnu-strip\" } >> ${HOME}/.cargo/config'
        docker exec -u root ${CONTAINER} bash -c 'echo objcopy = { path = \"aarch64-linux-gnu-objcopy\" } >> ${HOME}/.cargo/config'

        # installing cargo deb
        docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cargo install cargo-deb'
        ;;

    armhf)

        DEB_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/armhf/debian"
        BIN_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/armhf/bin"
        TARGET="armv7-unknown-linux-gnueabihf"
        CONTAINER="build-jammy-armhf"
        IMAGE="$IMAGE:jammy-armhf"

        mkdir -p ${DEB_OUTPUT_DIRECTORY}
        printf "Building on image $IMAGE\n"


        # preparing the container
        #docker pull ${IMAGE}
        docker run -it -d --name ${CONTAINER} ${IMAGE} bash

        # install rust
        docker exec -u root ${CONTAINER} bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y'

        # adding armhf target
        docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && rustup target add armv7-unknown-linux-gnueabihf'
        docker exec -u root ${CONTAINER} bash -c 'echo [target.armv7-unknown-linux-gnueabihf] >> ${HOME}/.cargo/config'
        docker exec -u root ${CONTAINER} bash -c 'echo linker = \"arm-linux-gnueabihf-gcc\" >> ${HOME}/.cargo/config'
        docker exec -u root ${CONTAINER} bash -c 'echo strip = { path = \"arm-linux-gnueabihf-strip\" } >> ${HOME}/.cargo/config'
        docker exec -u root ${CONTAINER} bash -c 'echo objcopy = { path = \"arm-linux-gnueabihf-objcopy\" } >> ${HOME}/.cargo/config'

        # installing cargo deb
        docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cargo install cargo-deb'
        ;;

    musl)

        DEB_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/amd64-musl/debian"
        BIN_OUTPUT_DIRECTORY="$OUTPUT_DIRECTORY/amd64-musl/bin"
        TARGET="x86_64-unknown-linux-musl"
        CONTAINER="build-jammy-amd64-musl"
        IMAGE="$IMAGE:jammy-amd64"

        mkdir -p ${DEB_OUTPUT_DIRECTORY}
        printf "Building on image $IMAGE\n"


        # preparing the container
        #docker pull ${IMAGE}
        docker run -it -d --name ${CONTAINER} ${IMAGE} bash

        # install rust
        docker exec -u root ${CONTAINER} bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y'

        # adding musl target
        docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && rustup target add x86_64-unknown-linux-musl'
        docker exec -u root ${CONTAINER} bash -c 'echo [target.x86_64-unknown-linux-musl] >> ${HOME}/.cargo/config'
        docker exec -u root ${CONTAINER} bash -c 'echo rustflags = \"-Ctarget-feature=-crt-static\" >> ${HOME}/.cargo/config'

        # installing cargo deb
        docker exec -u root ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cargo install cargo-deb'

        ;;

    *)
        printf "Unrecognized architecture $ARCH\n"
        exit 1
        ;;
esac





# cloning repos inside container
docker exec -u root ${CONTAINER} bash -c "cd /root && git clone $REPO -b $BRANCH"
docker exec -u root ${CONTAINER} bash -c "cd /root && git clone $PYREPO -b $BRANCH"
# build zenoh-flow
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow/ && cargo build --target=${TARGET} --release --all-targets'
# build zenoh-flow-python wrappers
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow-python/ && cargo build --target=${TARGET} --release --all-targets'

# build zenoh-flow-python
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow-python/ && python3 -m venv && source venv/bin/activate && cd zenoh-flow-python && pip3 install -r requirements-dev.txt && maturin build --release'


# generate debian packages for zenoh-flow-daemon, zenoh-flow-ctl and zenoh-flow meta-pacakge
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow/ && cargo deb --target=${TARGET} -p zenoh-flow-daemon --no-build'
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow/ && cargo deb --target=${TARGET}  -p zfctl --no-build'
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow/ && cargo deb --target=${TARGET}  -p zenoh-flow-plugin --no-build'

# generate debian packages for zenoh-flow-python-wrappers and meta pacakges
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow-python/ && cargo deb --target=${TARGET} -p -p zenoh-flow-python-source-wrapper --no-build'
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow-python/ && cargo deb --target=${TARGET} -p -p zenoh-flow-python-sink-wrapper --no-build'
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow-python/ && cargo deb --target=${TARGET} -p -p zenoh-flow-python-operator-wrapper --no-build'
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow-python/ && equivs-build zenoh-flow-python-extension'
docker exec -u root -e TARGET=${TARGET} ${CONTAINER} bash -c 'source ${HOME}/.cargo/env && cd /root/zenoh-flow-python/ && equivs-build zenoh-flow-python-extension-plugin'



# copy-out generated debian files
docker exec -u root ${CONTAINER} bash -c "mkdir /tmp/amd64 && cp /root/zenoh-flow/target/$TARGET/debian/*.deb /tmp/amd64"
docker exec -u root ${CONTAINER} bash -c "cp /root/zenoh-flow-python/target/$TARGET/debian/*.deb /tmp/amd64"
docker exec -u root ${CONTAINER} bash -c "cp /root/zenoh-flow-python/target/$TARGET/wheels/*.whl /tmp/amd64"
# docker exec -u root ${CONTAINER} bash -c "cp /root/zenoh-flow/zenoh-flow/resources/debian/*.deb /tmp/amd64"
docker cp  "$CONTAINER:/tmp/amd64" ${DEB_OUTPUT_DIRECTORY}

# copy-out generated binaries
docker exec -u root ${CONTAINER} bash -c "mkdir /tmp/bin && cp /root/zenoh-flow/target/$TARGET/release/zenoh-flow-daemon /tmp/bin"
docker exec -u root ${CONTAINER} bash -c "cp /root/zenoh-flow/target/$TARGET/release/zfctl /tmp/bin"
docker exec -u root ${CONTAINER} bash -c "cp /root/zenoh-flow/target/$TARGET/release/cargo-zenoh-flow /tmp/bin"
docker cp  "$CONTAINER:/tmp/bin" ${BIN_OUTPUT_DIRECTORY}

docker container rm --force ${CONTAINER}

echo "jammy $ARCH done!"
