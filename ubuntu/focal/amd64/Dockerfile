FROM ubuntu:focal

LABEL authors="Gabriele Baldoni"

RUN DEBIAN_FRONTEND=noninteractive apt update && \
	DEBIAN_FRONTEND=noninteractive apt install git python3-venv equivs musl-tools build-essential devscripts debhelper pkg-config dpkg-dev equivs libpython3-dev -y

COPY bin/uid_entrypoint /bin/uid_entrypoint
RUN mkdir -p /home/jenkins
RUN chgrp -R 0 /home/
RUN chmod -R g=u /home/
RUN chmod g=u /etc/passwd
RUN ["chmod", "+x", "/bin/uid_entrypoint"]
ENTRYPOINT [ "/bin/uid_entrypoint" ]
USER 1001

CMD /usr/bin/bash