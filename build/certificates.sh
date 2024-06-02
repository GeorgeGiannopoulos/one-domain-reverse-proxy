#!/bin/bash

# certificates.sh ----------------------------------------------------------------------------------
#
# Script Description:
#    This script manages the SSL certificates handled by nginx
#    The script executes the following steps:
#        1. Checks if certificates exist and if not then it creates dummy ones,
#           so the nginx can start (in any case)
#        2. Checks if certbot certificates exist and if not then generates new ones,
#           else renew them
#        3. Coping the certbot certificates to nginx ssl directory
#
# Required Arguments:
#
# Optional Arguments:
#    -h | --help  : Help message
#
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Initialize script
# --------------------------------------------------------------------------------------------------
#
source "/build/functions.sh"


# --------------------------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------------------------
#
log_info "Running: ${0##*/}"
log_env

# Check if HTTPS is enabled
if [[ "${HTTPS_ENABLED}" == 'false' ]]; then
    log_info "HTTPS is not enabled. Ignoring certificates generation"
    exit 0
fi

mkdir -p "${SSL_CERTIFICATES_DIR}"

# Check if execution mode is set
if [[ -z "${EXECUTION_MODE}" ]]; then
    log_error "Please specify EXECUTION_MODE variable"
    exit 1
fi

if [[ "${EXECUTION_MODE}" != 'production' && "${EXECUTION_MODE}" != 'development' ]]; then
    log_error "Unkwown EXECUTION_MODE variable: '${EXECUTION_MODE}'"
    exit 1
fi


# ------------------------------
# Self-Signed certificates
# ------------------------------
#
# Generate dummy self-signed certificates, so the nginx can start
if [[ ! -f "${SSL_CERTIFICATES_DIR}/${SSL_CERTIFICATE_KEY}" ]]; then
    log_info "Creating dummy certificates for $DOMAIN ..."
    openssl req -x509 -nodes -newkey rsa:$RSA_KEY_SIZE -days 1      \
        -keyout "${SSL_CERTIFICATES_DIR}/${SSL_CERTIFICATE_KEY}"    \
        -out "${SSL_CERTIFICATES_DIR}/${SSL_CERTIFICATE}"           \
        -subj '/CN=localhost'
fi


# ------------------------------
# Diffie Hellman key
# ------------------------------
#
# Generate a Diffie Hellman key encryption, so the nginx can start
if [[ ! -f "${SSL_CERTIFICATES_DIR}/${SSL_DHPARAM}" ]]; then
    log_info "Creating Diffie Hellman key for $DOMAIN ..."
    openssl dhparam -out "${SSL_CERTIFICATES_DIR}/${SSL_DHPARAM}" ${DH_KEY_SIZE}
fi

if [[ "${EXECUTION_MODE}" != 'production' ]]; then
    log_info "Running with Self-Signed certificates for $DOMAIN ..."
    exit 0
fi


# ------------------------------
# Certbot certificates
# ------------------------------
#
# Get the certbot arguments
domain=$(join_domains $DOMAIN)
email=$(email_arg $EMAIL)
staging=$(staging $STAGING)

# Generate certbot certificates
if [[ ! -f "${CERTBOT_DIR}/${SSL_CERTIFICATE_KEY}" ]]; then
    log_info "Creating certbot certificates for $DOMAIN ..."
    certbot certonly --standalone                \
                     --preferred-challenges http \
                     --non-interactive           \
                     --agree-tos                 \
                     $email                      \
                     $domain                     \
                     $staging
else
    log_info "Renew certbot certificates for $DOMAIN ..."
    certbot renew
fi

# ------------------------------
# Override certificates
# ------------------------------
#
if [[ ! -f "${CERTBOT_DIR}/${SSL_CERTIFICATE}" || ! -f "${CERTBOT_DIR}/${SSL_CERTIFICATE_KEY}" ]]; then
   log_warn "Certbot certificates haven't been generated!"
   exit 0
fi

cp "${CERTBOT_DIR}/${SSL_CERTIFICATE}" "${SSL_CERTIFICATES_DIR}/${SSL_CERTIFICATE}"
cp "${CERTBOT_DIR}/${SSL_CERTIFICATE_KEY}" "${SSL_CERTIFICATES_DIR}/${SSL_CERTIFICATE_KEY}"

#
# Handle certificates auto-renewal
#
# NOTE: certbot installs a system timer and a cronjob that auto-renews the certificates
#       If cron is installed on the system, then the cronjob handles the auto-renewal
#       but if the systemd or systemctl are install, then the system.timer handles it
# # Copy cron file to the cron.d directory
# echo "0 */12 * * * certbot renew > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/crontab
# chmod 0644 /etc/cron.d/crontab        # Give execution rights on the cron job
# /usr/bin/crontab /etc/cron.d/crontab  # Apply cron job
# Start cron
/usr/bin/crontab
