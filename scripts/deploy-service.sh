#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="${ROOT_DIR}/terraform"

SSH_USER="${SSH_USER:-ubuntu}"
SSH_KEY="${SSH_KEY:-${HOME}/.ssh/id_ed25519}"

usage() {
  echo "Usage: $0 {app|postgres|redis|all}"
  exit 1
}

require_env_var() {
  local file="$1"
  local variable="$2"

  if ! grep -Eq "^${variable}=.+$" "${file}"; then
    echo "Missing ${variable} in ${file}"
    exit 1
  fi
}

terraform_output() {
  terraform -chdir="${TERRAFORM_DIR}" output -raw "$1"
}

validate_service_env() {
  local service="$1"
  local env_file="${ROOT_DIR}/services/${service}/.env"

  if [[ ! -f "${env_file}" ]]; then
    echo "Missing ${env_file}"
    echo "Create it from .env.example before deploying."
    exit 1
  fi

  case "${service}" in
    app)
      require_env_var "${env_file}" "DB_HOST"
      require_env_var "${env_file}" "DB_PASSWORD"
      require_env_var "${env_file}" "REDIS_HOST"
      require_env_var "${env_file}" "REDIS_PASSWORD"
      ;;
    postgres)
      require_env_var "${env_file}" "POSTGRES_PASSWORD"
      ;;
    redis)
      require_env_var "${env_file}" "REDIS_PASSWORD"
      ;;
  esac
}

deploy_target() {
  local service="$1"
  local target_ip="$2"
  local remote_dir="/opt/${service}"
  local local_dir="${ROOT_DIR}/services/${service}"

  validate_service_env "${service}"

  local jump_ip
  jump_ip="$(terraform_output jump_host_public_ip)"

  local ssh_options=(
    -i "${SSH_KEY}"
    -o "IdentitiesOnly=yes"
    -o "StrictHostKeyChecking=accept-new"
    -o "ProxyJump=${SSH_USER}@${jump_ip}"
  )

  echo "Deploying ${service} to ${target_ip}..."

  # shellcheck disable=SC2029
  ssh "${ssh_options[@]}" "${SSH_USER}@${target_ip}" \
    "sudo mkdir -p '${remote_dir}' && sudo chown '${SSH_USER}:${SSH_USER}' '${remote_dir}'"

  # shellcheck disable=SC2029
  tar \
    --exclude=".env.example" \
    -C "${local_dir}" \
    -czf - . |
    ssh "${ssh_options[@]}" "${SSH_USER}@${target_ip}" \
      "tar -xzf - -C '${remote_dir}'"

  # shellcheck disable=SC2029
  ssh "${ssh_options[@]}" "${SSH_USER}@${target_ip}" \
    "cd '${remote_dir}' && sudo docker compose config --quiet && sudo docker compose up -d --build"

  echo "${service} deployed successfully."
}

deploy_postgres() {
  deploy_target "postgres" "$(terraform_output postgres_private_ip)"
}

deploy_redis() {
  deploy_target "redis" "$(terraform_output redis_private_ip)"
}

deploy_app() {
  deploy_target "app" "$(terraform_output application_instance_a_private_ip)"
  deploy_target "app" "$(terraform_output application_instance_b_private_ip)"
}

SERVICE="${1:-}"

case "${SERVICE}" in
  postgres)
    deploy_postgres
    ;;
  redis)
    deploy_redis
    ;;
  app)
    deploy_app
    ;;
  all)
    deploy_postgres
    deploy_redis
    deploy_app
    ;;
  *)
    usage
    ;;
esac
