# Code Review: Completion stop hook mutation rejection signal (#1012)

**Review Date:** 2026-10-31
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-completion-stop-hook-traps-session-after-rejected-parallel-mutation-1012`
**Base Branch:** `main` (merge base `52d818c3fc93288e1133f7d36fe76857f3c879a4`)
**Head Branch:** `bug/completion-stop-hook-rejected-mutation-1012` @ `53bdea616163ef327d95d600489c4283ea08d11d`
**Review Type:** Initial review

---

## Executive Summary

The branch fixes the trap in which a parallel skill that correctly rejects a mutation before any run checkpoint exists cannot end its turn, because `validate-orchestrator-output.ps1` returns a repairable `NoTarget` block that `stop_hook_active` never releases. The fix adds a final-line output signal `PARALLEL_MUTATION_REJECTED: <code>`, a closed set of four codes defined once in `.claude/rules/parallel-orchestration.md`, and a narrowly gated allow path in a new dot-sourced sibling. Evidence reviewed: the full diff `52d818c3f..53bdea616`, the three new test files, `artifacts/pester/powershell-coverage.xml`, the regenerated `artifacts/pr_context.summary.txt`, and every record under `evidence/`.

**What changed:**
- `.claude/hooks/validate-orchestrator-output-rejection.ps1` (new, 172 lines): `Get-ParallelMutationRejectionCode`, `Test-ParallelRunStateAbsent`, `Get-OrchestratorOutputRejectionDecision`, `Get-ParallelMutationRejectionHint`, and the script-scope code array.
- `.claude/hooks/validate-orchestrator-output.ps1`: one guarded dot-source, one decision call before the unresolved-branch `return`, and the hint append on that block message.
- `.claude/rules/parallel-orchestration.md`: new section `## Mutation Rejection Signal (issue #1012)` between `## Enum Ownership (F6/F7/F8 consume, never extend)` and `## F7 Seam`, plus a `paths:` entry.
- Four parallel skills: emission instructions at mapped STOP paths, run-existence-first ordering, and no-signal statements for unmapped paths.
- Byte-identical bundle copies, one `core.json` entry, and three new test files.

**Allow-path gate analysis (verified by inspection):**
- Artifact-type gate: `Get-OrchestratorOutputRejectionDecision` returns `$null` unless `$ArtifactType -cne 'parallel-orchestrator-state'` is false, so `orchestrator-state` and `epic-orchestrator-state` cannot reach the allow. `Get-ParallelMutationRejectionHint` returns `''` for those types, so their block messages are byte-identical with and without the signal (AC-9 rows assert `Message` equality).
- Resolution gate: the call sits inside `if (-not $resolution.Resolved)`, so a resolved checkpoint never reaches it; within the branch, `[string]$Resolution.Status -cne 'NoTarget'` rejects `Ambiguous` and `Rejected`. The resolver-exception path returns earlier and is unchanged.
- Signal gate: last non-blank line after `TrimEnd()`, case-sensitive `[regex]::Match` with an anchored pattern, then an ordinal membership check.
- State gate: any non-blank, unparseable, non-object, off-route, slugless, or same-slug parallel checkpoint text in any live root defeats the allow.
- Failure mode: an exception inside the helpers propagates to the existing script tail, which blocks (fail closed); a load failure of the sibling is reported through `Add-HookDependencyFailure`.

**Single-definition check:** The four codes appear in `.claude/rules/parallel-orchestration.md` (table) and in `$script:ParallelMutationRejectionCodes` (sibling) only. A repository grep finds `parallel-run` 1, `parallel-add` 1, `parallel-close` 2, `parallel-remove` 3 occurrences, and no skill names all four codes (`parallel-remove` names three). The other grep hits (`pm_unknown_item_message` in `.claude/lib/bash/parallel-mutation*.sh`) are pre-existing function names, not code-set restatements. The AC-11 parity row reads the rule table and compares it with the array; the Python contract test asserts that no skill restates the full set.

**Top 3 risks:**
1. A valid signal blocked by contradicting state (for example a stale unparseable parallel checkpoint in a live worktree) receives the generic hint, which tells the agent to emit the signal it already emitted; the stale-checkpoint remedy is documented only in `spec.md` (CR-3).
2. Merge overlap with sibling items #1009 to #1011 in the main hook, its bundle copy, and `core.json`; the edit was deliberately limited to three lines to reduce contention.
3. The Linux `poshqc / PowerShell hook suites` job has not run on this head; the new fixtures follow the Linux-safe patterns but confirmation is part of AC-20.

