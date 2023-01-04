FROM fedora:35

LABEL authors="Gabriele Baldoni"

RUN dnf update -y && \
	dnf install -y git curl fedora-packager rpmdevtools && \
	dnf groupinstall 'Development Tools' 'Development Libraries' -y

COPY bin/uid_entrypoint /bin/uid_entrypoint
RUN mkdir -p /home/jenkins
RUN chgrp -R 0 /home/
RUN chmod -R g=u /home/
RUN chmod g=u /etc/passwd
RUN ["chmod", "+x", "/bin/uid_entrypoint"]
ENTRYPOINT [ "/bin/uid_entrypoint" ]
USER 1001

CMD /usr/bin/bash