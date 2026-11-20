# Code Review — prd-feature gate target resolution (Issue #672)

- Timestamp: 2026-09-17T15-01
- Review cycle: 2 (re-review after the cycle-1 remediation)
- Feature folder: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672`
- Base branch: `epic/worktree-scoped-state-resolution-integration` @ `d039e89b2b2569151e9170e1bbefb9f974419f87`
- Head: `d6e5adb959b8e74d8acbf3278501bf75b07fac8e`
- Languages in scope: PowerShell only. The branch diff contains zero TypeScript, Python, and C# source files.

## Executive Summary

The remediation improved the design rather than patching around the finding. Deleting the
absolutely-placed-token pre-filter removed a local policy decision from the hook and left the resolution
module as the single owner of what counts as a placeable signal, which closes the cycle-1 blocking finding
and the cycle-1 non-blocking finding R3 with one edit. The delivered hook is shorter and more linear at the
decision seam than it was at cycle 1, and its comment-based help now matches the code it documents.

Correctness was checked by execution, not by inspection. Six end-to-end runs of the hook as a child
process, against the real filesystem with no mocks, confirm the four decision states the spec specifies:
allow on an absolute citation into another worktree, allow when the target is the session root, the
folder-absent ambiguity reason on a composed probe path, and the zero-candidate ambiguity reason on a
repo-relative citation that places nowhere. The work-mode-marker reason is no longer reachable from a
resolution failure, which was the substance of the blocking finding.

Four non-blocking findings remain, all documentation-accuracy or observation class. The most substantive is
N1: the pre-filter's removal means the hook now performs unbounded filesystem work inside the resolution
module on every delegation that carries a placeable signal, measured at 85.6 ms average and 180.4 ms
maximum in this host's 73-worktree topology, while the spec still asserts that filesystem access "remains
bounded by the same three seams". The cost is the correct price for closing the finding; the stale claim is
what needs correcting.

No blocking finding is recorded. No change is requested inside this branch.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md` | lines 426-430 | The performance statement "Filesystem access remains bounded by the same three seams" no longer describes the delivered behaviour. Removing the pre-filter routes every delegation carrying a placeable signal into the resolution module, which enumerates every worktree reachable from the session root and probes one path per worktree for a repo-relative token. | Amend the performance section to state that the derivation's filesystem cost scales with the worktree count, and record the measured figures. Consider whether the resolution module should memoise its enumeration per process; that decision belongs to the module's owner, not to this hook. | A performance claim that understates synchronous cost in a PreToolUse path is load-bearing for anyone later diagnosing delegation latency, and the scaling factor grows over the life of an epic. | Measured in-process over 5 iterations per shape: repo-relative citation 85.6 ms average, 180.4 ms maximum; absolute citation 13.6 ms average; no signal 3.7 ms average. `Get-WorktreeResolutionWorktreeRoot` enumerated 73 worktrees from the coordinating session root. |
| Minor | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | lines 19-21 | The header determinism statement claims no absolute path is derived from "the script file location", which the suite's own four `$PSScriptRoot` derivations contradict. | Narrow the sentence to the modelled values, in the same pass that narrows acceptance criterion 30. The wording proposed in `evidence/other/remediation-scope-decisions.2026-09-17T13-56.md` is accurate and can be reused. | The claim is the in-code twin of criterion 30. Leaving one corrected and the other not would leave the inaccuracy in the place a future reader is most likely to trust it. | Lines 99, 100, 109, and 110 each call `Resolve-Path "$PSScriptRoot/..."`. The four derivations are necessary and correct; only the prose is over-broad. |
| Minor | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | `BeforeAll`, line 13 and line 27 respectively | Both sibling suites now install a `Describe`-scope blanket mock of `Resolve-WorktreeCallTarget` returning a fixed `NoTarget` result, so neither suite can observe a derivation regression. | No change requested. If the derivation surface grows, prefer per-`Context` mocks so a future case can vary the status without lifting a `Describe`-scope default. | The mock is documented in place and is sound for suites that pre-date target resolution and assert the no-target behaviour. The repository's blanket-mock prohibition is scoped to existence mocks, which these are not. | The whole derivation surface therefore rests on the `TargetResolution` suite's 28 nodes, of which 8 exercise the derivation seam directly. |
| Minor | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | `.DESCRIPTION` step 1, lines 15-22 | The help block describes the derivation's states accurately but does not record that a repo-relative citation resolves only when the folder exists under exactly one worktree, which is a condition no active feature folder in this checkout satisfies. | Add one sentence to step 1 naming that condition, so a reader of the help block learns the same thing the deny text tells a caller at run time. | The deny reason already prescribes the absolute form, so the behaviour is discoverable at run time. The help block is where a maintainer looks first, and it currently implies a broader reach for the repo-relative form than the topology allows. | Scanning all 52 folders under `docs/features/active/` against a coordinating session root, zero place uniquely; this feature's own folder matches 9 worktrees. |

## Cycle-1 Findings — Closure Review

