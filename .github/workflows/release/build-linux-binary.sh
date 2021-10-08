#!/bin/bash

function build() {
  cd "${GITHUB_WORKSPACE}" || exit
  cargo build --release

  mkdir "${GITHUB_WORKSPACE}/bin"

  cp "${GITHUB_WORKSPACE}/target/release/safepkt-backend" \
    "${GITHUB_WORKSPACE}"'/'"${RELEASE_NAME}"
}
build