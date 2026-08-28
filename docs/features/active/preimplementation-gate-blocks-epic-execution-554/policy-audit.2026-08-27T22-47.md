# Policy Compliance Audit — issue #554

- Timestamp: 2026-08-27T22-47
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `f24bbc7f`
- Base: `origin/main` at `1e991b86` (merge-base confirmed identical to base tip)
- Diff form: `git diff origin/main...HEAD`
- Work mode: `full-bug` (marker read from `issue.md`); AC source is `spec.md` exclusively
- Worktree audited: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d`

## Verdict Summary

| Area | Verdict |
| --- | --- |
| Policy reading order and non-modification of policy sources | PASS |
| Scope constraints declared by the caller and by `spec.md` | PASS |
| File-size cap (500 lines) | PASS |
| PowerShell format stage | PASS |
| PowerShell lint stage (PSScriptAnalyzer) | PASS |
| Type-check stage | N/A (no typed language changed) |
| Architecture-boundary stage | N/A (no boundary-checked language changed) |
| Unit-test stage | PASS |
| Contract/schema stage | PASS |
| Integration-test stage | N/A |
| Evidence location compliance | PASS |
| Coverage — repo-wide PowerShell | PASS |
| Coverage — per-file, changed production files | **FAIL** |
| Coverage — no-regression on pre-existing lines | **FAIL** |
| Determinism and no-temporary-files test policy | PASS |

**Blocking findings: 4. Non-blocking findings: 6.**

## Rejected Scope Narrowing

None. The delegating prompt supplied the full branch diff against the resolved base branch and
imposed no subset, no plan-scope limitation, and no instruction to skip a toolchain or coverage
check. Two statements in the delegating prompt were checked rather than accepted:

1. *"Issue #555 (the Codex transport gap) is deliberately OUT of scope."* This is a scope statement
   about the **feature**, recorded in `spec.md` decision D5, not a narrowing of the **audit**. The
   full Codex diff was audited. Where D5's transport-gap argument is used to justify a coverage gap,
   the argument was evaluated on its merits rather than accepted (see Finding B1).
2. *"Do not treat [#510] as a regression of this change."* Verified independently rather than
   accepted: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
   **passes** in this worktree (`1 passed in 0.09s`). The condition described did not reproduce, so
   no annotation was needed.

## Languages With Changed Files

Only **PowerShell** has changed production files in the branch diff. TypeScript, Python, and C# have
zero changed files, so their coverage verdicts are `N/A` on the zero-changed-files basis permitted by
the coverage-verification procedure. The two changed `.psd1` settings files and the two changed
`.json` pack manifests are configuration, measured through the PowerShell coverage denominator they
control and through Python parity tests respectively.

| Language | Changed production files | Coverage artifact | Verdict |
| --- | --- | --- | --- |
| PowerShell | 8 `.ps1` (4 logical, 4 mirrors) + 2 `.psd1` | `artifacts/pester/powershell-coverage.xml` (present) | **FAIL** (per-file; repo-wide PASS) |
| Python | 0 | n/a | N/A — zero changed files |
| TypeScript | 0 | n/a | N/A — zero changed files |
| C# | 0 | n/a | N/A — zero changed files |

## Toolchain Verification (independently re-run, check-only)

All commands were run in the audited worktree.

| Stage | Command | Result |
| --- | --- | --- |
| Format | `Invoke-Formatter` over the six changed/new `.ps1` files with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, compared ordinally against file content | `FORMAT-CLEAN` on all six |
| Lint | `Invoke-ScriptAnalyzer` over the same six files with the same settings | `PSSA: 0 findings` |
| Type check | n/a | Not applicable to PowerShell per `.claude/rules/powershell.md` |
| Architecture | n/a | No dependency-cruiser / NetArchTest surface changed |
| Unit tests (targeted) | `Invoke-Pester` over the two new suites plus the six pre-existing gate/contract suites | `Tests Passed: 368, Failed: 0, Skipped: 0` |
| Unit tests (full PowerShell run) | `artifacts/pester/pester-junit.xml` produced by the executor's P6-T4 self-hosted run | `tests="3808" errors="0" failures="0" disabled="9"` |
| Contract / schema | `pytest` over `tests/scripts/dev_tools` filtered to manifest/parity/PoshQC/runsettings/bundled | `494 passed, 5 skipped` |
| Integration | n/a | No integration surface changed |

The single-pass requirement of `.claude/rules/general-code-change.md` is satisfied: format produced
no change, lint produced zero findings, and tests passed, in one pass.

## Scope-Constraint Verification

Each constraint stated by the caller and by `spec.md` was verified against the diff rather than
accepted on report.

| Constraint | Evidence | Verdict |
| --- | --- | --- |
| Only the Agent-matcher leg changes; Edit/Write and Bash legs behaviourally unchanged including the issue #539 staging exemption | `Test-ImplementationPath`, `Test-ImplementationCommand`, and `Test-ExemptOrchestrationStagingCommand` are untouched in the diff; the six pre-existing suites are absent from `git diff --name-only` and all 368 of their cases pass | PASS |
| The four `-helpers.ps1` copies are byte-untouched (D1) | `git diff --name-only origin/main...HEAD \| grep -c helpers.ps1` returns `0` | PASS |
| All four mirrored production pairs byte-identical | SHA-256 recomputed independently: `0c8c55ce…`, `0ffab72e…`, `b978bad8…`, `8e116581…`; all four pairs MATCH | PASS |
| Deny-by-default preserved with no new permissive path | Three deny assertions exist and pass. See Finding N4 for a spec-sanctioned widening that the criterion's wording does not describe | PASS with recorded observation |
| Issue #555 out of scope | No `.codex/config.toml` change in the diff; the Codex suite records the gap as a tested fact citing #555 | PASS |
| No file under `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, or `.github/copilot-instructions.md` written | Full `git diff --name-status` enumerated; zero matches | PASS |
| Exactly seven concrete files under `extensions/drm-copilot/resources/` | Diff contains exactly seven, matching the seven enumerated in `spec.md` §DECLARED BLAST RADIUS (c) | PASS |
| 500-line cap on every production `.ps1` | 489 / 477 / 495 / 477 (production); 494 / 235 (tests). All ≤ 500 | PASS |

