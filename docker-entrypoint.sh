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
  "default_temperature": ${NULLCLAW_TEMPERATURE:-0.7},
  "memory": {
    "backend": "${NULLCLAW_MEMORY_BACKEND:-sqlite}",
    "auto_save": ${NULLCLAW_MEMORY_AUTO_SAVE:-true},
    "embedding_provider": "${NULLCLAW_EMBEDDING_PROVIDER:-openai}",
    "vector_weight": ${NULLCLAW_VECTOR_WEIGHT:-0.7},
    "keyword_weight": ${NULLCLAW_KEYWORD_WEIGHT:-0.3}
  },
  "gateway": {
    "port": ${PORT:-3000},
    "require_pairing": false,
    "allow_public_bind": true
  },
  "autonomy": {
    "level": "${NULLCLAW_AUTONOMY_LEVEL:-supervised}",
    "workspace_only": ${NULLCLAW_WORKSPACE_ONLY:-true},
    "max_actions_per_hour": ${NULLCLAW_MAX_ACTIONS_PER_HOUR:-20},
    "max_cost_per_day_cents": ${NULLCLAW_MAX_COST_PER_DAY_CENTS:-500}
  },
  "security": {
    "sandbox": {
      "backend": "${NULLCLAW_SANDBOX_BACKEND:-auto}"
    },
    "resources": {
      "max_memory_mb": ${NULLCLAW_MAX_MEMORY_MB:-512},
      "max_cpu_percent": ${NULLCLAW_MAX_CPU_PERCENT:-80}
    },
    "audit": {
      "enabled": ${NULLCLAW_AUDIT_ENABLED:-true},
      "retention_days": ${NULLCLAW_AUDIT_RETENTION_DAYS:-90}
    }
  },
  "tunnel": {
    "provider": "${NULLCLAW_TUNNEL_PROVIDER:-none}"
  },
  "identity": {
    "format": "${NULLCLAW_IDENTITY_FORMAT:-openclaw}"
  },
  "secrets": {
    "encrypt": ${NULLCLAW_SECRETS_ENCRYPT:-true}
  },
  "heartbeat": {
    "enabled": ${NULLCLAW_HEARTBEAT_ENABLED:-false},
    "interval_minutes": ${NULLCLAW_HEARTBEAT_INTERVAL:-30}
  }
}
EOF
fi

exec nullclaw gateway \
  --host 0.0.0.0 \
  --port "${PORT:-3000}"