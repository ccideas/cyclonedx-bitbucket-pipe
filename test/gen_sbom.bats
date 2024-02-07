#!/usr/bin/env bats

# shellcheck disable=SC2030,SC2031,SC2317
# SC2030 (info): Modification of NPM_SHORT_PURLS is local (to subshell caused by @bats test)
# SC2031 (info): NPM_OUTPUT_FORMAT was modified in a subshell. That change might be lost.
# SC2317 (info): Command appears to be unreachable. Check usage (or ignore if invoked indirectly).
# None of the above checks are suitable for the bats framework

# file under test
load '../gen_sbom_functions.sh'

#--------------------------------------------------------------------------------
#---------------------------------Function Mocks---------------------------------
#--------------------------------------------------------------------------------

# don't actually call the npx command when running tests
cdxgen() {
  echo "mock of cyclonedx-npm"
}

generate_cyclonedx_sbom_for_npm_project() {
  echo "mock of generate_cyclonedx_sbom_for_npm_project()"
}

#--------------------------------------------------------------------------------
#---------------------------------------Tests------------------------------------
#--------------------------------------------------------------------------------

@test "Create output directory - output dir does not exist" {
  run check_output_directory

  EXPECTED_OUTPUT_DIR="build"

  [ -d "${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[0]}" = "writing output to ${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[1]}" = "creating ${EXPECTED_OUTPUT_DIR}" ]
  [ "$status" -eq 0 ]
}

@test "Create output directory - output dir does exist" {
  EXPECTED_OUTPUT_DIR="build"
  mkdir "${EXPECTED_OUTPUT_DIR}"

  run check_output_directory

  [ -d "${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[0]}" = "writing output to ${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[1]}" = "${EXPECTED_OUTPUT_DIR} already exists" ]
  [ "$status" -eq 0 ]
}

@test "Create output directory - custom dir - output dir does not exist" {
  export OUTPUT_DIRECTORY="build"
  run check_output_directory

  EXPECTED_OUTPUT_DIR=${OUTPUT_DIRECTORY}

  [ -d "${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[0]}" = "writing output to ${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[1]}" = "creating ${EXPECTED_OUTPUT_DIR}" ]
  [ "$status" -eq 0 ]
}

@test "Create output directory - custom dir - output dir does exist" {
  export OUTPUT_DIRECTORY="build"
  EXPECTED_OUTPUT_DIR=${OUTPUT_DIRECTORY}
  mkdir "${EXPECTED_OUTPUT_DIR}"

  run check_output_directory

  [ -d "${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[0]}" = "writing output to ${EXPECTED_OUTPUT_DIR}" ]
  [ "${lines[1]}" = "${EXPECTED_OUTPUT_DIR} already exists" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - no BITBUCKET_REPO_SLUG" {
  unset BITBUCKET_REPO_SLUG
  unset OUTPUT_FORMAT
  unset OUTPUT_DIRECTORY
  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to build/sbom.json" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - with BITBUCKET_REPO_SLUG" {
  export BITBUCKET_REPO_SLUG="SAMPLE_BITBUCKET_REPO"
  unset OUTPUT_FORMAT
  unset OUTPUT_DIRECTORY

  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to build/${BITBUCKET_REPO_SLUG}.json" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - with SBOM_FILENAME" {
  export SBOM_FILENAME="this_is_my_filename"
  unset OUTPUT_FORMAT
  unset OUTPUT_DIRECTORY

  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to build/${SBOM_FILENAME}.json" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - with a set output format" {
  export BITBUCKET_REPO_SLUG="SAMPLE_BITBUCKET_REPO"
  export NPM_OUTPUT_FORMAT="xml"

  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to build/${BITBUCKET_REPO_SLUG}.xml" ]
  [ "$status" -eq 0 ]
}

@test "Set output filename - custom dir - with a set output format" {
  export BITBUCKET_REPO_SLUG="SAMPLE_BITBUCKET_REPO"
  export NPM_OUTPUT_FORMAT="xml"
  export OUTPUT_DIRECTORY="build"

  run set_sbom_filename

  [ "${lines[2]}" = "sBOM will be written to build/${BITBUCKET_REPO_SLUG}.xml" ]
  [ "$status" -eq 0 ]
}

@test "Verify help function" {
  run help

  [ "${lines[0]}" = "Generates a CycloneDX sBOM file for the given project" ]
  [ "$status" -eq 0 ]
}

@test "Verify switches with params" {
  export CDXGEN_SPEC_VERSION="1.5"
  export CDXGEN_PROJECT_TYPE="node"
  export CDXGEN_PATH_TO_SCAN="samples/node"

  output=$(generate_switches)
  echo "${output}"

  FAILURE_DETECTED=0

  if [[ ${output} != *"--spec-version 1.5"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --spec-version was not properly set"
  fi

  if [[ ${output} != *"--type node"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: --type was not properly set"
  fi

  if [[ ${output} != *"samples/node" ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: path to scan was not properly set"
  fi

  return "${FAILURE_DETECTED}"
}

@test "Verify boolean cmd switches" {
  export CDXGEN_PRINT_AS_TABLE="true"

  output=$(generate_switches)
  echo "${output}"

  FAILURE_DETECTED=0

  if [[ ${output} != *"--print"* ]]; then
    FAILURE_DETECTED=$((FAILURE_DETECTED + 1))
    echo "error: did not find --print switch"
  fi

  return "${FAILURE_DETECTED}"
}

@test "Verify cdxgen is installed" {
  export CYCLONEDX_CDXGEN_VERSION="1.12.1"
  run verify_cdxgen

  [ "${lines[1]}" = "version 1.12.1 of cdxgen is installed" ]
}

@test "Verify cyclonedx-npm is installed - invalid version" {
  unset CYCLONEDX_CDXGEN_VERSION
  run verify_cdxgen
  [ "$status" -eq 1 ]
}

#--------------------------------------------------------------------------------
#--------------------------Setup and Teardown functions--------------------------
#--------------------------------------------------------------------------------

# Custom teardown function
teardown() {
  echo "running test cleanup"

  # remove sbom_output if it exists
  if [ -d "sbom_output" ]; then
    echo "removing sbom_output directory"
    rm -rf sbom_output
  fi

  # remove package.json if it exists
  if [ -f "package.json" ]; then
    echo "removing package.json"
    rm "package.json"
  fi

  # remove build if it exists
  if [ -d "build" ]; then
    echo "removing build directory"
    rm -rf build
  fi
}
