# Code Review: CI merge queue for `main` (#952)

---

**Review Date:** 2026-10-16
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its `-952` suffix matches the branch name.
**Base Branch:** `main`, resolved as `origin/main` @ `5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea` (merge base `5bdf22d0f`)
**Head Branch:** `bug/ci-merge-queue-for-main-952` @ `cc79f6382947e5eca97f9102490a8bbabf2fc61d` (no PR yet)
**Review Type:** Initial review after plan execution and orchestrator gates ORCH-2, ORCH-4, ORCH-5, ORCH-6

---

## Executive Summary

Reviewed evidence: the full branch diff (157 files; 18 PowerShell, 4 Python, 1 workflow YAML), `artifacts/pr_context.summary.txt` and appendix (regenerated 12:47:07 UTC at head `cc79f6382`), the feature-folder evidence including the ORCH-2, ORCH-4, ORCH-5, and ORCH-6 artifacts, and reviewer re-runs of Black, Ruff, Pyright, the full Python suite with coverage, and the contract suites.

**What changed:**
- `ci.yml` triggers on `merge_group` (`types: [checks_requested]`, no filter); the call graph reads no pull-request event field.
- A new helper per runtime, byte-identical (`enforce-epic-merge-gate-command.ps1`), defines `Test-EpicMergeGateCommandInScope` and `Get-EpicMergeGateSelectorPrNumber`. Both gates now gate every `gh pr merge` spelling except a pure `--disable-auto`, plus `gh api` calls naming `enqueuePullRequest`, `enablePullRequestAutoMerge`, `mergePullRequest`, or a `pulls/<n>/merge` path. The previous raw-scan fallback for wrapper payloads (`bash -c "gh pr merge ..."`) is preserved through the Indeterminate-match fail-closed rule, and both runtimes pin that case.
- `Invoke-MergeConfirmationParser.ps1` maps one PR snapshot to `merged | pending | not_queued | closed`.
- The release flow drops `--delete-branch` and waits through `Wait-ForPullRequestMerged` before checkout, pull, and tag.
- Procedures (parallel, orchestrate S9 step 6, epic, Codex epic) record a merge only after polling and an ancestry check; D10(a) makes the cleanup skill queue-aware; D10(b) grants the epic persona both parser invocations and pins them with a Python contract test.

**Top 3 risks:**
1. `.codex/hooks/enforce-epic-merge-gate-command.ps1` is at 75.47% line coverage in CI, and the recorded cause does not match the test file content, so adding tests alone may not move the metric (CR-1).
2. The text-based `gh api` scope cannot see a mutation supplied from a file; the limitation is undocumented (CR-5).
3. Under a queue, a merge-group failure leaves the PR head green; the procedures route it through `not_queued`, which depends on the procedure text being followed. No automated check covers that path beyond the documentation pins (Info).

