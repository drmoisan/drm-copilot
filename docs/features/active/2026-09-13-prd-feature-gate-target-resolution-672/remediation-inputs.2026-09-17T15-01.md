# Remediation Inputs — prd-feature gate target resolution (Issue #672)

- Timestamp: 2026-09-17T15-01
- Review cycle: 2 (re-audit after the cycle-1 remediation)
- Feature folder: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672`
- Work mode: `full-bug`; acceptance-criteria source is `spec.md` only
- Head reviewed: `d6e5adb959b8e74d8acbf3278501bf75b07fac8e`
- Base: `epic/worktree-scoped-state-resolution-integration` @ `d039e89b2b2569151e9170e1bbefb9f974419f87`

Source artifacts:

- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/policy-audit.2026-09-17T15-01.md`
- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/code-review.2026-09-17T15-01.md`
- `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/feature-audit.2026-09-17T15-01.md`

**Blocking findings: 0. Non-blocking findings: 4. One acceptance-criterion wording decision is routed to
the spec owner.**

## Status of this artifact

This is an advisory handoff, not a remediation trigger. No finding below blocks the pull request, and no
atomic remediation plan is requested for this branch. The single acceptance criterion that is not PASS by
reason of the delivered code is criterion 30, and its correct resolution is a wording decision that sits
above an executor's authority — which is precisely the position the cycle-1 executor took, and this review
agrees with that reasoning. Creating an execution plan to edit an approved criterion would invert the
direction of the check the criteria exist to perform.

Recommended routing: hold items D1 through D3 for a documentation pass owned by the spec owner or the epic
owner, either before merge as a docs-only commit on this branch or as a follow-up. Item D4 is an
observation with no action requested. Item F1 is a follow-up issue against two suites outside this feature.

## Cycle-1 findings — closure record

| Cycle-1 finding | Severity then | Verdict now | How it was verified |
|---|---|---|---|
| R1 — the repo-relative citation path is unchanged by the fix | Blocking | CLOSED | Option A applied. The pre-filter tokens `absolutely-placed` and `[A-Za-z]:` each return a count of 0 in the delivered hook. Six executions of the delivered hook as a child process, no mocks, real filesystem: the repo-relative citation that previously produced the marker reason now produces `TARGET_WORKTREE_AMBIGUOUS` with the remedy "Cite the target feature folder as an absolute path inside exactly one worktree". |
| R2 — stale comment-based help on the parent hook | Major | CLOSED | Both stale tokens return a count of 0. The rewritten seven-step resolution-order block matches the delivered branch order, including the ambiguity deny and the conditional checkpoint stand-in. |
| R3 — derivation policy living in the hook narrows the F1 contract | Major | CLOSED | Resolved by the same edit, as the cycle-1 inputs anticipated. The eligibility decision was deleted rather than relocated, which is correct: the resolution module already implemented the multi-worktree placement filter the predicate had been short-circuiting, so that module needed no change and is not in the diff. |
| R4 item 1 — the helpers description overstates "declarations only" | Minor | CLOSED | The stale sentence returns a count of 0. The replacement names the one file-scope import and the fail-closed rationale for leaving it unguarded. |
| R4 item 2 — criterion 30's over-broad determinism clause | Minor | DEFERRED; reasoning accepted, checkbox state corrected | See item D1. |

Also closed by the same edit, though it was recorded in cycle 1 as an observation rather than a required
fix: the false-approval mode of cycle-1 diagnostic D5. A repo-relative citation issued from a worktree
where a copy of the folder happens to exist previously returned `allow`; it now denies with the ambiguity
code. Execution row E4 confirms this. That closes the shape the spec names as risk R1, which was the
highest-rated risk in the feature.

## Verification of the executor's seven remediation gates

Each value below was measured during this review, not copied from the executor's artifacts. All seven hold.

| Gate | Executor verdict | Reviewer verdict | Reviewer measurement |
|---|---|---|---|
| 1 — formatter and analyzer | PASS | PASS | `Invoke-Formatter` output compared with `-ceq` is byte-identical for all 7 changed `.ps1` files. `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` returns 0 findings per file, total 0. |
| 2 — the three prd-feature suites and the new rows | PASS | PASS | From the JUnit report grouped by `classname`: 47, 25, and 28 nodes, 0 failures and 0 skips in each. All seven named rows located by name, each with exactly one node and no child `failure` element. |
| 3 — the contract suite and the 17-suite batch | PASS | PASS | `PreToolUseSchema.Contract.Tests.ps1` at 15 nodes, 0 failures, and absent from every diff hunk. The `enforce-orchestration-preimplementation-gate` and `enforce-epic-merge-gate` filter yields 17 distinct suite files, 556 nodes, 0 failures. |
| 4 — SHA-256 equality for both pairs | PASS | PASS | `D87B0E0DAA34023019630E22AD9C1C80059AEF2BF5531B3162221B30B4080B32` and `6529667B99D64205DB53AA43A0D895BAE164824C283E158012C6B027D82E123D`, each equal across its pair under `-ceq`. Both values match the executor's record exactly. |
| 5 — per-file line coverage at or above 85 | PASS | PASS | Parent hook 88 of 97, 90.72 percent. Sibling 60 of 62, 96.77 percent. Each `sourcefile` node matched exactly once, keyed on the parent package directory. Zero `BRANCH` counter elements, so no branch figure exists to evaluate and none is recorded as a failure. |
| 6 — the failing node set and `errors = 0` | PASS | PASS | `//testcase[failure]` returns exactly 2 elements, and both are the pre-existing pair. `//testcase[error]` returns 0. The root `testsuites` element carries `tests="4761" failures="2" errors="0"`. No third failing node exists. |
| 7 — the evidence-location validator | PASS | PASS | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exits 0 with no reported path. |