**PR readiness recommendation:** **Conditional Go** - No Blocker or Major code findings; readiness depends on the CI run on the PR head (AC-20) and on recording the CI coverage figures for PA-1 and PA-2.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | commit `569be86e0` | commit message | CR-1: The Phase 0 evidence commit reuses the preparation-run message ("prepare bug 1012 ... Add the active feature folder ..."), but its content is six baseline evidence files and plan check-offs. The commit is pushed. | Do not rewrite pushed history (forced pushes are denied by repository hooks). State the mismatch in the PR description; a squash merge replaces the message on `main`. | The message misdescribes the commit for anyone reading branch history; the content is correct and the defect has no functional effect. Non-blocking. | `git show --stat 569be86e0`; `evidence/qa-gates/self-review.2026-10-31T11-34.md` line 173 |
| Minor | `artifacts/pester/powershell-coverage.xml` | report-level counters | CR-2: The canonical coverage artifact was overwritten after the P5-T3 full run by a coverage-enabled targeted run (session 11:23:16 to 11:26:38 UTC; report-level LINE 1708 of 22371). The per-file figures still match `coverage-comparison.2026-10-31T11-13.md`, but the repo-wide figure that record relies on can no longer be reproduced from the artifact. | Record the repo-wide line figure in the evidence file at the time of the full run, and disable coverage (or redirect output) for targeted and isolation runs. For this item, record the CI merged figure (policy-audit PA-1). | Evidence must be reproducible from the artifact it cites. The blocking aspect is tracked as PA-1 (awaiting_ci); this row records the process cause. | `artifacts/pester/powershell-coverage.xml` header and report counters; `evidence/regression-testing/isolation.2026-10-31T11-33.md` Route note |
| Minor | `.claude/hooks/validate-orchestrator-output-rejection.ps1` | `Get-ParallelMutationRejectionHint`, lines 161-171 | CR-3: When the signal is valid but the state-absence scan defeats the allow, the block message carries only the generic hint ("ends its final output with the line 'PARALLEL_MUTATION_REJECTED: <code>'"). It does not say that contradicting checkpoint text in a live worktree caused the block, and the block is repairable, so `stop_hook_active` does not release it. | Optional follow-up within the item or a later change: when the code is valid, append a line stating that a live worktree holds parallel checkpoint text that contradicts the no-state claim, and name the `artifacts/orchestration/handoff/` remedy. | The behavior matches the spec outcome table ("block as today") and AC-8, so this is not a defect against the spec. The remaining trap is narrow (a stale or malformed parallel checkpoint in a live worktree) and the spec records it as a residual risk. Non-blocking. | Code inspection; `spec.md` Risks & Mitigations |
| Info | `spec.md` | `Decision on unmapped STOP paths` | CR-4: The spec says each affected skill states that its unmapped STOP paths emit no signal and lists the `parallel-orchestrate` stops, while the same spec excludes `parallel-orchestrate/SKILL.md` from change. The three mutating skills carry the statement; `parallel-orchestrate` does not. | None required; AC-13 names only `parallel-add`, `parallel-close`, and `parallel-remove`, and AC-16 requires `parallel-orchestrate` unchanged. | Internal wording inconsistency in the spec; no AC is affected. | `spec.md` lines 118 and 164; `git diff --stat 52d818c3f HEAD -- .claude/skills/parallel-orchestrate/` (empty) |
| Info | `.claude/skills/parallel-close/SKILL.md`, `.claude/skills/parallel-remove/SKILL.md` | `items_in_flight`, `unknown_item` emission points | CR-5: These rejections occur while the run checkpoint exists, so the resolver resolves and full validation applies; the signal has no effect on these paths. | None; the emission follows the spec table and is harmless. | Documents expected behavior for future readers. | Code inspection; `self-review.2026-10-31T11-34.md` line 174 |

No Blocker or Major findings. No file-size Warning rows: the largest covered file in the diff is 412 logical lines (`validate-orchestrator-output.MutationRejection.Tests.ps1`); no covered file is at or above 700 lines, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The main-hook edit is minimal: one guarded load, one call placed before the existing block `return`, and one string append. Reverting it restores the prior decision path exactly.
- The parser is strict and simple: `TrimEnd()`, last line by `LastIndexOf("`n")`, an anchored case-sensitive pattern, then an ordinal membership check. A `\r` inside a CRLF last line is removed by `TrimEnd()`, and leading whitespace on the last line does not match, consistent with "no leading text".
- The state-absence scan uses `ConvertFrom-Json -NoEnumerate` so a one-element JSON array is not read as an object, matching the resolver's own parse rule in `WorktreeRunResolution.psm1`.
- Ordinal comparisons (`-cne`, `-ccontains`, `-ceq`, `[StringComparison]::Ordinal`) throughout.
- The sibling imports nothing, starts no process, and uses no call operator; an AST test pins this.

#### API and safety notes

- All four helpers use `[CmdletBinding()]`, `[OutputType()]`, and explicit `Mandatory`/`AllowNull`/`AllowEmptyString` attributes; verbs `Get` and `Test` are approved.
- `Get-ParallelMutationRejectionHint` handles empty output: `LastIndexOf` returns -1 and `Substring(0)` yields an empty line, which does not start with the prefix.
- PSScriptAnalyzer reports 0 findings (`evidence/qa-gates/pssa.2026-10-31T10-56.md`).

