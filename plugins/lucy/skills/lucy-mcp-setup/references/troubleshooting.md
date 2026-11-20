# Troubleshooting

Users cannot see server logs. For anything below that says "contact Lucy support", have the user email **help@lucydata.ai** with the time of the attempt, their account email, and the exact error text.

## Login and connection stage

| Symptom | Cause | Fix |
|---|---|---|
| Login page shows "redirect_uri not registered" (or `redirect_mismatch`) | The callback URL the client sent is not one the login server allows | **Claude Code**: update to 2.1.231 or newer. If Lucy was added by hand, `--callback-port 8088` was almost certainly omitted: `claude mcp remove lucy-rag -s user`, then re-add with the flag (or just use the plugin). **Codex**: the global callback setting is missing (see `other-clients.md`) |
| No login page, `invalid_scope` | A disallowed scope (e.g. `profile`) was requested | Claude requests only what the server advertises, so this rarely happens. Remove any extra scopes |
| After login the browser lands on `lucydata.ai/solutions/rag` and the connection never completes | The account has not been approved for Lucy MCP access | Contact Lucy support to request access, then log in again (`/mcp` → `lucy-rag` → Authenticate) |
| Login succeeds but every tool call returns 401 | Access was removed after login, or an old registration with a retired client ID | Log in again. If it persists, remove the manual entry (`claude mcp remove lucy-rag -s user`) and use the plugin, or contact Lucy support |
| Opening `/mcp` in a browser shows `OAuth access token required` | Normal. `/mcp` is the endpoint called with a token | No action |
| Claude Code `/mcp` → Authenticate never returns from the browser | Another process holds port 8088 | Check with `lsof -nP -iTCP:8088 -sTCP:LISTEN`, free the port, retry |
| `needs authentication` again after weeks of use | The 30-day login expired | `/mcp` → `lucy-rag` → Authenticate |
| HTTP `503 auth_unavailable` | Temporary outage of the auth backend | Retry shortly. If it persists, contact Lucy support |

## Tool call stage

| Symptom | Check |
|---|---|
| MCP server not shown in the client | The session started before the plugin was installed. Run `/reload-plugins` or start a new session. Claude Desktop: fully quit (menu bar icon → Quit) and reopen |
| Call returns `BACKEND_UNREACHABLE` / `[CONNECTION_CLOSED] code=1006` | Problem behind the MCP server. Nothing for the user to fix. Retry, then contact Lucy support |
| Call returns `TIMEOUT` | The message names the stage: opening (10 s) or receive (120 s). Complex queries can run long in the receive stage |
| Call returns `BACKEND_PROTOCOL_ERROR` | Contact Lucy support |
| No response for 30+ seconds | Multi-hop queries take 30–120 s. Normal |
| Got a list of sources instead of an answer | Normal. The server returns retrieved chunks (`contexts`) only; Claude synthesizes the answer |
| Tool is not called automatically | Name the server, e.g. "Search with lucy-rag for …". Prompts containing "10-K", "SEC filing", or company + year match well |

## Access request the user can send

> Hello, I'd like access to the Lucy SEC filings search MCP server (lucy-rag-mcp). Account email: `<email>`. Client: Claude Code.

Korean version:

> 안녕하세요. Lucy SEC 공시 검색 MCP 서버(lucy-rag-mcp) 사용 권한을 요청드립니다. 계정 이메일: `<email>`. 사용 클라이언트: Claude Code.
