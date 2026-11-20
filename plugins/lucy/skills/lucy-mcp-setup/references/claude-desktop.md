# Claude Desktop / claude.ai

Lucy is listed in the claude.ai connector directory, so the user only logs in; no client ID or secret is needed. The connection lives on the user's claude.ai account and applies to every surface signed in with it: Claude Desktop, claude.ai web, mobile, and Claude Code (where it appears as `claude.ai <connector name>`).

Do not edit the local `claude_desktop_config.json` for this.

## Steps

1. Open `https://claude.ai/directory/lucy-sec-filings-search` (or Settings → Connectors → Browse connectors and search for "Lucy").
2. Press **Connect**. A Lucy login page opens (`auth.lucydata.ai`). Log in.
3. To use it in a conversation, make sure the connector is toggled on in the tools (connectors) menu of the input box.

The account must be approved for Lucy MCP access. Without approval the login page sends the user to `https://lucydata.ai/solutions/rag` instead of connecting; see the access request in `troubleshooting.md`.

## When the tool description changes

If the server changes its tool description or behavior, use **Refresh** in the connector settings (or disconnect and connect again).
