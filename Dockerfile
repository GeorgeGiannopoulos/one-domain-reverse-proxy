FROM nginx:latest

# TODO: Add here the project's domain
ENV PROJECT_DOMAIN='project.domain.gr' \
    EXECUTION_MODE='production' \
    CERT_STAGING=0 \
    CONFIG_DIR='/config'

# Install dependencies:
# NOTE: Install either 'systemd-sysv' or 'cron' to auto-renew certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends cron certbot && \
    apt-get clean

# Copy configuration files, handler pages:
COPY config/* ${CONFIG_DIR}/
COPY default/ /usr/share/nginx/html/

# Copy configuration scripts:
# NOTE: Append numbers as suffixes before each script's name to dictate the execution order.
#       Start from 99 and dicrease them, so the nginx default scripts to be executed first
COPY ./build/* /build/
RUN chmod 750 -R /build/ && \
    mv /build/environment.sh /docker-entrypoint.d/97-environment.sh && \
    mv /build/configurate.sh /docker-entrypoint.d/98-configurate.sh && \
    mv /build/certificates.sh /docker-entrypoint.d/99-certificates.sh

WORKDIR /etc/nginx

# Expose to the World:
EXPOSE 80 443

# Ensure Persistence of Data:
VOLUME ["/etc/ssl/live", "/etc/letsencrypt"]
