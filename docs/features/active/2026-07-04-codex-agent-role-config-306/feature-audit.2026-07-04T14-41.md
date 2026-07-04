# Feature Audit: codex-agent-role-config (Issue #306)

**Audit Date:** 2026-07-04
**Feature Folder:** `docs/features/active/2026-07-04-codex-agent-role-config-306`
**Base Branch:** `main` / `origin/main`
**Head Branch:** `bug/codex-agent-role-config-306` at `0a8e29edbebfa6fc6ebfbbd7a92abb9c39218d18`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

## Scope and Baseline

- **Base branch:** `main` resolved to `origin/main` at `f530d0e3ae7c5d0974b72cf0956e862dd94041c5`
- **Head branch/commit:** `bug/codex-agent-role-config-306` at `0a8e29edbebfa6fc6ebfbbd7a92abb9c39218d18`
- **Merge base:** `f530d0e3ae7c5d0974b72cf0956e862dd94041c5`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-07-04-codex-agent-role-config-306/evidence/**`
  - Additional evidence: current `git diff --check`, check-only Prettier, Black, evidence-location validation, and MCP plan validation
- **Feature folder used:** `docs/features/active/2026-07-04-codex-agent-role-config-306`
- **Requirements source:** `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md`
- **Work mode resolution note:** `issue.md` contains `- Work Mode: full-bug`, so `spec.md` is the authoritative acceptance-criteria source.
- **Scope note:** PR context artifacts were current for the reviewed head and were not refreshed.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md` - primary and only AC source for `full-bug`.

### Acceptance criteria

1. `.codex/agents/orchestrator.toml` and the bundled orchestrator role TOML use a valid Codex role schema with `[skills] config = [{ name = "...", enabled = true }, ...]` entries for every required orchestrator skill.
2. The orchestrator role TOML no longer contains any role-local `[mcp_servers.drm-copilot]` block or full MCP transport settings.
3. The full `drm-copilot` MCP transport remains only in `.codex/config.toml` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`.
4. `drm-copilot: New Codex Worktree Session` resolves a Codex executable from the installed VS Code extension package path when `codexExecutablePath` is blank and PATH/PATHEXT lacks `codex`.
5. Existing configured executable path and PATH/PATHEXT resolution behavior remains covered and unchanged.
6. Regression tests cover role TOML shape, MCP transport location, pushed-down payload parity, installed-extension Codex executable fallback, and missing-executable failure behavior.
7. `codex doctor --json` validation passes on an affected or fresh worktree without the documented role-definition warnings.
8. No unintended behavior changes occur outside the defined Codex role config and executable-resolution scope.
9. Full toolchain pass completed for changed TypeScript and Python contract-test surfaces.
10. Docs/config references updated to match the new resolver behavior and role schema.

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Valid Codex role schema in root and bundled role TOML | PASS | `role-config-location-verification.md`; Python contract tests | `poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py --cov=scripts/dev_tools --cov-report=term-missing` | Root and bundled role TOML use `[skills].config` sequence. |
| 2 | No role-local MCP transport in orchestrator role TOML | PASS | `role-config-location-verification.md`; Python contract tests | Same Pytest command | `mcp_servers` absent from root and bundled role TOML. |
| 3 | Full MCP transport remains only in config TOML | PASS | `role-config-location-verification.md`; Python contract tests | Same Pytest command | Config files retain `npx`, args, required flag, enabled tools, and validator approval setting. |
| 4 | Installed VS Code extension Codex executable fallback | PASS | `typescript-resolver-command.pass-after.md`; `typescript-jest-coverage.final.md` | `npm run test:unit -- --coverage` | Resolver and command handler tests cover installed-extension fallback. |
| 5 | Configured executable path and PATH/PATHEXT behavior unchanged | PASS | Existing and updated Jest tests in `extension.test.ts` and `codex-worktree-session-command.test.ts` | `npm run test:unit -- --coverage` | Recorded coverage artifact reports PASS. |
| 6 | Regression tests cover required behavior | PASS | Python and TypeScript coverage artifacts; fail-before/pass-after evidence | Pytest/Jest commands recorded in evidence | Required regression surfaces are represented. |
| 7 | `codex doctor --json` passes without documented warnings | PASS | `codex-doctor.pass-after.md` | `codex doctor --json` with installed extension executable | Evidence records exit 0 and no documented warning classes. |
| 8 | No unintended behavior changes outside role config and executable-resolution scope | FAIL | Reusable skill files contain issue #306-specific plan-path invariants; `spec.md:50` marks orchestration delegation/checkpoint rule changes out of scope. | `Select-String` over root and bundled orchestration skills | Hardcoded issue #306 path appears in six reusable skill files. |
| 9 | Full toolchain pass completed for changed TypeScript and Python surfaces | FAIL | Recorded artifacts show pass, but current review verification fails. | `git diff --check f530d0e3ae7c5d0974b72cf0956e862dd94041c5..HEAD`; `npx prettier --check ...`; `poetry run black --check .` | Current `git diff --check` exits 1 and check-only Prettier exits 1; Black exits 0. |
| 10 | Docs/config references updated | PASS | `package.json` description, role/config evidence, `spec.md` | Diff inspection and evidence review | Documentation matches resolver fallback and role schema, subject to whitespace remediation. |

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 2 criteria

**Top gaps preventing PASS:**

1. Issue #306-specific plan-path text was added to reusable orchestration skills, which is outside the accepted feature scope.
2. Current branch verification fails `git diff --check`.
3. Current check-only TypeScript formatting fails.

**Recommended follow-up verification steps:**

1. Remove issue-specific plan-path text from reusable skills while preserving a generic plan-path resolution rule.
2. Clean whitespace and rerun `git diff --check`.
3. Rerun check-only TypeScript formatting and refresh affected QA evidence.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, criteria evaluated as PASS may be checked off, while criteria evaluated as FAIL must remain unchecked. The authoritative `spec.md` currently has all 10 criteria checked, but this review found criteria 8 and 9 are not supported by current evidence. No source checkbox edits were made during review; remediation should reconcile source checkboxes after the defects are fixed and verified.

### AC Status Summary

- Source: `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md`
- Total AC items: 10
- Checked off (delivered): 8 supported by this review
- Remaining (unsupported by current review evidence): 2
- Items remaining:
  - No unintended behavior changes occur outside the defined Codex role config and executable-resolution scope.
  - Full toolchain pass completed for changed TypeScript and Python contract-test surfaces.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-04-codex-agent-role-config-306/spec.md` | 10 | 8 supported by review | 2 unsupported by review | Source file currently has all 10 checked; remediation must reconcile after fixes. |
