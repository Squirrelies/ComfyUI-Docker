#!/usr/bin/env bash
set -euo pipefail

### Run commands as root before handing off execution to the non-root user.


# Hand off to the main process defined by CMD
exec gosu ${CONT_USER} "$@"