## Evidence Location Compliance

`python scripts/dev_tools/validate_evidence_locations.py --root .` exits **0** with no output.

The branch diff contains **zero** files under `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, or `artifacts/coverage/`. Every evidence artifact is written to
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/<kind>/` using the
kinds `baseline`, `issue-updates`, `other`, `qa-gates`, and `regression-testing`, all of which are
canonical. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose.

## Coverage Verification

Coverage was verified by inspecting the pre-existing artifact
`artifacts/pester/powershell-coverage.xml` (JaCoCo form). No coverage generation was re-run. All
figures below were recomputed independently from that artifact and from `git diff -U0` against the
merge base; they are not copied from the executor's evidence.

### Repo-wide PowerShell — PASS

| Counter | Covered | Missed | Percentage |
| --- | --- | --- | --- |
| LINE | 7174 | 440 | **94.22%** |
| INSTRUCTION | 9865 | 660 | 93.73% |
| METHOD | 626 | 41 | 93.85% |

94.22% is above the uniform 85% line threshold in `.claude/rules/quality-tiers.md`. Pester measures
no branch coverage, so no branch figure exists and none is required; the absence is not recorded as
a FAIL, per the PowerShell exemption in `.claude/rules/general-unit-test.md`.

### Coverage Exclusion Policy — PASS

Both new production files are registered in `CodeCoverage.Path` in **both**
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and both
appear as `sourcefile` entries in the coverage report. No production path is excluded. The two
settings files carry identical diffs and their Python text-parity test passes.

### Per-file, changed production files — FAIL

| File | New/Modified | Measured lines | Uncovered | File line coverage | Verdict vs 85% |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Modified | 150 | 29 | **80.67%** | FAIL |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | New | 132 | 2 | **98.48%** | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | Modified | 162 | 29 | **82.10%** | FAIL |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | New | 132 | 24 | **81.82%** | FAIL |

The four `extensions/drm-copilot/resources/` mirrors are byte-identical copies of the four files
above and are not separately instrumented; their coverage is the coverage of their sources.

### Changed-line coverage — reproduced exactly

| File | Measurable added | Uncovered added | Changed-line coverage |
| --- | --- | --- | --- |
| `.claude/…/gate.ps1` | 42 | 10 | 76.19% |
| `.claude/…/gate-modes.ps1` | 132 | 2 | 98.48% |
| `.codex/…/gate.ps1` | 42 | 27 | 35.71% |
| `.codex/…/gate-modes.ps1` | 132 | 24 | 81.82% |
| **Aggregate** | **348** | **63** | **81.90%** |

These figures reproduce the executor's `coverage-delta.2026-08-27T22-36.md` table exactly. The
executor's measurement is accurate.

### Regression on pre-existing lines — FAIL

The audit went one step further than the executor's artifact and partitioned each file's uncovered
lines into **added** and **pre-existing**:

- `.claude/…/gate.ps1` uncovered pre-existing lines: `125, 170, 171, 174, 175, 176, 179, 180, 181,
  182, 185, 252, 253, 255, 425, 485, 486, 487, 490`.
- `.codex/…/gate.ps1` uncovered pre-existing lines: `197, 206`.

