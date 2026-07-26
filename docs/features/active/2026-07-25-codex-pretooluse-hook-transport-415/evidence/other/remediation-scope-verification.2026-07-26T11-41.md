# Remediation Scope and Hygiene Verification (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P6-T9]

Timestamp: 2026-07-26T11-41

## Anchor reconciliation (recorded deviation)

The plan records the branch anchor as `abaa6d51655309843cc51a92cef513dd87d8987a`. At execution start, HEAD was `fef82fa2f2f1dfc25cf96fad1b1b55e953b75dc5`, one commit past that anchor. Both were verified to resolve. The intervening commit `fef82fa2 docs(415): clear remediation plan preflight after rebase` touched only `remediation-plan.2026-07-25T21-03.md`, so the two anchors are code-identical. The remediation delta below is computed from **both**: `git diff abaa6d51 --name-only` (the plan-stated anchor) and, where the distinction matters, `git diff fef82fa2` (the true pre-remediation tip). They differ only in that the `abaa6d51` delta additionally lists the plan document, which `fef82fa2` already contained.

## Commands and outputs

### Command: `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede` (merge-base)
EXIT_CODE: 0

```
67 files changed, 5879 insertions(+), 1332 deletions(-)
```

(64 files at [P0-T2]; +3 tracked-file entries reflect this cycle's two runsettings edits, `.gitignore`, and the two edited test files, less overlap. Untracked new test files and evidence artifacts are not counted by `git diff`.)

### Command: `git status --porcelain`
EXIT_CODE: 0

6 modified tracked files and 24 untracked new files. Full listing reproduced in the assertions below.

### Command: `git diff abaa6d51655309843cc51a92cef513dd87d8987a --name-only` (remediation delta, tracked)
EXIT_CODE: 0

```
.gitignore
docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-25T21-03.md
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1
tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
```

### Command: `git ls-files --others --exclude-standard` (remediation delta, untracked)
EXIT_CODE: 0

5 new test files under `tests/scripts/codex-hooks/` and 19 new evidence artifacts under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/`.

## Assertions

### (a) NO path under `.claude/` appears in the remediation delta — **HOLDS**

Verification: `{ git diff abaa6d51 --name-only; git ls-files --others --exclude-standard; } | grep -c "^\.claude/"` → **0**.

No file under `.claude/` — including `.claude/state/`, `.claude/agent-memory/`, `.claude/rules/`, `.claude/hooks/`, `.claude/skills/`, and any bundled `.claude` copy — was created, modified, or deleted. Files under `.claude/` were read for policy and precedent only, as [P0-T1] requires. No agent-memory file was written.

### (b) The remediation delta contains ONLY the permitted paths — **HOLDS**

| Permitted category | Limit | Actual | Files |
|---|---|---|---|
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 1 | 1 | modified at [P1-T1] |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (preflight RC-1) | 1 | 1 | modified at [P1-T1] |
| `.gitignore` | 1 | 1 | modified at [P5-T1], exactly one added line |
| Test files under `tests/scripts/codex-hooks/` | ≤ 9 (≤ 3 per phase from Phases 2, 3, 4) | **7** | see breakdown below |
| Files under `FEATURE/` | unbounded | 20 | the plan document plus 19 evidence artifacts |

Test-file breakdown against the per-batch cap (RI-6):

| Phase | Production files | Test files | Names | Cap |
|---|---:|---:|---|---|
| 1 | 2 (`.psd1` config pair, RI-2) | 0 | — | ≤ 3 / ≤ 3 — OK |
| 2 | 0 | 3 | `codex-pretooluse-file-mapping.Tests.ps1` (new), `legacy-codex-hook-contracts.Tests.ps1` (edited), `codex-pretooluse-transport.Tests.ps1` (edited) | ≤ 3 — OK |
| 3 | 0 | 3 | `codex-test-purity-hooks.Tests.ps1`, `codex-batch-budget-hooks.Tests.ps1`, `codex-evidence-and-checkpoint-hooks.Tests.ps1` (all new) | ≤ 3 — OK |
| 4 | 0 | 1 | `codex-completion-consistency-hook.Tests.ps1` (new) | ≤ 3 — OK |
| 5 | 1 non-PowerShell (`.gitignore`, RI-2) | 0 | — | outside both language budgets |

No path outside these categories appears in the delta.

File-size compliance (Hard Constraint 5, measured as `(Get-Content -LiteralPath $path).Count`):

| Test file | Lines | ≤ 500? |
|---|---:|---|
| `codex-pretooluse-file-mapping.Tests.ps1` | 411 | YES |
| `legacy-codex-hook-contracts.Tests.ps1` | 478 | YES |
| `codex-pretooluse-transport.Tests.ps1` | 489 | YES |
| `codex-test-purity-hooks.Tests.ps1` | 304 | YES |
| `codex-batch-budget-hooks.Tests.ps1` | 346 | YES |
| `codex-evidence-and-checkpoint-hooks.Tests.ps1` | 400 | YES |
| `codex-completion-consistency-hook.Tests.ps1` | 168 | YES |

### (c) No `.codex/hooks/*.ps1` production file and no `.codex/config.toml` changed since the anchor — **HOLDS**

Verification: `git diff abaa6d51655309843cc51a92cef513dd87d8987a --name-only -- .codex/ | wc -l` → **0**.
Cross-check against the true pre-remediation tip: `git diff fef82fa2 --name-only -- .codex/ | wc -l` → **0**.

Nothing under `.codex/` changed. `.codex/config.toml` retains its three `PreToolUse` matcher groups with 5 / 5 / 8 handler blocks unmodified; no hook registration was disabled, removed, bypassed, or weakened; no handler's allow/deny policy function was changed. Root and bundled Codex copies remain byte-identical, re-verified by the parity suites in every green PoshQC test run.

### (d) No `.codex/state/*` file is staged or committed — **HOLDS**

Verification: `git ls-files .codex/state | wc -l` → **0**. Additionally `Test-Path .codex/state` → **False** after every full test run in Phases 2, 3, 4, and 6: the directory does not exist on disk. The batch-budget entrypoint cases are deliberately restricted to payloads that cannot reach the state-writing path, and every filesystem seam in the unit cases is injected, so the suite creates no repository state. The `.gitignore` entry added at [P5-T1] is a preventive measure whose acceptance is binary and independent of the directory's existence (`git check-ignore .codex/state/probe` exits 0).

## Output Summary

All four assertions hold with command output captured above. Scope is confined to the measurement-configuration pair, `.gitignore`, seven test files, and feature-folder evidence. No production behaviour was changed anywhere in this remediation.
