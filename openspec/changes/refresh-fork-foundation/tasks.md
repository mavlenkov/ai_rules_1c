## 1. Git Baseline

- [x] 1.1 Create and verify backup branch/tag references for the pre-refresh fork tip
- [ ] 1.2 Create an ancestry-only merge with current `origin/main` and verify that the tree id is unchanged
- [ ] 1.3 Verify that `origin/main` is now an ancestor and normal merge-base/divergence checks work

## 2. Maintainer Documentation

- [ ] 2.1 Restructure `FORK-TODO.md` so active debt and current upstream state precede historical records
- [ ] 2.2 Align README, `CLAUDE.md`, and `AGENT-INSTALL.md` with actual Bash/PowerShell tool coverage and current artifact counts
- [ ] 2.3 Correct stale OpenCode, model-tier, validator, CI, and latest-upstream statements
- [ ] 2.4 Repair the OpenSpec configuration and existing structural whitespace defects

## 3. Execution Discipline

- [ ] 3.1 Audit existing rules against the agreed session, context, polling, retry, tool-error, explore/apply, and user-load failure modes
- [ ] 3.2 Add only missing focused requirements without enlarging `AGENTS.md` unnecessarily
- [ ] 3.3 Update model-routing requirements so routine tasks use one tier/model and multi-model review remains exceptional

## 4. Verification

- [ ] 4.1 Run `openspec validate --change refresh-fork-foundation` and repository rule validation
- [ ] 4.2 Run PowerShell installer smoke tests in disposable fixtures
- [ ] 4.3 Run Bash installer smoke tests for all supported tools with an isolated HOME
- [ ] 4.4 Verify artifact counts, manifests, path rewrites, MCP output formats, and OpenCode frontmatter gates
- [ ] 4.5 Run final `git diff --check`, inspect scope, and confirm no real target project or external workspace changed
