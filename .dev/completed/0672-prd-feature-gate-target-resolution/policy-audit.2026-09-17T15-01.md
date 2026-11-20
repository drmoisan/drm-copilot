# Policy Compliance Audit — prd-feature gate target resolution (Issue #672)

- Timestamp: 2026-09-17T15-01
- Review cycle: 2 (re-audit after the cycle-1 remediation)
- Feature folder: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672`
- Work mode: `full-bug` (marker read from `issue.md` line 12, `- Work Mode: full-bug`)
- Acceptance-criteria source: `spec.md` only
- Base branch: `epic/worktree-scoped-state-resolution-integration`, resolved to `origin/epic/worktree-scoped-state-resolution-integration`
- Merge base: `d039e89b2b2569151e9170e1bbefb9f974419f87`
- Head: `d6e5adb959b8e74d8acbf3278501bf75b07fac8e` on `feature/2026-09-13-prd-feature-gate-target-resolution-672`
- Diff scope: 89 files changed across 16 commits; 9 code and settings files, 80 markdown documents
- Cycle-1 artifacts re-audited: `policy-audit.2026-09-17T12-29.md`, `code-review.2026-09-17T12-29.md`, `feature-audit.2026-09-17T12-29.md`, `remediation-inputs.2026-09-17T12-29.md`

## Executive Summary

The cycle-1 blocking finding is closed. The remediation selected Option A and deleted the
absolutely-placed-token pre-filter, so the assembled call text now reaches `Resolve-WorktreeCallTarget`
unconditionally. That was confirmed by executing the delivered hook as a child process through its real
entrypoint, against the real filesystem and with no mocks: a repo-relative citation whose folder exists in
no worktree now denies with `TARGET_WORKTREE_AMBIGUOUS` and an actionable remedy, where the pre-change hook
denied with the work-mode-marker reason that would have sent the caller to edit another repository's
`issue.md`. The false-approval mode recorded as cycle-1 diagnostic D5 is closed by the same edit.

All seven remediation gates were re-measured independently and all seven hold. Formatter drift is zero on
all seven changed `.ps1` files, analyzer findings are zero, both repository-to-bundle SHA-256 pairs are
equal, per-file line coverage is 90.72 percent and 96.77 percent against an 85 percent threshold, the
repository-wide JUnit failure set is exactly the two pre-existing environment-coupled nodes with `errors`
at 0, and the evidence-location validator exits 0. The new `TargetResolution` suite measures 499 physical
lines against the 500-line cap.

Zero blocking findings remain. Four non-blocking findings are recorded, all documentation-accuracy or
observation class. One acceptance criterion moves to PARTIAL: criterion 30's literal wording is
contradicted by the delivered suite, and the executor's deferral of the re-wording is accepted as correct
in its reasoning while the criterion's checkbox state is not. Criterion 37 remains legitimately
unsatisfiable in this worktree and stays unchecked.

**PR readiness: GO.**

## Rejected Scope Narrowing

None detected. The delegating prompt supplied the resolved base branch, the merge-base SHA, the branch
head, the refreshed PR-context artifact paths, and the instruction "apply no scope narrowing relative to
the first review". It directed specific verifications rather than restricting the audit surface, and it
asserted no language to be out of scope. No instruction attempted to limit the audit to a plan, task,
phase, or file subset. The audit was performed against the full branch diff versus
`d039e89b2b2569151e9170e1bbefb9f974419f87`.

Base-branch reconciliation, recorded because two values are in play. The local ref
`epic/worktree-scoped-state-resolution-integration` has advanced to `79fd5a95` in this checkout, so
`git merge-base HEAD epic/...` answers `79fd5a95`. The authoritative base is the remote-tracking ref the
PR-context artifact resolved, `origin/epic/worktree-scoped-state-resolution-integration @ d039e89b`, which
equals the supplied merge base and is an ancestor of the head. The wider of the two ranges was audited.

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0 with no reported
path.

Every evidence artifact added by this branch is under the canonical `<FEATURE>/evidence/<kind>/` scheme.
The branch diff contains zero files under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`,
`artifacts/qa-gates/`, `artifacts/evidence/`, or `artifacts/coverage/`. Kinds used: `baseline/` (7 files),
`other/` (14), `qa-gates/` (25), `regression-testing/` (14), `remediation-baseline/` (6). All five are
canonical kinds per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

