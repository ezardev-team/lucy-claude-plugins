# Other clients: Codex

Codex can use the same server and client ID. The account must be approved for Lucy MCP access.

## Codex (CLI / Desktop)

- **Codex 0.158 or newer** is required (`codex --version`; `codex update` if older). CLI and Desktop share `~/.codex/config.toml`.

1. Pin the callback port. Add at the top of `~/.codex/config.toml` (before the first `[...]` table):
   ```toml
   mcp_oauth_callback_port = 8088
   mcp_oauth_callback_url = "http://localhost:8088/callback"
   ```
2. Register:
   ```bash
   codex mcp add lucy-rag --url https://lucy-rag-mcp.ezar.co.kr/mcp \
     --oauth-client-id lucy-mcp-cli \
     --oauth-resource https://lucy-rag-mcp.ezar.co.kr/mcp
   ```
   If a login wait starts right after registering, press `Ctrl+C` and continue to step 3.
3. Log in:
   ```bash
   codex mcp login lucy-rag --scopes "https://lucy-rag-mcp.ezar.co.kr/mcp/rag.read"
   ```
   On success the Auth column of `codex mcp list` reads `OAuth`.
4. On a "redirect_uri not registered" page, send the `redirect_uri` from the login URL to Lucy support (help@lucydata.ai).
