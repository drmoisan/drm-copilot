# Code Review: Runbook commands not checked against pinned tool versions (#1128)

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128`
**Base Branch:** `main`
**Head Branch:** `bug/runbook-command-version-check`
**Review Type:** Initial review

---

## Executive Summary

The branch adds a pure PowerShell module (`RunbookCommandVersion.psm1`, 221 lines), a SubagentStop hook (132 lines), skill, agent and example text, bundle and `.agents` mirrors, a core pack manifest entry, three new Pester files (64 tests), and a one-line order-dependence fix in `OrchestratorState.Tests.ps1`. No Python or TypeScript file changed. Implementation follows the spec and the repository hook patterns.

**What changed:**
Module functions are pure over strings; the hook reads files only through `-ReadFile`, `-TestFile`, and `-ListRootFile` seams and resolves the item worktree through `Resolve-SubagentStopTargetWorktree`. Mirrors are byte-identical (verified with `cmp`).

**Top 3 risks:**
1. A multi-line command (backslash continuation) produces false findings for each continuation line.
2. A chained or env-prefixed command (`cd x && python -m nuitka ...`, `FOO=1 python -m nuitka`) resolves to the wrong tool, so the real tool goes unchecked.
3. The live hook is not exercised before merge (coordinator-accepted).

**PR readiness recommendation:** **Go** - all six acceptance criteria are met, gates are green, and the open points are non-blocking design limitations that match the spec text.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/runbook/RunbookCommandVersion.psm1` | `Get-RunbookCommandVersionFinding` lines 188-193 | Each non-blank line of a counted fence is a command, as the spec states. A Nuitka command split with `\` continuation lines yields tools `-standalone` and `main-py`, so the gate demands nonsensical `Version check:` lines. Probe output: "Counted block 1 runs tool -standalone ... no 'Version check:' line". | Follow-up: join continuation lines (trailing `\` or backtick) before tool extraction, or document that commands must be single-line. | The motivating tool (Nuitka) is commonly written across several lines; the gate would produce repair noise. Spec-conformant, so non-blocking. | Executed probe of the head module via a scratch launcher |
| Minor | `.claude/lib/runbook/RunbookCommandVersion.psm1` | `Get-RunbookCommandToolName` lines 102-121 | Only the first token (plus launcher forms) names the tool. `cd x && python -m nuitka` returns `cd`; `FOO=1 python -m nuitka` returns `foo=1`. | Follow-up: skip leading `VAR=value` tokens and consider the command after `&&`/`;`/`\|`. | The gate enforces honest marking, not correctness (spec non-goal), so this is a coverage gap, not a defect. | Executed probe |
| Info | `.claude/hooks/validate-human-exception-runbook-output.ps1` | lines 104-113 | Lockfile reads use a directory listing of the resolved root, so only top-level lockfiles are read; matches the spec's assumption. | None. | Documented in spec Assumptions. | Source inspection |
| Info | `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | lines 387-393 | `Remove-Module OrchestratorStateUnconditional` before the lazy import removes an order dependence. | None; accepted in scope by the coordinator. | Fixes a per-file coverage swing that depended on shard contents. | `pester-final.2026-11-08T15-08.md` note |

No covered file reaches 700 lines (largest new file: `RunbookCommandVersion.Tests.ps1`, 340 lines); no file-size Warning applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well
- Advanced functions with `CmdletBinding`, `OutputType`, comment-based help, approved verbs.
- Pure module over strings; I/O isolated to injectable hook seams.
- Hook follows the dependency-guard and uncaught-error pattern and is added to `subagentstop-uncaught-error.Tests.ps1`.
- Module coverage 91/91 lines; hook 54/58 lines (93.1%) from the parsed `powershell-coverage.xml`.

#### API and safety notes
- Lockfile names come from a directory listing of the resolved root; no user-controlled path reaches `Get-Content` beyond the resolved runbook path.
- `ConvertFrom-Json -AsHashtable` correctly handles the empty-string root key of `package-lock.json`.

#### Error handling and logging
- Block messages list every finding with the `HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING:` prefix; a validator error fails closed with exit 2.
- A malformed `package-lock.json` would throw inside the hook and be caught by the fail-closed handler, which labels it non-repairable.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1` (340 lines)
- `tests/scripts/claude-hooks/validate-human-exception-runbook-output.Tests.ps1` (246 lines) and `.TargetWorktree.Tests.ps1` (152 lines)
- `evidence/qa-gates/pester-final.2026-11-08T15-08.md`, `powershell-static.2026-11-08T14-18.md`, `pytest-final.2026-11-08T15-08.md`

### Quality assessment prompts
- Tests use in-memory seams and no temporary files; one behavior per `It`.
- Positive, negative, and edge flows are covered. No test covers a continuation-line command (the gap in finding 1).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials |
| No unsafe subprocess or command construction | PASS | Neither the module nor the hook starts a process |
| Input validation at boundaries | PASS | `runbook_path` shape check, rejection of out-of-tree paths through `Resolve-SubagentStopArtifactLocation`, payload anomaly block |
| Error handling remains explicit | PASS | Fail-closed handler and dependency-failure block |
| Configuration / path handling is safe | PASS | Paths resolved against the target worktree root; no absolute path encoded in artifacts |

---

## Research Log

No external research was required.

---

## Verdict

The change is ready for normal PR flow. The two Minor findings are design limitations consistent with the spec's stated first-token and per-line command model; they are suitable for a follow-up and do not block merge. Post-merge, confirm the live hook behavior as the coordinator planned.