Verdict: **PASS**.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Every input is injected as data. The three prd-feature suites report 47, 25, and 28 nodes with zero failures inside a 4761-node repository-wide run, and the same per-suite results appear in the executor's per-suite run. |
| Isolation | PASS | Each `It` targets one decision path or one helper function. |
| Fast execution | PASS | The repository-wide run completes in 150.4 seconds for 4761 nodes; the three prd-feature suites are a small fraction of that. |
| Determinism | PASS | No wall-clock read, sleep, GUID, temporary-file, `TestDrive`, or working-directory change appears in the three suites. Synthetic worktree roots are bare string literals; the modelled current directory is carried on an injected `SessionRoot` member. |
| Readability | PASS | Case names state the decision and the condition; each row carries a rationale comment. |
| Scenario completeness | PASS | Allow, three distinct deny reasons, four work modes, two path forms, two modelled roots, payload anomaly, and indeterminate marker are all covered. |
| Arrange-Act-Assert | PASS | Every case arranges mocks and payload, invokes the decision, then asserts. |
| No external dependencies | PASS | All three filesystem seams are mocked in every case that reaches them, and the derivation seam is mocked where a case must fix its outcome. |
| No temporary files | PASS | Confirmed by reading all three suites end to end. |
| Test file location mirrors source | PASS | `tests/scripts/claude-hooks/` mirrors `.claude/hooks/`. |
| Coverage exclusion policy | PASS | The new production file was added to `CodeCoverage.Path` in both copies of `pester.runsettings.psd1`. No production path is excluded, and `CodeCoverage.Path` is an allow-list rather than an `exclude` list. |

### 1.2 Coverage Metrics

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| PowerShell | 9 | 100 across the three prd-feature suites; 4761 repository-wide | 100 passed / 0 failed in scope; 4759 passed / 2 failed repository-wide | 95.65% repository-wide line | 95.66% repository-wide line | 96.77% line on the new helpers file |
| TypeScript | 0 | N/A | N/A | N/A | N/A | N/A |
| Python | 0 | 17 delivery-contract tests | 17 passed / 0 failed | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

Coverage evidence checklist:

- TypeScript baseline coverage artifact: N/A — the branch diff contains zero TypeScript files.
- TypeScript post-change coverage artifact: N/A — the branch diff contains zero TypeScript files.
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/baseline/baseline-poshqc-test.2026-09-17T10-34.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, re-parsed independently during this audit
- Per-language comparison summary: PowerShell is the sole language with changed files and its disposition is PASS; the other three languages have zero changed files on this branch.

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.65% repository-wide line (9333 covered of 9757). Post-change: 95.66% repository-wide line (9386 covered of 9812). Change: +0.01 percentage points. New/changed-code coverage: 96.77% line on `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` and 90.72% line on `.claude/hooks/enforce-prd-feature-before-planner.ps1`. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, report-level `counter type="LINE"` element and the two per-file `sourcefile` nodes, each matching exactly once.
- TypeScript: N/A — zero changed files in the branch diff.
- Python: N/A — zero changed files in the branch diff.
- C#: N/A — zero changed files in the branch diff.

Threshold application. The uniform tier rule in `.claude/rules/quality-tiers.md` requires line coverage at
or above 85 percent, and branch coverage at or above 75 percent for branch-capable languages. PowerShell is
not branch-capable under Pester: the coverage report carries zero `BRANCH` counter elements for both
delivered files, so no branch figure exists and none is recorded as a failure, per
`.claude/rules/powershell.md`. Both delivered production files clear the line threshold.

