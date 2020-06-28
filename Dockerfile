FROM pennsive/neuror:4.0
COPY run.R /run.R
ENTRYPOINT [ "docker-entrypoint.sh", "/run.R" ]