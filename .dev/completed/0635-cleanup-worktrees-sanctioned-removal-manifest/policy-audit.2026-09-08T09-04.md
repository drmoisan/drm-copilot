# Policy Audit — cleanup-worktrees-sanctioned-removal-manifest (Issue #635)

- Component: `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.claude/skills/cleanup-merged-worktrees/SKILL.md`, and their push-down mirrors
- Date: 2026-09-08
- Auditor: feature-review agent
- Work mode: `full-bug` (marker read from `issue.md`); acceptance-criteria source is `spec.md` only
- Base branch (resolved): `epic/cleanup-merged-worktrees-hardening-integration`
- Merge base: `0ea7e577ea787017541c3164fbb97b7d12d8ab57`
- Head under review: `4d5ecaca609cc1f2d61171be58effc545078771d`
- Caller-supplied diff anchor: `d250cf72ee24139735e7f08b07d002ae0e4f1d00`
- PR context artifacts: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (regenerated during this review; both carry `Head SHA: 4d5ecaca609cc1f2d61171be58effc545078771d` and the same generated-context timestamp)

## Executive Summary

The change adds a third authorization branch to both worktree-removal PreToolUse gates, sourced
from a new sanctioned-removal manifest at `artifacts/orchestration/cleanup-worktrees-manifest.json`,
and adds the corresponding skill-text contract. Scope is 15 changed or added files against the
resolved base: 3 production PowerShell files, 3 byte-identical mirrors, 2 PoshQC runsettings files,
1 pack manifest, 1 skill document, 2 mirrored skill/lib copies counted in the mirror set, and 4
Pester suites.

**Overall verdict: PASS.** All 37 acceptance criteria in `spec.md` are satisfied on independent
verification. The PowerShell toolchain completed a clean single pass; CI reports zero test failures
against this tree; per-file line coverage for the three changed production files is 92.5926%,
95.2381% and 93.6709%, all above the uniform 85% threshold, and repo-wide PowerShell line coverage
is 95.4520%. No blocking finding was identified. Two Medium, non-blocking findings and several Low
and informational findings are recorded in `code-review.2026-09-08T09-04.md`; none of them meets the
remediation trigger, so no `remediation-inputs` artifact was produced.

The central design question — whether the new path is a real authorization decision or an escape
hatch — is assessed in section 8 and answered: it is an authorization decision. Both directions are
pinned by tests (a sanctioned removal allowed, an unsanctioned one still denied), and the one path
by which the manifest could widen what the gates already protect is closed by a presence-only
checkpoint exclusion that is deliberately narrower than the gates' own `merge_status` predicate.

## Scope Determination

The audit scope is the full branch diff against the resolved base branch. It was computed and
cross-checked two ways, and the two agree:

| Method | Command | Result |
| --- | --- | --- |
| Merge base with resolved base branch | `git merge-base origin/epic/cleanup-merged-worktrees-hardening-integration HEAD` | `0ea7e577` |
| Code scope from that merge base | `git diff --stat 0ea7e577 HEAD -- .claude .codex extensions scripts tests` | 15 files, 1833 insertions, 18 deletions |
| Caller-supplied anchor | `git diff --stat d250cf72 4d5ecaca` | same 15 code files plus the feature's own docs and `epic-status.md` |

The caller-supplied anchor `d250cf72` and the resolved merge base `0ea7e577` differ only by the
epic integration branch's own `epic-status.md` (7 lines), which the branch carries as a clean
merge at `0ea7e577`. Neither choice attributes issue #545's merged edits to this feature. The
scope used for this audit is the merge-base scope, which is the stricter of the two for code.

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller and none was accepted. The caller supplied a diff
anchor together with an explicit justification for it, and independent verification (above) confirms
that the anchor yields the same code scope as the merge base with the resolved base branch. That is
base-branch resolution, not scope narrowing. No language with changed files was marked out of scope,
informational only, or not applicable, and no coverage check was waived.

## Evidence Location Compliance

| Check | Command | Result |
| --- | --- | --- |
| Validator | `python scripts/dev_tools/validate_evidence_locations.py --root .` | EXIT 0, no output |
| Forbidden-path scan of the branch diff | `git diff --name-only 0ea7e577 HEAD \| grep -E '^artifacts/(baselines\|qa\|evidence\|coverage)/'` | no matches |

All feature evidence is under
`docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/evidence/` in the
canonical sub-paths `baseline/`, `regression-testing/`, `qa-gates/`, `issue-updates/` and `other/`.
No non-canonical evidence path is present. **PASS.**

## Policy Rule: modified-workflow-needs-green-run

**Does not fire.** The branch diff touches no path matching `.github/workflows/**`,
`.github/actions/**`, or `scripts/benchmarks/**`. Verified by
`git diff --name-only 0ea7e577 HEAD | grep -E '^\.github/(workflows|actions)/|^scripts/benchmarks/'`,
which returned no matches.