Lines **170-185 of the Claude copy are the entire body of `Test-PreparationModeDelegation`.** That
function's only production call site was inside `Test-ImplementationDelegation`, which this change
replaced; nothing in production calls it now, and no Claude-side test calls it directly. Ten
previously-covered pre-existing lines therefore became uncovered as a direct consequence of this
change. The asymmetry confirms the diagnosis: the Codex copy of the same now-dead function retains
coverage only because `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` calls it
directly, which is why only lines 197 and 206 are uncovered there.

Derived (not measured) baseline file coverage, computed by removing the added lines and restoring
the ten orphaned lines to covered:

| File | Estimated baseline | Post-change | Estimated movement |
| --- | --- | --- | --- |
| `.claude/…/gate.ps1` | ≈ 91.7% (99/108) | 80.67% | ≈ −11 pp |
| `.codex/…/gate.ps1` | ≈ 98.3% (118/120) | 82.10% | ≈ −16 pp |

These are derived estimates, clearly marked as such: the Phase 0 baseline artifact retains only
repo-wide JaCoCo counters and no per-file line map, so an exact baseline comparison is not available
from committed evidence. The direction and approximate magnitude are nonetheless well supported,
and the ten-line orphaning is a direct structural observation that does not depend on the estimate.

## Blocking Findings

### B1 — `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` is a new production file at 81.82%, and the D5 exemption does not cover its uncovered lines

**Severity: Blocking.** Rule: `.claude/rules/quality-tiers.md` uniform line threshold ≥ 85%;
coverage-verification procedure for new files.

The 24 uncovered added lines are `94, 95` (the `Write-Debug` catch) and `197, 228, 230-232, 234-237,
242-244, 246, 248-250, 268, 270-274`. Line 197 is the unknown-mode `return ''`; 228-250 is the whole
body of `Find-OrchestrationDelegationTargetFolder`; 268-274 is the whole body of
`Find-OrchestrationDelegationIssueNumber`.

The executor's Group 3 attributes these to the decision-D5 transport gap. **That attribution is
over-extended and the audit rejects it for this file.** D5 prohibits *"fabricating an `Agent`
envelope on the Codex side and asserting a decision on it."* Every function listed above is a pure
string function that takes a `[string] $Prompt` or `[string] $Mode` and returns a string. Calling
one requires no envelope, asserts nothing about transport, and is exactly what the Codex suite
already does in three of its five `Context` blocks. The Claude suite already covers all of them with
literal-string fixtures that can be copied verbatim. The gap is a consequence of the Codex suite
carrying 13 `It` blocks rather than the Claude suite's 43, not a consequence of D5.

Remediation: add the equivalent `It` blocks to
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`.
Projected result: 2 uncovered of 132, i.e. **98.48%**.

### B2 — `Test-PreparationModeDelegation` is orphaned on the Claude surface, producing dead production code and a ten-line coverage regression

**Severity: Blocking.** Rules: `.claude/rules/general-unit-test.md` ("Code changes or refactors must
not reduce coverage for the lines that were changed"); `.claude/rules/general-code-change.md`
(simplicity, no dead indirection).

The new structural classifier resolves preparation mode through
`Resolve-OrchestrationDelegationMode` and its own marker table, duplicating the logic that
`$script:PreparationModeMarkers` + `Test-PreparationModeDelegation` still implement in the same
file. The old function has no remaining production caller on either surface. On the Claude surface
it also has no test caller, so ten measurable lines that were covered at the merge base are now
uncovered.

This is a real regression and it is **not disclosed anywhere** in
`coverage-delta.2026-08-27T22-36.md`; it is part of the "up to 9 misses [that] are unattributed"
that artifact flags without diagnosing. It also leaves two independent implementations of the same
preparation-marker rule in one file, which is a divergence hazard for a security-relevant gate.

Remediation, either of:
- (preferred, smaller) add a direct Claude-side unit test for `Test-PreparationModeDelegation`
  mirroring the existing Codex legacy-contract cases, restoring the ten lines; or
- remove the orphaned function and `$script:PreparationModeMarkers` from all four copies. This is
  larger, touches a function `spec.md` lists as "Not modified", and would break the Codex legacy
  contract test, so it is recorded as the less-preferred option and a candidate follow-up.

### B3 — `Get-OrchestrationModeDenyReason` is uncovered on the Codex surface

**Severity: Blocking (small).** Lines 352-353 of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.

This is a pure string builder with two mandatory string parameters. It requires no envelope and no
transport. It is the function that satisfies acceptance criterion "(Amendment 3) A denied
delegation's reason names the checkpoint actually consulted and the failed predicate" — so the Codex
copy of the criterion's implementing function is entirely unverified. One direct `It` block closes
it.

### B4 — the classifier's non-orchestrator allow branch is untested on the reachable surface

**Severity: Blocking (small).** Line 210 of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`:

