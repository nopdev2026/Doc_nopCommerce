#!/usr/bin/env bash
# Arranca nopdev-docs-mcp (http) en Codespaces si no está corriendo.
# Uso desde fuera:  gh codespace ssh -c <codespace> -- bash /workspaces/Doc_nopCommerce/mcp/start-server.sh
#
# El token se lee de ~/.nopdev-docs.env (fuenteado si existe). GitHub NO inyecta
# los codespaces secrets en los scripts de ciclo de vida, así que ese fichero es
# la fuente de verdad del token dentro del codespace.
set -u
cd "$(dirname "$0")" || exit 1

if curl -s -m 3 http://localhost:8787/health >/dev/null 2>&1; then
  echo "ya estaba corriendo:"
  curl -s -m 3 http://localhost:8787/health
  echo
  exit 0
fi

if [ -f "$HOME/.nopdev-docs.env" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$HOME/.nopdev-docs.env"
  set +a
fi

if [ -z "${MCP_TOKEN:-}" ]; then
  echo "ERROR: falta MCP_TOKEN (no existe ~/.nopdev-docs.env o está vacio)."
  exit 1
fi

setsid nohup node http.js > "$HOME/nopdev-docs-http.log" 2>&1 &

for _ in 1 2 3 4 5 6 7 8 9 10; do
  sleep 1
  if curl -s -m 3 http://localhost:8787/health >/dev/null 2>&1; then
    echo "arrancado:"
    curl -s -m 3 http://localhost:8787/health
    echo
    exit 0
  fi
done

echo "ERROR: el servidor no responde en 10 s. Log:"
tail -20 "$HOME/nopdev-docs-http.log" 2>/dev/null
exit 1