Artifact currency. The coverage report was written at 14:32:28 and the JUnit report at 14:33:16. The latest
mtime among the seven delivered `.ps1` files is 14:24:24, the worktree is clean against the head commit,
and `git status --porcelain --untracked-files=all` returns empty. Both reports therefore describe the
delivered content and were inspected rather than regenerated, per the evidence-verification model.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity first | PASS | Deleting the pre-filter made the decision path shorter than at cycle 1: `Get-PrdFeatureCallTarget` now assembles text, reads the envelope `cwd`, and delegates. |
| Reusability | PASS | Target derivation, path normalisation, and the ambiguity reason code are imported from `.claude/lib/worktree-resolution/`, not restated. Zero occurrences of `git worktree`, `Get-Location`, `$PWD`, `Resolve-Path`, or any ambiguity-code literal in either delivered production file, against a control of 2 occurrences of the literal in the resolution module. |
| Extensibility | PASS | The `-ResolvedTarget` injection parameter follows the established `-CheckpointRaw` seam precedent and binds with `$PSBoundParameters.ContainsKey`, so an explicitly supplied empty value suppresses the derivation rather than falling through to it. |
| Separation of concerns | PASS | Pure string and collection logic sits in the dot-sourced sibling; the three filesystem seams stay in the parent. |
| Module rigor tier | PASS | The hook set is enforcement tooling; the uniform coverage gates were applied. |
| Mandatory toolchain loop | PARTIAL | Format, analyzer, and every targeted suite pass in a single clean pass, independently re-run. The full-repository Pester stage carries 2 failures that are pre-existing and environment-coupled. See exception E1. |
| File size limit (500 lines) | PASS | Largest delivered file is 499 lines. Full ledger in section 9. |
| Error handling — fail fast | PASS | Both `Import-Module` calls are deliberately unguarded so an unloadable resolution module denies the delegation rather than degrading to a permissive path. Every deny path retains the `PRD_FEATURE_BLOCKED:` prefix. |
| No silent error suppression | PASS | The two `catch` blocks in the parent return `$null` for a genuinely unreadable file, which the caller treats as a deny condition rather than as success. |
| Naming | PASS | `PascalCase` verb-noun function names consistent with the repository's other hooks. |
| Public API compatibility | PASS | The three mock seam names and signatures, the dot-source guard, and both PreToolUse payload shapes are unchanged; `PreToolUseSchema.Contract.Tests.ps1` passes unedited at 15 of 15 and appears in no diff hunk. |
| Dependencies | PASS | No new external dependency. The only new import is a repository-internal module already merged at the merge base. |
| I/O boundaries | PARTIAL | Every disk read the hook itself performs goes through one of the three seams, but the derivation the hook now always invokes performs unbounded filesystem reads inside the resolution module. The spec's own performance statement no longer describes the delivered behaviour. See finding N1 in the code review. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell is the only language with changed source files.

