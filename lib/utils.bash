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

# Borrowed to someone, but I don't remember who it was, sorry :(
# Print message $2 with log-level $1 to STDERR, colorized if terminal
# log DEBUG "DOCKER_HOST ${DOCKER_HOST}"
function log() {
  local level=${1?}
  shift
  local code
  local line
  code=''
  line="[$(date '+%F %T')] $level: $*"
  if [ -t 2 ]; then
    case "$level" in
    INFO) code=36 ;;
    DEBUG) code=35 ;;
    WARN) code=33 ;;
    ERROR) code=31 ;;
    *) code=37 ;;
    esac
    echo -e "\e[${code}m${line} \e[94m(${FUNCNAME[1]})\e[0m"
  else
    echo "$line"
  fi >&2
}

download_release() {
  local version filename url platform
  version="$1"
  filename="$2"

  platform=$(get_platform)
  url=$(k9s_get_download_url "$version" "$platform")

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
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

    local tool_cmd
    tool_cmd="$(get_tool_cmd)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
    echo "* Install locally or globally with:"
    echo "asdf local $TOOL_NAME $version"
    echo "asdf global $TOOL_NAME $version"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}

# from https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
function vercomp() {
  if [[ "$1" == "$2" ]]; then
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
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}

get_version_short() {
  local version=$1
  echo "$version" | tr -d "v"
}

get_platform() {
  echo "$(uname)_$(get_cpu)"
}

get_cpu() {
  local machine_hardware_name
  machine_hardware_name="$(uname -m)"

  case "$machine_hardware_name" in
  'x86_64')
    vercomp "$version" "0.26.7"
    if [[ $? == 1 ]]; then local cpu_type="amd64"; else local cpu_type="x86_64"; fi
    ;;
  'powerpc64le' | 'ppc64le') local cpu_type="ppc64le" ;;
  'aarch64') local cpu_type="arm64" ;;
  'armv5l' | 'armv6l' | 'armv7l') local cpu_type="arm" ;;
  *) local cpu_type="$machine_hardware_name" ;;
  esac

  echo "$cpu_type"
}

get_filename_post_0_14_0() {
  local version="$1"
  local platform="$2"

  echo "${TOOL_NAME}_${platform}.tar.gz"
}

get_filename_pre_0_14_0() {
  local version="$1"
  local platform="$2"

  echo "${TOOL_NAME}_${version}_${platform}.tar.gz"
}

get_filename_0_24_10() {
  local version="$1"
  local platform="$2"

  echo "${TOOL_NAME}_v${version}_${platform}.tar.gz"
}

k9s_get_download_url() {
  local version="$1"
  local platform="$2"
  local filename
  local path_version

  # https://github.com/derailed/k9s/releases/download/v0.16.1/k9s_Linux_x86_64.tar.gz
  # https://github.com/derailed/k9s/releases/download/0.11.1/k9s_0.11.1_Linux_x86_64.tar.gz
  vercomp "$version" "0.14.0"
  case $? in
  0) op='=' ;;
  1) op='>' ;;
  2) op='<' ;;
  esac
  if [[ "$op" == '<' ]]; then
    filename="$(get_filename_pre_0_14_0 "$version" "$platform")"
  else
    filename="$(get_filename_post_0_14_0 "$version" "$platform")"
  fi

  vercomp "$version" "0.13.0"
  case $? in
  0) op='=' ;;
  1) op='>' ;;
  2) op='<' ;;
  esac
  if [[ "$op" == '<' ]]; then
    path_version="$version"
  else
    path_version="v$version"
  fi

  vercomp "$version" "0.24.10"
  case $? in
  0) op='=' ;;
  1) op='>' ;;
  2) op='<' ;;
  esac
  if [[ "$op" == '=' ]]; then
    filename="$(get_filename_0_24_10 "$version" "$platform")"
    path_version="v$version"
  else
    : # do not alter behavior
  fi

  vercomp "$version" "0.25.0"
  case $? in
  0) op='=' ;;
  1) op='>' ;;
  2) op='<' ;;
  esac
  if [[ "$op" == '<' ]] && [[ "$platform" == "Darwin_arm64" ]]; then
    fail "Version $version is not supported on platform $platform"
  else
    : # do not alter behavior
  fi

  echo "https://github.com/derailed/k9s/releases/download/${path_version}/${filename}"
}