| Cycle-1 finding | Cycle-1 severity | Cycle-2 verdict | Basis |
|---|---|---|---|
| R1 — the repo-relative citation path is unchanged by the fix | Blocking | CLOSED | Option A applied. The pre-filter tokens return a count of 0, and six end-to-end executions of the delivered hook show the ambiguity reason where the marker reason previously appeared. |
| R2 — stale comment-based help on the parent hook | Major | CLOSED | Both stale tokens return a count of 0; the rewritten seven-step block matches the delivered branch order. |
| R3 — derivation policy living in the hook narrows the F1 contract | Major | CLOSED | The eligibility decision was deleted with the pre-filter, leaving one owner. The resolution module needed no change because it already implemented the placement filter the predicate had short-circuited. |
| R4 item 1 — helpers description overstates "declarations only" | Minor | CLOSED | The sentence now names the one file-scope import and its fail-closed rationale. |
| R4 item 2 — criterion 30's over-broad determinism clause | Minor | DEFERRED, accepted in reasoning | The refusal to re-word an approved criterion is correct and is adopted. The checkbox state is not: the criterion is evaluated PARTIAL and reverted to unchecked by this review, with the wording decision routed to the spec owner. |

## Design and Implementation Notes

**The remediation removed code rather than adding a special case.** The cycle-1 hook held a predicate that
decided which citations were eligible to reach the derivation. That predicate was both a duplicated policy
decision and the mechanism of the defect, because it suppressed the two signal channels — `Branch` and
relative `FilePath` — that can place a repo-relative call. Deleting it is the smaller and more honest
change, and it is why one edit closes two findings. The replacement comment on
`Get-PrdFeatureCallTarget` states the new contract plainly: eligibility is the derivation's decision, the
outcome is fail-closed, and a call that places in no worktree or in several denies before any probe runs.

**The fail-closed ordering is correct and is asserted.** The ambiguity branch returns before
`Find-PrdFeatureFolderCandidate` runs, and the suite pins that with a zero-invocation count on
`Get-PrdFeatureFileExistence`. The two allow rows pin exact positive counts of 1 and 2 against their work
modes, so an implementation that returned `allow` without probing would fail. This is the guard set the
spec's risk R1 calls for, and it is the right emphasis: the change converts a visible stall into a decision
that can be wrong in the permissive direction, so the probe counts matter more than the decision values.

**The folder-absent guard is still conditioned on the composed path differing from the bare one.** At line
393 the guard fires only when `$probeFolder -ne $folderNormalized`, which is true only for the
`OtherWorktree` status. That was the mechanism cycle-1 identified as leaving the marker reason reachable.
It remains conditioned the same way, and it is now sufficient, because a repo-relative citation that cannot
be placed never reaches this line: it is denied earlier by the derivation's own ambiguity branch. Execution
row E1 confirms the earlier branch fires and row E5 confirms the guard fires on the composed path. The
narrow condition is therefore correct rather than incidentally survived, but it depends on the derivation
continuing to answer `Ambiguous` for an unplaceable relative token. That coupling is worth remembering if
the derivation's zero-candidate behaviour is ever softened.

**The extraction is faithful.** `Resolve-PrdFeatureWorkMode` and `Get-PrdFeatureRequiredFile` are
byte-identical to their base-branch forms, confirmed by extracting the base file at the merge base and
diffing the moved region. The parent retains exactly the three seams the existing suites mock, and the
sibling declares no parameter block, no requires directive, and no entrypoint. Its one file-scope statement
is the resolution-module import, which is now documented as such.

**Comment density and rationale quality are above the repository norm.** Each branch in the decision
function carries a comment explaining why the branch exists rather than what it does — for example, that a
checkpoint belongs to the session that wrote it, so letting it choose between two cited folders would
validate the call against a sibling session's record. That is the useful form of comment, and it is the
reason this change set reads clearly despite touching a gate with four decision states.

## Test Quality Assessment

| Dimension | Assessment | Evidence |
|---|---|---|
| Fail-before evidence | Adequate | `evidence/regression-testing/prefilter-removal.2026-09-17T13-56.md` and `fail-before-remediation.2026-09-17T13-56.md` record pre-remediation controls for the three new rows. |
| Assertion specificity | Strong | Deny rows assert on the reason class and additionally assert the absence of the competing reason, with `Should -Not -BeLike '*work mode could not be determined*'` appearing on both ambiguity rows. |
| Invocation-count discipline | Strong | Zero-count guards on both ambiguity paths; exact counts of 1 and 2 on the allow rows; a `-Times 1 -Exactly` assertion that the derivation is reached on a branch-signal call and `-Times 0 -Exactly` that it is not reached on an empty-text call. |
| Data-driven row design | Strong | Two `-ForEach` arrays declared at discovery scope with run-time copies in `BeforeAll`, which is the correct Pester 5 form. |
| Isolation of the derivation | Adequate with a caveat | The new rows mock `Resolve-WorktreeCallTarget`, so they verify the hook's handling of a modelled placement rather than the module's real placement of a relative token. That is correct unit isolation, and the end-to-end gap is what this review's own executions cover. |
| Determinism | Strong | Every synthetic root is a bare string literal; the modelled current directory is data. No temporary file, no working-directory change, no wall-clock or randomness read. |
| Suite size discipline | Adequate | 499 lines against a 500-line cap leaves one line of headroom. Any further row will force a fourth suite or a split, which the header's own placement rationale anticipates. |

Note on the last row: one line of headroom is not a defect today, but it is a maintenance fact worth
stating plainly. The next case added to this file cannot be added to this file.

## Verdict

**No blocking findings.** The cycle-1 blocking finding is closed on executed evidence. Four non-blocking
findings are recorded, none of which gates the pull request. Recommendation: proceed to PR, and route the
criterion-30 wording decision and finding N1's spec correction to the spec owner as a documentation pass,
together with the N2 twin in the suite header.
