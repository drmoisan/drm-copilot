# [P13-T9] Final acceptance-criteria traceability review

Timestamp: 2026-09-07T17-25

Command:

```
# AC source resolution
grep -n "Work Mode" issue.md                       # -> "- Work Mode: full-bug", so spec.md is the sole AC source
sed -n '1451,1649p' spec.md                        # the "## Acceptance Criteria" section, 37 checkbox items
grep -c "^- \[x\]" / grep -c "^- \[ \]" over that range   # checkbox tally
# evidence-path existence confirmed by directory listing of evidence/{baseline,qa-gates,regression-testing,other,issue-updates}
```

EXIT_CODE: 0

**AC source resolution.** `issue.md` line 12 carries `- Work Mode: full-bug`. Per the
acceptance-criteria-tracking mode table, `full-bug` resolves the AC source to `spec.md` **only**.
`user-story.md` exists in the feature folder but is not an AC source under this mode and no
checkbox in it is treated as an acceptance criterion.

## Row count and tally

`spec.md` `## Acceptance Criteria` (lines 1451 to 1649) holds **37** checkbox items. Before this
task the tally was 29 checked and 8 unchecked. This task checks off 4 of those 8 and leaves 4
unchecked, each for a stated reason. Final tally after this task: **33 checked, 4 unchecked**, two
of which are scheduled to close in [P13-T10] and [P13-T11] immediately after this task.

## Traceability table, all 37 criteria

