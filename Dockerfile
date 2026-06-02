FROM ghcr.io/pryaxis/tshock:6.1@sha256:911459f0ce02014a64c197647a16e9ee57e4d16695de8cfda1f1b552af56ab43

USER root

# Create app code directory
RUN mkdir -p /app/code

# Copy and register the start script
COPY start.sh /app/code/start.sh
RUN chmod +x /app/code/start.sh

EXPOSE 7777 7878

# Override the upstream ENTRYPOINT so Cloudron can use CMD directly
ENTRYPOINT []
CMD ["/app/code/start.sh"]