Two supplementary verifications the delegating prompt requested:

- **The 499-line cap check.** `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` measures 499 physical lines, confirmed both by line count and by newline count over the raw text. It is within the 500-line cap with one line of headroom. Recorded as a maintenance fact: the next case added to this file cannot be added to this file.
- **Artifact currency.** The coverage report was written at 14:32:28 and the JUnit report at 14:33:16, both after the latest delivered-file mtime of 14:24:24, with a clean worktree at the head commit. Both reports therefore describe the delivered content, so they were inspected rather than regenerated.

## Non-blocking findings requiring action

### D1 — criterion 30's wording decision (spec owner)

**Affected acceptance criterion:** 30 (`spec.md` line 655). Verdict PARTIAL. Reverted to `- [ ]` by this
review; the criterion text was not modified.

**The finding, restated.** The criterion states the new suite "derives no absolute path from the
environment, the current directory, the script file location, or a source-control query". The delivered
suite derives four absolute paths from `$PSScriptRoot` at lines 99, 100, 109, and 110. Three of the four
clauses hold in full. The fourth does not.

**What this review accepts and what it does not.** The executor's refusal to re-word the criterion is
accepted and endorsed: narrowing an epic-approved criterion to match what was delivered inverts the
direction of the check. What is not accepted is leaving the criterion at `- [x]` in the interim, because a
checked criterion is a delivered claim and that claim is false on its literal terms. The correct interim
state under `.claude/skills/acceptance-criteria-tracking/SKILL.md` is unchecked with the gap documented.

**Requested action.** The spec owner decides between two dispositions:

1. Accept the narrower wording proposed verbatim in
   `evidence/other/remediation-scope-decisions.2026-09-17T13-56.md`, which this review has read and finds
   accurate, then re-check the criterion. This is the recommended disposition.
2. Keep the current wording and require the suite to locate the files under test without `$PSScriptRoot`.
   This is not recommended: a Pester suite cannot dot-source its subject without locating it, and
   `$PSScriptRoot`-relative location is the form every sibling suite in this tree uses.

No code change is required under either disposition.

### D2 — the spec's performance statement no longer describes the delivered behaviour

**File:** `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, lines 426-430.
Severity Major, non-blocking. Recorded as code-review finding N1.

The section states "Filesystem access remains bounded by the same three seams." Removing the pre-filter
routes every delegation carrying a placeable signal into the resolution module, which enumerates every
worktree reachable from the session root and, for a repo-relative token, probes one path per worktree. This
host's topology has 73 worktrees.

Measured in-process over 5 iterations per shape, with the stopwatch around the decision function so the
host start-up cost is excluded:

| Call shape | Average | Minimum | Maximum |
|---|---|---|---|
| repo-relative citation | 85.6 ms | 61.2 ms | 180.4 ms |
| absolute citation | 13.6 ms | 7.5 ms | 33.6 ms |
| no placeable signal | 3.7 ms | 2.9 ms | 5.3 ms |

**Requested action.** Amend the performance section to state that the derivation's filesystem cost scales
with the worktree count, and record the measured figures. The cost itself is the correct price for closing
R1 and is not a defect in the chosen option. Whether the resolution module should memoise its enumeration
per process is a question for that module's owner, not for this hook, and is raised here only so it is not
lost.

### D3 — the suite header carries the same over-broad claim as criterion 30

**File:** `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, lines
19-21. Severity Minor. Recorded as code-review finding N2.

The header determinism statement asserts that "no absolute path here is derived from the runtime
environment, the current directory, the script file location, or a source-control query", which the same
four derivations contradict. The executor recorded this as out of scope because no remediation task
authorised editing that prose; that handling is accepted.