**PR readiness recommendation:** **Not ready** - one Blocker (CR-1); AC-28 pending CI.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.codex/hooks/enforce-epic-merge-gate-command.ps1` | lines 63, 64, 68, 160, 161, 166, 173, 176-180, 183 | CR-1: new file at 75.47% line and changed-line coverage (40/53) on R_final, below 85%. The byte-identical Claude copy is at 94.34%. ORCH-6 states the Codex suites do not drive the URL selector or the REST reader, but `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:134,135,149,151` drive both and pass, while lines 63-64 and 176-180 are reported uncovered. | (1) Diagnose the attribution: confirm which helper file the Codex suite's calls resolve to during the coverage run (for example `(Get-Command Get-EpicMergeGateSelectorPrNumber).ScriptBlock.File` inside the suite, or a coverage run scoped to the Codex suite). (2) Add Codex cases for the `--` terminator (with and without a following token), `gh pr merge --merge=5`, a branch-name selector, a flags-only `gh pr merge --merge`, and a `gh api` call with no resolvable number. (3) If attribution is the cause, fix it in the test setup so the Codex suite loads only the Codex helper; do not add coverage exclusions. (4) Dispatch a new R_final and repeat ORCH-4 to ORCH-6. | New-file line coverage >= 85% is required (`.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`). A misdiagnosed cause risks a cycle that adds duplicate tests without changing the figure. | `evidence/qa-gates/coverage-comparison.2026-10-16T12-40.md`; reviewer reading of the Codex suite |
| Minor | `.claude/hooks/enforce-epic-merge-gate-command.ps1` | lines 68, 160, 161 | CR-2 (in-item, same file): the branch-name selector (`return $null` at 68) and the `--` terminator (160-161) are not exercised on the Claude runtime. The file passes at 94.34%. | Add the same `--` and branch-name cases to `enforce-epic-merge-gate.MergeQueue.Tests.ps1` (B-4 group) with expected `$null`/`5` results. | Both runtimes share the file; parity of cases keeps both suites diagnostic. | ORCH-6 uncovered-line list |
| Minor | `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` | lines 98, 101, 108, 128 | CR-3 (in-item, same file): `MERGED` with a null `mergedAt` (98), the `[datetimeoffset]` branch (101), the string fallback (108), and the empty-input path (128) are not exercised. AC-12 requires null fields to be handled. | Add cases: `MERGED` with `"mergedAt":null` (expect `MergedAt` `''`); `-PrJson ''` (expect the `null or empty` throw); call `ConvertTo-MergeConfirmationTimeText` directly with a `[datetimeoffset]` and a non-ISO string. If the `[datetimeoffset]` branch is unreachable from `ConvertFrom-Json` output, keep it only with a direct test. | Closes the residual gaps in a file that passes the threshold and pins the documented null handling. | ORCH-6 uncovered-line list; parser lines 95-108, 127-129 |
| Minor | `.claude/hooks/enforce-epic-merge-gate-command.ps1` (and Codex twin) | `Get-EpicMergeGateSelectorPrNumber`, lines 165-167 | CR-4 (in-item, same file): any `--merge=<value>` token returns immediately; for a non-numeric value (for example `--merge=true 5`) the reader returns `$null` and never reads the positional `5`. The outcome is fail-closed (no-number branches), so an authorized merge spelled that way is denied rather than wrongly allowed. | Return only when the equals-joined value parses as a number; otherwise advance the index and continue scanning. Add a case `gh pr merge --merge=true 5` expecting `5`. Apply byte-identically to both copies and mirrors. | Makes the reader consistent with its documented rule that the first non-flag token is the selector. | Source reading |
| Minor | `.claude/hooks/enforce-epic-merge-gate-command.ps1` (and Codex twin) | header comment lines 1-15; `Test-EpicMergeGateApiMutationText` | CR-5 (in-item, same file): the `gh api` scope inspects command text only. A mutation supplied through `-F query=@mutation.graphql` or `--input payload.json` is not detected and is allowed. | Document the limitation in the helper header and add it to the spec's Rollout follow-ups (or `policy-followups.md` if it is treated as a policy item). Optionally fail closed for `gh api graphql` with an `@file` query or `--input`, with a test. | The spec claims the gate covers `gh api` merge and enqueue mutations; the residual route should be stated, not implied closed. | Source reading; spec Data flow table |
| Info | `coverage-comparison.2026-10-16T12-40.md` | "Uncovered changed lines" paragraph | CR-6 (same feature): the recorded cause for the Codex gap is inconsistent with the Codex suite content (see CR-1). | Correct the cause statement in the next ORCH-6 artifact after the diagnosis in CR-1. | Evidence should match observed test content. | Codex suite lines 134-135, 149, 151 |
| Info | `spec.md` | lines 71 and 334 | CR-7 (same feature): the spec lists the cleanup-skill edit as out of scope and as a follow-up, but D10(a) delivered it in-item (`.claude/skills/cleanup-merged-worktrees/SKILL.md:206-212` and mirror). | Record the coordinator-authorized deviation in an evidence note (for example `evidence/other/scope-deviation-d10.<timestamp>.md`) and reference it from the PR body; do not add AC items. | Keeps the planning record consistent with the delivered diff. | `git diff 5bdf22d0f HEAD -- .claude/skills/cleanup-merged-worktrees/SKILL.md` |
| Nit | `ruleset/runbook.md` | line 23 | CR-8 (same feature): the capture step writes `protect-main.live.json` into the tracked feature folder ("Run every command below from this folder"). | Direct the capture to a scratch location or state that the capture file is not committed. | Avoids an untracked or accidentally committed live snapshot. | Runbook lines 11 and 23 |
| Info | `coverage-comparison.2026-10-16T12-40.md` | header | CR-9 (same feature): ORCH-6 records per-file figures but no repository-wide PowerShell line figure. | Record the repository-wide PowerShell line figure from R_final `powershell-coverage.xml` in the next ORCH-6. | The review procedure reports a repository-wide figure per language. | ORCH-6 artifact |
| Info | `tests/scripts/workflows/CiWorkflow.Tests.ps1` | lines 212-239 | CR-10: the call-graph test follows only the reusable workflows that `ci.yml` calls directly. No called workflow calls another today (reviewer search), so the test is accurate now. | No change required; consider a recursive walk if nested reusable workflows are introduced. | Future-proofing only. | `uses: ./.github/workflows` search |
| Info | `.claude/settings.json` | permissions | CR-11 (pre-existing, unrelated to this diff's correctness): the main-session `orchestrate` S9 step 6 now prescribes the merge-confirmation parser, but no project-level allow rule exists for it, as none exists for `Invoke-CiGateParser.ps1`. | No change in this item; the same prompt-or-bypass behavior already applies to the CI-gate parser. | Parity with the existing parser. | `grep Invoke-CiGateParser .claude/settings.json`: no match |

---

## Detailed Review Notes

### Correctness

- Scope predicate: `Test-EpicMergeGateCommandInScope` returns true for any Indeterminate `gh pr merge` match, so wrapper payloads remain gated after removal of the raw-scan fallback; `R2a-C1` and `R2a-X1` (`bash -c "gh pr merge --merge 688"`) still pass on R_final.
- `--disable-auto` exemption requires the absence of every action flag, so `gh pr merge 5 --disable-auto --squash` stays gated.
- REST pattern `(?:^|/)pulls/(\d+)/merge(?:$|[^\w-])` matches `repos/o/r/pulls/5/merge` and rejects `pulls/5/merges`. A read-only `GET pulls/<n>/merge` is also gated; the spec states "(any method)", so this is intended.
- GraphQL mutations carry a node ID, not a number, so they always take the no-number branches; under the parallel and standalone branches that is a deny. This matches the spec.
- `Wait-ForPullRequestMerged`: bounded polls `floor(T/I) + 1`, sleep only between polls, every failure writes one stderr line and returns 1 before checkout. `gh api` `-F owner={owner}` placeholders are resolved by `gh`.
- The release flow does not perform the ancestry check the procedures require; the spec requires only the wait before checkout for the release flow, so this is consistent with AC-14 and AC-15.

### Mirrors and manifests

- 13/13 changed files under `.claude/`, `.codex/`, `.agents/` are byte-identical to their bundle mirrors (reviewer `git hash-object`); the four helper copies share hash `d7dfe732d`.
- Manifest entries: helper in both `core.json` files; parser in the Claude `core.json`.

### Policy constraints

- No edit under `.claude/rules/` or `.github/instructions/`; `policy-followups.md` records the three stale rule lines with verbatim quotes (verified).
- The ruleset is not applied: no code path issues a `PUT` to the rulesets endpoint; the runbook states the user-owned precondition and the expected 422 with fallbacks.

---

## Typed-Python Review

The four Python files are test code. `test_epic_orchestrator_permission_contracts.py` derives both the prescribed `pwsh` invocations and the grants from committed files through shared seam parsers and enforces a cardinality floor of two, so a degenerate parse cannot pass. Pyright reports 0 errors; Ruff and Black are clean. No suppressions were added.

---

## Summary

| Severity | Count | IDs |
|---|---|---|
| Blocker | 1 | CR-1 |
| Major | 0 | - |
| Minor | 4 | CR-2, CR-3, CR-4, CR-5 |
| Nit | 1 | CR-8 |
| Info | 5 | CR-6, CR-7, CR-9, CR-10, CR-11 |

CR-1 is the only blocking finding. CR-2 to CR-9 are in-item (same files or same feature) and are carried into the remediation inputs for the same cycle. CR-10 and CR-11 require no change.
