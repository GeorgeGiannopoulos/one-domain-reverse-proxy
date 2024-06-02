#!/bin/bash

# functions.sh -------------------------------------------------------------------------------------
#
# Script Description:
#    This script contains functions used by all the scripts
#
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Environmental
# --------------------------------------------------------------------------------------------------
EXECUTION_MODE="${EXECUTION_MODE:-production}"  # Options: 'production', 'deployment'
PROJECT_DOMAIN="${PROJECT_DOMAIN:-project.domain.gr}"  # TODO: Add here the project's domain
HTTPS_ENABLED="${HTTPS_ENABLED:-true}"
CERT_STAGING="${CERT_STAGING:-0}"  # Options: 0, 1  # NOTE: Set to 1 if you're testing your setup to avoid hitting request limits


# --------------------------------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------------------------------
# Logging
VERBOSE=false
# Certificates Arguments
DOMAIN="${PROJECT_DOMAIN}"
EMAIL='project@domain.gr' # NOTE: Adding a valid address is strongly recommended  # TODO: Add here the project's email
RSA_KEY_SIZE=4096
DH_KEY_SIZE=2048
STAGING=${CERT_STAGING}
# nginx Arguments
NGINX_DIR='/etc/nginx'
NGINX_DEFAULT_CONFIG_DIR="${NGINX_DIR}/conf.d"
NGINX_CUSTOM_CONFIG_DIR="${NGINX_DIR}/config"
CERTBOT_DIR="/etc/letsencrypt/live/${DOMAIN}"
SSL_CERTIFICATES_DIR="/etc/ssl/live/domain"
SSL_CERTIFICATE='fullchain.pem'
SSL_CERTIFICATE_KEY='privkey.pem'
SSL_DHPARAM='ssl-dhparams.pem'
SSL_CONFIG='ssl.conf'


# --------------------------------------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------------------------------------
log() {
    printf '%s %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%S:%3NZ") $1 | $2"
    return
}

log_info() {
    log "INFO " "$1"
    return
}

log_warn() {
    log "WARNING" "$1"
    return
}

log_error() {
    log "ERROR" "$1"
    return
}

log_env() {
    # Log Environmental Variables
    log_info "Execution Mode   : '${EXECUTION_MODE}'"
    log_info "Execution URL    : '${PROJECT_DOMAIN}'"
    log_info "HTTPS Enabled    : '${HTTPS_ENABLED}'"
    log_info "Cert Staging Mode: '${CERT_STAGING}'"
}

join_domains() {
    domain=$1
    if [[ -z $domain ]]; then
        log_error "Domain is empty! Please provide one."
        exit 1
    fi
    domain_arg="-d $domain"
    echo "${domain_arg}"
}

email_arg() {
    # Select appropriate EMAIL arg
    email=$1
    case "$email" in
        "") email_arg="--register-unsafely-without-EMAIL" ;;
        *) email_arg="--email $email" ;;
    esac
    echo $email_arg
}

staging() {
    staging=$1
    # Enable STAGING mode if needed
    if [ $STAGING != "0" ]; then
        echo "--staging"
    fi
    echo ''
}