**Requested action.** Narrow the sentence in the same pass as D1, so the criterion and its in-code twin are
corrected together. Re-mirror is not required: this is a test file with no bundled counterpart. Re-run the
formatter and the analyzer afterwards, and re-confirm the line count stays at or under 500, since the file
has one line of headroom.

### D4 — the repo-relative placement channel has no reachable allow in this topology

Severity Minor, observation only. **No action requested.** Recorded as code-review finding N4 so it is not
re-diagnosed as a defect in a later cycle.

The channel is real and correctly implemented, but it allows only when the cited folder exists under
exactly one worktree. Scanning all 52 folders under `docs/features/active/` in this worktree against a
coordinating session root, zero place uniquely; this feature's own folder matches 9 worktrees. The
practical effect for the first row of the `issue.md` decision matrix is a correct, actionable deny rather
than an allow.

This is within the contract. `issue.md` Expected Behavior states "When the target cannot be identified, the
hook denies with a distinct, greppable ambiguity reason code", and `spec.md` scope states the same. It is
also a material improvement on the cycle-1 state, in which the same shape denied with a remedy that would
have edited another repository's `issue.md`. One optional improvement is offered as a Minor code-review
finding: add a sentence to the hook's `.DESCRIPTION` step 1 naming the exactly-one-worktree condition, so
a maintainer reading the help block learns what the deny text already tells a caller at run time.

## Not remediation for this branch — recorded so it is not re-diagnosed

### F1 — the two repository-wide Pester failures are pre-existing and environment-coupled

They must not be treated as a regression of this branch and must not be remediated inside it. The failure
set was re-parsed during this review and is exactly the pair below, with `errors` at 0 and no third member:

- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. `Test-EpicBaseBranchOverride`, check 6 in `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, calls `Get-PrAuthorCheckpointContent`, which the test's `BeforeEach` does not mock, so it reads live orchestration state. Check 6 applies to `gh pr create` only, which is why the sibling `gh pr edit` case in the same `Context` passes.
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` — `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`. `enforce-epic-wave-barrier.ps1` denies on ambient epic-checkpoint state.

Neither failing suite, nor `.claude/hooks/enforce-pr-author-skill.ps1`, nor
`.claude/hooks/enforce-epic-wave-barrier.ps1`, nor any `.codex/` path appears in the 89-file branch diff.

**Suggested follow-up outside this branch.** File one issue against both suites for the shared defect: each
reaches live orchestration state through a seam its own `BeforeEach` leaves unmocked, so its result depends
on the worktree it runs in. The fix is to mock `Get-PrAuthorCheckpointContent` in the `allowed commands`
`Context` of the pr-author suite, and to supply a synthetic epic checkpoint to the Codex integration suite
rather than letting it read the ambient one. Until that lands, any acceptance criterion or plan gate
demanding a JUnit `failures` value of 0 is unsatisfiable in an epic-child worktree.

**Consequence for criterion 37.** It remains FAIL on its literal terms and stays unchecked, carried as
accepted exception E1. The recommended long-term disposition, offered for the spec owner rather than
requested of an executor, is to re-word the criterion to compare the observed failure set against a
recorded baseline pair rather than requiring an absolute zero. That change is out of scope here for the
same reason D1 is.

## Acceptance-criteria check-off record

- Criteria 1 through 29, 31 through 36, and 38: confirmed PASS and left checked.
- Criterion 30: evaluated PARTIAL and reverted from `- [x]` to `- [ ]` by this review. Text unmodified.
- Criterion 37: evaluated FAIL and left unchecked.
- Criteria 6 and 10: reverted by the cycle-1 remediation as requested, re-checked by the executor after the
  new regression rows passed, and independently confirmed PASS by this review. Left checked.

Final tally: 38 criteria, 36 PASS, 1 PARTIAL, 1 FAIL. Blocking findings: 0.

## Gate for accepting any future documentation pass on D1 through D3

1. `Invoke-Formatter` reports zero drift and `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` reports zero findings for the edited test file.
2. `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` stays at or under 500 physical lines, measured on the delivered file. It currently has one line of headroom.
3. The three prd-feature suites still report 47, 25, and 28 nodes with zero failures.
4. No criterion text other than criterion 30's is changed, and criterion 30's replacement is the wording
   recorded in `evidence/other/remediation-scope-decisions.2026-09-17T13-56.md` or a wording the spec owner
   substitutes explicitly.
5. No production `.ps1` file is edited, so no re-mirroring and no SHA-256 re-verification is required. If
   the optional `.DESCRIPTION` sentence in finding N4 is adopted, both mirrors must be re-synchronised and
   SHA-256 equality re-verified for both pairs.