Note for the record: coverage evidence for this feature was produced by a `workflow_dispatch` of
the unmodified `.github/workflows/_poshqc.yml`. That is a use of the workflow, not a modification of
it, so the rule is not engaged by it.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Independence | PASS | Every new test registers its seams in `BeforeEach`/`BeforeAll`; no shared mutable fixture crosses `It` boundaries. The two `Describe` blocks in the matrix suite use separate `BeforeAll` bodies expressly so the two hooks' script-scope state does not collide (`CleanupWorktreeManifestGateMatrix.Tests.ps1:12-14`). |
| Isolation | PASS | One behavior per `It`. Each matrix case differs from one canonical fixture in exactly the property its case name states, so a deny is attributable to that property alone. |
| Fast execution | PASS | Per-suite times from the local JUnit: matrix 1.882s over 82 tests, module suite 0.092s over 7, epic gate suite 0.680s over 50, parallel gate suite 0.572s over 49. |
| Determinism | PASS | No wall-clock read: every clock value is a constructed `[datetime]::new(..., Utc)` returned by a mock of `Get-CleanupWorktreeManifestUtcNow`. No filesystem read: every manifest fixture is a literal JSON string returned by a mock of `Get-CleanupWorktreeManifestContent`. Mock bodies are built with `[scriptblock]::Create` from literal expression strings because a `-ModuleName` mock body executes in module session state. |
| Readability | PASS | Case names state the falsified condition; the matrix carries a per-condition comment block. |
| Line coverage >= 85% | PASS | Section 5. |
| Branch coverage | N/A by tool capability | Pester measures command and line coverage only; no PowerShell branch gate applies per `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`. This is a threshold exemption, not a measurement exemption. |
| No coverage regression on changed lines | PASS | `evidence/qa-gates/coverage-delta.2026-09-06T23-09.md` records both gate hooks improving against baseline run `34186767775` and no pre-existing file losing coverage. |
| Coverage exclusion policy | PASS | No production path was excluded. The opposite occurred: the new module was **added** to `CodeCoverage.Path` in both runsettings files, moving the CI denominator from 96 to 97 files. |
| Scenario completeness | PASS | 32 deny cases spanning conditions 1-9, 7 allow cases, 1 `preserved_files` isolation pin, 1 duplicate-resolution pin, each run against both gates (82 tests), plus 4 added `It` blocks per existing gate suite and 7 module unit tests. |
| Arrange-Act-Assert | PASS | Explicit in the module suite; structurally present in the table-driven matrix. |
| No external dependencies | PASS | No network, no process spawn, no live executable in any new test. |
| **No temporary files** | PASS | `grep -nE "TestDrive\|New-Item\|Out-File\|Set-Content\|GetTempPath\|New-TemporaryFile\|\[System\.IO\.File\]"` across all four suites returned no match. |
| Test file location mirrors production tree | PASS | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` to `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1`; the gate-matrix suite dot-sources both hooks and lives at `tests/scripts/claude-hooks/`. No colocation in the production tree. |

**Observation (not a finding against this feature).** The two locally failing tests named in section
6 fail because `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` does not mock
`Get-PrAuthorCheckpointContent`, and `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`
executes handlers that read the live checkpoint. Both are dependencies on mutable external state,
which the Determinism requirement above forbids. Neither file is changed by this feature; recorded
as a follow-up candidate in section 8, not as a finding against this branch.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Simplicity first | PASS | The predicate is a flat sequence of nine guarded early returns in the specified order. No indirection beyond the two seams the determinism rule mandates. |
| Reusability | PASS | The parse, normalization, lookup and predicate live once in `CleanupWorktreeManifest.psm1` and are consumed by both hooks. Neither hook re-implements the parse. |
| Extensibility | PASS | The three allow-sets are named script-scope constants. Widening any of them is a visible edit to a named constant that a test pins. |
| Separation of concerns | PASS | The module holds pure predicate logic plus two one-line I/O seams. Checkpoint policy stays in the hooks, which own the checkpoint seams; the module's `Test-CleanupManifestCheckpointCoversPath` takes an already-parsed object. |
| Mandatory toolchain loop | PASS | Section 7. Format, analyze and test completed in a single clean pass with no restart. |
| **500-line limit** | PASS | Per-file: epic gate 467, parallel gate 335, new module 415, epic gate suite 495, parallel gate suite 457, matrix suite 318, module suite 152. All under 500. |
| Fail fast and explicitly | PASS with note | The module deliberately raises nothing: every malformation resolves to `$null` or `$false`, so a consuming hook always reaches its own unchanged deny. This is the correct posture for a PreToolUse gate — a throw would surface as a hook error rather than a deny — and it matches the existing gates' documented conventions. The broad `catch` is confined to the two `ConvertFrom-Json` boundaries. |
| No silent error suppression | PASS | The two `try`/`catch` blocks set `$parsed = $null` and the caller then denies. The failure is not swallowed; it is converted into the safe decision. |
| Naming | PASS with a Low finding | Approved verbs throughout (`Get-`, `Test-`, `Find-`, `ConvertTo-`). One noun-prefix inconsistency recorded as F-05 in the code review. |
| Public API compatibility | PASS | Additive only. No existing exported function signature changed; no existing decision changed. |
| Dependencies | PASS | No new external dependency. The module imports nothing. |
| I/O boundaries | PASS | Exactly one filesystem read (`Get-CleanupWorktreeManifestContent`) and one clock read (`Get-CleanupWorktreeManifestUtcNow`), each behind its own named seam. |
| Module rigor tier | T1 (enforcement/authorization surface) | Coverage and determinism obligations are met; the untyped-escape-hatch and property-test gates do not have PowerShell analogues. |

## 3. Language-Specific Code Change Policy Compliance — PowerShell

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| PowerShell 7+ compatible | PASS | `Set-StrictMode -Version Latest`; no Windows PowerShell-only construct. `#Requires -Version 7.0` on the new suites. |
| Advanced functions with `CmdletBinding()` | PASS | All six exported functions. |
| Parameter attributes and validation | PASS | `[Parameter(Mandatory = $true)]` and `[ValidateNotNullOrEmpty()]` on `-RecordArrayName`; `[AllowNull()]`/`[AllowEmptyString()]` where a null input is a meaningful state. |
| `ShouldProcess` for state-changing actions | N/A | The module performs no state change. It reads and decides. |
| Avoid mutable script-scoped variables | PASS | The five script-scope variables are read-only constants. This is required by AC-19 and AC-20 and follows the `$script:AllowedMergeStatuses` precedent in both hooks. |
| Avoid `Invoke-Expression` | PASS | Absent. Confirmed by the no-Python guard suite, which also fails on `Invoke-Expression` and `iex`. |
| Approved verbs | PASS | PSScriptAnalyzer clean (section 7). |
| Under 500 lines | PASS | Section 2. |
| **No Python in enforcement hooks** | PASS | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` scans `.claude/hooks` and `.claude/lib`, so the new module is automatically in scope. Suite passes and its allowlist remains empty. Evidence: `evidence/qa-gates/no-python-guard-final.2026-09-06T23-09.md`. |
| Design seams (adapter seam for clock and filesystem) | PASS | Both seams are the "tiny helper" form the rule prescribes, not a generic runner framework. |
| **Change budget: <= 3 production and <= 3 test files per batch** | PASS | 3 production PowerShell files and 3 Pester test files, delivered in tracked batches. Evidence: `evidence/qa-gates/batch-{b,c,e,f}-budget-reset.2026-09-06T23-09.md` and `batch-{a,c}-suite.2026-09-06T23-09.md`. |
| Push-down parity | PASS | `diff -q` reports the repository copy and the `extensions/drm-copilot/resources/claude-customizations/` mirror identical for all four `.claude/**` files. Both PoshQC runsettings files carry the identical new entry. |

## 4. Language-Specific Unit Test Policy Compliance — PowerShell

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Pester 5.x, `*.Tests.ps1` naming | PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`. |
| `Describe`/`Context`/`It`, one behavior per `It` | PASS | Module suite uses five `Context` groupings; matrix uses two `Describe` blocks, one per hook. |
| Mock sparingly, prefer real code paths | PASS | Only the two module seams and the hooks' own checkpoint seams are mocked. The decision logic under test is executed for real end to end from `Invoke-*GateDecision`. |
| Never mock external executables directly | N/A | No executable is invoked. |
| Mock registration order | PASS | Seams registered in `BeforeEach` before any `Invoke-*GateDecision` call. |
| Mock signature parity | PASS | Seam mocks are parameterless, matching the parameterless seam functions. |
| No implicit working-directory assumption | PASS | Suites resolve paths through `Resolve-Path "$PSScriptRoot/../../../..."`. |
| Test Explorer / terminal parity | PASS by construction | No ambient PATH, profile or CWD dependency in any new test. |
| Coverage regression on changed lines is blocking | PASS | No regression; see section 5. |

## 5. Test Coverage Detail

Coverage is mandatory for every language with changed files. Changed-file inventory by extension
across the branch diff: 8 `.ps1`, 2 `.psm1`, 2 `.psd1`, 1 `.json`, 48 `.md`. **PowerShell is the only
coverage language with changed files.**

| Language | Changed files | Coverage artifact | Verdict |
| --- | --- | --- | --- |
| PowerShell | yes | `artifacts/poshqc-ci/final/powershell-coverage.koverage.xml` (CI run `34205298954`), mirrored into `evidence/qa-gates/final-coverage.2026-09-06T23-09.md` | **PASS** |
| Python | none (0 `.py` files changed) | not applicable | N/A |
| TypeScript | none (0 `.ts`/`.tsx` files changed) | not applicable | N/A |
| C# | none (0 `.cs` files changed) | not applicable | N/A |

### PowerShell figures

| Scope | Line coverage | Threshold | Verdict |
| --- | --- | --- | --- |
| Repo-wide | 8563 / 8971 = **95.4520%** | >= 85% | PASS |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` (new file) | 100 / 108 = **92.5926%** | >= 85% | PASS |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (modified) | 100 / 105 = **95.2381%** | >= 85% | PASS |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (modified) | 74 / 79 = **93.6709%** | >= 85% | PASS |

Branch coverage is not evaluated: Pester measures command and line coverage only, so no branch
percentage exists for PowerShell. Its absence is not recorded as FAIL, per the workflow contract and
`.claude/rules/powershell.md`.

### Independent verification of the coverage route (caller fact 2)

The caller asked that this be checked rather than assumed. Three checks were performed:

1. **Route validity.** AC-25 requires the self-hosted PoshQC invocation and excludes
   `mcp__drm-copilot__run_poshqc_test`. The CI step in `_poshqc.yml:41-42` imports the repository's
   own `PoshQC.psm1`, which binds `$script:PesterSettings` to the repository's
   `settings/pester.runsettings.psd1`, and calls the same `Invoke-PoshQCTest`. Omitting
   `-SettingsPath` in CI binds exactly the file the criterion's parenthetical passes explicitly.
   Only the host differs. The known environment defect the spec warns about — the MCP runner reading
   the installed extension's settings — is therefore avoided.
2. **The new file is in the denominator.** The downloaded coverage XML carries
   `<package name=".claude/lib/cleanup-manifest">` with `<sourcefile name="CleanupWorktreeManifest.psm1">`
   and its own `<counter type="LINE" missed="8" covered="100" />`. The report-level
   `counter type="CLASS" covered="97"` is one higher than the baseline run's 96, which is the direct
   observation that the `CodeCoverage.Path` entry took effect. This is the property AC-25 exists to
   secure and it is confirmed, not asserted.
3. **The measured tree matches the tree under review.** The coverage run's head is `05bbc4e1`, not
   the current head `4d5ecaca`. `git diff --name-only 05bbc4e1 4d5ecaca` returns **eight paths, all
   Markdown under the feature folder** (`plan`, `spec.md` checkbox state, and six evidence files).
   No PowerShell, JSON, or `.psd1` file changed between the measured head and the current head, so
   the figures apply to the current head's code tree.

**Verdict on caller fact 2: verified.** The route is the one AC-25 names, the new file is inside the
denominator, and the measurement applies to the head under review.

## 6. Test Execution Metrics

### CI (canonical environment)

Root element of `artifacts/poshqc-ci/final/pester-junit.xml`, produced by run `34205298954` at head
`05bbc4e1`, transcribed from the downloaded artifact:

```
<testsuites ... name="Pester" tests="4460" errors="0" failures="0" disabled="9" time="187.741">
```

Derived passed = 4460 - 0 - 0 - 9 = **4451**. Failed **0**. Run conclusion `success`. The artifact's
existence is itself positive evidence that Format, Analyze and Test all passed, because
`_poshqc.yml:44-52` carries no `if: always()` on the upload step.

### Local (this worktree)

Root element of `artifacts/pester/pester-junit.xml`:

```
<testsuites ... name="Pester" tests="4460" errors="0" failures="2" disabled="9" time="148.716">
```

Same 4460-test denominator, 2 failures.

### Per-suite results for the suites this work created or changed

| Suite | Tests | Passed | Failures | Errors |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` | 7 | 7 | 0 | 0 |
| `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` | 82 | 82 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 50 | 50 | 0 | 0 |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 49 | 49 | 0 | 0 |

97 tests are net new (82 matrix + 7 module + 4 per existing gate suite). The pre-existing counts in
the two gate suites (46 and 45) are unchanged, which is the mechanical form of the AC-06 non-widening
pin.

### Independent verification of the two local failures (caller fact 1)

The caller asked that the attribution be checked rather than assumed. Six checks were performed and
all six agree:

1. **The failing set is exactly two, mechanically enumerated.** `grep -n 'status="Failed"'` against
   the local JUnit returns exactly two `testcase` elements, at lines 1512 and 4848. No third.
2. **The checkpoint exists and carries the trigger.** `grep -o '"epic_mode"[^,]*'` against
   `artifacts/orchestration/orchestrator-state.json` returns `"epic_mode": true`.
3. **Failure 2 names its own cause in its message.** The recorded failure text is
   `enforce-epic-wave-barrier.ps1 x Bash: ... "permissionDecisionReason":"EPIC_WAVE_BARRIER_BLOCKED: '635' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint."`
   The feature key `'635'` in that message is this orchestration run's own checkpoint. This is direct
   evidence, not inference.
4. **Failure 1's mechanism is confirmed structurally.**
   `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:35` defaults `-CheckpointPath` to
   `artifacts/orchestration/orchestrator-state.json`; `:90` denies when `epic_mode` is true and no
   matching `--base` is present. `grep` for `Mock` across `enforce-pr-author-skill.Tests.ps1` shows
   `Get-PrAuthorCheckpointContent` is **not** among the mocked commands, so the read reaches disk.
5. **The discriminator holds.** The gate's scope filter at `:74` is
   `Test-CommandLineInvocation ... -SubcommandPath @('pr', 'create')`, so it constrains `gh pr create`
   only. The failing node is the `gh pr create` case; its immediate sibling
   `allows gh pr edit --body-file artifacts/pr_body_12.md when context exists` **passes** in the same
   run. A general breakage would have failed both. This is the discriminator the attribution predicts.
6. **CI is clean over the identical denominator.** `.gitignore:6` is `/artifacts`, so no such
   checkpoint exists on a runner. The CI JUnit for the same tree reports `tests="4460" ... failures="0"`
   — the same test count with zero failures.

**Verdict on caller fact 1: verified.** Both failures are attributable to this orchestration run's
own `epic_mode: true` checkpoint under gitignored `artifacts/`, read from disk by two hooks through
seams the affected suites do not mock. Neither failure is caused by this feature, and both are absent
in the canonical environment. Section 1 records the unmocked seam as a repository-level follow-up
candidate against files this feature did not change.

## 7. Code Quality Checks

| Check | Command | Result |
| --- | --- | --- |
| Format | `mcp__drm-copilot__run_poshqc_format` | PASS, no files auto-fixed on the final pass. `evidence/qa-gates/final-format.2026-09-06T23-09.md`; post-format no-diff confirmed by `evidence/qa-gates/post-format-no-diff.2026-09-06T23-09.md` |
| Lint | `mcp__drm-copilot__run_poshqc_analyze` | PASS, zero analyzer findings. `evidence/qa-gates/final-analyze.2026-09-06T23-09.md` |
| Type check | not applicable | PowerShell has no type-check stage per `.claude/rules/powershell.md` |
| Architecture boundaries | not applicable | No dependency-cruiser or NetArchTest surface in scope |
| Tests | `mcp__drm-copilot__run_poshqc_test` | PASS against the declared Known-Local-Red Inventory; CI PASS with 0 failures |
| Contract / schema | manifest contract | The `removals[]` and `preserved_files[]` shapes are defined identically in `spec.md` and in `SKILL.md`; `schema_version` is pinned to `1` and any other value fails closed |
| Coverage | `workflow_dispatch` of `_poshqc.yml`, run `34205298954` | PASS, section 5 |
| Push-down parity | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | PASS. `evidence/qa-gates/push-down-resource-contracts-state-exempt-final.2026-09-06T23-09.md` |
| Pack manifest completeness | `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` | PASS. `evidence/qa-gates/pack-manifest-completeness.2026-09-06T23-09.md` |
| No-Python guard | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | PASS, allowlist empty |
| Evidence locations | `python scripts/dev_tools/validate_evidence_locations.py --root .` | PASS, EXIT 0 |

The toolchain loop completed format, analyze and test in a single pass with no restart, which is what
AC-37 requires.

## 8. Gaps and Exceptions

### 8.1 Assessment of the central question: authorization decision or escape hatch

The change adds a path by which `git worktree remove` becomes permitted. The assessment below is
structural, drawn from reading the predicate and the branch placement, not from the executor's
characterization.

**The evidence that it is a real authorization decision:**

1. **The protected population is provably untouched.** Condition 10 is implemented as
   `Test-CleanupManifestCheckpointCoversPath`, a **presence** test, not an authorization test. If the
   target path appears in the epic checkpoint's `features[]` or the parallel checkpoint's `items[]`
   at all — regardless of that record's `merge_status`, and in the epic gate regardless of the
   parallel checkpoint's `route_id` — the manifest branch does not apply and control falls through to
   the unchanged deny. This is deliberately **broader than** the gates' own positive predicates,
   which do read `merge_status` and `route_id`. The manifest therefore cannot authorize a single
   removal that either checkpoint tracks. Pinned by AC-03 and AC-04, each of which uses a
   `merge_status` of `in_progress` so that a deny can only come from the exclusion.
2. **Branch placement preserves every existing decision.** The new branch runs after both existing
   positive predicates in the epic gate and after the single predicate in the parallel gate. It
   returns only `allow` and only from a position previously occupied by the deny. It cannot convert
   an existing allow into a deny, and cannot change the decision point at which an existing allow is
   returned. AC-06 pins this mechanically: the pre-existing test counts in both gate suites are
   unchanged at 46 and 45.
3. **The allow-set is narrow and named.** `branch_state` is restricted to exactly `NOT_MERGED` and
   `HAS_UNIQUE_RESIDUALS` — the two states the skill permanently forbids adding to the script's
   apply-mode allowlist, and therefore the only durable residual the manifest needs to serve.
   `PROTECTED_CURRENT` is never authorized. The three merged states and the detached case are
   excluded. `removal_disposition` is a single-member set. All three sets are script-scope constants
   pinned by named tests (AC-19, AC-20).
4. **The existing allow-set is not reused.** `removal_disposition` is a deliberately distinct key
   from `merge_status`, and `$script:AllowedMergeStatuses` is asserted unchanged in both hooks
   (AC-07). The manifest does not widen the checkpoint vocabulary; it introduces a parallel one with
   its own narrower rules.
5. **Both directions are pinned by tests.** 32 deny cases and 7 allow cases run against both gates
   (82 tests), covering conditions 1-9 exhaustively, plus the two condition-10 deny pins and the two
   fail-before allow cases. The fail-before evidence records the two allow tests failing against the
   unfixed hooks at exit code 4 before the fix landed, so the tests demonstrably discriminate.
6. **Freshness bounds the window.** `artifacts/` is gitignored, so a stale manifest would persist
   after its run ends. The 24-hour bound against an injected clock closes that, and the specification
   records — correctly — that the epic gate's existing "session-stamped paths make a stale collision
   implausible" argument does **not** transfer to cleanup targets, which are ordinary long-lived
   paths.

**The residuals, stated plainly:**

- **The manifest is written by the same agent that issues the removal, into a gitignored
  directory.** Anyone able to write a conforming manifest could authorize a removal. This is the same
  posture `enforce-pr-author-skill.ps1` takes for its receipt mechanism, it is recorded as such in
  D8 and restated in the skill text under "Accepted residual", and no acceptance criterion claims
  otherwise. The `bash <file>` indirection remains open and is documented as accepted, not closed —
  meaning this change does not raise or lower the weakest link, it makes the sanctioned route
  narrower than that weakest link. That is the correct relationship for a policy-level deterrent.
- **`evidence` is required to be a non-empty string but its content is not validated.** The
  specification says this field is what makes a record "an auditable verdict rather than a bare
  allowlist entry". Mechanically it is an allowlist entry plus a required, unvalidated string. No
  automated check can validate justification quality, so this is a correct design given the
  constraint, but the claim is stronger than the check. Recorded as F-12 (informational).
- **A `--force` spelling reaches the manifest allow.** Recorded as F-02 (Medium, non-blocking). See
  the code review.
- **Two contract fields declared fail-closed in the specification are unimplemented.** Recorded as
  F-01 (Medium, non-blocking). See the code review.

**Conclusion.** This is an authorization decision, not an escape hatch. The distinguishing property
is condition 10: the change deliberately declines to authorize anything the gates were already
protecting, and it declines on presence alone rather than on the gates' own authorization predicate,
which is the conservative choice at the one point where the two could have been confused. An escape
hatch would have reused the `merge_status` predicate there, or omitted the exclusion entirely; the
implementation does neither, and a named test would fail if it did.

### 8.2 Assessment of the three judgment calls referred by the caller

**Judgment call 1 — condition 8 encoded as an authorized-verdict subset rather than vocabulary
minus an exclusion list. The subset form is correct.**

The two are behaviourally identical today. They diverge only when the verdict vocabulary is extended,
and they diverge in opposite safety directions: the subset form leaves a newly added verdict
**unauthorized** (fail closed); the exclusion form would authorize it **by silence** (fail open).
Every other rule in this design fails closed on an unknown value — `schema_version` explicitly
"is not accepted by silence" for a forward version, `branch_state` denies on any value outside the
authorized set, `removal_disposition` denies on anything outside its single member. The exclusion
form would have been the only construct in the module that failed open, and it would have done so
silently at exactly the moment a new content classification was introduced. The module's own comment
states this rationale at the constant. `spec.md` condition 8's wording ("is in the vocabulary, and is
neither `GENUINELY_NEW` nor `STILL_RELEVANT`") describes the intended membership, not a required
implementation shape, and AC-15's four required test cases — absent, out of vocabulary,
`GENUINELY_NEW`, `STILL_RELEVANT` — all pass under the subset encoding and are present in the matrix.
**No finding. The choice is correct and should not be reversed.**

**Judgment call 2 — the manifest-write step added as a named section after triage step 10 rather
than as a new numbered step before step 9. Acceptable, with a Low finding.**

The stated reason is verified: AC-33 and the plan both cite "step 9" by number, and inserting a new
numbered step before it would have renumbered step 9 to step 10, falsifying both references. The
substance AC-32 requires is present — the section names
`artifacts/orchestration/cleanup-worktrees-manifest.json` and specifies all six top-level fields, all
six `removals[]` fields, and all ten `preserved_files[]` fields — and the section opens with an
explicit ordering directive in bold: "Write the manifest before step 9 of the Dirty Worktree Triage
Procedure acts on any `SAFE_TO_DELETE` verdict."

The residual risk is that a reader executing the procedure linearly reaches step 9 before reaching
the section that tells them to have written the manifest already. That risk is materially reduced
because step 9's own new text carries a forward reference — "the Sanctioned Removal Manifest
**below** carries a record for that exact path" — so a linear reader is pointed at the section at
the moment it becomes relevant and cannot silently miss it. The stronger form would have added a
one-line pointer at the head of the triage procedure rather than relying on the mid-step reference.
Recorded as F-07 (Low). **AC-32 and AC-33 both PASS.**

**Judgment call 3 — `spec.md` D6's must-not-touch list names constructs that do not exist at the
base commit. The executor's handling is correct and is independently confirmed.**

Verified directly against the anchor's own copies rather than against the working tree:

```
git show d250cf72:.claude/hooks/enforce-epic-worktree-removal-gate.ps1     | grep -n "Trim(|Test-CommandLineInvocation|Get-CommandLineOperand|Test-CommandLineFlag"
git show d250cf72:.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | grep -n ...
```

Both return only the #545 structural helpers (`Test-CommandLineFlag`, `Get-CommandLineOperand`,
`Test-CommandLineInvocation`) and **no** extraction regex string and **no** `.Trim('"''')` call. The
absence therefore predates this feature by exactly one merged sibling, and the protected role —
detection of the removal invocation and extraction of its operand — is carried at the base commit by
the helper call sites. Those call sites are byte-identical between `d250cf72` and `4d5ecaca` in both
hooks; the entire hook diff is three additions per file, all strictly after the `$worktreePath`
assignment, which is exactly the may-touch list D6 defines.

AC-31 is satisfied in substance: every construct named in the must-not-touch list that exists is
unchanged, and the role the two absent constructs used to carry is unchanged. Recorded for the
record: this confirms the epic resolved D6 toward **R6-B** (#545 widened to cover the two removal
gates), contradicting D6's stated recommendation of R6-A. That divergence is inconsequential here
precisely because the design was written to compose with either resolution — the manifest acceptance
sits entirely below the detection call site — which is the design property doing the work.
**AC-31 PASS.** Recorded as F-10 (informational) so the spec's stale list is not read later as an
unmet obligation.

### 8.3 Documented assumptions

- The conjunctive-denial premise (both gates must allow for a removal to proceed) is Claude Code
  runtime behavior and is not verifiable from repository content. `spec.md` D2 states it at that
  strength and no acceptance criterion asserts it; the criteria assert per-hook decision outputs
  only. This audit adopts the same posture and does not treat the premise as verified.
- MCP tooling (`resolve_policy_audit_template_asset`, `validate_orchestration_artifacts`) was not
  available in this agent's tool surface. The three artifacts were therefore constructed against the
  canonical section list enumerated in `.claude/skills/policy-audit-template-usage/SKILL.md` and
  `.claude/skills/feature-review-workflow/SKILL.md` rather than copied from a resolved MCP asset, and
  were not passed through the MCP validator. All required headings are present. This deviation is
  recorded here rather than left implicit.
- `pwsh` cannot be invoked in this worktree (runtime worktree-isolation guard), so no toolchain stage
  was re-executed during review. Every toolchain verdict in section 7 is read from pre-existing
  evidence artifacts and, where possible, cross-checked against the raw JUnit and coverage XML rather
  than against the artifact's own prose.

### 8.4 Follow-up candidates (not remediation)

1. F-01: implement or downgrade the `run_id` and `branch` fail-closed rules.
2. F-02: reject a `--force` spelling in the manifest branch.
3. The unmocked `Get-PrAuthorCheckpointContent` seam in `enforce-pr-author-skill.Tests.ps1` and the
   live-checkpoint read in `codex-pretooluse-integration.Tests.ps1`. Files not changed by this
   feature.
4. The four candidates `spec.md` already records: the `.codex` gate hook (D7), the
   `validate-bash.ps1` `git reset --hard` block (D10), the stale five-versus-six receipt-check
   docstring (D9), and the `bash <file>` indirection (D8).

## 9. Summary of Changes

| File | Change | Lines |
| --- | --- | --- |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | NEW. Path constant, three allow-set constants, read seam, clock seam, normalization, record lookup, allow predicate, checkpoint presence test | 415 |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | One `Import-Module`, one script-scope constant, one branch before the final deny | +23 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | Same three additions | +22 |
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | `allowed-tools` grant, step-4 `<N>` fix, step-9 removal authorization, new Sanctioned Removal Manifest section with contract and accepted-residual note | +158/-18 |
| `extensions/.../claude-customizations/.claude/**` | Byte-identical mirrors of all four | mirror |
| `extensions/.../claude-customizations/pack-manifests/core.json` | +1 module entry | +1 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror | +1 `CodeCoverage.Path` entry each | +6 each |
| `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` | NEW. 82 tests | 318 |
| `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` | NEW. 7 tests | 152 |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | +4 tests | +67 |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | +4 tests | +65 |

No-diff pins verified by `git diff --stat 0ea7e577 HEAD -- <paths>` returning empty output for:
`.claude/lib/hook-payload/HookPayload.psm1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`,
`.claude/hooks/validate-bash.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, and the four
`scripts/bash/cleanup_worktrees*` files.

## 10. Compliance Verdict

| Section | Verdict |
| --- | --- |
| 1. General unit test policy | PASS |
| 2. General code change policy | PASS |
| 3. PowerShell code change policy | PASS |
| 4. PowerShell unit test policy | PASS |
| 5. Coverage (PowerShell) | **PASS** |
| 5. Coverage (Python, TypeScript, C#) | N/A — zero changed files in each |
| 6. Test execution | PASS |
| 7. Code quality checks | PASS |
| Evidence location compliance | PASS |
| modified-workflow-needs-green-run | Not triggered |
| Acceptance criteria (37 of 37) | PASS |

**Overall: PASS. Remediation is not required.** No FAIL result, no PARTIAL result, no blocking code
review finding, no failing toolchain stage, no coverage shortfall, and no unmet acceptance criterion.
`remediation-inputs.<timestamp>.md` was therefore not produced, and no remediation plan was
requested.

## Appendix A: Test Inventory

| Suite | Tests | New | Purpose |
| --- | --- | --- | --- |
| `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1` | 7 | 7 | Module unit surface: the two vocabulary constants (AC-19, AC-20), path normalization, first-match lookup, keyless-record skip, the conforming allow predicate, and checkpoint presence coverage |
| `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` | 82 | 82 | Fail-closed matrix: 32 deny cases across conditions 1-9, 7 allow cases, 1 `preserved_files` isolation pin, 1 duplicate-resolution pin, each run against both gates |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | 50 | 4 | Manifest allow (AC-01), condition-10 epic deny pin (AC-03), unchanged block reason (AC-05), `AllowedMergeStatuses` pin (AC-07) |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 49 | 4 | Manifest allow (AC-02), condition-10 parallel deny pin (AC-04), unchanged block reason (AC-05), `AllowedMergeStatuses` pin (AC-07) |
| **Total** | **188** | **97** | |

Deny-case distribution by condition: C1 3, C2 5, C3 4, C4 3, C5 1, C6 3, C7 3, C8 4, C9 6. Allow-case
distribution: C3 1 (at-bound), C5 4, C9 2.

## Appendix B: Toolchain Commands Reference

Commands run by this review (check-only, no mutation of source or policy):

```
git -C <worktree> merge-base origin/epic/cleanup-merged-worktrees-hardening-integration HEAD
git -C <worktree> diff --stat 0ea7e577 HEAD -- .claude .codex extensions scripts tests
git -C <worktree> diff --stat d250cf72 4d5ecaca -- <no-diff pin paths>
git -C <worktree> diff --name-only 05bbc4e1 4d5ecaca
git -C <worktree> show d250cf72:.claude/hooks/enforce-epic-worktree-removal-gate.ps1
git -C <worktree> show d250cf72:.claude/hooks/enforce-parallel-worktree-removal-gate.ps1
git -C <worktree> status --porcelain
diff -q .claude/<file> extensions/drm-copilot/resources/claude-customizations/.claude/<file>
wc -l <seven changed or added PowerShell files>
grep -n "396" .claude/skills/cleanup-merged-worktrees/SKILL.md
grep -nE "TestDrive|New-Item|Out-File|Set-Content|GetTempPath|New-TemporaryFile|\[System\.IO\.File\]" <four suites>
grep -n 'status="Failed"' artifacts/pester/pester-junit.xml
grep -o '"epic_mode"[^,]*' artifacts/orchestration/orchestrator-state.json
python scripts/dev_tools/validate_evidence_locations.py --root .
python -m scripts.dev_tools.pr_context.collector --base origin/epic/cleanup-merged-worktrees-hardening-integration --head HEAD --repo-root .
```

Commands whose results were read from pre-existing evidence rather than re-executed, because `pwsh`
cannot start in this worktree under the runtime worktree-isolation guard:

```
mcp__drm-copilot__run_poshqc_format
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test
gh workflow run _poshqc.yml --ref bug/cleanup-worktrees-sanctioned-removal-manifest-635-r2
gh run view 34205298954 --json databaseId,headSha,status,conclusion,createdAt,updatedAt,event
gh run download 34205298954 --name poshqc-test-results --dir artifacts/poshqc-ci/final
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root . -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
```
