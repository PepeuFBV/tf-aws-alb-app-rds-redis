#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/aws-login.sh             Prompt for credentials
  scripts/aws-login.sh --paste     Read a pasted AWS credentials block from stdin
  scripts/aws-login.sh < block.ini Read a credentials block from stdin
USAGE
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

paste_mode=false
if [[ "${1:-}" == "--paste" ]]; then
  paste_mode=true
  shift
fi

if (( $# > 0 )); then
  usage >&2
  exit 2
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: AWS CLI ('aws') is not installed or not on PATH." >&2
  exit 127
fi

access_key_id=""
secret_access_key=""
session_token=""

if [[ ! -t 0 ]]; then
  paste_mode=true
fi

if [[ "$paste_mode" == true ]]; then
  if [[ -t 0 ]]; then
    echo "Paste the complete [default] AWS credentials block, then press Ctrl-D:"
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    case "$line" in
      ''|'#'*|';'*|'['*']') continue ;;
      *=*)
        key="${line%%=*}"
        value="${line#*=}"
        key="$(printf '%s' "$key" | sed 's/[[:space:]]*$//')"
        value="$(printf '%s' "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        case "$key" in
          aws_access_key_id) access_key_id="$value" ;;
          aws_secret_access_key) secret_access_key="$value" ;;
          aws_session_token) session_token="$value" ;;
        esac
        ;;
    esac
  done
else
  if [[ ! -t 0 ]]; then
    echo "Error: interactive credential prompts require a terminal." >&2
    exit 2
  fi

  read -r -p "AWS_ACCESS_KEY_ID: " access_key_id
  read -r -s -p "AWS_SECRET_ACCESS_KEY: " secret_access_key
  printf '\n'
  read -r -s -p "AWS_SESSION_TOKEN: " session_token
  printf '\n'
fi

if [[ -z "$access_key_id" || -z "$secret_access_key" || -z "$session_token" ]]; then
  echo "Error: credentials block must include aws_access_key_id, aws_secret_access_key, and aws_session_token." >&2
  exit 2
fi

aws_dir="${HOME}/.aws"
credentials_file="${AWS_SHARED_CREDENTIALS_FILE:-${aws_dir}/credentials}"
config_file="${AWS_CONFIG_FILE:-${aws_dir}/config}"
mkdir -p "$(dirname "$credentials_file")" "$(dirname "$config_file")"

umask 077
credentials_tmp="${credentials_file}.tmp.$$"
config_tmp="${config_file}.tmp.$$"
trap 'rm -f "$credentials_tmp" "$config_tmp"' EXIT

cat > "$credentials_tmp" <<EOF
[default]
aws_access_key_id = ${access_key_id}
aws_secret_access_key = ${secret_access_key}
aws_session_token = ${session_token}
EOF
cat > "$config_tmp" <<'EOF'
[default]
region = us-east-1
EOF
chmod 600 "$credentials_tmp" "$config_tmp"
mv "$credentials_tmp" "$credentials_file"
mv "$config_tmp" "$config_file"
trap - EXIT

export AWS_PROFILE=default
export AWS_DEFAULT_REGION=us-east-1
export AWS_REGION=us-east-1

echo "Credentials saved to the local AWS config location; validating with AWS STS..."
if aws sts get-caller-identity; then
  echo "AWS credentials validated successfully (region: us-east-1)."
else
  echo "AWS credential validation failed. Check that the Learner Lab session is active and the credentials are current." >&2
  exit 1
fi
