#!/bin/bash

# environment.sh -----------------------------------------------------------------------------------
#
# Script Description:
#    This script uses envsubst to load environmental variables to nginx config files
#    NOTE: Must be executed before running the configurate.sh script that copies the files
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

# TODO: Add here the config files with environmental variables
FILES="
${CONFIG_DIR}/base.conf
${CONFIG_DIR}/main.conf
${CONFIG_DIR}/upstream_servers.conf
"
for f in $FILES; do
    if [[ -f "$f" ]]; then
        log_info "Update Environmental Variables in '$f'..."
        envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < "$f" > temp$$; mv temp$$ "$f"
    fi
done

exit 0