| Requirement | Verdict | Evidence |
|---|---|---|
| Formatter clean | PASS | `Invoke-Formatter` produced byte-identical output for all 7 changed `.ps1` files, compared with `-ceq`. |
| PSScriptAnalyzer clean | PASS | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` returned 0 findings for each of the 7 files, total 0. |
| Comment-based help on every function | PASS | All 14 delivered functions carry a `.SYNOPSIS`; the sibling carries 8 help blocks for its file header plus 7 functions. |
| Type checking | PASS | Not applicable to PowerShell per the mandatory toolchain loop. |
| No Python in the enforcement path | PASS | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` contributes 28 nodes to the repository-wide run and none of them is in the 2-member failure set. |
| Bundled-payload mirroring | PASS | SHA-256 equality holds for both pairs: `D87B0E0DAA34023019630E22AD9C1C80059AEF2BF5531B3162221B30B4080B32` for the parent hook and `6529667B99D64205DB53AA43A0D895BAE164824C283E158012C6B027D82E123D` for the sibling. |
| Documentation accuracy of the changed file | PASS | The cycle-1 FAIL is cleared. The `.DESCRIPTION` resolution-order block now describes the derived-target disambiguator, the unresolved-tie deny, the derivation's own ambiguity deny, the conditional checkpoint stand-in, and the probe-anchoring rule. Both stale tokens return a count of 0: `earliest-occurring candidate` and `If no candidate was found in the prompt`. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
|---|---|---|
| Pester 5 discovery/run separation respected | PASS | `-ForEach` data arrays are declared at discovery scope; run-time copies are re-declared in `BeforeAll`. |
| `Should -Invoke ... -Exactly` used for invocation counts | PASS | Zero-count guards on the ambiguity branch and exact positive counts on every allow row, including the new repo-relative allow row. |
| No blanket always-true existence mocks | PASS | Every `Get-PrdFeatureFileExistence` mock is keyed on the fully composed probe path. The one pre-existing blanket mock in `enforce-prd-feature-before-planner.Tests.ps1` was replaced with a path-keyed mock in this change set. |
| Test file naming and placement | PASS | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`. |
| No process working-directory dependence | PASS | The modelled current directory is data on an injected target result or on a mocked derivation return. |
| Fail-before evidence for the remediation | PASS | `evidence/regression-testing/fail-before-remediation.2026-09-17T13-56.md` and `evidence/regression-testing/prefilter-removal.2026-09-17T13-56.md` record the pre-remediation controls for the three new rows. |
| Derivation-seam coverage of the new rows | PASS | The three rows the cycle-1 inputs required are present and passing: the repo-relative allow row, the zero-candidate ambiguity row, and the branch-signal row asserting `Should -Invoke Resolve-WorktreeCallTarget -Times 1 -Exactly`. |

## 5. Test Coverage Detail

Per-file line coverage read from `artifacts/pester/powershell-coverage.xml` during this audit, keyed on the
parent `package` directory name so no bundled mirror can contaminate a figure. Both `sourcefile` match
counts were exactly 1.

| File | Status | Covered / Total | Line coverage | Threshold | Verdict |
|---|---|---|---|---|---|
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | added | 60 / 62 | 96.77% | >= 85% | PASS |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | modified | 88 / 97 | 90.72% | >= 85% | PASS |
| Repository-wide PowerShell | not applicable | 9386 / 9812 | 95.66% | >= 85% | PASS |

No-regression determination on changed lines. Against the pre-remediation state recorded in
`evidence/remediation-baseline/baseline-test-and-coverage.2026-09-17T13-56.md`, the parent hook moved from
90 of 99 to 88 of 97 and the sibling from 58 of 62 to 60 of 62. The parent's covered count and total count
each fell by exactly 2, which is the pre-filter's `if` test and its `return $null`, both of which were
covered before deletion. Removing an equal covered and total count from a ratio below 100 percent lowers
that ratio slightly without any retained line losing coverage. The sibling gained 2 covered lines with an
unchanged denominator. No line covered before the remediation is uncovered now.

Instruction (command) coverage, recorded for completeness because Pester measures it: 90.65 percent on the
parent hook and 97.33 percent on the sibling. No branch-coverage figure is recorded or required; both
`sourcefile` nodes carry zero `BRANCH` counter elements.

## 6. Test Execution Metrics

| Run | Source of the value | Result |
|---|---|---|
| Three prd-feature suites | `artifacts/pester/pester-junit.xml`, grouped by `classname` during this audit | 47 + 25 + 28 = 100 nodes, 0 failed, 0 skipped |
| PreToolUse schema contract | same report, `classname` filter | 15 nodes, 0 failed |
| No-Python enforcement guard | same report, `classname` filter | 28 nodes, 0 failed |
| Must-not-regress gate suites | same report, `classname` filter on `enforce-orchestration-preimplementation-gate` and `enforce-epic-merge-gate` | 17 distinct suite files, 556 nodes, 0 failed |
| Delivery contract tests | `poetry run pytest` re-run during this audit | 17 passed, exit 0 |
| Repository-wide Pester | `artifacts/pester/pester-junit.xml` root `testsuites` element | tests 4761, failures 2, errors 0, 4761 `testcase` elements counted |

### 6.1 The two repository-wide failures — independent re-determination

The failure set is exactly the pre-existing pair, and `errors` is 0. Both members were re-identified by
parsing `//testcase[failure]` during this audit:

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` — `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

No third failing node exists, so the remediation introduced no regression. `//testcase[error]` returns
zero elements. Neither failing suite, nor `.claude/hooks/enforce-pr-author-skill.ps1`, nor
`.claude/hooks/enforce-epic-wave-barrier.ps1`, nor any `.codex/` path appears in the branch diff. The
causes were traced in the cycle-1 audit to two unmocked seams that read live orchestration state, which is
ambient to the worktree rather than written by this branch. That determination is unchanged and is not
re-litigated here.

## 7. Code Quality Checks

