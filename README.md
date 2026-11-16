# Lucy plugins for Claude

Search U.S. SEC filings from [Claude Code](https://claude.com/claude-code) with [Lucy](https://lucydata.ai).

The **`lucy`** plugin registers the Lucy SEC filings search MCP server
(`https://lucy-rag-mcp.ezar.co.kr/mcp`) as `lucy-rag` and adds the `lucy-mcp-setup` skill,
which checks the connection, walks you through login, and verifies it.

- Covers 10-K, 10-Q, 8-K, 20-F, 40-F, 6-K, DEF 14A, S-1 and S-3 filings (and amendments) from 2016 onward, where indexed.
- No client secret. Log in once; the login lasts 30 days.
- Requires a Lucy account approved for MCP access. To request access, email **help@lucydata.ai** with your account email.

## Install

Requires Claude Code 2.1.231 or newer (`claude --version`).

```bash
claude plugin marketplace add ezardev-team/lucy-claude-plugins
claude plugin install lucy@lucydata
```

If Claude Code was already open, run `/reload-plugins` (or start a new session).

## Log in

In Claude Code, open `/mcp`, select **`plugin:lucy:lucy-rag`**, and choose **Authenticate**.
Log in with your Lucy account in the browser window that opens.

Or just say `Connect me to Lucy` (`루시 연결해줘`), or run `/lucy:lucy-mcp-setup`, and the skill will guide you.

## Use

Ask in plain language. Include the company and the period.

```
Summarize the main risk factors in NVIDIA's latest 10-K.
NVDA의 최신 risk factor 알려줘
Compare Apple's and Microsoft's AI-related risk disclosures.
```

Claude calls the `rag_context` tool and answers from the returned filing passages. It separates
original filing text from derived analysis and does not give investment advice.

## Update

```bash
claude plugin marketplace update lucydata
claude plugin update lucy@lucydata
```

## Claude Desktop and claude.ai

This plugin is for Claude Code. In Claude Desktop and claude.ai, use the
[Lucy SEC filings search](https://claude.ai/directory/lucy-sec-filings-search) connector in the
claude.ai directory instead.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `plugin:lucy:lucy-rag` is not listed in `/mcp` | Run `/reload-plugins` or start a new session |
| `redirect_mismatch` on the login page | Update Claude Code to 2.1.231 or newer |
| Login never returns from the browser | Another process is using port 8088: `lsof -nP -iTCP:8088 -sTCP:LISTEN` |
| Logged in, but tool calls return 401 | Your account is not approved yet. Email help@lucydata.ai |
| Lucy tools listed twice | Remove an older manual registration: `claude mcp remove lucy-rag -s user` |

## Uninstall

```bash
claude plugin uninstall lucy@lucydata
```
