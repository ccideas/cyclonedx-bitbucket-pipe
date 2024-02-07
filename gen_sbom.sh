#!/usr/bin/env bash
set -e

if [ "${DEBUG_BASH}" = true ]; then
  set -x
fi

if [ -z "${GEN_SBOM_SCRIPT_LOCATION}" ]; then
  source "./gen_sbom_functions.sh"
else
  source "${GEN_SBOM_SCRIPT_LOCATION}/gen_sbom_functions.sh"
fi

#--------------------------------------------------------------------------------
#----------------------------------Program Start---------------------------------
#--------------------------------------------------------------------------------

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  help
  exit 0
fi

set_sbom_filename
generate_cyclonedx_sbom
