#!/bin/bash

# configurate.sh -----------------------------------------------------------------------------------
#
# Script Description:
#    This script manages the nginx configuration
#
# Required Arguments:
#
# Optional Arguments:
#    -d | --deployment : Copies the configuration for the deployment (Prompts a Down-Time message)
#    -h | --help       : Help message
#
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Initialize script
# --------------------------------------------------------------------------------------------------
#
# Turn on bash's exit on error (e)
set -e

source "/build/functions.sh"


# --------------------------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------------------------
#
log_info "Running: ${0##*/}"
log_env


mkdir -p "${NGINX_DEFAULT_CONFIG_DIR}"
mkdir -p "${NGINX_CUSTOM_CONFIG_DIR}"

# Copy configuration file
#
# server_http.conf or server_https.conf
if [[ "${HTTPS_ENABLED}" == 'true' ]]; then
    log_info "Coping '${CONFIG_DIR}/server_https.conf' to '${NGINX_DEFAULT_CONFIG_DIR}/server_https.conf'"
    cp "${CONFIG_DIR}/server_https.conf" "${NGINX_DEFAULT_CONFIG_DIR}/server_https.conf"
else
    log_info "Coping '${CONFIG_DIR}/server_http.conf' to '${NGINX_DEFAULT_CONFIG_DIR}/server_http.conf'"
    cp "${CONFIG_DIR}/server_http.conf" "${NGINX_DEFAULT_CONFIG_DIR}/server_http.conf"
fi
# base.conf
log_info "Coping '${CONFIG_DIR}/base.conf' to '${NGINX_CUSTOM_CONFIG_DIR}/base.conf'"
cp "${CONFIG_DIR}/base.conf" "${NGINX_CUSTOM_CONFIG_DIR}/base.conf"
# common_headers.conf
log_info "Coping '${CONFIG_DIR}/common_headers.conf' to '${NGINX_CUSTOM_CONFIG_DIR}/common_headers.conf'"
cp "${CONFIG_DIR}/common_headers.conf" "${NGINX_CUSTOM_CONFIG_DIR}/common_headers.conf"
# common_proxy_headers.conf
log_info "Coping '${CONFIG_DIR}/common_proxy_headers.conf' to '${NGINX_CUSTOM_CONFIG_DIR}/common_proxy_headers.conf'"
cp "${CONFIG_DIR}/common_proxy_headers.conf" "${NGINX_CUSTOM_CONFIG_DIR}/common_proxy_headers.conf"
# errors.conf
log_info "Coping '${CONFIG_DIR}/errors.conf' to '${NGINX_CUSTOM_CONFIG_DIR}/errors.conf'"
cp "${CONFIG_DIR}/errors.conf" "${NGINX_CUSTOM_CONFIG_DIR}/errors.conf"
# main.conf -> locations.conf
log_info "Coping '${CONFIG_DIR}/main.conf' to '${NGINX_CUSTOM_CONFIG_DIR}/locations.conf'"
cp "${CONFIG_DIR}/main.conf" "${NGINX_CUSTOM_CONFIG_DIR}/locations.conf"
# ssl.conf
log_info "Coping '${CONFIG_DIR}/ssl.conf' to '${NGINX_CUSTOM_CONFIG_DIR}/ssl.conf'"
cp "${CONFIG_DIR}/ssl.conf" "${NGINX_CUSTOM_CONFIG_DIR}/ssl.conf"
# upstream_servers.conf
log_info "Coping '${CONFIG_DIR}/upstream_servers.conf' to '${NGINX_CUSTOM_CONFIG_DIR}/upstream_servers.conf'"
cp "${CONFIG_DIR}/upstream_servers.conf" "${NGINX_CUSTOM_CONFIG_DIR}/upstream_servers.conf"

exit 0
