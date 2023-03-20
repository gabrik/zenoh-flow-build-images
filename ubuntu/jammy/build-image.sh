
#!/bin/bash


set -e

case "$ARCH" in
    amd64)
        sg docker -c "docker build ./amd64 -f ./amd64/Dockerfile -t gabrik91/ubuntu-build:jammy-amd64 --no-cache" --oom-kill-disable
        ;;
    arm64)
        sg docker -c "docker build ./arm64 -f ./arm64/Dockerfile -t gabrik91/ubuntu-build:jammy-arm64 --no-cache" --oom-kill-disable
        ;;
    armhf)
        sg docker -c "docker build ./armhf -f ./armhf/Dockerfile -t gabrik91/ubuntu-build:jammy-armhf --no-cache" --oom-kill-disable
        ;;
    *)
    printf "Unrecognized architecture $ARCH\n"
    exit 1
    ;;
esac

exit 0