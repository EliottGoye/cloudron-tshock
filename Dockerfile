FROM ghcr.io/pryaxis/tshock:6.2@sha256:70e59a8e6b4c79b5fad469d320962c1fc98625ed3a955510a2f2641dbff2f7e7 

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
