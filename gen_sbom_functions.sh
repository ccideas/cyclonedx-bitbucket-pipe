#!/usr/bin/env bash
set -e

if [ "${DEBUG_BASH}" = true ]; then
  set -x
fi

# Statics
DEFAULT_OUTPUT_DIRECTORY="build"
SWITCHES=()

## purpose: generate a CycloneDX sBOM

check_output_directory() {
  if [ -n "${OUTPUT_DIRECTORY}" ]; then
    export OUTPUT_DIR="${OUTPUT_DIRECTORY}"
  else
    export OUTPUT_DIR="${DEFAULT_OUTPUT_DIRECTORY}"
  fi

  echo "writing output to ${OUTPUT_DIR}"
  if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "creating ${OUTPUT_DIR}"
    mkdir "${OUTPUT_DIR}"
  else
    echo "${OUTPUT_DIR} already exists"
  fi
}

set_sbom_filename() {
  check_output_directory

  if [ -n "${SBOM_FILENAME}" ]; then
    OUTPUT_FILENAME="${OUTPUT_DIR}/${SBOM_FILENAME}"
  elif [ -n "${BITBUCKET_REPO_SLUG}" ]; then
    OUTPUT_FILENAME="${OUTPUT_DIR}/${BITBUCKET_REPO_SLUG}"
  else
    OUTPUT_FILENAME="${OUTPUT_DIR}/sbom"
  fi

  # set the file extension
  if [ -n "${NPM_OUTPUT_FORMAT}" ]; then
    OUTPUT_FILENAME="${OUTPUT_FILENAME}.${NPM_OUTPUT_FORMAT}"
  else
    OUTPUT_FILENAME="${OUTPUT_FILENAME}.json"
  fi

  echo "sBOM will be written to ${OUTPUT_FILENAME}"
  SWITCHES+=("--output" "${OUTPUT_FILENAME}")
}

help() {
  echo "Generates a CycloneDX sBOM file for the given project"
}

verify_cdxgen() {
  echo "verifying @cyclonedx/cdxgen is installed"

  if [[ "${CYCLONEDX_CDXGEN_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "version ${CYCLONEDX_CDXGEN_VERSION} of cdxgen is installed"
  else
    echo "ERROR: cannot validate version of cdxgen. Verify npm package is installed"
    exit 1
  fi
}

generate_switches() {
  if [ -n "${CDXGEN_SPEC_VERSION}" ]; then
    SWITCHES+=("--spec-version" "${CDXGEN_SPEC_VERSION}")
  fi

  if [ -n "${CDXGEN_PROJECT_TYPE}" ]; then
    SWITCHES+=(--type "${CDXGEN_PROJECT_TYPE}")
  fi

  if [ -n "${CDXGEN_OUTPUT}" ]; then
    SWITCHES+=("--output" "${CDXGEN_OUTPUT_FORMAT}")
  fi

  if [ "${CDXGEN_PRINT_AS_TABLE}" = true ]; then
    SWITCHES+=("--print")
  fi

  if [ -n "${CDXGEN_PATH_TO_SCAN}" ]; then
    SWITCHES+=("${CDXGEN_PATH_TO_SCAN}")
  fi

  echo "the following switches will be used"
  echo "${SWITCHES[@]}"
}

unknown_project_format() {
  echo "ERROR: unknown project format"
  echo "currently only node/npm based projects are supported"
  exit 1
}

generate_cyclonedx_sbom() {
  CYCLONEDX_CDXGEN_VERSION=$(cdxgen --version)
  verify_cdxgen
  generate_switches
  echo "running: cdxgen " "${SWITCHES[@]}"
  cdxgen "${SWITCHES[@]}"
}
