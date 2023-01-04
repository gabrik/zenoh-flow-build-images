
#!/bin/bash


set -e

case "$ARCH" in
    amd64)
        sg docker -c "docker build ./amd64 -f ./amd64/Dockerfile -t eclipse/zenoh-flow-alpine3-build:amd64 --no-cache" --oom-kill-disable
        ;;
    arm64)
        printf "Not yet $ARCH\n"
        exit 1
        ;;
    armhf)
        printf "Not yet $ARCH\n"
        exit 1
        ;;
    *)
    printf "Unrecognized architecture $ARCH\n"
    exit 1
    ;;
esac

exit 0