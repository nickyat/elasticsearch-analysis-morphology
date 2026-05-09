#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-analysis-morphology:9.4.0}"
CONTAINER="${CONTAINER:-analysis-morphology-smoke}"
PORT="${PORT:-19200}"
BASE_URL="http://127.0.0.1:${PORT}"
TEXT="${TEXT:-машины}"

cleanup() {
    docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
}

log() {
    printf '%s\n' "$*"
}

fail() {
    printf 'Ошибка: %s\n' "$*" >&2
    exit 1
}

cleanup
trap cleanup EXIT

log "Запускаю Elasticsearch: образ ${IMAGE}, порт ${PORT}"
docker run -d \
    --name "${CONTAINER}" \
    -p "127.0.0.1:${PORT}:9200" \
    -e discovery.type=single-node \
    -e xpack.security.enabled=false \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    "${IMAGE}" >/dev/null

log "Жду готовности Elasticsearch..."
ready=false
for _ in $(seq 1 90); do
    if curl -fsS "${BASE_URL}" >/dev/null 2>&1; then
        ready=true
        break
    fi
    sleep 1
done

"${ready}" || fail "Elasticsearch не поднялся за 90 секунд"

plugins="$(curl -fsS "${BASE_URL}/_nodes/plugins")"
case "${plugins}" in
    *'"name":"analysis-morphology"'*) log "Плагин analysis-morphology установлен" ;;
    *)
        fail "плагин analysis-morphology не найден в _nodes/plugins"
        ;;
esac

log "Проверяю _analyze для текста: ${TEXT}"
analysis="$(curl -fsS \
    -H 'Content-Type: application/json' \
    -X POST "${BASE_URL}/_analyze" \
    -d "{\"tokenizer\":\"standard\",\"filter\":[\"lowercase\",\"russian_morphology\"],\"text\":\"${TEXT}\"}")"

case "${analysis}" in
    *'"token"'*) ;;
    *)
        printf '%s\n' "${analysis}" >&2
        fail "_analyze не вернул токены"
        ;;
esac

tokens="$(printf '%s\n' "${analysis}" | grep -o '"token":"[^"]*"' | sed 's/"token":"//;s/"$//')"

log "Токены:"
printf '  - %s\n' ${tokens}
log "Smoke test пройден"
