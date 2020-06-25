FROM pennsive/neuror:4.0.1
COPY run.R /run.R
ENTRYPOINT [ "/run.R" ]