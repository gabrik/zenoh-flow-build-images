
#!/bin/bash

set -e

REPO="https://github.com/eclipse-zenoh/zenoh-flow"
BRANCH="master"

case "$DISTRO" in
    ubuntu-jammy)
        bash -c "ARCH=$ARCH ./ubuntu/jammy/build-cross.sh"
        ;;
    ubuntu-focal)
        bash -c "ARCH=$ARCH ./ubuntu/focal/build-cross.sh"
        ;;
    fedora-35)
        bash -c "ARCH=$ARCH ./fedora/35/build-cross.sh"
        ;;
    alpine-3)
        bash -c "ARCH=$ARCH ./alpine/3/build-cross.sh"
        ;;
    *)
    printf "Unrecognized distribution $DISTRO\n"
    exit 1
    ;;
esac

echo "Done!"