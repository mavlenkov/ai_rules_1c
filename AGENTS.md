# AGENTS.md

## Cursor Cloud specific instructions

This repository is a **configuration-only toolkit** (no runnable application). It contains Cursor IDE rules, agents, skills, and commands for 1C:Enterprise development. There are no runtime dependencies, no build steps, no tests, and no services to start.

### Repository contents

| Category | Count | Location |
|----------|-------|----------|
| AI Agents | 11 | `.cursor/agents/*.md` |
| Rules (MDC) | 11 | `.cursor/rules/*.mdc` |
| Skills | 2 | `.cursor/skills/*/SKILL.md` |
| Commands | 2 | `.cursor/commands/*.md` |
| MCP config | 1 | `.cursor/mcp.json` (8 MCP servers on localhost) |

### Key notes

- **No dependencies to install.** The repo has no `package.json`, `requirements.txt`, or any package manager files.
- **No build or lint commands.** All content is markdown (`.md`), MDC (`.mdc`), and JSON.
- **MCP servers are external.** The 8 MCP servers in `.cursor/mcp.json` point to `localhost` ports (8000-8011) and are expected to be tunneled/proxied from `vibecoding1c.ru`. They are not started from this repo.
- **Primary language is Russian.** Code examples, documentation, and comments are in Russian.
- **Validation:** To verify repository integrity, check that `mcp.json` is valid JSON and all `.md`/`.mdc` files are present and non-empty. See `README.md` for the full expected directory structure.
