#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  case "$1" in

    "$PRODUCT_SOFTWARE")
      pushImage "$VERSION_JIRA"
      ;;

    "$PRODUCT_CORE")
      pushImage "core.$VERSION_JIRA"
      ;;

    "$PRODUCT_SERVICE_DESK")
      pushImage "servicedesk.$VERSION_SERVICE_DESK"
      ;;
    *)
      pushImage "$VERSION_JIRA"
      pushImage "core.$VERSION_JIRA"
      pushImage "servicedesk.$VERSION_SERVICE_DESK"
      ;;
  esac
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