| Check | Command re-run during this audit | Result |
|---|---|---|
| Formatter drift | `Invoke-Formatter` on 7 changed `.ps1` files, compared with `-ceq` | 0 files with drift |
| Analyzer, repository settings | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` on 7 files | 0 findings, total 0 |
| File-size cap | `Get-Content ... .Count` on all 7 changed `.ps1` files | maximum 499, cap 500 |
| Bundled mirror byte identity | `Get-FileHash -Algorithm SHA256` on both pairs, compared with `-ceq` | True for both |
| Pack-manifest registration | occurrence count of the sibling path in `core.json` | exactly 1, in correct alphabetical position |
| Coverage-path registration parity | occurrence count in both `pester.runsettings.psd1` copies | exactly 1 in each, identical 4-line addition |
| No local re-implementation of the resolution contract | string scan for four discovery tokens and the ambiguity literal across both production files | 0 occurrences of each, against a non-zero control in the resolution module |
| Moved-function byte identity | `diff -u` of the base hook's `Resolve-PrdFeatureWorkMode` and `Get-PrdFeatureRequiredFile` region against the sibling's | byte-identical, zero differences |
| Codex mirror absence | `Test-Path .codex/hooks/enforce-prd-feature-before-planner.ps1` | False, as the spec states |
| Spec acceptance-criteria text integrity | full `git diff` of `spec.md` from base to head | only checkbox state changed; no criterion text was altered, added, or removed |
| Delivered-hook behaviour | six end-to-end executions of the hook as a child process with the payload supplied through `CLAUDE_HOOK_INPUT` | see section 8 |
| Decision latency | in-process stopwatch over the decision function, 5 iterations per shape | 85.6 ms average for a repo-relative citation, 13.6 ms for an absolute citation, 3.7 ms with no signal |

## 8. Gaps and Exceptions

### 8.1 Cycle-1 findings — closure determination

**R1 (was Blocking) — CLOSED, verified by execution.** The pre-filter is gone: `absolutely-placed` and
the `[A-Za-z]:` pattern each return a count of 0 in the delivered hook, and `Get-PrdFeatureCallTarget`
hands the assembled text to `Resolve-WorktreeCallTarget` on every call that carries any text. Six
executions of the delivered hook, as a child process through its real entrypoint, with no mocks and against
the real filesystem:

| Row | Envelope `cwd` | Citation form | Decision | Reason class |
|---|---|---|---|---|
| E1 | coordinating worktree | repo-relative, folder in no worktree | deny | `TARGET_WORKTREE_AMBIGUOUS`, 0 candidate worktrees |
| E2 | coordinating worktree | repo-relative, own feature folder | deny | `TARGET_WORKTREE_AMBIGUOUS`, 9 candidate worktrees |
| E3 | coordinating worktree | absolute into the item worktree | allow | probe composed under the target root |
| E4 | the item worktree itself | repo-relative, own feature folder | deny | `TARGET_WORKTREE_AMBIGUOUS`, 9 candidate worktrees |
| E5 | coordinating worktree | absolute, folder absent under the target | deny | folder-absent ambiguity reason |
| E6 | the item worktree itself | absolute into the item worktree | allow | bare repo-relative spelling retained |

E1 is the cycle-1 diagnostic re-run against the delivered hook. Its reason is no longer the
work-mode-marker reason recorded in `evidence/regression-testing/fail-before.2026-09-17T11-20.md`; it is
the ambiguity reason with the remedy "Cite the target feature folder as an absolute path inside exactly one
worktree". E5 confirms the second clause of criterion 6 on a composed probe path. E4 closes cycle-1
diagnostic D5: the shape that previously returned `allow` on the strength of a copy of the folder under the
session root now denies, which removes the false-approval mode the spec names as risk R1.

**R2 (was Major) — CLOSED.** Both stale help tokens return a count of 0, and the rewritten block's seven
numbered steps match the delivered branch order, including the ambiguity deny and the condition under which
the checkpoint may still stand in.

**R3 (was Major) — CLOSED by the same edit.** The eligibility predicate that held a local derivation-input
decision no longer exists, leaving `Resolve-WorktreeCallTarget` as the single owner of what counts as a
placeable signal. Recorded distinction: the decision was deleted rather than relocated. The resolution
module is not in the branch diff and needed no change, because it already implemented the multi-worktree
placement filter the deleted predicate had been short-circuiting. Criterion 24 re-verified at zero
occurrences with a non-zero control.

**R4 item 1 (was Minor) — CLOSED.** The sibling's `.DESCRIPTION` now names its one file-scope statement and
the fail-closed rationale for leaving that import unguarded. The stale sentence returns a count of 0.

**R4 item 2 (was Minor) — DEFERRAL ACCEPTED IN REASONING, REJECTED IN CHECKBOX STATE.** The executor's
reasoning is correct and is adopted: narrowing an epic-approved acceptance criterion to match what was
delivered inverts the direction of the check the criteria exist to perform, and is outside an executor's
authority. The proposed replacement wording in
`evidence/other/remediation-scope-decisions.2026-09-17T13-56.md` is accurate and is endorsed for the spec
owner's decision. What is not accepted is leaving criterion 30 at `- [x]` in the interim. The criterion's
literal text states the suite "derives no absolute path from ... the script file location", and the
delivered suite derives four such paths at lines 99, 100, 109, and 110. A checked criterion is a delivered
claim, and that claim is presently false on its literal terms. Under
`.claude/skills/acceptance-criteria-tracking/SKILL.md`, a criterion evaluated other than PASS is left
unchecked and the gap documented. Criterion 30 is therefore evaluated PARTIAL and reverted to `- [ ]` by
this review, with the wording decision routed to the spec owner. No criterion text was modified.

### 8.2 New findings this cycle

**N1 (Major, non-blocking) — the spec's performance statement no longer describes the delivered
behaviour, and the derivation's filesystem cost scales with worktree count.** `spec.md` lines 427-428 state
"Filesystem access remains bounded by the same three seams." With the pre-filter removed, every
`atomic-planner` delegation whose text carries any placeable signal now enters the resolution module, which
enumerates every worktree reachable from the session root and, for a repo-relative token, performs one
existence probe per worktree. This host's topology has 73 worktrees. Measured in-process over 5 iterations
per shape: 85.6 ms average and 180.4 ms maximum for a repo-relative citation, 13.6 ms average for an
absolute citation, and 3.7 ms average when the call carries no signal. This is a real cost paid
synchronously on each such delegation, and it is not a defect in the chosen remediation option — it is the
price of the placement channel that closes R1. It is recorded because the spec asserts the opposite and
because the scaling factor is the worktree count, which grows over a long-running epic.

**N2 (Minor) — the delivered suite's own header carries the same over-broad claim as criterion 30.**
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` lines 19-21
state that "no absolute path here is derived from the runtime environment, the current directory, the
script file location, or a source-control query", which the same four `$PSScriptRoot` derivations
contradict. The executor recorded this as out of scope for the remediation because no task authorised
editing that prose. That handling is accepted; the correction belongs in the same pass as criterion 30's.