#### Error handling and logging

- Load failure surfaces through `Add-HookDependencyFailure` and the existing dependency-failure decision (S1 to S6 rows for repository and mirror pass).
- An exception in the decision helper propagates to the tail, which already converts it to `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: validator error: ...` (fail closed).

### Python implementation audit

#### What changed well

- `test_parallel_mutation_rejection_signal_contracts.py` reads the code set from the rule table instead of hard-coding it for the subset check, and asserts per-section emission against the spec's emission table.

#### Typing and API notes

- No new public Python API surface was added. All helpers are annotated; Pyright is clean.

#### Error handling and logging

- Not applicable to a read-only contract test.

---

## Test Quality Audit

Automated evidence covers every outcome-table row of the spec. Coverage of the two changed PowerShell files was re-read by the reviewer from the JaCoCo class counters: 43 of 43 lines for the sibling, 122 of 123 for the hook (the missed line is unchanged). The expect-fail run shows the new rows failed before the fix for the expected reasons (54 Pester and 24 pytest failures), so the rows test the change rather than pre-existing behavior.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/validate-orchestrator-output-rejection.Tests.ps1` - 38 unit rows across the four helpers plus the AST structure row; seams mocked in script and module scope; no file I/O.
- `tests/scripts/claude-hooks/validate-orchestrator-output.MutationRejection.Tests.ps1` - 28 end-to-end rows through the shipped resolver, the script-tail exit-0 row, and the rule-to-hook parity row.
- `tests/scripts/dev_tools/test_parallel_mutation_rejection_signal_contracts.py` - 28 contract cases over the rule and four skills.
- `evidence/regression-testing/expect-fail.2026-10-31T10-42.md` - pre-implementation failures recorded per row.
- `evidence/regression-testing/hook-suites.2026-10-31T10-50.md` - the named regression rows (R8 to R11, O-5, E-ORC-2, H5, fail-closed dispatch, S2-6, S1 to S6) pass.
- `evidence/regression-testing/isolation.2026-10-31T11-33.md` - three seeded shuffled container orders and a reversed pytest order pass.
- `evidence/qa-gates/mirror-parity.2026-10-31T10-57.md` - 7 of 7 hash pairs equal; 104 push-down tests pass. The reviewer re-confirmed parity with `git hash-object` on all 7 pairs at head (identical blob ids).

### Quality assessment prompts

- **Determinism:** no clock, RNG, network, process start, or temporary file; synthetic roots `/synthetic-worktrees/<name>`.
- **Isolation:** each `Context` targets one helper or one AC; `Invoke-HookTail` restores stdin, stderr, `CLAUDE_HOOK_INPUT`, and dependency-failure state in `finally`.
- **Speed:** 66 Pester rows within a 1564-row targeted run; no waits.
- **Diagnostics:** block-row assertions pass `$result.Message` as `-Because`, so a failure prints the actual hook message.
- **Linux safety:** case-sensitive operators, forward-slash joins, `(Get-Location).Path.Replace([char]92, '/')` for the session root, lowercase file names, and no drive letters. The map keys `"$root/artifacts/orchestration/parallel-orchestrator-state.json"` match `Join-WorktreeResolutionPath` output for forward-slash roots, the same pattern the existing `WorktreeResolution` suite uses on Linux.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Inspection of all changed files. |
| No unsafe subprocess or command construction | PASS | The sibling starts no process and uses no call operator (AST row). |
| Input validation at boundaries | PASS | Strict anchored grammar, ordinal membership, and state-absence scan before any allow. |
| Allow path cannot weaken other types or resolutions | PASS | Artifact-type and `NoTarget` gates precede the signal check; the call is unreachable for resolved checkpoints; AC-7 and AC-9 rows. |
| Error handling remains explicit | PASS | Guarded load and fail-closed tail. |
| Configuration / path handling is safe | PASS | Paths composed only through `Get-WorktreeRunCheckpointPath`; no registration change (`.claude/settings.json` unchanged). |
| No Python in enforcement hooks | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` (33 passed). |

---

## Research Log

No external research was required. The hook payload field `last_assistant_message` was already consumed by the existing envelope reader; the research record `research/research.2026-10-30T12-15.md` covers the design inputs.

---

## Verdict

The implementation is small, strictly gated, and well tested, and it matches the spec's outcome table. The code set is defined once in the rule, mirrored only by the sibling's array, and pinned by the parity row; no skill restates the set; bundle copies are byte-identical and the manifest lists the new sibling. The findings are three Minor items (a reused commit message, an overwritten coverage artifact, and a less specific hint for the contradicting-state block) and two Info notes, none of which blocks the merge.

The change is ready for PR authoring. Merge readiness depends on the CI run on the PR head (AC-20, including the Linux hook-suite job) and on recording the CI coverage figures for the two `awaiting_ci` policy items.