```powershell
    if ($subagentType -ne 'orchestrator') {
        return $false
    }
```

This is the single uncovered added line the executor's four-group characterization does **not**
account for (the four groups cover 62 of the 63 lines; line 210 is the 63rd). It is an **allow**
branch — returning `$false` means "not an implementation delegation", so the gate permits the
operation — inside the newly written classifier, on the Claude surface, which is the only surface
where the `Agent` transport is reachable. Nothing in the Claude suite exercises it. The equivalent
branch is covered on the Codex copy (`task-researcher` ⇒ `$false`), so the behaviour is verified on
a byte-identical algorithm, but not on the shipped, reachable path. One `It` block closes it.

## Non-Blocking Findings

### N1 — the executor's group line counts do not add up, though the total does

`coverage-delta.2026-08-27T22-36.md` states Group 1 = 18, Group 2 = 3, Group 3 = 40, Group 4 = 2,
summing to 63. Recomputed from the report the groups are 16, 3, 39, and 4, summing to 62, with line
210 unaccounted for. The total of 63 is correct; the per-group attribution is not. Group 4 counted
only one of the two surfaces' `Write-Debug` catches.

### N2 — the residual Codex decision-branch gap is genuine and should be recorded as a named exception

After B1, B3, and B4 are remediated, `.codex/…/gate.ps1` remains at ≈ 83.3% (27 uncovered of 162).
The residual is the two filesystem read seams (8 lines), the non-injected `else` arm (2 lines), and
the epic/parallel decision branch (15 lines). The first two are legitimately I/O-bound and exist to
satisfy the no-filesystem-I/O test rule. **The 15-line decision branch is the one place where the
D5 transport-gap argument does hold**: driving it requires constructing a delegation payload for the
Codex decision function, which is what D5 prohibits. This residual should be recorded as an explicit,
justified exception tied to issue #555 rather than left implicit in a coverage table.

### N3 — order-dependence remains in `Find-OrchestrationDelegationIssueNumber`

The function returns the **first** bare-hash match when no keyed `issue_num` is present. A prompt
citing two hash numbers (for example a target issue and a superseded PR reference) resolves a
different number depending on their order, and therefore can produce a different record match and a
different decision. This is a narrow residual of exactly the wording-dependence Fault 1 exists to
eliminate. It is Non-blocking because: the AC scopes the guarantee to the test-matrix cases, none of
which carries two hash numbers; the keyed form takes precedence; and the folder-token path takes
precedence over the issue number in `Find-OrchestrationModeRecord` for every kickoff that carries a
folder token. Recommended follow-up: prefer the keyed form only, or require a unique bare-hash match.

### N4 — the structural classifier introduces a spec-sanctioned permissive widening the AC wording does not describe

Pre-change, any payload whose serialization contained `implementation` or `execute` classified as an
implementation delegation, including a payload carrying no `subagent_type` at all. Post-change, a
payload whose `subagent_type` is absent or unrecognized always classifies as not-implementation and
is allowed. This is exactly the contract `spec.md` specifies (`if subagentType != 'orchestrator' ->
not implementation (allow)`), it is the intended structural fix, and exposure is bounded because the
`Agent`/`Task` matcher always supplies `subagent_type`. It is recorded here only because the
acceptance criterion is worded "no new permissive path", which is literally broader than what the
design delivers. The criterion's three checkable deny assertions all pass.

### N5 — the Codex pack manifest still omits the Codex main gate hook

`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists
`-helpers.ps1` and now `-modes.ps1`, but has never listed
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`. Verified pre-existing: the base
manifest at `origin/main` also omits it. Not introduced by this change and not this feature's to
fix, but the omission is now more visible because a second dot-sourced sibling of an unpacked hook
was added. Recommended follow-up issue.

### N6 — the known #510 failure did not reproduce

`test_bundled_claude_payload_contains_all_repo_runtime_contracts` **passes** in this worktree. The
condition annotated at `evidence/other/known-preexisting-failure-510.2026-08-26T11-36.md` and in the
delegating prompt was not observable at audit time. Recorded so the annotation is not read as an
unverified claim.

## Policy Reading Order Confirmation

Read in the mandated order before evaluating any change: `CLAUDE.md`;
`.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`;
`.claude/rules/quality-tiers.md`; `.claude/rules/powershell.md` (via the changed `.ps1` scope);
`.claude/rules/parallel-orchestration.md` and `.claude/rules/orchestrator-state.md` (for the
checkpoint schemas the new predicates consume); `.claude/rules/plan-acceptance-gates.md` (for the
unfalsifiable-gate argument the executor invokes); `.claude/rules/tonality.md`.

No policy document was modified by this audit or by the branch.