**N3 (Minor, observation) — both sibling suites now carry a `Describe`-scope blanket mock of the
derivation.** `enforce-prd-feature-before-planner.Tests.ps1` and
`enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` each mock `Resolve-WorktreeCallTarget` in
`BeforeAll` to return a fixed `NoTarget` result. The intent is documented in place and is sound: those
suites pre-date target resolution and assert the no-target behaviour. The consequence is that neither suite
can observe a derivation regression, so the whole of that surface rests on the `TargetResolution` suite.
This is not a policy violation — the repository's blanket-mock prohibition is scoped to existence mocks —
and no change is requested.

**N4 (Minor, observation) — the repo-relative placement channel has no reachable allow outcome in this
host's topology.** The channel is real and correctly implemented, but it allows only when the cited folder
exists under exactly one worktree. Scanning all 52 folders under `docs/features/active/` in this worktree
against a coordinating session root, zero place uniquely; this feature's own folder matches 9 worktrees.
The practical effect for the first row of the `issue.md` decision matrix is therefore a correct,
actionable deny rather than an allow. That outcome is within the contract: `issue.md` Expected Behavior
states "When the target cannot be identified, the hook denies with a distinct, greppable ambiguity reason
code", and `spec.md` scope states the same. It is recorded so a later reader does not infer from criterion
10 that a repo-relative citation now allows in a multi-worktree checkout.

### 8.3 Accepted exceptions

**Exception E1 — the full toolchain loop does not reach a zero-failure pass.** Acceptance criterion 37
requires the JUnit `failures` attribute to be 0. It is 2, for the two pre-existing environment-coupled
causes in section 6.1. The executor left the criterion unchecked and recorded the deviation; that handling
is correct and is accepted again this cycle. The criterion as written is not satisfiable in this worktree
without repairing two suites outside this feature's scope. The recommended disposition remains a follow-up
issue against those two suites, not a change inside this branch.

**Exception E2 — criterion 29 records an ordering claim.** The cross-file mock smoke case exists and
passes, but its "run before the remainder of the extraction is committed" ordering is attested by
`evidence/regression-testing/cross-file-mock-smoke.2026-09-17T10-55.md` and the commit sequence rather than
being independently reproducible after the fact. Accepted on the evidence, unchanged from cycle 1.

## 9. Summary of Changes

File-size ledger for every `.ps1` file in the change set, measured on the delivered files:

