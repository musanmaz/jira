#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  case "$1" in

    "$PRODUCT_SOFTWARE")
      buildSoftware
      ;;

    "$PRODUCT_CORE")
      buildCore
      ;;

    "$PRODUCT_SERVICE_DESK")
      buildServiceDesk
      ;;
    *)
      buildSoftware
      buildCore
      buildServiceDesk
      ;;
  esac
}

buildSoftware() {
  local tag="9.0.0"
  local product="$PRODUCT_SOFTWARE"
  local version="$VERSION_JIRA"

  buildImage "$product" "$version" "$tag"
  tagImage "$tag" "$version"

}

buildCore() {
  local tag="9.0.0"
  local product="$PRODUCT_CORE"
  local version="$VERSION_JIRA"

  buildImage "$product" "$version" "$tag"
  tagImage "$tag" "$tag.$version"

}

buildServiceDesk() {
  local tag="5.0.0"
  local product="$PRODUCT_SERVICE_DESK"
  local version="$VERSION_SERVICE_DESK"

  buildImage "$product" "$version" "$tag"
  tagImage "$tag" "$tag.$version"

}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