Every row carries at least one task identifier and at least one evidence artifact path. Every path
below was confirmed present on disk by directory listing at the time this artifact was written. Paths
are relative to
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/`.

| AC | Subject | Tasks | Evidence artifact (exists on disk) | Status |
|---|---|---|---|---|
| AC-01 | over-match regression recorded failing | [P1-T4], [P1-T5], [P1-T6], [P1-T7], [P1-T8], [P1-T9], [P1-T10], [P1-T11] | `evidence/regression-testing/fail-before-claude-triggerscoping.2026-09-07T11-40.md` | **PASS** |
| AC-02 | under-match regression recorded failing | [P1-T4], [P1-T5], [P1-T6], [P1-T7] | `evidence/regression-testing/fail-before-codex-triggerscoping.2026-09-07T11-44.md` | **PASS** |
| AC-03 | both regressions pass after the fix, both sides | [P5-T3], [P5-T7], [P13-T8] | `evidence/regression-testing/pass-after-both-directions.2026-09-07T17-22.md` | **PASS**, checked off by this task |
| AC-04 | scanner segment properties and heredoc cases | [P2-T1], [P2-T3], [P2-T4] | `evidence/qa-gates/batch-b1-toolchain.2026-09-07T12-26.md` | **PASS** |
| AC-05 | scan-text selection and wrapper-set membership | [P2-T1], [P2-T3], [P2-T4] | `evidence/qa-gates/batch-b1-toolchain.2026-09-07T12-26.md` | **PASS** |
| AC-06 | structural relocation classifier, six steps | [P3-T1], [P3-T3], [P3-T4] | `evidence/qa-gates/batch-b2-toolchain.2026-09-07T12-45.md` | **PASS** |
| AC-07 | trigger literals byte-unchanged | [P5-T1], [P6-T1], [P7-T1], [P10-T3], [P12-T3] | `evidence/qa-gates/trigger-literals-byte-unchanged.2026-09-07T15-50.md` | **OPEN ADJUDICATION**, left unchecked |
| AC-08 | every D3 row has a named case per side | [P1-T4], [P1-T6], [P12-T12] | `evidence/qa-gates/d3-row-test-mapping.2026-09-07T16-08.md` | **PASS** |
| AC-09 | no existing denial weakened | [P1-T12], [P12-T13] | `evidence/qa-gates/deny-preservation-audit.2026-09-07T16-11.md` | **PASS** |
| AC-10 | issue #539 exemption layer unchanged | [P5-T1], [P12-T14] | `evidence/qa-gates/539-exemption-layer-unchanged.2026-09-07T16-12.md` | **PASS** |
| AC-11 | promotion hook changed in all four copies | [P6-T1], [P6-T2], [P6-T3], [P6-T5], [P6-T6], [P6-T7] | `evidence/qa-gates/batch-b8-toolchain.2026-09-07T13-52.md` and `evidence/qa-gates/batch-b9-toolchain.2026-09-07T14-02.md` | **PASS** |
| AC-12 | `enforce-pr-author-skill-helpers.ps1` both Claude copies | [P7-T1], [P7-T2], [P7-T3] | `evidence/qa-gates/batch-b10-toolchain.2026-09-07T14-04.md` | **PASS** |
| AC-13 | parser is two dot-sourced `.ps1` files in eight locations | [P2-T1], [P2-T2], [P2-T5], [P3-T1], [P3-T2], [P3-T6], [P4-T1], [P4-T2], [P4-T4], [P4-T5] | `evidence/qa-gates/scope-and-size.2026-09-07T15-46.md` | **PASS** |
| AC-14 | registration set complete at fourteen entries | [P4-T7], [P4-T8], [P4-T9], [P4-T10], [P4-T11], [P4-T12] | `evidence/qa-gates/registration-inventory.2026-09-07T12-55.md` | **PASS** |
| AC-15 | both parity mechanisms green in the same change | [P4-T13], [P4-T15], [P12-T5], [P13-T5], [P13-T6], [P13-T10] | `evidence/qa-gates/parity-mechanisms.2026-09-07T15-57.md`, `evidence/qa-gates/final-python-contracts.2026-09-07T17-14.md`, `evidence/qa-gates/final-codex-contract-suite.2026-09-07T17-18.md` | **SATISFIED, check-off deferred to [P13-T10]** |
| AC-16 | recomputed pair-hash parity at the final commit | [P12-T4] | `evidence/other/pair-hash-parity.2026-09-07T15-52.md`, confirmed current by `evidence/qa-gates/final-poshqc-format.2026-09-07T17-03.md` | **PASS** |
| AC-17 | every touched or added file at or under 500 lines | [P2-T5], [P2-T6], [P3-T6], [P4-T14], [P7-T10], [P12-T7], [P13-T6] | `evidence/qa-gates/line-cap-inventory.2026-09-07T16-00.md` and `evidence/qa-gates/final-codex-contract-suite.2026-09-07T17-18.md` | **PASS**, checked off by this task |
| AC-18 | line coverage at or above 85 on every changed production file | [P0-T9], [P4-T10], [P4-T11], [P12-T8], [P12-T9], [P12-T10], [P13-T4] | `evidence/qa-gates/final-per-file-coverage.2026-09-07T17-13.md`, `evidence/qa-gates/coverage-remediation.2026-09-07T16-46.md`, `evidence/qa-gates/coverage-delta.2026-09-07T17-00.md` | **PASS**, checked off by this task |
| AC-19 | no Python introduced | [P12-T6] | `evidence/qa-gates/no-python-scan.2026-09-07T15-58.md` | **PASS** |
| AC-20 | issue #539 spec annotated additively at five locations | [P11-T1] through [P11-T6] | `evidence/qa-gates/539-spec-additive-only.2026-09-07T15-40.md` | **PASS** |
| AC-21 | all nine hooks carry a diff across their full copy sets | [P12-T1], [P12-T2] | `evidence/qa-gates/nine-hook-copy-set-coverage.2026-09-07T15-46.md` | **PASS** |
| AC-22 | issue #591 recorded as superseded; **the PR body states it** | [P11-T7] | `evidence/issue-updates/issue-591.2026-09-07T15-41.md` | **BLOCKED on the PR body**, left unchecked |
| AC-23 | PoshQC toolchain passes clean in a single pass | [P13-T1], [P13-T2], [P13-T3], [P13-T11] | `evidence/qa-gates/final-poshqc-format.2026-09-07T17-03.md`, `evidence/qa-gates/final-poshqc-analyze.2026-09-07T17-05.md`, `evidence/qa-gates/final-selfhosted-test.2026-09-07T17-11.md` | **SATISFIED, check-off deferred to [P13-T11]** |
| AC-24 | manual replay recorded | [P12-T11] | `evidence/qa-gates/manual-replay.2026-09-07T16-05.md` | **PASS** |
| AC-25 | promotion-hook `gh` relocation closes in all four copies (AT-5) | [P6-T1], [P6-T3], [P6-T5], [P6-T7], [P6-T9] | `evidence/regression-testing/pass-after-at3-at5.2026-09-07T14-06.md` | **PASS** |
| AC-26 | AT-1 denies | [P1-T2], [P1-T3], [P8-T1], [P8-T3], [P8-T14] | `evidence/regression-testing/pass-after-at1-at7.2026-09-07T14-31.md` | **PASS** |
| AC-27 | AT-2 returns `688` | [P1-T2], [P1-T3], [P9-T1], [P9-T3], [P9-T11] | `evidence/regression-testing/pass-after-at2-at4.2026-09-07T15-06.md` | **PASS** |
| AC-28 | AT-4 allows | [P1-T2], [P1-T3], [P9-T1], [P9-T3], [P9-T11] | `evidence/regression-testing/pass-after-at2-at4.2026-09-07T15-06.md` | **PASS** |
| AC-29 | AT-6 still denies, in the same suite | [P1-T2], [P5-T9], [P13-T7] | `evidence/regression-testing/pass-after-acceptance-cases.2026-09-07T17-20.md`, `evidence/regression-testing/pass-after-at6-deny-preservation.2026-09-07T13-41.md`, `evidence/qa-gates/deny-preservation-audit.2026-09-07T16-11.md` | **PASS**, checked off by this task |
| AC-30 | AT-7 closes the cross-runtime divergence | [P1-T2], [P8-T3], [P8-T8], [P8-T12], [P8-T13], [P8-T14] | `evidence/regression-testing/pass-after-at1-at7.2026-09-07T14-31.md` | **PASS** |
| AC-31 | `validate-bash.ps1` matching primitive with AT-8, AT-9, AT-10 | [P10-T1] through [P10-T6], [P10-T8], [P10-T9], [P10-T10], [P12-T3] | `evidence/regression-testing/pass-after-validate-bash.2026-09-07T15-14.md` | **PASS** |
| AC-32 | `enforce-parallel-abandon-gate.ps1` with AT-11 and AT-12 | [P10-T12], [P10-T13], [P10-T14], [P10-T15], [P10-T16] | `evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md` and `evidence/qa-gates/batch-b19-toolchain.2026-09-07T15-32.md` | **PASS** |
| AC-33 | `enforce-pr-author-skill.epic-base-branch.ps1` both Claude copies | [P7-T5], [P7-T6], [P7-T7], [P7-T8] | `evidence/regression-testing/pass-after-epic-base-branch-existing-suite.2026-09-07T14-07.md` | **PASS** |
| AC-34 | Codex merge gate does not acquire the Claude copy's defect | [P9-T6], [P9-T9] | `evidence/qa-gates/codex-merge-gate-no-digit-scan.2026-09-07T14-59.md` | **PASS** |
| AC-35 | D12 parser contract documented and honoured | [P3-T1], [P3-T5] | `evidence/qa-gates/batch-b2-toolchain.2026-09-07T12-45.md` | **PASS** |
| AC-36 | `Test-CommandLineFlag` serves all three presence-only call sites | [P3-T1], [P3-T3], [P7-T1], [P8-T1], [P8-T10], [P9-T1], [P12-T15] | `evidence/qa-gates/test-commandlineflag-call-sites.2026-09-07T16-13.md` | **PASS** |
| AC-37 | the two D11.6 follow-ups filed as separate potential entries | [P11-T8], [P11-T9] | `evidence/qa-gates/scope-and-size.2026-09-07T15-46.md` group 6, which enumerates `docs/features/potential/2026-09-07-codex-preimplementation-gate-modes-module-unregistered.md` and `docs/features/potential/2026-09-07-parallel-abandon-equals-joined-disposition-runtime-confirmation.md`, both confirmed present | **PASS** |

37 rows. Every row carries at least one task identifier and at least one evidence artifact path that
exists on disk.

## AC-32's AT-12 row, per D11.6

D11.6 forbids marking AT-12 satisfied until the equals-joined bypass is confirmed by an **executed**
run rather than derived from `argparse` semantics. That run exists: [P10-T12] drove
`Test-ParallelAbandonCommandInScope` with the equals-joined spelling against the unfixed hook and
recorded the returned value in
`evidence/regression-testing/at12-runtime-confirmation.2026-09-07T15-25.md`. AC-32 is therefore
marked satisfied on an executed-run basis, not a derived one.

## The four criteria left unchecked, each with its reason

### AC-07 — trigger literals byte-unchanged: OPEN ADJUDICATION, referred to feature-review

This criterion is **not** checked off, and it is not left unchecked because the work is incomplete.
It is left unchecked because the specification and the plan state two requirements that cannot both
hold, and resolving the conflict is not the executor's call.

- **What the spec requires.** AC-07 requires that the pr-author hook's `gh pr create` and
  `gh pr edit` expressions be **byte-unchanged**.
- **What the plan directs.** [P7-T1] directs replacing those expressions with a call to
  `Test-CommandLineInvocation`. That function takes no pattern operand, so there is no place for the
  literals to survive as operands. Replacing the expressions necessarily removes them.
- **Why both cannot hold.** A literal that has been replaced by a call taking no pattern operand
  does not exist in the file, so it cannot be byte-unchanged. The two readings are mutually
  exclusive; this is not a matter of degree.
- **What was delivered.** The delivered state satisfies [P7-T1]. The pr-author trigger decision now
  evaluates through `Test-CommandLineInvocation`, which is what AC-12 requires and what closes the
  under-match defect the spec's D6 declares in scope.
- **What is recorded.** `evidence/qa-gates/trigger-literals-byte-unchanged.2026-09-07T15-50.md`
  records the byte-unchanged inspection for the literal sets that **did** survive: the five
  preimplementation-gate patterns, the promotion hook's four forbidden-token literals and its two
  `gh` expressions, the six `validate-bash.ps1` denylist literals, and the two
  `enforce-parallel-abandon-gate.ps1` token constants. Those are unchanged. The pr-author
  expressions are the sole part of AC-07 that the delivered state does not satisfy as written.

**Referred to feature-review** to adjudicate whether AC-07's pr-author clause should be amended to
match D6 and [P7-T1], or whether the pr-author change should be reworked to preserve the literals.
It is deliberately not resolved in the plan's favour here.

### AC-22 — issue #591 supersession stated in the PULL REQUEST BODY: blocked on the PR

The supersession text is written and recorded at
`evidence/issue-updates/issue-591.2026-09-07T15-41.md`, and no separate follow-up candidate was
filed for the merge-gate, worktree-removal, abandon-gate, or `validate-bash` instances, because D11
delivers all four here. The clause this criterion cannot yet satisfy is the last sentence: **the
pull-request body states the supersession and names issue #591.** No pull request exists for this
branch yet, so no PR body exists to carry that statement.

This is blocked on the PR body, not on any code change and not on any missing evidence. It becomes
satisfiable the moment the PR is authored with the recorded text in its body.

### AC-15 — both parity mechanisms green: check-off deferred to [P13-T10]

Every component is already green and recorded: the Codex byte-identity `It` and the shared-module
pack-manifest `It` both pass in
`evidence/qa-gates/final-codex-contract-suite.2026-09-07T17-18.md` ([P13-T6]), and
`test_push_down_claude_resource_contracts.py` passes in
`evidence/qa-gates/final-python-contracts.2026-09-07T17-14.md` ([P13-T5]). The remaining component
is the pair of bundled-tree pack-manifest completeness suites, which [P13-T10] re-runs as the very
next task. The check-off is held until that run is recorded rather than anticipated.

### AC-23 — PoshQC toolchain clean in a single pass: check-off deferred to [P13-T11]

The three stages have each run and each passed: format with a set-difference count of 0
(`final-poshqc-format.2026-09-07T17-03.md`), analyze with 0 diagnostics at or below the [P0-T6]
baseline (`final-poshqc-analyze.2026-09-07T17-05.md`), and test with the carve-out satisfied
(`final-selfhosted-test.2026-09-07T17-11.md`). The clause this criterion turns on is **single
pass**, which is a claim about the sequence rather than about any one stage, and [P13-T11] is the
task that records it with the supporting timestamps. The check-off is held until that record exists.

## Output Summary

37 acceptance criteria reviewed against `spec.md`, the sole AC source under `full-bug` work mode.
Every row carries at least one task identifier and at least one evidence artifact path confirmed
present on disk. **4 criteria checked off by this task: AC-03, AC-17, AC-18, AC-29.** Tally moves
from 29/37 to 33/37. **4 remain unchecked:** AC-07 as an open adjudication referred to
feature-review because the spec's byte-unchanged clause and the plan's [P7-T1] direction cannot both
hold; AC-22 blocked on a pull-request body that does not yet exist; AC-15 satisfied but deferred to
[P13-T10]; AC-23 satisfied but deferred to [P13-T11]. AC-32's AT-12 row is marked satisfied on the
basis of the [P10-T12] executed run, as D11.6 requires.
