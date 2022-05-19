#!/bin/bash
# shellcheck disable=SC2015

umask 0077
export LANG=C
export LC_ALL=C

declare -r ipsver=25
silent=no
tmpdir="${TEMP:=/tmp}"
index_url="${REMOTE_URI:-https://oss.help/scripts/tools/ipset/.list}"
list_name=$(basename "${index_url}")
script_name="custom.refresh-ipset"
script_path="/usr/local/sbin"
shacmd=$(command -v sha256sum || command -v gsha256sum 2>/dev/null)
err=0

function show_notice() { test "${silent}" != "yes" && echo -e "[NOTICE] ${*}"; return 0; }
function show_error() { echo -e "[ERROR] ${*}" >&2; err=1; return 1; }

function fetch_files() {
  cd "${1}" && \
    {
      wget -q -P "${1}" "${index_url}" && \
      wget -q -i "${1}/${list_name}" -P "${1}"
    } && \
      ${shacmd} -c --status SHA256SUMS 2> /dev/null || {
        show_error "Something went wrong, checksums of downloaded files mismatch."
        ${shacmd} -c "${1}/SHA256SUMS"
        return 1
      }
}

function install_files() {
  test -d "${script_path}" || mkdir "${script_path}"
  cd "${script_path}" && \
    mv "${tmp_dir}/${script_name}" "${script_path}/${script_name}" && \
      chmod 700 "${script_path}/${script_name}"
}

test "$(id -u)" != "0" && { show_error "Sorry, but you must run this script as root."; exit 1; }

tmp_dir="${tmpdir}/refresh-ipset.${$}"
mkdir -p "${tmp_dir}" && \
  fetch_files "${tmp_dir}" && \
    install_files "${tmp_dir}" && \
      show_notice "Script ${script_name} (v$ipsver) was updated."
test -d "${tmp_dir}" && rm -rf "${tmp_dir}"
test "${err}" -eq 1 && { show_error "Installation failed."; }
exit "${err}"
