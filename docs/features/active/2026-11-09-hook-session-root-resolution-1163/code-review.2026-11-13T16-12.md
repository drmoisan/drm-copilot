# Code Review: Hook Session-Root Resolution (Issue #1163)

**Review Date:** 2026-11-13
**Branch:** `bug/hook-session-root-resolution-1163` @ `e5948a38dbe6ffaba2315f72ffb03f0057d84aa8` (PR #1170)
**Base:** `main`; merge base `1d62aa292161035aec8058e6c370f133e10a04db` (equal to the re-fetched `origin/main`)
**Review type:** Re-audit, remediation cycle 2 (C1, CI failure); prior reviews `code-review.2026-11-13T14-23.md` and `code-review.2026-11-13T15-02.md`.
**Scope:** full branch diff, 170 files (20 production PowerShell files and their 20 bundle mirrors, 35 PowerShell test files, 2 pack manifests, 8 Markdown policy and brief copies, 3 npm lockfiles, 1 promoted potential-feature record, feature-folder files)

## Executive Summary

CI on PR #1170 at `ab6c96321` failed only the three `NPM Audit Gate` jobs (C1): new moderate advisories against `hono` and `@hono/node-server` were published after the last green `main` run. Cycle 2 ran `npm audit fix` without `--force` in each manifest. The three lockfiles each change six lines, raising `hono` 4.13.14 to 4.13.18 and `@hono/node-server` 2.1.5 to 2.1.8; no other lockfile entry, no `package.json`, and no source or test file changed. The reviewer re-ran the gate command in each manifest at review time and all three exited 0.

The remaining `deepmerge` advisory (GHSA-gcqx-w48m-w2h4) is low severity, below the gate's `moderate` level, and its vulnerable range has no upper bound, so no override can resolve it; the only `npm audit` remedy is `--force`, which installs jest@25.1.0 (a breaking downgrade). Leaving it is correct.

The PowerShell code reviewed in the 2026-11-13T15-02 re-audit is unchanged, and its findings still hold. No new blocking finding was identified.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved (C1) | `package-lock.json`; `extensions/drm-copilot/package-lock.json`; `packages/mcp-server/package-lock.json` | `node_modules/hono`, `node_modules/@hono/node-server` entries | `hono` 4.13.18 and `@hono/node-server` 2.1.8 with matching `resolved` and `integrity`; 6 insertions and 6 deletions per lockfile; no platform-specific or optional entry removed. | None. | The patch versions lie inside the existing caret `overrides` ranges, so `npm ci` stays in sync with each `package.json`. | Reviewer `git diff <merge base> HEAD` of the three lockfiles; reviewer `npm audit --audit-level=moderate` exit 0 in each manifest; `npm-audit-final.*.2026-11-13T16-00.md` |
| Info (U1, unrelated to this item) | `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`, `python-native-corpus.json`, `python-surface-corpus.json` | root `format:check` script | Root Prettier check exits 1 on these three fixtures. They are unchanged on the branch (last changed on `main` in `bd8aa11b6`), and no CI workflow runs Prettier. | File a separate issue: add the fixtures to `.prettierignore` (which already holds `tests/fixtures/` for byte-exact fixtures) or reformat them. | A pre-existing `main` defect outside this item; per OD-8 it is filed rather than fixed here. | Reviewer `git diff --stat` of the folder (empty); `grep` of `.github/workflows/` for `prettier` and `format:check` (no match); `typescript-static-final.2026-11-13T16-03.md` |
| Info (CR5) | `docs/features/active/2026-11-09-hook-session-root-resolution-1163/remediation-plan.2026-11-13T15-36.md` | `[P2-T2]` | Checked off while the root Prettier step does not meet the literal acceptance; the evidence records the deviation and the baseline comparison (no new finding). | None for this item; the deviation is disclosed. | U1 is outside the cycle's permitted change scope (P2-T8 forbids `tests/` changes). | `typescript-static-final.2026-11-13T16-03.md` `## Deviation` |
| Info (CR1, carried) | `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-orchestrator-output-target.ps1` | consumers of `Resolve-SubagentStopTargetWorktree` | Both inherit the prunable exclusion and the working-directory source through the shared helper; the feature-review coverage hook has no dedicated pinning row. | Optional: one pinning row in the feature-review coverage suite. | Keeps the inherited decision visible to later helper edits. | Prior reviews; helper unchanged |
| Info (CR2, carried) | `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | default `WorktreeListInvoker` | Calls `git` in a script block rather than an `Invoke-GitExe` wrapper, matching the composed `HookTargetWorktree.psm1` seam; the one uncovered line in each new file. | None required. | Consistent with the composed module. | Module text; coverage XML |
| Info (CR3, carried) | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; removal gates | D9 default `BranchWorktreeResolver` | One worktree listing per rooted record that names no live root. | Optional: list once per gate call if record counts grow. | Bounded process count per hook call. | Prior reviews |
| Info (CR4, carried) | `evidence/qa-gates/pester-parallel-final.2026-11-13T14-54.md` | Output Summary | Summary script read 0 skipped; the JUnit root reports `disabled="10"`, equal to earlier runs. | None; evidence is append-only. | Prevents a later reader from inferring a change in skipped tests. | `artifacts/pester/pester-junit.xml` root element |
| Warning | `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | whole file | 750 logical lines (700-line advisory tier; the hard limit is 800). | Consider splitting the issue #1163 receipt-root Describe into its own suite in a later change. | File-size advisory tier. | `awk 'END{print NR}'` at head |

No covered file exceeds 800 logical lines, and `config/file-size-baseline.json` is not in the diff. Cycle 2 changed no covered file.

## Detailed Review

### C1 lockfile change

Each lockfile diff against the merge base is limited to:

```text
node_modules/@hono/node-server: 2.1.5 -> 2.1.8 (version, resolved, integrity)
node_modules/hono:              4.13.14 -> 4.13.18 (version, resolved, integrity)
```

The reviewer checked for the known Windows `npm install` hazard of dropping platform-specific optional entries from a lockfile: no line other than these six changed, so `npm ci` on `ubuntu-latest` sees the same package set as before apart from the two upgrades. Root and extension `overrides` already pin both packages with caret ranges, and the new versions satisfy them, so no `package.json` edit was needed. This matches the scope evidence `scope-invariants.2026-11-13T16-05.md`.

### Downstream verification

- `npm run build` exit 0 in `extensions/drm-copilot` (tsc, extension bundle, MCP server bundle) and in `packages/mcp-server`, the two packages that bundle `hono` at runtime.
- Root Jest 5493 passed and extension Jest 5476 passed, with every per-file line and branch figure equal to the remediation baseline.
- The manifest-reading contract tests (`test_typescript_rule_npm_commands_resolve_to_root_package_scripts`, `test_brief_npm_run_tokens_exist_in_package_json`, `test_consumer_engines_remain_independent_of_development_runtime`, `test_cli_reference_lists_every_discovery_mcp_tool_and_command`) pass within the 151-test selection.

### PowerShell code

Unchanged since the 2026-11-13T15-02 re-audit: `git diff --name-only 15d3af2d1..HEAD` lists no path outside the feature folder other than the three lockfiles.

## Verification Performed

- `git fetch origin`; `git merge-base origin/main HEAD` equals `1d62aa292`.
- `git diff --name-status <merge base> HEAD` (170 files) and the lockfile diffs.
- `npm audit --audit-level=moderate` in `.`, `extensions/drm-copilot`, and `packages/mcp-server`: exit 0 in each (6 low, 6 low, 0).
- `gh pr view 1170`: head `e5948a38d`, open, mergeable; CI checks queued or in progress.
- Fixture provenance check for U1; `gh issue list` search found no open issue for it.
- Logical line counts of every covered file in the diff at or above 500 lines.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.

No reviewer test-suite run was made: the owner directive allows one parallel suite at a time, the cycle's Jest and pytest gates ran after the last lockfile commit, and later commits add only documents.

## Verdict

**PASS.** C1 is resolved. No blocking finding; U1, CR1 to CR5, and the Warning are non-blocking.
