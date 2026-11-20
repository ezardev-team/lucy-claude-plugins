---
name: lucy-mcp-setup
description: Connect, authenticate, and verify the Lucy SEC filings search MCP server (lucy-rag-mcp, https://lucy-rag-mcp.ezar.co.kr/mcp) in Claude Code and Claude Desktop/claude.ai. Use this skill whenever the user wants to set up, register, connect, fix, or troubleshoot Lucy, lucy-rag, lucy-rag-mcp, or the rag_context tool, or hits MCP OAuth errors against it (redirect_mismatch, invalid_scope, 401, "Needs authentication"), even if they never say "MCP" or "setup". Also trigger on Korean phrasing such as "lucy-rag 연결", "루시 연결해줘", "lucy MCP 셋업", "SEC 공시 검색 도구 붙여줘", "rag_context 도구가 안 보여", "Claude에서 Lucy 쓰게 해줘", "MCP 로그인이 안 돼". Can also be consulted for Codex connections to the same server.
---

# Lucy MCP Setup

Walk the user through connecting the production `lucy-rag-mcp` server to a Claude client, doing as much as possible on their behalf.
The server is protected by OAuth 2.1, so the work is **preflight → register → user login → verify**.
The user must type their Lucy password themselves; everything else (checks, command construction, registration, verification) is yours to do. Keep the moments that need the user's hands short and precise.

**Respond in the user's language.** Keep commands, URLs, and error strings verbatim.

## Fixed values

| Item | Value |
|---|---|
| MCP server URL | `https://lucy-rag-mcp.ezar.co.kr/mcp` |
| OAuth client ID — Claude Code / Codex | `lucy-mcp-cli` (public, no secret) |
| Claude Code callback port | `8088` (`http://localhost:8088/callback`) |
| Login server | `https://auth.lucydata.ai` (Lucy sign-in; the MCP server discovers it automatically) |
| Scopes | `https://lucy-rag-mcp.ezar.co.kr/mcp/rag.read` |
| Tool | `rag_context(question, thread_id?)` |

**Every route needs a Lucy account approved for MCP access** (request it from help@lucydata.ai; the request text is in `references/troubleshooting.md`). Without approval, the login page sends the user to `https://lucydata.ai/solutions/rag` instead of completing the connection.

## Step 1. Preflight

Run `scripts/preflight.sh` first. It is read-only and checks:

- Server reachability (`/health`) and the OAuth discovery documents (PKCE S256 advertised, login at `auth.lucydata.ai`, scopes)
- Whether the `claude` CLI exists and `claude mcp add` supports the OAuth flags
- Any Lucy server already registered (`claude mcp list` entries matching `lucy-rag-mcp.ezar.co.kr`)
- Whether callback port 8088 is in use

Branch on the result.

- **A server pointing at `lucy-rag-mcp.ezar.co.kr/mcp` already shows "Connected"**: setup is done. If its name starts with `claude.ai ...`, it is a claude.ai connector synced into Claude Code, and no separate Claude Code registration is needed. Tell the user and jump to Step 5.
- **The `lucy` plugin is installed**: it already registers the server as `lucy-rag` (plugin-provided, shown in `/mcp`) with the public client and port 8088. Skip Step 3 and go to Step 4.
- **More than one entry points at `lucy-rag-mcp.ezar.co.kr/mcp`** (e.g. the plugin's `lucy-rag`, an older user-scope `lucy-rag` added with `claude mcp add`, and/or a synced `claude.ai ...` connector): they all reach the same server, so it works, but Claude sees the tool two or three times. Recommend keeping the plugin's entry and removing the manual one with `claude mcp remove lucy-rag -s user` (confirm with the user first; it also drops that entry's saved login). Keep the `claude.ai ...` connector if they use Lucy in claude.ai/Desktop — it can only be turned off there, under Settings → Connectors.
- **"Needs authentication"**: registered but not logged in. Go to Step 4.
- **Port 8088 is in use**: the login callback cannot be received. Show the owning process and ask the user whether to stop it (do not kill it yourself). Only port 8088 is allowed as a callback, so the port must be freed.
- **Server unreachable**: a network/DNS problem. Setup is pointless until it resolves, so stop here and show the user the output of `curl -I https://lucy-rag-mcp.ezar.co.kr/mcp`.

## Step 2. Choose a route

Two routes exist depending on where the user wants to use Lucy. If they have already said, do not ask.

| Route | Fits when | Automation |
|---|---|---|
| **A. claude.ai connector** | They want Lucy in Claude Desktop, claude.ai web/mobile. Claude Code on the same account picks it up automatically | GUI only; you give step-by-step guidance |
| **B. Claude Code** | They only use Claude Code, or want it separate from their claude.ai account | Already registered by this plugin; otherwise one `claude mcp add` you can run yourself. Login is the user's |

If they want both, do A first and ask whether B can be skipped (once A syncs into Claude Code, B is a duplicate).

## Step 3. Register

### Route B: Claude Code

If this plugin is installed, the server is already registered by the plugin's `.mcp.json` — nothing to add. Go to Step 4.

Without the plugin (or if the user wants it at user scope under their own name), there is no secret, so **you can run this yourself**:

```bash
claude mcp add --transport http --scope user \
  --client-id lucy-mcp-cli --callback-port 8088 \
  lucy-rag https://lucy-rag-mcp.ezar.co.kr/mcp
```

- `--scope user` stores it in user settings (`~/.claude.json`) so every project can use it. For a single project, use `--scope local`.
- Omitting `--callback-port 8088` makes Claude Code pick a random port each time, and the login server rejects it with `redirect_mismatch`. This is the most common mistake.
- Claude Code 2.1.231 or newer is required.

After registering, run `claude mcp get lucy-rag` to confirm the URL, client ID, and callback port 8088 were stored.

### Route A: Claude Desktop / claude.ai

A GUI procedure the user performs. Use the **directory connector** (`https://claude.ai/directory/lucy-sec-filings-search` → Connect): the user only logs in, with no client ID or secret. Read `references/claude-desktop.md` and guide them through it.

## Step 4. Login

- **Claude Code**: in a new (or the current) session, `/mcp` → `lucy-rag` → **Authenticate**. A Lucy login page opens in the browser on the `auth.lucydata.ai` domain.
- **claude.ai**: the Connect button is the login.

If login fails, take the exact error text and look it up in `references/troubleshooting.md`. A "redirect_uri not registered" page, `invalid_scope`, and being sent to `lucydata.ai/solutions/rag` (no access yet) cover almost every case.

## Step 5. Verify

1. Confirm the server shows `✔ Connected` in `claude mcp list`.
2. Have the user ask one of these in a fresh Claude session. Success means `rag_context` is called and `contexts[]` comes back populated.
   - "Summarize the main risk factors in Apple's 2024 10-K."
   - "Compare Apple's and Microsoft's AI-related risk disclosures in their 10-K filings."
3. If the tool is not called automatically, tell them to name the server, e.g. "Search with lucy-rag for …". Automatic matching works well when the prompt contains words like "10-K", "SEC filing", "risk factor", or a company name plus a year.

The response contains no answer text, only retrieved chunks (`contexts`) and a `thread_id`. Claude synthesizes the answer from the chunks. If the user says "I got sources instead of an answer", explain that this is the intended behavior. Follow-up questions reuse the same `thread_id`. Complex queries can take 30–120 seconds.

## Wrap-up

Finish with a single summary: which route was used and where it was registered, whether login completed, the verification result, and any remaining human tasks. If the account still needs access approval, give the user the request text from `references/troubleshooting.md` to send to help@lucydata.ai.

## Reference files

- `scripts/preflight.sh` — Step 1 check script. Read-only.
- `references/claude-desktop.md` — Claude Desktop / claude.ai directory connector procedure.
- `references/troubleshooting.md` — symptom → cause → fix table and the access request text.
- `references/other-clients.md` — Codex procedure (read only when asked).
