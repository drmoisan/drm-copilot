# Code Review: Standalone orchestration merge on green (#997)

---

**Review Date:** 2026-10-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997`
**Feature Folder Selection Rule:** the only active feature folder added on the branch; its suffix matches issue #997 in the branch name.
**Base Branch:** `main` (merge base `fd4fe5b2985f3caaaffb60d9dc393584e7750c3a`, equal to `origin/main`)
**Head Branch:** `bug/standalone-orchestration-merge-on-green-997` (`e8d649ac21f6cd2216613ddaccab9b49307568a8`)
**Review Type:** Re-review of the full branch diff after a proportionate remediation cycle (prior review `2026-10-29T17-10`)

---

## Executive Summary

The branch adds a fail-closed green-CI branch (3b) to the merge gate so a standalone orchestration can merge its own pull request after S9 CI is green and the live head equals `ci_gate.head_sha`. The prior review passed. The remediation commit `e8d649ac2` hardened stage C to decline `--admin`, pinned the valueless `--match-head-commit` case with a test, and aligned one `parallel-orchestrate/SKILL.md` sentence with the best-effort disclosure.

This review re-examined the whole branch, with particular attention to the `--admin` decline and to every fail-closed case, using the repository suites and a separate reviewer probe that drives `Invoke-EpicMergeGateDecision` end to end.

**What changed in the remediation cycle:**
- `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`: one line in stage C, `if (Test-CommandLineFlag ... -FlagName '--admin') { return $silent }`, placed after the shape check and before the stage D live-head call; header and `.SYNOPSIS` updated.
- `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`: four rows (`--admin` in the command-shape table; `--admin` with a green checkpoint falling through to the unchanged branch-4 deny; `--squash` and `--rebase` still allow; valueless `--match-head-commit`).
- `orchestrator-state.md` lists `--admin` in condition 1; `parallel-orchestrate/SKILL.md` sentence reworded; spec AC-14 amended; three mirrors refreshed.

**Prior observations, current status:**
1. Low, `--admin` accepted: resolved. Ten spellings decline in the reviewer probe.
2. Low, unparseable parallel checkpoint treated as no record: open, carried forward (within the disclosed best-effort window).
3. Info, valueless pin unpinned: resolved by the new row.
4. Info, absolute-sounding sentence: resolved; the sentence now reads "a parallel child that records them cannot merge ... the exclusion is best-effort when the keys are omitted."
5. Info, AC-32 live check: unchanged; deferred by design.

**Top 3 risks:**
1. The residual parallel-exclusion window (a parallel child that no readable record names and that wrote neither marker key) remains, as disclosed in both hook headers, both rules, and both skills.
2. The control trusts the checkpoint's recorded `ci_gate.conclusion`, the same trust model as branch 1 and the #670 record.
3. Branch 1 accepts any truthy `epic_mode`, including the string `"false"` (pre-existing; see the findings table).

**PR readiness recommendation:** **Go**. No Blocker, Major, or Minor finding. Three Low and one Info observation are recorded below. Merge remains subject to the S9 CI green gate on the final PR head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low | `.claude/hooks/enforce-epic-merge-gate.ps1` (pre-existing code, not edited by the branch) | `Test-ChildCheckpointAllowsEpicMerge` (branch 1), `-not [bool]$Checkpoint.epic_mode` | `[bool]'false'` is `$true` in PowerShell, so a per-feature checkpoint with `epic_mode: "false"` and `step9_status: "passed"` is allowed by branch 1. Branch 3b is never reached for that input. The reviewer probe row "declines fail-closed checkpoint epic_mode string false" returned `allow` through the full gate. | Separate hardening item, or an in-item fix with an AC-17 amendment: accept only a JSON boolean `true` in branch 1 (`$Checkpoint.epic_mode -is [bool] -and $Checkpoint.epic_mode`). | Not introduced by this branch: the function is unchanged from `main`, and AC-17 requires it to stay unedited. The green-CI branch declines the input as AC-11 specifies (pure-function rows). The input grants no access beyond what `epic_mode: true` already grants branch 1, which also checks only `step9_status`. The spec's Risks section names "`epic_mode` handling accepts a truthy string"; its mitigation covers branch 3b only. | Reviewer probe run (scratchpad `AdminProbe.Tests.ps1`); source read of `Test-ChildCheckpointAllowsEpicMerge`; `git diff origin/main...HEAD -- .claude/hooks/enforce-epic-merge-gate.ps1` shows no edit to it. |
| Low | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (consumed, not edited) | `Resolve-WorktreeRunTargetByRecord` skips a checkpoint that `Get-WorktreeRunCheckpoint` cannot parse | Carried forward from the prior review: layers 1a and 1b treat a corrupt parallel-orchestrator checkpoint as no record, so the green branch does not fail closed on it. | No change for this item; a later hardening item could report an unreadable run checkpoint as `Ambiguous` to the green-CI caller. | Inside the disclosed best-effort exclusion; the branch-4 and docs-only callers share the same resolver semantics. | Prior review source read; resolver unchanged by the branch. |
| Low | `docs/features/active/2026-10-29-standalone-orchestration-merge-on-green-997/evidence/` | Remediation-cycle artifacts `*.2026-10-29T18-05.md` to `self-review.2026-10-29T19-30.md`; `qa-gates/file-size.2026-10-29T19-20.md` | The evidence file names and `Timestamp:` fields are later than the remediation commit (13:51:41 -0400, 17:51 UTC) and than this review (17:56 UTC), so they do not record when the runs happened. The file-size artifact records `wc -l`, which the file-size policy does not use. | Future runs: take the timestamp from the UTC clock at write time and measure logical lines with `@(Get-Content -LiteralPath <path>).Count`. No change needed for this item. | The recorded results were reproduced by the reviewer (full-run JUnit 12203/0 failures; coverage 57/57 and 132/132; logical counts 325 and 329 equal the recorded figures), so the evidence content is accurate. | `date -u` at review time; `git show -s e8d649ac2`; reviewer line counts. |
| Info | `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` | `declines --admin combined with a valid green checkpoint ...` | The remediation plan predicted the generic final deny text; the row asserts the `STANDALONE_MERGE_AUTHORIZATION_ABSENT` branch-4 deny. That is the correct observed behavior: the command names PR 42, so branch 4 runs and denies before the final text. The deviation is recorded in `regression-testing/admin-pass-after.2026-10-29T18-15.md`. | None. | The row also asserts no `GREEN_CI` suffix and zero live-head calls, which is the property the plan required. | Source read of `Invoke-EpicMergeGateDecision`; reviewer run. |

No Blocker, Major, or Minor findings. No covered file in the branch diff is at or above 700 lines (largest 476), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- One string appended to `MERGE_ON_GREEN_FRAGMENTS`; not touched by the remediation cycle. The edited `parallel-orchestrate/SKILL.md` sentence is outside the pinned fragments, and `test_parallel_orchestrator_surface_contracts.py` passes at head.

#### Typing and API notes

- Black, Ruff, and Pyright clean (reviewer, at head).

#### Error handling and logging

- Not applicable; a data constant only.

### TypeScript implementation audit

#### What changed well

- Not applicable; no TypeScript file changed.

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- Not applicable.

### PowerShell implementation audit

#### What changed well

- The `--admin` decline uses the shared `Test-CommandLineFlag` parser, which compares tokens after quote stripping and matches both `--admin` and `--admin=<value>`. It reads the tokens of the first structural `gh pr merge` match, and stage C has already rejected chains, wrappers, and prefixes, so the only remaining match is the command itself.
- The decline is silent and sits before stage D, so `gh` is not started and every existing deny text is unchanged. With an explicit PR number the command falls through to branch 4 and receives its unchanged deny.
- The PowerShell `-eq` comparison in `Test-CommandLineFlag` is case-insensitive, so `--ADMIN` also declines. `gh` would reject that spelling, so the decline is conservative.
- Branches 1 to 4, the docs-only branch, and the #670 branch are untouched by the remediation commit.

#### API and safety notes

- `Get-EpicMergeGateGreenCiDecision` still returns `[ordered]@{ Allowed; Suffix }`.
- `--squash` and `--rebase` still allow with a green checkpoint, as the amended AC-14 states; `orchestrate/SKILL.md` S9 issues `--merge` with `--match-head-commit`.

#### Error handling and logging

- Unchanged.

### C# implementation audit

#### What changed well

- Not applicable; no C# file changed.

#### Type safety and API notes

- Not applicable.

#### Error handling and logging

- Not applicable.

---

## Test Quality Audit

The reviewer ran the 12 `enforce-epic-merge-gate*.Tests.ps1` suites and `hook-dependency-failure.SpecialCases.Tests.ps1` at head (317 passed, 0 failed), plus a 34-row adversarial probe in the session scratchpad (not committed).

### Reviewed test and QA artifacts

- `regression-testing/admin-fail-before.2026-10-29T18-05.md`: the two `--admin` rows failed against the pre-fix hook (decision `allow`), and the `--squash`/`--rebase` rows passed. This shows the rows detect the defect.
- `regression-testing/admin-pass-after.2026-10-29T18-15.md`: 33 tests, 0 failures after the fix.
- `regression-testing/valueless-match-head.2026-10-29T18-20.md`: the valueless-pin row passes against unchanged logic.
- `regression-testing/isolation.2026-10-29T19-20.md`: three seeded shuffles of 11 suites, 245 passed each.
- `qa-gates/pester-full.2026-10-29T19-10.md`: 12193 passed, 0 failed; sibling 57/57.

### Reviewer probe results

| Probe group | Rows | Result |
|---|---|---|
| Control: plain `gh pr merge 42 --merge`, green checkpoint | 1 | allow |
| `--admin` spellings: trailing, before `--squash`, before the PR number with `--rebase`, double-quoted, single-quoted, `--admin=true`, `--ADMIN`, after `--`, newline-separated, with a matching `--match-head-commit` | 10 | deny, zero live-head calls |
| Checkpoint: `ci_gate` absent, conclusion `failure`, `step9_status` `pending`, `pr_number` string, `pr_number` 43, `parallel_mode` true, `parallel_slug` set, uppercase head, differing `pr_gate.head_sha`, unparseable, null | 11 | deny |
| Checkpoint: `epic_mode` string `"false"` | 1 | allow through pre-existing branch 1 (Low finding) |
| Command shape: chain, `-R`, `--repo`, `--auto`, `/pull/` URL, `GH_REPO=` prefix, bare, different PR number | 8 | deny |
| Stage D/E: stale head, unresolved head, mismatched pin | 3 | deny with `GREEN_CI_HEAD_STALE`, `GREEN_CI_LIVE_HEAD_UNRESOLVED`, `GREEN_CI_MATCH_HEAD_MISMATCH` |

### Quality assessment prompts

- **Determinism:** fixed synthetic SHAs and roots; no clock, process, or temporary file in the new rows.
- **Isolation:** the new rows reuse suite-level mocks and per-row closures.
- **Speed:** the decision suite runs in about 1.2 s.
- **Diagnostics:** `-Because` carries the reason or the command.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection. |
| No unsafe subprocess or command construction | PASS | `gh` arguments are a fixed array with the integer PR number; stage C runs before stage D. |
| `--admin` declines in 3b | PASS | Two repository rows; ten probe spellings; zero live-head calls. |
| `--squash` and `--rebase` unchanged | PASS | Repository rows allow. |
| Stale head declines | PASS | `GREEN_CI_HEAD_STALE` row and probe. |
| Pending or failed CI declines | PASS | Exact `success` only; repository rows and probe. |
| `step9_status` not passed declines | PASS | Exact `passed` only; repository rows and probe. |
| Unbound or different PR number declines | PASS | Repository rows; probe (string `"42"`, 43). |
| Missing or unparseable checkpoint declines | PASS | Repository rows; probe. |
| Bare command declines | PASS | Repository row asserts the exact final deny text; probe. |
| `gh` failure or timeout declines | PASS | Wrapper rows; `GREEN_CI_LIVE_HEAD_UNRESOLVED` row and probe. |
| Differing or valueless `--match-head-commit` declines | PASS | `GREEN_CI_MATCH_HEAD_MISMATCH` rows, including the new valueless row. |
| `epic_mode` non-boolean declines in 3b | PASS | Pure-function rows. Through the full gate, the string `"false"` is allowed by pre-existing branch 1 (Low finding). |
| Parallel child declines when recorded | PASS | Layers 1a, 1b, 2 rows; probe (`parallel_mode`, `parallel_slug`). |
| Parallel exclusion described as best-effort | PASS | The reworded `parallel-orchestrate/SKILL.md` sentence now matches the hook headers, both rules, and `orchestrate/SKILL.md`. |
| Branches 1 to 4, docs-only, and #670 unchanged | PASS | Remediation diff touches only stage C; regression suite and unchanged `enforce-epic-merge-gate.Tests.ps1` pass. |
| Hook dependency failure fails closed | PASS | Row C9 in the reviewer run. |
| Mirrors byte-identical | PASS | `cmp`, 6 of 6. |

---

## Research Log

No external research was required. The review relied on the branch diff, the remediation plan, the spec, the evidence folder, the consumed helpers (`hook-command-invocation-operands.ps1`, `hook-docs-only-diff.ps1`, `WorktreeRunResolution.psm1`), and repository policy files.

---

## Verdict

The change is ready for the normal PR flow. The remediation commit closes the `--admin` acceptance with a minimal, correctly placed decline that leaves every existing deny text and branch unchanged, and the new rows were shown to fail before the fix. Every fail-closed case of branch 3b declines. The one probe row that reached `allow` did so through pre-existing branch 1, which the spec requires to remain unedited; it is recorded as a Low finding for a hardening decision rather than as a defect of this branch. Merge remains subject to the S9 CI green gate on the final PR head.
