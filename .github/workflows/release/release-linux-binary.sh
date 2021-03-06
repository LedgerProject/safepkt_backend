#!/bin/bash

function publish() {
  local binary
  binary="${1}"

  echo "=> About to publish ""${binary}"

  if [ ! -e "${binary}" ];
  then
      echo 'Invalid binary ('"${binary}"')'
      return 1
  fi

  local checksum
  checksum="$(sha256sum "${binary}" | cut -d ' ' -f 1)"

  local base_url
  base_url='https://api.github.com/repos/'"${GITHUB_REPOSITORY}"

  local upload_url
  upload_url="$(curl \
    -H 'Content-Type: application/octet-stream' \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    "${base_url}"/releases 2>> /dev/null | \
    jq -r '.[] | .upload_url' | \
    head -n1)"

  upload_url=${upload_url/\{?name,label\}/}

  local release_name
  release_name="$(curl \
    -H 'Content-Type: application/octet-stream' \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    "${base_url}"/releases 2>> /dev/null | \
    jq -r '.[] | .tag_name' | \
    head -n1)"

  if [ "$( echo -n "${binary}" | grep -c 'cli' )"  != "0" ];
  then
      release_name="$(echo -n "${release_name}" | sed -E 's/-backend/-cli/g')"
  fi

  echo '=> Release name is '"${release_name}"

  curl \
    -X POST \
    --data-binary @"${binary}" \
    -H 'Content-Type: application/octet-stream' \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    "${upload_url}?name=${release_name}-linux"

  curl \
    -X POST \
    --data "$checksum" \
    -H 'Content-Type: text/plain' \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    "${upload_url}?name=${release_name}-linux.sha256sum"
}

publish "${GITHUB_WORKSPACE}"'/'"${RELEASE_NAME}"
publish "${GITHUB_WORKSPACE}"'/'"${CLI_RELEASE_NAME}"