| Lines | File |
|---|---|
| 456 | `.claude/hooks/enforce-prd-feature-before-planner.ps1` |
| 320 | `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` |
| 456 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` |
| 320 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` |
| 446 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` |
| 454 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` |
| 499 | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` |

The 499-line figure for the new suite was verified two ways during this audit: `Get-Content ... .Count`
returns 499 and a newline count over the raw text returns 499, so the file is 499 newline-terminated
physical lines and is within the 500-line cap with one line of headroom.

Also changed: both copies of `pester.runsettings.psd1` (a 4-line addition each),
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one added path), and 80
markdown documents, which are exempt from the file-size cap.

Behavioural change surface relative to the merge base: one new ambiguity deny branch; removal of the
unconditional session-root checkpoint fallback and of the positional tie-break; probe-path composition
against a derived target root; unconditional delegation of the call text to the resolution module;
extraction of five pure functions into a dot-sourced sibling.

## 10. Compliance Verdict

| Area | Verdict |
|---|---|
| General unit test policy | PASS |
| General code change policy | PARTIAL — toolchain loop, exception E1; I/O-boundary documentation, finding N1 |
| PowerShell code change policy | PASS |
| PowerShell unit test policy | PASS |
| Coverage thresholds (PowerShell) | PASS |
| Coverage thresholds (TypeScript, Python, C#) | N/A — zero changed files in the branch diff |
| Evidence location compliance | PASS |
| Delivery registration and bundled mirroring | PASS |
| Cycle-1 blocking finding closure | PASS |
| Acceptance-criteria delivery | PARTIAL — 36 PASS, 1 PARTIAL, 1 FAIL under accepted exception E1 |

**Overall verdict: PASS with non-blocking findings. Zero blocking findings remain.** The four non-blocking
findings and the criterion-30 wording decision are carried into
`remediation-inputs.2026-09-17T15-01.md` as an advisory handoff. None of them gates the pull request.

## Appendix A: Test Inventory

| Suite | Cases | Result |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 47 | 47 passed |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | 25 passed |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 28 | 28 passed |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (unedited) | 15 | 15 passed |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 28 | 28 passed |
| 17 `enforce-orchestration-preimplementation-gate*` and `enforce-epic-merge-gate*` suites | 556 | 556 passed |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and two sibling modules | 17 | 17 passed |

The `TargetResolution` suite grew from 25 nodes at cycle 1 to 28, which is the three rows the cycle-1
remediation inputs required. All three were located by name in the JUnit report, each with exactly one node
and no child `failure` element.

## Appendix B: Toolchain Commands Reference

All PowerShell commands below were executed from the worktree root through a POSIX wrapper that changes
directory and then invokes the PowerShell host on a script file, which is this host's route to the
PowerShell tool. No value in this artifact is taken from a PoshQC MCP result, whose summary is composed
before the child process runs and carries no captured output.

1. `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, once per changed `.ps1` file
2. `Invoke-Formatter -ScriptDefinition (Get-Content -LiteralPath <file> -Raw)` compared with `-ceq` against the original text
3. `Get-FileHash -LiteralPath <file> -Algorithm SHA256` on each repository and bundled pair, compared with `-ceq`
4. `[xml] $cov = Get-Content artifacts/pester/powershell-coverage.xml -Raw`, then the report-level `counter` elements and `//sourcefile[@name='<leaf>']` with its `LINE`, `INSTRUCTION`, and `BRANCH` counters
5. `[xml] $junit = Get-Content artifacts/pester/pester-junit.xml -Raw`, then `/testsuites` attributes, `//testcase[failure]`, `//testcase[error]`, and `classname` grouping
6. `Get-Content -LiteralPath <file>` count and a newline count over the raw text, for the file-size ledger
7. `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q`
8. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
9. `git diff --name-status d039e89b2b2569151e9170e1bbefb9f974419f87..d6e5adb959b8e74d8acbf3278501bf75b07fac8e` and per-path `git diff` for the settings, manifest, and test files
10. `git merge-base --is-ancestor d039e89b... HEAD` and `git log --oneline d039e89b...HEAD` for the base reconciliation
11. `git show d039e89b...:.claude/hooks/enforce-prd-feature-before-planner.ps1` piped to a scratch file, then `diff -u` of the moved-function region against the delivered sibling
12. Review diagnostics D1 through D4: `Resolve-WorktreeCallTarget` and `Get-WorktreeResolutionWorktreeRoot` called directly for placement counts; the hook invoked as a child process with the payload supplied through `CLAUDE_HOOK_INPUT`; and a stopwatch over `Invoke-PrdFeatureBeforePlannerDecision` for the latency figures
