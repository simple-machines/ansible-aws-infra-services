#!/usr/bin/env bash
set -e
if ! [ -a .vaultpassword ]
then
    echo "Vault password file '.vaultpassword' not found."
    exit 1
fi
OPERATION="edit"
if ! [ -a /project/$CLUSTER_NAME/infrastructure/$TARGET_ENV.vault.yml ]
then
    echo "Creating new vault for $TARGET_ENV"
    OPERATION="create"
fi

command -v ansible-vault >/dev/null 2>&1 || { echo "Please install ansible-vault before running this script." >&2; exit 1; }
ansible-vault -vvv --vault-password-file=/project/.vaultpassword $OPERATION /project/$CLUSTER_NAME/infrastructure/$TARGET_ENV.vault.yml