#!/usr/bin/env bash
set -euo pipefail

GH_REPO="https://github.com/derailed/k9s"
TOOL_NAME="k9s"

fail() {
  printf "asdf-%s: %s\n" $TOOL_NAME "$*"
  exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  list_github_tags
}

download_release() {
  local version filename url platform
  version="$1"
  filename="$2"

  platform=$(get_platform "${version}")
  url=$(k9s_get_download_url "$version" "$platform")

  printf "* Downloading %s release %s...\n" "${TOOL_NAME}" "${version}"
  curl "${curl_opts[@]}" --output "${filename}" -C - "${url}" || fail "Could not download ${url}"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

    [ -x "${install_path}/$TOOL_NAME" ] || fail "Expected $install_path/${TOOL_NAME} to be executable."

    printf "* %s %s installation was successful!\n" "${TOOL_NAME}" "${version}"
    printf "* Make it local or global with:\n"
    printf "asdf local %s %s\n" "${TOOL_NAME}" "${version}"
    printf "asdf global %s %s\n" "${TOOL_NAME}" "${version}"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}

# from https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
function vercomp() {
  if [[ "$1" == "$2" ]]; then
    printf "=\n"
    return 0
  fi
  local IFS=.
  # shellcheck disable=SC2206
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i = 0; i < ${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      printf ">\n"
      return 0 # >
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      printf "<\n"
      return 0 # <
    fi
  done
  printf "=\n"
  return 0 # =
}

get_platform() {
  local _version="$1?"
  printf "%s_%s\n" "$(uname)" "$(get_cpu "$_version")"
}

get_cpu() {
  local _version="$1?"
  local machine_hardware_name
  machine_hardware_name="$(uname -m)"

  case "$machine_hardware_name" in
  'x86_64')
    op=$(vercomp "$_version" "0.26.7")
    if [[ "${op}" == ">" ]]; then local cpu_type="amd64"; else local cpu_type="x86_64"; fi
    ;;
  'powerpc64le' | 'ppc64le') local cpu_type="ppc64le" ;;
  'aarch64') local cpu_type="arm64" ;;
  'armv5l' | 'armv6l' | 'armv7l') local cpu_type="arm" ;;
  *) local cpu_type="$machine_hardware_name" ;;
  esac

  printf "%s\n" "${cpu_type}"
}

get_filename_post_0_14_0() {
  local version="$1"
  local platform="$2"

  printf "%s_%s.tar.gz\n" "${TOOL_NAME}" "${platform}"
}

get_filename_pre_0_14_0() {
  local version="$1"
  local platform="$2"

  printf "%s_%s_%s.tar.gz\n" "${TOOL_NAME}" "${version}" "${platform}"
}

get_filename_0_24_10() {
  local version="$1"
  local platform="$2"

  printf "%s_v%s_%s.tar.gz\n" "${TOOL_NAME}" "${version}" "${platform}"
}

k9s_get_download_url() {
  local version="$1"
  local platform="$2"
  local filename
  local path_version

  # https://github.com/derailed/k9s/releases/download/v0.16.1/k9s_Linux_x86_64.tar.gz
  # https://github.com/derailed/k9s/releases/download/0.11.1/k9s_0.11.1_Linux_x86_64.tar.gz
  op=$(vercomp "$version" "0.14.0")
  if [[ "$op" == '<' ]]; then
    filename="$(get_filename_pre_0_14_0 "$version" "$platform")"
  else
    filename="$(get_filename_post_0_14_0 "$version" "$platform")"
  fi

  op=$(vercomp "$version" "0.13.0")
  if [[ "$op" == '<' ]]; then
    path_version="$version"
  else
    path_version="v$version"
  fi

  op=$(vercomp "$version" "0.24.10")
  if [[ "$op" == '=' ]]; then
    filename="$(get_filename_0_24_10 "$version" "$platform")"
    path_version="v$version"
  else
    : # do not alter behavior
  fi

  op=$(vercomp "$version" "0.25.0")
  if [[ "$op" == '<' ]] && [[ "$platform" == "Darwin_arm64" ]]; then
    fail "Version $version is not supported on platform $platform"
  else
    : # do not alter behavior
  fi

  printf "https://github.com/derailed/k9s/releases/download/%s/%s\n" "${path_version}" "${filename}"
}
