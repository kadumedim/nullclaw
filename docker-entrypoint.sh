#!/bin/sh
set -e

CONFIG_DIR="${HOME}/.nullclaw"
CONFIG_FILE="${CONFIG_DIR}/config.json"

mkdir -p "${CONFIG_DIR}"

if [ ! -f "${CONFIG_FILE}" ]; then
  cat > "${CONFIG_FILE}" <<EOF
{
  "api_key": "${NULLCLAW_API_KEY}",
  "default_provider": "${NULLCLAW_PROVIDER:-openrouter}",
  "default_model": "${NULLCLAW_MODEL:-anthropic/claude-sonnet-4}",
  "default_temperature": 0.7,
  "memory": {
    "backend": "sqlite",
    "auto_save": true
  },
  "gateway": {
    "port": ${PORT:-3000},
    "require_pairing": false,
    "allow_public_bind": true
  },
  "autonomy": {
    "level": "supervised"
  },
  "identity": {
    "format": "openclaw"
  }
}
EOF
fi

exec nullclaw gateway \
  --port "${PORT:-3000}" \
  --host 0.0.0.0