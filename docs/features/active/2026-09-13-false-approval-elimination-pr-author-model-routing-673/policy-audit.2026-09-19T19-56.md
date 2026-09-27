# Policy Compliance Audit — Issue #673 (also closes #672)

Timestamp: 2026-09-19T19-56
Reviewer: feature-review
Branch: `bug/false-approval-elimination-673`
Base branch: `main`, merge base `b7c11616`
Head: `4b45ca7f`, ten commits
Work mode: `full-bug`; acceptance-criteria sources are `spec.md` in each of the two feature folders
Scope: the full branch diff against the resolved base branch — 147 changed files, 11837 insertions,
598 deletions

## Executive Summary

The change removes three process-directory bindings through which an enforcement gate could validate
one item's action against a sibling item's orchestrator checkpoint and return allow. It replaces them
with portable-identity resolution in a new library module, migrates a fourth gate to the same
mechanism (which closes issue #672), and states the checkpoint-hygiene and delegation-identity rules
the mechanism depends on in three orchestration skills.

**Overall policy verdict: PASS.** Every mandatory gate defined by the repository's policy files is
met. Findings: **0 Blocking, 2 Important, 8 Advisory.** No finding blocks merge.

Every figure in this audit was derived from primary artifacts by this reviewer rather than read from
the executor's summaries. Specifically: the coverage and JUnit reports were parsed directly and every
per-file percentage and changed-line percentage was recomputed; all ten mirror-pair digests and both
pinned frozen-surface digests were recomputed; four Python suites were re-executed; the
evidence-location validator was run; all 147 changed files were scanned for host tokens with every hit
examined line by line; commit ordering was reconstructed from the commit log; and artifact freshness
was established by comparing every changed file's last-write time against the report write times.

| Area | Verdict |
| --- | --- |
| Tonality policy | PASS |
| General code change policy | PASS |
| General unit test policy | PASS |
| Module rigor tier gates | PASS |
| PowerShell language policy | PASS |
| Coverage verification | PASS |
| Evidence location compliance | PASS |
| Policy documents unmodified | PASS |

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller. The delegation prompt states, verbatim:

> `Scope determination is yours. Execute the full contract; do not narrow it.`

The prompt did name one already-accepted deviation and asked that it not be reported as a new finding
while explicitly inviting disagreement. That instruction does not narrow the audit. Coverage
verification was performed independently and in full for every language with changed files, every
figure was recomputed rather than accepted, and the reviewer's assessment of the deviation — including
one qualification that raises rather than lowers the priority of the planned follow-up — is recorded
in section 8 and in `code-review.2026-09-19T19-56.md`.

No caller instruction supplied a non-canonical evidence path, so no
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` entry is recorded.

## Evidence Location Compliance

- `scripts/dev_tools/validate_evidence_locations.py --root .` exited **0** with no output, on two runs.
- The 147-path branch diff was scanned for files written under `artifacts/baselines/`,
  `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. **Zero matches.**
- All evidence produced by the change set sits under the canonical
  `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/<kind>/`
  layout, with `baseline/`, `other/`, `qa-gates/` and `regression-testing/` as the kinds used.
- The four review artifacts this reviewer writes are placed in the feature folder root, which is
  their canonical location, not under `artifacts/`.

## 1. General Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Independence — any order | PASS | The one wrapper that changes the process directory captures both the PowerShell location and the .NET current directory before its `try` and restores both in its `finally`, so a throwing row cannot leak the change. Read at `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` lines 67-77. |
| Isolation — one behaviour per test | PASS | One `It` per behaviour. Each matrix row states one resolution outcome through a mocked seam, so a failure identifies the row's own condition. |
| Fast execution | PASS | 4963 rows in one Pester run; the four Python suites re-executed here returned in 0.24 seconds. |
| Determinism | PASS | No changed test reads a wall clock or touches the network. The pre-existing model-routing suite's new `BeforeEach` pins the resolution seam to the session root specifically so its rows stay independent of whichever worktrees exist on the running machine, and every presence-gating row in that file mocks the checkpoint reader, so no live checkpoint is read. |
| Readability and maintainability | PASS | Rows are named by matrix row identifier and asserted condition; every new file carries a synopsis-and-description header stating its subject and its determinism position. |
| Line coverage at or above 85% | PASS | Recomputed; see sections 1.2 and 5. |
| Branch coverage at or above 75% | Not applicable to PowerShell | Pester measures command and line coverage only. Per `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md` no branch-coverage gate applies to PowerShell. This is a threshold exemption, not a measurement exemption; PowerShell production files remain in the denominator. |
| No regression on changed lines | PASS | Recomputed; 100% on all six modified hooks, 99.06% on the new module. |
| No production file excluded from coverage | PASS | The change adds one coverage entry and removes none. The new module was added to `CodeCoverage.Path` in both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled counterpart. No `exclude` entry matching a production source path was introduced. |
| Scenario completeness | PASS | Ten matrix rows per hook family covering resolved, unresolved, absent, empty, unparseable, double-checkout, disagreeing-identity and out-of-scope conditions, plus rows asserting that the genuine-absence reason and the target-resolution reason never appear in each other's decisions. |
| Arrange–Act–Assert | PASS | Present and labelled in both new structural guards; the matrix suites follow the same three-part shape. |
| No external dependencies | PASS | No network, database or live executable. Fixtures are committed bytes under `tests/fixtures/worktree-resolution/`. |
| No temporary files in tests | PASS | Independently confirmed: no changed test file references a temporary-file API, the Pester scratch drive, or the temporary-directory environment variable. The two rows needing a real readable file point at already-committed repository files. |
| Test files mirror source layout | PASS | Library tests under `tests/scripts/claude-lib/worktree-resolution/`, hook tests under `tests/scripts/claude-hooks/`, the two cross-cutting contract guards under `tests/scripts/claude-runtime/` per the repository's pre-existing convention for guards with no single production counterpart. No test file was placed in a production source tree. |
| Documentation per test | PASS | Every new file carries a header; every row's name states its scenario. |
| Contract and schema tests at host boundaries | PASS | `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` is unedited (empty diff, verified) and passes. Bundled-payload parity, pack-manifest completeness and PoshQC-settings parity suites were re-executed by this reviewer and pass. |
| Determinism infrastructure | PASS | No banned wall-clock, sleep or delay API appears in any changed test file. |

### 1.1 Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
| --- | --- | --- | --- | --- | --- | --- |
| PowerShell | 29 `.ps1`, 2 `.psm1`, 2 `.psd1` | 4963 | 0 failures, 0 errors, 9 pre-existing skips | 95.72% line, repo-wide | 95.77% line, repo-wide | 99.06% on the one new module; 100% changed-line on all six modified hooks |
| Python | 1 test-support file | 4419 | 0 failures, 5 pre-existing skips | N/A — no production Python file changed, so the Python coverage denominator is unchanged by this branch | N/A — same reason | N/A — the one changed file is expected-value test data, which the Coverage Exclusion Policy places outside the denominator |
| TypeScript | 0 | 0 | N/A — nothing to run | N/A — zero changed files | N/A — zero changed files | N/A — zero changed files |
| C# | 0 | 0 | N/A — nothing to run | N/A — zero changed files | N/A — zero changed files | N/A — zero changed files |

### 1.2 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: not applicable. Zero TypeScript files changed on this branch, so no TypeScript coverage obligation attaches and `coverage/lcov.info` was neither required nor produced for this run.
- TypeScript post-change coverage artifact: not applicable for the same reason. The branch touches no `.ts` or `.tsx` file, which was confirmed from the changed-file inventory in `artifacts/pr_context.appendix.txt` and from the extension histogram in the same artifact.
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/evidence/baseline/r3-phase0-pester-coverage.md`, which records repo-wide line coverage of 95.72% with 9487 lines covered and 424 not covered, plus a per-file figure for each of the six in-scope hooks.
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml`, parsed directly by this reviewer. Its report-level line counter reads 9603 covered of 10027 instrumented, which is 95.77%, and the figure agrees exactly with an independent sum over every source file element.
- Per-language comparison summary: PowerShell moved from 95.72% to 95.77% repo-wide with changed-line coverage at 100% on all six modified hooks and 99.06% on the new module, while Python, TypeScript and C# carry no coverage obligation on this branch. The per-language bullets are in section 1.2.1 below.

### 1.2.1 Per-Language Coverage Comparison

- PowerShell: Baseline: 95.72% repo-wide line coverage. Post-change: 95.77% repo-wide line coverage. Change: +0.05 points repo-wide, with the count of lines not covered steady at 424 across both runs. New/changed-code coverage: 99.06% on the one new module and 100% changed-line coverage on every one of the six modified hooks. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` recomputed by this reviewer for the post-change figures, with the baseline figures read from `evidence/baseline/r3-phase0-pester-coverage.md`.
- Python: Baseline: N/A. Post-change: N/A. Change: none, because no production Python file changed. New/changed-code coverage: N/A. Disposition: N/A. Evidence: the single changed Python file is `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, whose eight changed lines are a comment and one expected-digest value; both of its pinned digests were recomputed by this reviewer and both match, and the four suites that consume it were re-executed and returned 53 passed.
- TypeScript: Baseline: N/A. Post-change: N/A. Change: none. New/changed-code coverage: N/A. Disposition: N/A. Evidence: zero TypeScript files in the 147-path branch diff.
- C#: Baseline: N/A. Post-change: N/A. Change: none. New/changed-code coverage: N/A. Disposition: N/A. Evidence: zero C# files in the 147-path branch diff.

Recorded for completeness rather than elided: `artifacts/python/lcov.info` was not produced for this
run. A literal reading of the artifact-presence rule would return FAIL for any language with a changed
file. PASS is recorded for Python because the coverage denominator is provably unchanged — the only
changed Python file is test-support data, which `.claude/rules/general-unit-test.md` places outside the
denominator — and because that file's correctness was verified directly rather than inferred, by
recomputing both pinned digests and re-executing the four consuming suites.

## 2. General Code Change Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Simplicity first | PASS | Eight exported functions and two private decision helpers in the new module; each decision arm is one early return. The two resolved target states collapse into one switch arm in both gates because the path is now composed identically for both. |
| Reusability | PASS | Neither reason-code literal and no derivation, normalisation or ambiguity-code logic is re-implemented. A content search for both code spellings across `.claude/hooks/` and `.claude/lib/` matches only the two definitions at `.claude/lib/worktree-resolution/WorktreeResolution.psm1` lines 55 and 59 and two doc-comment mentions at 466 and 478. |
| Extensibility | PASS | All public functions use `CmdletBinding()` with named parameters and a declared output type; the session-root parameter is optional with a documented default. The four-state result shape is produced only by the single pre-existing constructor. |
| Separation of concerns | PASS | The module's only filesystem read and its only enumeration are isolated as the two declared seams; pure normalisation and signal scanning reach no disk. |
| Module rigor tier classified | PASS | These are runtime enforcement surfaces, not `quality-tiers.yml` projects. No project entry was added, so the tier-classification stage is unaffected, and the uniform gates apply and are met. |
| Seven-stage toolchain, one clean pass | PASS | See section 7. |
| File size limit of 500 lines | PASS | See section 9. |
| Fail fast and explicitly | PASS | Three module imports are unguarded at script scope, using stop-on-error semantics in the module and in two of the three gates, with a comment at each site stating that a resolver which cannot load is itself the unresolvable state and must not degrade to the permissive path it replaces. |
| No silent error swallowing | PARTIAL | Two readers in the new module use a broad catch that returns null without logging. Both are documented as returning null for absent-or-unreadable, and null propagates to a deny, so the direction is fail-closed and no failure becomes an allow. The cost is diagnostic only: a permission error and an absent file yield the same detail text. Recorded as Advisory A-7, not Blocking. |
| Naming | PASS | Approved verbs throughout. The `ConvertTo-` verb on the private result builder is chosen and documented specifically to avoid a state-changing-verb analyzer finding rather than suppressing it. |
| Public API compatibility | PARTIAL | Three hook-internal seams gained a mandatory checkpoint-path parameter, losing a relative default. Every in-repo caller was updated, and a structural guard asserts that fact against the parsed syntax tree. These functions have no consumer outside their own hook. One documentation consequence is Advisory A-6. |
| Dependencies | PASS | No package added. All imports are repository-local modules. |
| I/O boundaries | PASS | Domain logic is testable without disk; the three filesystem touches are named seams. |
| Temporary files in tests prohibited | PASS | Confirmed independently; see section 1. |

## 3. Language-Specific Code Change Policy Compliance

PowerShell is the only production language changed. `.claude/rules/powershell.md` applies.

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Toolchain order: format, analyze, test | PASS | Recorded in the three final gate artifacts and corroborated independently from the JUnit report; see section 7. |
| PowerShell 7 or later | PASS | The new module documents PowerShell 7 or later and uses only compatible constructs; new test files declare a version requirement of 7.0. |
| Advanced functions with `CmdletBinding()` | PASS | Every function added carries it, with a declared output type and named parameters marked mandatory where required. |
| No global or mutable script-scoped state | PARTIAL | One script-scope variable moved from a constant to state assigned inside a function and read by a later block in the same file, where the equivalent local was already in scope. No defect follows: both blocks are guarded by the identical condition, so the assignment always precedes the read. Recorded as Advisory A-3. |
| No `Invoke-Expression`, no hard-coded credentials or host paths | PASS | None present. The host-token scan in section 8 confirms no drive-letter or user-profile path in any delivered production or test file. |
| Approved verbs and descriptive nouns | PASS | Zero analyzer findings at any severity in the final pass. |
| Cohesive and under 500 lines | PASS | See section 9. |
| Change budget respected | PASS | Routed through the large path with an atomic plan, so the direct-mode two-file cap does not apply. Work was executed in phase batches, each within the per-batch cap. |
| Design seams minimal | PASS | Each gate adds exactly one one-line resolution seam wrapping the library call, justified in its doc-comment by the determinism policy. No generic runner framework introduced. |
| No analyzer debt deferred | PASS | Eleven suppression attributes were added, all in test files, each naming a single rule on a single function with a justification stating the function changes no system state. Zero suppressions were added to production code. |

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Verdict | Evidence |
| --- | --- | --- |
| Pester 5 as the framework | PASS | New test files declare a Pester module requirement of 5.0.0 or later and use `Describe`, `Context` and `It`. |
| Test files named with the framework suffix | PASS | Every new test file uses the `.Tests.ps1` suffix; the one shared helper is a plain `.ps1` dot-sourced by two suites and carries no `Describe` block. |
| One behaviour per `It` | PASS | Verified by reading all four new suites. |
| Mock the wrapper, never the executable | PASS | No test mocks a source-control executable. Worktree enumeration is reached only through the declared seam, which is what the suites mock. |
| Mock signature parity | PASS | The four analyzer findings about mock-body parameters declared but not read were fixed by removing the unread declarations rather than by suppressing them. |
| Mock registration order preserves Test Explorer parity | PASS | Mocks are registered in `BeforeAll` or `BeforeEach` blocks before the code under test can resolve the command. |
| Dot-source and import order for script-function imports | PASS | Each suite imports the modules it needs explicitly and dot-sources the hook under test in the test scope; one recorded smoke case proves a mock registered in the test scope is observed by a caller defined in the other dot-sourced file. |
| Deterministic: no network, no mutable machine state, no implicit working directory | PASS | Confirmed. The single directory-changing wrapper sets the directory explicitly as the behaviour under test and restores it in a `finally`. |
| Line coverage at or above 85% | PASS | See section 5. |
| No branch-coverage gate for PowerShell | Confirmed | Pester emits no branch counter; the report-level counters are instruction, line, method and class only. |
| Coverage regression on changed lines is blocking | PASS | Changed-line coverage is 100% on all six modified hooks. |
| No assertion weakened to pass | PASS | Filtering the diff of the three files holding the seven protected regression rows to lines carrying a test name or an assertion returns **zero** changed lines. |

## 5. Test Coverage Detail

Method: `artifacts/pester/powershell-coverage.xml` was parsed directly. Per-file covered and
not-covered line counts were summed from the line elements. Changed-line coverage was computed by
intersecting the added-line numbers of the base-to-head diff for each file with the instrumented lines
in the report and counting those with a non-zero hit count.

Freshness, verified rather than assumed: the coverage and JUnit reports were written at 19:22:12Z and
19:23:43Z. Every production and test file in the change set has a last-write time earlier than both,
the latest being 19:17:28Z. The three commits timestamped after the run touch only documentation and
evidence, except one whose six small test-file edits — the suppression additions from the first pass of
the quality loop — were written at 19:16:05Z and committed afterwards. The reports therefore reflect
the content at head.

| File | New or modified | Covered / not covered / total | Line % | Changed-line % | Verdict |
| --- | --- | --- | --- | --- | --- |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | new | 105 / 1 / 106 | 99.06% | 99.06% | PASS |
| `.claude/hooks/enforce-pr-author-skill.ps1` | modified | 46 / 4 / 50 | 92.00% | 100% | PASS |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | modified | 87 / 3 / 90 | 96.67% | 100% | PASS |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | modified | 24 / 2 / 26 | 92.31% | 100% | PASS |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | modified | 54 / 3 / 57 | 94.74% | 100% | PASS |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | modified | 84 / 9 / 93 | 90.32% | 100% | PASS |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | modified | 57 / 2 / 59 | 96.61% | 100% | PASS |

The new file clears the 90% new-file threshold. Every modified file clears the 85% uniform floor and
the 80% modified-file threshold. Repo-wide PowerShell line coverage is 95.77%, well above the 80%
repo-wide flag threshold. No branch threshold applies to PowerShell.

Lines not covered, enumerated so the residue is visible rather than asserted absent:

- New module: line 206, the branch-filtered arm of the enumerator call inside the liveness seam.
- prd gate: lines 173, 174, 177, 180, 181, 183 — the read, parse, parse-failure and field-extraction
  arms of the checkpoint-folder reader, whose absent-file early return at line 168 **is** covered — and
  lines 473, 475, 477, the entry-point tail a dot-sourced test cannot reach.
- prd helpers: lines 132 and 144, inside the folder-token normaliser.
- pr-author hook: lines 309, 310, 311, 314. pr-author helpers: lines 180, 196, 219. Epic base-branch
  sibling: lines 44 and 97. Model-routing gate: lines 271, 273, 275. All are entry-point tails or
  branches the suites do not drive; none was introduced by this change.

## 6. Test Execution Metrics

| Metric | Baseline at merge base | Head at `4b45ca7f` | Source |
| --- | --- | --- |  --- |
| Pester rows executed | 4871 | 4963 | Baseline artifact; head recomputed from `artifacts/pester/pester-junit.xml` |
| Pester passed | 4862 | 4954 | Same |
| Pester failed | 0 | 0 | Same; root element records zero failures |
| Pester errored | 0 | 0 | Same; root element records zero errors |
| Pester skipped | 9 | 9 | Same; pre-existing skips, unchanged |
| Pester testsuites | not recorded | 209 | Recomputed by this reviewer |
| Python tests passed | not re-derived | 4419 | `evidence/qa-gates/r3-final-pytest.md` |
| Python tests skipped | not re-derived | 5 | Same; pre-existing |
| Python suites re-executed by this reviewer | not applicable | 53 passed, 0 failed | Direct execution of the four suites named by acceptance criteria |

New rows added by the change set, recomputed from the JUnit report by testsuite name: 27 in the
library module suite, 18 in the pr-author matrix suite, 20 in the model-routing matrix suite, 13 in the
prd identity suite, 2 in the orchestrator-state value-contract suite, 7 in the checkpoint-hygiene
contract suite, 8 in the checkpoint-path structural guard. All pass.

## 7. Code Quality Checks

| Stage | Result | Source |
| --- | --- | --- |
| 1. Formatting | Zero files reformatted, 506 already formatted, porcelain output identical; the Python formatter reports one file unchanged | `evidence/qa-gates/r3-final-poshqc-format.md`, `r3-final-black.md` |
| 2. Linting | Zero analyzer findings at Error, Warning and Information severity; the Python linter reports all checks passed | `r3-final-poshqc-analyze.md`, `r3-final-ruff.md` |
| 3. Type checking | Zero errors, warnings and informations from the Python type checker; not applicable to PowerShell per its rule file | `r3-final-pyright.md` |
| 4. Architecture-boundary tests | Not applicable, supported by a measured count of zero architecture-boundary tooling references under `tests/scripts` | `r3-seven-stage-loop.md` |
| 5. Unit tests | 4954 passed, 0 failed, 0 errored, 9 pre-existing skips; Python 4419 passed with 5 pre-existing skips | `r3-final-pester-coverage.md`, `r3-final-pytest.md`, corroborated from the JUnit artifact |
| 6. Contract and schema checks | Bundled-payload parity passes; all ten mirror pairs byte-equal; the worktree-resolution manifest suite passes 10 of 10; the frozen-surface pin passes with one digest re-baselined and the other unchanged | `r3-final-mirror-gate.md`, plus digest recomputation and suite re-execution by this reviewer |
| 7. Integration tests | The two fixture matrices run against committed fixture bytes with real checkpoint reads, 18 and 20 rows; the end-to-end row spawns a real child process and passes | JUnit report, rows read by name |

Single-pass status: the clean pass is pass 2. Pass 1 is disclosed rather than hidden: it failed at the
analyzer stage with 15 Warning-severity findings in test files this change authored — eleven on
factory and mock-registration helper verbs, four on mock-body parameters declared but not read. The
eleven took a narrow suppression with a justification matching a pattern the repository already applies
to pre-existing helpers in the same situation; the four unread parameter declarations were removed. Six
test files changed, so the loop restarted from formatting as the policy requires. In pass 2 no step
failed and no step changed a file.

Digest and parity checks performed by this reviewer rather than accepted:

- Ten mirror pairs recomputed by SHA-256 between `.claude/` and the bundled payload tree: **all equal**.
- Both pinned frozen-surface digests recomputed from the working tree: **both match** the committed
  values, including the one deliberately left unchanged, so the pin still fails loudly on an
  unintended edit to the agent file.
- Four Python contract suites re-executed: **53 passed**.

## 8. Gaps and Exceptions

### 8.1 The one condition on the branch that is not met

Plan task `[P11-T5]` carries a whole-file coverage no-regression sub-condition. Two files fell: the prd
gate from 90.72% to 90.32%, its helpers from 96.77% to 96.61%. The task is left unchecked in the plan
and the shortfall is recorded in a dedicated evidence artifact rather than argued into compliance.

Independently confirmed by this reviewer: the post-change counts of lines not covered are 9 and 2;
changed-line coverage is 100% on both files; the repository floor of 85% holds with the lowest in-scope
figure at 90.32%; repo-wide PowerShell line coverage rose. `.claude/rules/general-unit-test.md` states
the no-regression rule over the lines that were changed, and that rule is satisfied. **No repository
policy is violated.** The unmet condition is the plan's own stricter whole-file sub-condition, and the
arithmetic explanation is correct: deleting covered code lowers a covered-over-total ratio while
leaving the count of untested lines where it was.

The reviewer's one qualification, which raises rather than lowers the priority of the planned
follow-up: in **both** regressed files the lines not covered sit on code paths this change re-pointed.
Six of the gate's nine are the read, parse and field-extract body of the checkpoint-folder reader —
the function whose parameter contract this change made mandatory and whose input changed from a
process-relative literal to an absolute resolved path. Both of the helpers' two are inside the
folder-token normaliser, which the renamed selector now calls with the checkpoint value. So the
follow-up closes a verification gap on the change's own altered contract rather than repairing a ratio.
Recorded as Important finding I-2.

### 8.2 Host-data containment, the change's own gate applied to the change

The branch's criterion AC-38 forbids a drive-letter path, a user-profile path, or the executing
account name in any added or modified file, exempting three superseded plan documents. All 147 changed
files were scanned independently.

- Genuine carriers: **two**, both inside the exempt set — one superseded plan dated 2026-09-13 and one
  dated 2026-09-18. The operative plan dated 2026-09-19 and the third exempt plan carry zero.
- Four further scan hits were examined line by line and are **false positives of the scan pattern**,
  not host data: one regular-expression literal in the prd helpers at line 52 whose escape sequence
  resembles a drive-letter path, its byte-identical bundled mirror, and one issue-URL line in each of
  the two `spec.md` files.
- Evidence artifacts that formerly carried host paths are redacted to bracketed placeholders, confirmed
  by reading the two reproduction control pairs in full.

The four review artifacts produced by this review contain no absolute filesystem path, drive letter,
user-profile path or account name; a scan of all four returns zero hits. Where a literal would have
matched such a scan — the branch-signal regular expression at
`.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` line 61, and the work-mode marker
pattern in the prd helpers at line 52 — it is named by file, line and role instead of reproduced.

### 8.3 Findings index

Full statements, reasoning and recommended actions are in `code-review.2026-09-19T19-56.md`.

| ID | Severity | Statement |
| --- | --- | --- |
| I-1 | Important | The new fail-closed identity requirement is stated in one orchestration skill, while two other surfaces that issue receipt-gated delegations do not state it, so those flows can be denied until their prompts are amended. |
| I-2 | Important | The checkpoint-folder reader's read, parse and field-extract body has zero direct coverage, and this change altered that function's parameter contract. |
| A-1 | Advisory | The consumed branch-signal pattern can match a prose phrase, and this change promotes it to a primary worktree selector on two prompt-reading gates. Mitigated twice; residual exposure is narrow. |
| A-2 | Advisory | The prd gate's document probe stays process-directory-relative for a session-root target. Spec-sanctioned, pre-existing, and fails toward a false denial. |
| A-3 | Advisory | A script-scope constant became mutable script-scope state where an explicit parameter pass was available. |
| A-4 | Advisory | The new structural guard's in-scope file list omits the prd helpers sibling. |
| A-5 | Advisory | Three issue #672 criteria are checked off under narrowings their text does not permit, all authorised by issue #673's AC-37 and stated openly in the evidence. |
| A-6 | Advisory | Five acceptance criteria still say "ambiguity reason code" where the delivered tests assert the no-target code; the reconciliation lives in a separate restated-conditions table. |
| A-7 | Advisory | Two library readers swallow a read or parse failure without a distinguishing diagnostic. Fail-closed; diagnostic cost only. |
| A-8 | Advisory | Two small redundancies: a dead conjunct in the probe-anchoring guard, and a duplicated ascent per resolved call. |

### 8.4 Exceptions claimed and accepted

| Exception | Basis | Accepted |
| --- | --- | --- |
| Architecture-boundary stage recorded not applicable | Measured count of zero architecture-boundary tooling references under `tests/scripts` | Yes — the plan authorises this one entry and the measurement supports it |
| No branch-coverage figure for PowerShell | Pester emits no branch counter; confirmed from the report-level counters | Yes — a capability limit stated in two rule files |
| Fail-before run impossible for one row | Issue #687 had already delivered that behaviour before this plan's first task; an exception dossier names three substitute records | Yes — declaring the exception is the correct handling |
| Whole-file coverage no-regression on two files | See 8.1 | Accepted by the orchestrator; confirmed here to breach no repository threshold |

## 9. Summary of Changes

| Dimension | Value |
| --- | --- |
| Files changed | 147 — 97 Markdown, 29 `.ps1`, 13 `.json`, 3 `.txt`, 2 `.psd1`, 2 `.psm1`, 1 `.py` |
| Insertions / deletions | 11837 / 598 |
| Production files changed | 6 hooks plus 1 new library module, each with a byte-identical bundled mirror; 2 PoshQC settings files; 1 pack manifest; 3 skill documents |
| Test files added | 7 suites plus 1 shared dot-sourced helper |
| Test files modified | 9 |
| Fixture files added | 19 committed fixtures plus one fixture README |
| Largest production file | `.claude/hooks/enforce-prd-feature-before-planner.ps1` at 477 lines |
| Largest test file | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` at 499 lines |
| New library module | 392 lines |
| File-size cap breaches | None. The orchestrator-state module is 499 lines, unmodified, and pinned to that exact count by a test row |
| Policy documents modified | None |
| Protected enforcement surfaces modified | None. Verified by explicit pathspec diff: no file matching the pre-implementation gate name pattern and no epic merge gate file appears in the diff |

## 10. Compliance Verdict

**PASS.**

Every mandatory gate defined by `.claude/rules/general-code-change.md`,
`.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`,
`.claude/rules/powershell.md` and `.claude/rules/tonality.md` is met, and each was corroborated from
primary artifacts rather than from the executor's summaries. Zero Blocking findings. Coverage is PASS
for PowerShell and PASS for Python, with TypeScript and C# carrying zero changed files. Evidence
location compliance is clean on both a validator run and a diff scan. No policy document was modified.

Two Important findings are recorded — one documentation-propagation gap that can block two flows until
a sentence is added to two skill documents, and one coverage gap on the function whose contract this
change altered — and eight Advisory findings. None blocks merge. Remediation inputs are in
`remediation-inputs.2026-09-19T19-56.md`.

## Appendix A: Test Inventory

Suites added by the change set, with row counts recomputed from the JUnit report:

| Suite | Rows | Subject |
| --- | --- | --- |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1` | 27 | The new module's four target states, issue-number normalisation, signal scanning, liveness filtering and tie-breaking |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 18 | The pr-author ten-row matrix against committed fixture roots, plus reason-code separation and one-resolved-path rows |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | 20 | The model-routing ten-row matrix, plus resolved-path reads for both resolved states |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` | 13 | The prd gate's identity resolution, deny ordering and checkpoint disambiguation |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1` | 2 | The checkpoint value contract the gates rely on |
| `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` | 7 | The hygiene rule in three skills and the delegation-identity rule, with the gated-agent list read from the gate itself |
| `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | 8 | Structural guard: every checkpoint reader call supplies its path, no in-scope hook carries the checkpoint filename in a string expression, and the orchestrator-state module keeps its exact line count |
| `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` | not a suite | Shared fixture-path resolver, directory wrapper and target-result wrapper, dot-sourced by two matrix suites |

Suites modified: the pr-author target-resolution suite, the pr-author epic base-branch suite and its
trigger-scoping sibling, the model-routing suite, three prd suites, the orchestrator-state suite, and
one Python expectation module. The three files holding the seven protected regression rows changed by
insertion and argument addition only, with zero changed lines carrying a test name or an assertion.

## Appendix B: Toolchain Commands Reference

Commands whose recorded results this audit relies on, as named in the cited evidence artifacts:

| Purpose | Command |
| --- | --- |
| PowerShell formatting | `Invoke-PoshQCFormat` via the PoshQC module |
| PowerShell linting | `Invoke-PoshQCAnalyze` via the PoshQC module |
| PowerShell tests with coverage | `Invoke-PoshQCTest -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` |
| Python formatting | `poetry run black .` |
| Python linting | `poetry run ruff check .` |
| Python type checking | `poetry run pyright` |
| Python tests | `poetry run pytest` |

Commands executed by this reviewer during the audit:

| Purpose | Command |
| --- | --- |
| Evidence location validation | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` |
| Contract suites re-executed | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q` |
| Coverage recomputation | Direct parse of `artifacts/pester/powershell-coverage.xml` for per-file and report-level line counters |
| Changed-line coverage | Intersection of `git diff -U0 b7c11616 4b45ca7f -- <file>` added-line numbers with the report's instrumented lines |
| Mirror parity | `sha256sum` over each of the ten mirrored pairs |
| Frozen-surface pins | `sha256sum` over the epic skill and the epic-orchestrator agent file |
| Commit ordering | `git log --reverse` restricted to `.claude/hooks/` and to the baseline evidence directory |
| Protected-row byte identity | `git diff` over the three files, filtered to lines carrying a test name or an assertion |
| Host-token scan | Pattern scan over all 147 changed files, with every hit inspected line by line |
