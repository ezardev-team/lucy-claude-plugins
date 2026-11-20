#!/usr/bin/env bash
# Read-only preflight for connecting Claude clients to lucy-rag-mcp.
# Prints OK / WARN / FAIL lines; never modifies any configuration.

set -u

MCP_URL="https://lucy-rag-mcp.ezar.co.kr/mcp"
BASE_URL="https://lucy-rag-mcp.ezar.co.kr"
CALLBACK_PORT=8088
REQUIRED_SCOPE="https://lucy-rag-mcp.ezar.co.kr/mcp/rag.read"

ok()   { printf 'OK   %s\n' "$*"; }
warn() { printf 'WARN %s\n' "$*"; }
fail() { printf 'FAIL %s\n' "$*"; }

echo "== Server =="
health="$(curl -sS -m 10 "$BASE_URL/health" 2>&1)"
if [[ "$health" == *'"status":"ok"'* ]]; then
  ok "/health reachable: $health"
else
  fail "/health unreachable or unexpected: $health"
  echo "     -> Network/DNS problem. Setup cannot proceed until this resolves."
fi

mcp_code="$(curl -sS -m 10 -o /dev/null -w '%{http_code}' "$MCP_URL" 2>/dev/null || echo "000")"
case "$mcp_code" in
  401) ok "/mcp answers 401 without a token (expected: OAuth-protected)";;
  000) fail "/mcp did not respond (curl exit). Check network.";;
  *)   warn "/mcp answered HTTP $mcp_code (expected 401). Contact help@lucydata.ai if this persists.";;
esac

prm="$(curl -sS -m 10 "$BASE_URL/.well-known/oauth-protected-resource" 2>/dev/null)"
if [[ "$prm" == *"$REQUIRED_SCOPE"* ]]; then
  ok "protected-resource metadata advertises rag.read"
else
  warn "protected-resource metadata missing expected scopes: $prm"
fi

asm="$(curl -sS -m 10 "$BASE_URL/.well-known/oauth-authorization-server" 2>/dev/null)"
if [[ "$asm" == *'"S256"'* ]]; then
  ok "authorization-server metadata advertises PKCE S256"
else
  warn "authorization-server metadata lacks code_challenge_methods_supported S256 (clients will refuse OAuth): ${asm:0:200}"
fi
if [[ "$asm" == *'"https://auth.lucydata.ai/oauth2/authorize"'* ]]; then
  ok "login goes through auth.lucydata.ai"
else
  warn "authorization endpoint is not auth.lucydata.ai: ${asm:0:200}"
fi

echo
echo "== Claude Code CLI =="
if command -v claude >/dev/null 2>&1; then
  ok "claude CLI found: $(claude --version 2>/dev/null | head -1)"
  help="$(claude mcp add --help 2>&1)"
  for flag in --client-id --callback-port; do
    if [[ "$help" == *"$flag"* ]]; then ok "claude mcp add supports $flag"; else fail "claude mcp add lacks $flag — update Claude Code"; fi
  done
else
  warn "claude CLI not on PATH — Claude Code route (B) unavailable in this shell"
fi

echo
echo "== Existing registrations =="
if command -v claude >/dev/null 2>&1; then
  list="$(claude mcp list 2>/dev/null)"
  matches="$(printf '%s\n' "$list" | grep -i 'lucy-rag-mcp.ezar.co.kr' || true)"
  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" | while IFS= read -r line; do
      if [[ "$line" == *"Connected"* ]]; then
        ok "already registered and connected: $line"
      elif [[ "$line" == *"Needs authentication"* ]]; then
        warn "registered but not logged in: $line"
      else
        warn "registered, status unclear: $line"
      fi
    done
    if printf '%s\n' "$matches" | grep -q '^claude.ai'; then
      echo "     -> A 'claude.ai ...' entry is a claude.ai connector synced into Claude Code; no separate 'claude mcp add' is needed for Claude Code."
    fi
  else
    ok "no existing Lucy server registered in Claude Code"
  fi
  if claude mcp get lucy-rag >/dev/null 2>&1; then
    echo "--- claude mcp get lucy-rag ---"
    claude mcp get lucy-rag 2>/dev/null
  fi
fi

echo
echo "== Callback port $CALLBACK_PORT =="
if command -v lsof >/dev/null 2>&1; then
  holders="$(lsof -nP -iTCP:"$CALLBACK_PORT" -sTCP:LISTEN 2>/dev/null | tail -n +2)"
  if [[ -z "$holders" ]]; then
    ok "port $CALLBACK_PORT is free"
  else
    warn "port $CALLBACK_PORT is in use — OAuth callback will fail until it is freed:"
    printf '%s\n' "$holders"
  fi
else
  warn "lsof not available; cannot check port $CALLBACK_PORT"
fi
