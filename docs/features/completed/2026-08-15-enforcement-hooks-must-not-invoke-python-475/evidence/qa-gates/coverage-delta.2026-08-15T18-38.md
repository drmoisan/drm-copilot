# Coverage Delta Verification — [P15-T8]

Timestamp: 2026-08-15T18-38

Command (comparison inputs, all numeric values read from coverage reports, never inferred from exit codes):

- PowerShell baseline: `evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md` (values from `artifacts/pester/powershell-coverage.xml` / `powershell-coverage.koverage.xml`)
- PowerShell final: `evidence/qa-gates/final-poshqc-test.2026-08-15T18-30.md` (values from `artifacts/pester/powershell-coverage.xml`, produced by the repository's own PoshQC entry point with the repository settings file)
- Python baseline: `evidence/baseline/baseline-pytest.2026-08-15T19-21.md` (values from `poetry run coverage json`)
- Python final: `evidence/qa-gates/final-pytest.2026-08-15T18-36.md` (values from `poetry run coverage json`)

EXIT_CODE: 1

Output Summary: **REMEDIATION-REQUIRED.** Python meets both floors with headroom and shows no regression. PowerShell meets the suite-level line floor at 95.73% (up from 94.85%) and fourteen of the sixteen named targets meet the 85% line floor, twelve of them at or near 100%. **Two modified files fall below the 85% line floor**: `.claude/hooks/enforce-discovery-artifact-gate.ps1` at 82.76% (baseline 87.27%) and `.claude/hooks/validate-discovery-artifact-gate.ps1` at 83.61% (baseline 87.93%). PowerShell branch coverage is not emitted by the toolchain (instrument limitation established in the baseline); recorded factually, no threshold relaxed. Per this task's acceptance text, any floor failure makes the plan outcome remediation-required rather than PASS.

## PowerShell — Suite Level

| Metric | Baseline `[P0-T4]` | Final `[P15-T3]` | Delta | Floor | Status |
| --- | --- | --- | --- | --- | --- |
| Line coverage | 94.85% (4019/4237) | **95.73%** (5088/5315) | +0.88 pts | >= 85% | MET |
| Instruction coverage | 94.46% (5457/5777) | 95.56% (7128/7459) | +1.10 pts | — | — |
| Branch coverage | NOT EMITTED | NOT EMITTED | — | >= 75% | **UNMEASURABLE** |
| Files analyzed | 52 | 64 | +12 | — | — |
| Tests | 2233 | 2732 | +499 | — | — |
| Failures | 0 | 0 | 0 | — | — |

The +12 analyzed files are exactly the twelve new `.claude/lib/**` modules. The baseline run
used the MCP tool's bundled Pester settings; the final coverage run used the repository's own
entry point with the repository settings so that the newly registered coverage targets are
actually measured. The suite-level line coverage rose despite the larger denominator.

### Branch Coverage — Instrument Limitation, Not a Waiver

Pester 5's JaCoCo exporter records command/line hit data only and never populates branch arcs.
Verified in `[P0-T4]` by three independent checks: no `counter type="BRANCH"` element exists
at report, package, class, or sourcefile level; summing `mb`/`cb` across every `<line>` node
yields 0/0; and the converted koverage file contains no `BRANCH` token. The same holds in the
final run. The 75% PowerShell branch floor cannot be evaluated with this instrument. This is
recorded as a measurement gap. **No threshold was relaxed, no check was dropped, and no
coverage target was removed.**

## PowerShell — Per-File, Modified and New Files

New files (all created by this feature; no baseline exists, so the floor is evaluated
absolutely):

| File | Final line % | 85% floor |
| --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | 100.00% (112/112) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | 100.00% (90/90) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` | 100.00% (80/80) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` | 100.00% (80/80) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` | 100.00% (73/73) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | 100.00% (28/28) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` | 100.00% (65/65) | MET |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | 100.00% (67/67) | MET |
| `.claude/lib/codex-routing/CodexTopology.psm1` | 100.00% (108/108) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | 99.06% (105/106) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | 98.99% (98/99) | MET |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | 94.44% (102/108) | MET |

New-code line coverage across the twelve new modules: **1008 covered / 1015 total = 99.31%.**

Modified files (baseline exists, so both the floor and no-regression are evaluated):

| File | Baseline line % | Final line % | Delta | 85% floor |
| --- | --- | --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 97.17% (103/106) | **100.00%** (108/108) | +2.83 pts | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | 100.00% (50/50) | **100.00%** (96/96) | 0.00 pts | MET |
| `.claude/hooks/validate-orchestrator-output.ps1` | 92.16% (94/102) | **94.55%** (104/110) | +2.39 pts | MET |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 87.27% (48/55) | **82.76%** (48/58) | **−4.51 pts** | **FAILED** |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 87.93% (51/58) | **83.61%** (51/61) | **−4.32 pts** | **FAILED** |
| `.claude/lib/model-routing/ModelRouting.psm1` (unmodified, listed in baseline) | 100.00% (46/46) | 100.00% (46/46) | 0.00 pts | MET |

`OrchestratorState.psm1` was predicted to possibly tick down from the probe deletion; it rose
to 100%. No increase was required or planned there.

### The Two Floor Failures

Covered-line counts are **unchanged** (48 and 51). Each file gained exactly **3 uncovered
lines**, so the denominator grew while the numerator held. The added lines are the replacement
body of `Invoke-DiscoveryValidatorExe` from `[P3-T2]` and `[P3-T3]`:

- `enforce-discovery-artifact-gate.ps1` newly uncovered: lines 64, 66, 67, 70, 71.
- `validate-discovery-artifact-gate.ps1` newly uncovered: lines 67, 69, 70, 73, 74.

That body resolves the module path, guards its existence, imports the module, and delegates.
It is longer than the single `& python -m ...` invocation it replaced and is **unreachable in
the test suite by design**: `Invoke-DiscoveryValidatorExe` is the mocked seam, and the plan's
Hard Constraints require all 26 existing seam references to survive unmodified (15 `Mock`
registrations plus 11 `Should -Invoke` assertions). Every test that reaches these hooks
replaces the function, so the real body never executes. The logic it delegates to is covered
through `DiscoveryValidation.psm1` at 94.44%.

The remaining uncovered lines in both files (224/227/228/231/233 and 251/252/253/254/257) are
pre-existing main-entry lines present at baseline.

### Actions Deliberately Not Taken

- The 85% line floor was **not relaxed**; `CoveragePercentTarget` was not changed.
- Neither file was removed from the coverage-target list. The coverage-exclusion policy in
  `.claude/rules/general-unit-test.md` forbids excluding any production source path, and
  doing so to hide a failing file would be exactly the accommodation the self-gating
  invariant prohibits.
- No check row, error string, or threshold was weakened anywhere.
- No test files were added or modified: the Change-Budget Accounting states Phases 13-15 make
  "no production or test file changes; evidence, documentation, and AC checkoffs only".

Remediation item for the next cycle (not executed here): add direct-invocation tests for the
two `Invoke-DiscoveryValidatorExe` bodies exercising the module-missing guard and the
delegation path without a mock, in a phase whose change budget permits test-file edits.

## Python

| Metric | Baseline `[P0-T8]` | Final `[P15-T7]` | Delta | Floor | Status |
| --- | --- | --- | --- | --- | --- |
| Line (statement) coverage | 92.30% (13288/14396) | 92.30% (13288/14396) | 0.00 pts | >= 85% | MET |
| Branch coverage | 84.68% (4476/5286) | 84.66% (4475/5286) | −0.02 pts | >= 75% | MET |
| Passed | 3785 | 3785 | 0 | — | — |
| Failed | 0 | 0 | 0 | — | — |
| Skipped | 5 | 5 | 0 | — | — |

**Changed/new Python code coverage: not applicable — there is none.** This feature adds no
Python production code and does not modify `scripts/dev_tools/*.py` (verified in `[P15-T9]`
clause (i)). Statement counts and statement coverage are byte-identical to the baseline. The
−0.02 point branch delta is a single arc (covered 4476 → 4475, partial 556 → 557) in
already-covered pre-existing code, not a regression on changed lines.

## Verdict

| Criterion | Result |
| --- | --- |
| PowerShell suite line floor (>= 85%) | MET — 95.73% |
| PowerShell branch floor (>= 75%) | UNMEASURABLE — instrument emits no branch data |
| PowerShell new-file line floors | MET — all twelve, 99.31% aggregate |
| PowerShell modified-file line floors | **FAILED on 2 of 5** |
| PowerShell no-regression on changed lines | **FAILED on the same 2 files** |
| Python line floor (>= 85%) | MET — 92.30% |
| Python branch floor (>= 75%) | MET — 84.66% |
| Python no-regression on changed lines | MET — no changed Python code |

**Plan outcome on this task: REMEDIATION-REQUIRED, not PASS.**
