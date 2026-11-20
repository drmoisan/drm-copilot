# Code Review: Runbook commands not checked against pinned tool versions (#1128)

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128`
**Base Branch:** `main`
**Head Branch:** `bug/runbook-command-version-check`
**Review Type:** Re-audit after remediation cycle 1

---

## Executive Summary

The branch adds a pure PowerShell module (`RunbookCommandVersion.psm1`, now 301 lines), a SubagentStop hook (132 lines), skill, agent and example text, bundle and `.agents` mirrors, a core pack manifest entry, three new Pester files, and a one-line order-dependence fix in `OrchestratorState.Tests.ps1`. No Python or TypeScript file changed. Remediation cycle 1 closed both prior Minor findings (RI-1 and RI-2).

**What changed in this cycle:**
`Get-RunbookCountedBlock` joins a physical line ending in a backslash, backtick, or caret to the next line before tool extraction. `Split-RunbookCommandSegment` splits a logical command on `&&`, `||`, `;` and `|` outside quotes, and `Get-RunbookSegmentToolName` skips leading `NAME=value` assignments and names no tool for `cd`, `pushd`, `popd`, `export`, `set`, `source`, `.`, `echo` or a `$env:` token. `Get-RunbookCommandToolName` now emits one name per segment.

**Resolution of prior findings (verified by execution of the head module through a scratch launcher outside the repository):**
- RI-1: a block `python -m nuitka \`, `  --standalone \`, `  main.py` with `Version check: verified against nuitka 4.3.4` and a pinned nuitka 4.3.4 yields 0 findings; the same block without a marker yields exactly one finding, for nuitka.
- RI-2: `cd x && python -m nuitka --clean-cache=all` with the marker yields 0 findings; without the marker it yields the nuitka finding; `FOO=1 python -m nuitka x` without a marker yields the nuitka finding. `Get-RunbookCommandToolName` on `cd x && FOO=1 poetry run python -m nuitka y | tee z; echo "a && b"` returns `nuitka` and `tee`; the quoted `&&` is not split.

**Top risks:**
1. The live hook is not exercised before merge (coordinator-accepted; post-merge check).
2. Tokenization is a lexical approximation (no subshell, heredoc, or `$(...)` handling); this matches the spec's honest-marking, not-correctness non-goal.

**PR readiness recommendation:** **Go** - all six acceptance criteria are met, gates are green, and no blocking finding exists.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/runbook/RunbookCommandVersion.psm1` | `Get-RunbookCountedBlock` lines 215-228 | RI-1 resolved. Continuation joining is applied per fenced block; a comment line is never joined, and a dangling continuation at the end of a block is emitted. | None. | Closes the prior Minor finding 1. | Executed probe; `ri-fail-before.2026-11-08T15-35.md` (22 failed before, 0 after) |
| Info | `.claude/lib/runbook/RunbookCommandVersion.psm1` | `Split-RunbookCommandSegment`, `Get-RunbookSegmentToolName` lines 90-166 | RI-2 resolved. Segment splitting respects quotes, assignments are skipped, and the nine builtin/environment forms name no tool; launchers recurse into the wrapped command. | None. | Closes the prior Minor finding 2. | Executed probe |
| Info | `.claude/hooks/validate-human-exception-runbook-output.ps1` | lines 104-113 | Lockfile reads use a directory listing of the resolved root, so only top-level lockfiles are read; matches the spec's assumption. | None. | Documented in spec Assumptions. | Source inspection |
| Info | `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` | lines 387-393 | `Remove-Module OrchestratorStateUnconditional` before the lazy import removes an order dependence. | None; accepted in scope by the coordinator. | Fixes a per-file coverage swing that depended on shard contents. | `pester-final.2026-11-08T15-56.md` |

No covered file reaches 700 lines (largest: `RunbookCommandVersion.Tests.ps1`, 495 lines; module 301 lines); no file-size Warning applies and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well
- Advanced functions with `CmdletBinding`, `OutputType`, comment-based help, approved verbs.
- Pure module over strings; I/O isolated to injectable hook seams.
- The new helpers are small and single-purpose; the module-level help documents the join, split, and skip rules.
- Module coverage 129/129 lines; hook 54/58 lines (93.1%) from the parsed `powershell-coverage.xml`.
- Mirrors verified byte-identical with `cmp`: module, hook, agent, skill, and example against the bundle copies, and the `.agents` skill and example against the `codex-and-agents-customizations` copies.

#### API and safety notes
- Exported functions are unchanged (`Get-RunbookPinnedToolVersion`, `Get-RunbookCommandToolName`, `Get-RunbookCommandVersionFinding`); `Get-RunbookCommandToolName` now emits zero or more names, and its only caller iterates over the result with an array subexpression.
- Lockfile names come from a directory listing of the resolved root; no user-controlled path reaches `Get-Content` beyond the resolved runbook path.
- `ConvertFrom-Json -AsHashtable` correctly handles the empty-string root key of `package-lock.json`.

#### Error handling and logging
- Block messages list every finding with the `HUMAN_EXCEPTION_RUNBOOK_OUTPUT_MISSING:` prefix; a validator error fails closed with exit 2.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1` (495 lines)
- `tests/scripts/claude-hooks/validate-human-exception-runbook-output.Tests.ps1` and `.TargetWorktree.Tests.ps1`
- `evidence/qa-gates/pester-final.2026-11-08T15-56.md`, `powershell-static.2026-11-08T15-46.md`, `pytest-final.2026-11-08T16-03.md`, `self-review.2026-11-08T16-04.md`

### Quality assessment prompts
- Tests use in-memory seams and no temporary files; one behavior per `It`.
- Positive, negative, and edge flows are covered, including the two reproductions, which failed before the fix (22 failures) and pass after it.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials |
| No unsafe subprocess or command construction | PASS | Neither the module nor the hook starts a process; the segment splitter only tokenizes text |
| Input validation at boundaries | PASS | `runbook_path` shape check, rejection of out-of-tree paths through `Resolve-SubagentStopArtifactLocation`, payload anomaly block |
| Error handling remains explicit | PASS | Fail-closed handler and dependency-failure block |
| Configuration / path handling is safe | PASS | Paths resolved against the target worktree root; no absolute path encoded in artifacts |

---

## Research Log

No external research was required.

---

## Verdict

The change is ready for normal PR flow. Both prior Minor findings are resolved and verified by execution; no blocking finding remains. Post-merge, confirm the live hook behavior as the coordinator planned.
