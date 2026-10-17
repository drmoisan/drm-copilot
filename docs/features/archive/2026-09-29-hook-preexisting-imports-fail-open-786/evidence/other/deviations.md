# Deviations

Rule 15 record of departures and their triggering observations.

## [P0-T3] Route wrapper form

- Observation: the Bash isolation guard refused command lines that combined `sh` with output redirection or `echo`, and a separate PreToolUse hook refused a `cd`-chained `grep`/`cat`. The accepted form is `cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/<wrapper>.sh <arguments>`.
- Fallback applied: route `sh` is used through one generic wrapper, `<SCRATCHPAD>/r.sh <name> <arguments>`, which changes to the worktree root, runs `pwsh -NoProfile -File <SCRATCHPAD>/<name>.ps1 <arguments>`, writes the combined output to `<SCRATCHPAD>/<name>.out`, and prints `EXIT=<code>`. The route remains `sh` (a fresh PowerShell 7 process per script, worktree root as working directory); only the per-script two-line `.sh` companion is replaced by the generic wrapper.

## Phase 0 Timestamp correction

- Observation: the `Timestamp:` field of fourteen Phase 0 artifacts was first written with values ahead of the actual run time.
- Correction applied: each value was replaced with the artifact's actual file write time (minute precision) before the Phase 0 commit; no other field changed. Affected artifacts: p0-execution-route.md, p0-pre-merge-state.md, p0-upstream-precondition.md, p0-merge.md, hook-dependency-enumeration-repo.md, hook-dependency-enumeration-mirror.md, hook-dependency-rows.md, hook-dependency-reconciliation.md, hook-guard-worklist.md, p0-line-counts.md, p0-batch-budget-probe.md, p0-poshqc-format.md, p0-mcp-poshqc-format.md, p0-poshqc-analyze.md.

## [P3-T6] Behaviour-suite exception handling

- Observation: the B, X, and C suites first caught the exception of an & invocation and asserted on it, so a failed row began with `Expected` and RS-6 would classify a raw load-failure throw as `NO-DECISION`, which would make the RS-4 `AND_ROUTE_MOCKS_OBSERVED` reading unmeasurable.
- Correction applied (test construction, before the [P3-T6] run): `Invoke-HookProcess` in tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1, tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1, and tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 no longer catches the exception; it propagates to the It, which fails with the raw message. Stdin and stderr are still restored in finally. No assertion that judges a block result changed.

## [P5-T2] to [P5-T6] Final newline added by the mechanical transformer

- Observation: the candidate transformer writes every file with a final newline. Seven Claude hook files had none at BASE: enforce-epic-merge-gate.ps1, enforce-epic-worktree-removal-gate.ps1, enforce-evidence-locations.ps1, enforce-feature-folder-order.ps1, enforce-parallel-worktree-removal-gate.ps1, enforce-pr-author-skill.ps1, and enforce-promotion-mcp-only.ps1.
- Correction applied: from [P5-T4] onward the candidate's final newline is removed before R-INSTALL when the tree file has none (`<SCRATCHPAD>/eofmatch.ps1`), so six of the seven files keep their original end-of-file state. enforce-epic-merge-gate.ps1 (installed in [P5-T2] before the check existed) and its mirror now end with a newline. The line count measured by R-LINES is unchanged, and the change has no effect on behaviour.

## [P5-T2], [P5-T4] Decision check placed where the #690 call was

- Observation: section 2.3 says the #690 call in enforce-epic-merge-gate.ps1 (`:317-319`) and in enforce-epic-worktree-removal-gate.ps1 (`:297-299`) is deleted with its closing brace. Section 2.2(d) puts the two decision-check statements first in the same function.
- Applied: in both hooks the four-line call block was replaced in place by the two 2.2(d) statements, keeping the comment line above it. The comment line is now the only statement before the check, and S6 passes for both hooks.

## [P6-T7] C8 harness route

- Observation: run 1 of the special-cases suite failed C8 on .claude/hooks/validate-orchestrator-output.ps1 with `The term 'Add-HookDependencyFailure' is not recognized`. With the helper absent, the CommandNotFound error raised inside a guard's catch is statement-terminating. In a registered hook's own `pwsh -File` process it ends only that statement, and the hook reaches the tail and exits 2. Under the in-process `&` route it propagates to the nearest enclosing try in the caller, which is the It block. A probe confirmed both behaviours. The hook was correct; the test route could not model a process boundary, so C8 could not pass for any hook.
- Correction applied (test construction): C8 in tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 now runs the hook through `Invoke-HookInFreshRunspace`, which uses a new runspace with no enclosing try. In that runspace, local Join-Path and Import-Module functions make the helper bootstrap and the named dependency fail, replacing the Pester mocks for this row only. The assertions (exit code 2 and the bootstrap stderr prefix) are unchanged. The same probe showed that the runspace route still fails when `$ErrorActionPreference = 'Stop'` precedes the import, so C8 still detects the RS-8 hazard. No other row changed. RS-10 was not triggered (C4 passed on run 1).

## [P8-T9] C4 module-instance cleanup

- Observation: the first [P8-T9] run failed one row: the `baseline mock interception probe` of tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1, with `Get-EpicScopeCheckpointText in module EpicScopeResolution ... was called 0 times`. The same probe passed when that file ran alone. A per-row order probe showed the C4 rows of tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 as the cause. They dot-source real hooks with real `-Force` imports, which leave duplicate worktree-resolution and orchestrator-state module instances in the session. A later container's `-ModuleName` mocks then bind to an instance the code under test does not call. CI runs SpecialCases before FailClosed (alphabetical order), so the same failure would occur there.
- Correction applied (test construction): the C4 `finally` block now also removes every loaded module whose path contains `worktree-resolution` or `orchestrator-state`. Later containers import fresh single instances. No assertion changed. The re-run passed (1421 passed, 0 failed).

## [P9-T7] Acceptance (c) cannot be met as written

- Observation: check (c) counts added lines that match `python|poetry` case-insensitively and requires 0 for every selected production file. The section 2.2(d) and 2.2(e) lines are mandatory in every hook and carry the hook's section 3 R-PREFIX. In four hooks that prefix contains the word "python": `Python unit test purity hook:` in .claude/hooks/check-python-test-purity.ps1, `PYTHON_LARGE_PATH_REQUIRED:` in both enforce-python-batch-budget.ps1 copies, and `check-python-test-purity:` in .codex/hooks/check-python-test-purity.ps1. Each of these files therefore counts 3.
- Impact: none of these lines invokes Python. The no-Python guard passes (32 passed, 0 failed), and its three files are unmodified. AC-26 is still satisfied in substance.
- Action: the counts are recorded as measured in p9-no-python.md, and [P9-T7] is left unchecked. Plan revision input: exclude string-literal R-PREFIX text from (c), or match invocation forms (`python`, `python3`, `poetry run`, `py -m`) as command names only.

## [P10-T1] RS-10 applied after a full-suite C4 failure

- Observation: the first full R-PESTER run (530.65 s; 9335 passed, 2 failed) failed the two C4 rows `makes the pre-loaded OrchestratorStateUnconditional visible to the lazy-load check in .claude/lib/orchestrator-state/OrchestratorState.psm1` (Get-Command returned nothing inside the OrchestratorState module scope). The same rows pass when the special-cases suite runs alone, with the claude-hooks folder, and with coverage enabled. The failure depends on module instances that earlier containers of the full run leave in the session. Pester's `Run.Exit = $true` then ended the run with exit 2, which ended the R-PESTER route script before it printed its report.
- Action: RS-10, which the plan prescribes for any C4 failure (FR-7.3 disproved in the full-run context). ` -Global` was added after `-Force` on each of the seven pre-load lines: enforce-discovery-artifact-gate.ps1 (1), enforce-pr-author-skill.ps1 (2), validate-discovery-artifact-gate.ps1 (1), and validate-orchestrator-output.ps1 (3). Each was installed through its own R-INSTALL (P10-T1#RS10-1 to #RS10-4; resets P10-T1#RS10-1 and #RS10-2; smoke pass) and mirrored (equal). No Codex hook has a pre-load line, so Phase 7 is unaffected. The special-cases, completeness, and Claude behaviour suites pass afterwards (748 passed, 0 failed). The FR-7.3 status in p6-special-cases.md (`confirmed`, from the isolated run) is superseded by this record: in the full-suite context FR-7.3 is disproved and -Global is applied.

## [P10-T2] Behaviour-suite mocks lose full-run coverage

- Observation: in the full R-PESTER run, several Codex files showed their entry-point tails and helper bodies as uncovered (for example .codex/hooks/validate-bash.ps1 80.25%, .codex/hooks/hook-dependency-guard.ps1 57.89%), although the tests that execute those lines passed and folder-level runs covered them almost fully. Diagnostic coverage probes (Pester 5.6.1 profiler tracer, scratch scripts only) showed the following:
  - The loss reproduces only when the B1 rows of tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 run together with a large preceding volume of tests.
  - Excluding the B1 rows removes the loss. Excluding the B2 rows, the B3 rows, the special-cases suite, the proof file, or the new structural suites does not.
  - Rewriting the B1 mocks from `[scriptblock]::Create(...)` bodies and parameter filters to literal scriptblocks also removes the loss: validate-bash.ps1 misses 1 command and hook-dependency-guard.ps1 misses 1 command, the same as the folder-level run.
- Correction applied (test construction): in both behaviour suites, the B1 Import-Module and Join-Path mocks now use literal scriptblocks that read the failing dependency through It-scope locals (`$failedDependency`, `$failedChildPath`). Assertions are unchanged, and both suites pass (214 passed, 0 failed). The suites also invoke hooks through platform-native full paths (`Get-HookInvocationPath`, added to tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1). That change was made earlier in the same investigation; it did not change coverage on its own and is kept.

## [P10-T3], [P10-T4] Full-run coverage attribution gap (escalated)

- Observation: after the [P10-T2] remediation, the full R-PESTER run passes (9495 passed, 0 failed) and 53 of 57 changed files are at or above 85.00. Four Codex files remain below the floor in that run: enforce-epic-child-worktree-binding.ps1 (74.70), enforce-epic-planning-only.ps1 (82.25), hook-dependency-guard.ps1 (57.89), and validate-bash.ps1 (80.25). Five Codex files fail the no-regression rule. Probe runs of the claude-hooks, claude-lib, claude-runtime, and codex-hooks set (coverage-comparison.md, bisect output) show validate-bash.ps1, hook-dependency-guard.ps1, and enforce-orchestration-preimplementation-gate.ps1 each missing one command. Across full runs, the per-file results for these Codex files change while the overall percentage stays at 87.07%.
- Assessment: the lines are executed by passing tests. The gap is in how the Pester 5.6.1 profiler tracer attributes hits in the full 330-container run. One trigger was found and removed (B1 mocks built with [scriptblock]::Create). The remaining trigger is not identified.
- Action: [P10-T3] and [P10-T4] are left unchecked, and their artifacts carry ACCEPTANCE-GAP lines. AC-24 cannot be checked while they remain open. Plan revision input:
  - Isolate the Codex suites into their own R-PESTER pass for coverage measurement, or
  - pin the coverage mode (CodeCoverage.UseBreakpoints = $true) for this measurement.
  - Either option needs an operator decision, because R-PESTER and the runsettings file are fixed by the plan.

## [P11-T3] Final full-run coverage gap (escalated)

- Observation: the final R-PESTER run (QC pass 4) reports `Tests Passed: 9495, Failed: 0` and JUnit root failures 0 and errors 0. Every named testsuite passes. The same four Codex files are below 85.00, with the same values as [P10-T3]. The three UNCOVERED-CHANGED groups are also unchanged.
- Action: [P11-T3] is left unchecked with an ACCEPTANCE-GAP line in final-pester-coverage.md. The plan revision input recorded for [P10-T3] and [P10-T4] applies unchanged.

## Remediation cycle 1: coverage measurement artifact

- Timestamp: 2026-10-10T18-55
- Source: remediation-plan.2026-10-10T06-50.md rule 5, taken by [P2-T10] (cycle 1, hosting H2). Full records: evidence/other/r1-coverage-diagnosis.md, sections `[P2-T2]` to `[P2-T9]` `Cycle 1 (H2)` and `## Verdict`.
- Verdict lines:
  - HOSTING-PARITY: yes
  - REPRODUCER-LOSS: k=234 | m=42
  - ILOSS-REPRODUCER: k=125 | m=0
  - Q-SET: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1, tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
  - CULPRIT: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | role=pre | LOSS-WITHOUT=no | ILOSS-WITHOUT=no
  - CULPRIT-CONFIRMED: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | yes
  - CULPRIT: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | role=post | LOSS-WITHOUT=no | ILOSS-WITHOUT=no
  - CULPRIT-CONFIRMED: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | yes
  - SHARED-CULPRIT: no | no container removes both signals
  - MECHANISM: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | other
  - MECHANISM: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | other
  - FIX-CLASS: none
  - FIX-SUBJECT: none
  - VERDICT: measurement artifact
- NC results (cycle 1, H2): NC1-LOSS no; NC2-LOSS no; NC3-LOSS no; NC2-ILOSS no; NC3-ILOSS no; NC4: CleanupWorktreeManifestGateMatrix.Tests.ps1 22, hook-dependency-failure.Claude.Tests.ps1 1, hook-dependency-failure.Codex.Tests.ps1 1, activate.Tests.ps1 1.
- Bisection lines (a = 238, b = 42; 23 new probes, cap 36):
  - BISECT: search=ANY | stage=A | k=0 | m=42 | LOSS=no | ILOSS=no | reused=yes
  - BISECT: search=ANY | stage=A | k=238 | m=42 | LOSS=yes | ILOSS=no | reused=yes
  - BISECT: search=ANY | stage=A | k=119 | m=42 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=ANY | stage=A | k=178 | m=42 | LOSS=no | ILOSS=yes | reused=no
  - BISECT: search=ANY | stage=A | k=148 | m=42 | LOSS=no | ILOSS=yes | reused=no
  - BISECT: search=ANY | stage=A | k=133 | m=42 | LOSS=no | ILOSS=yes | reused=no
  - BISECT: search=ANY | stage=A | k=126 | m=42 | LOSS=no | ILOSS=yes | reused=no
  - BISECT: search=ANY | stage=A | k=122 | m=42 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=ANY | stage=A | k=124 | m=42 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=ANY | stage=A | k=125 | m=42 | LOSS=no | ILOSS=yes | reused=no
  - LOOP-END: search=ANY | stage=A | lo=124 | hi=125
  - BISECT: search=ANY | stage=B | k=125 | m=42 | LOSS=no | ILOSS=yes | reused=yes
  - BISECT: search=ANY | stage=B | k=125 | m=0 | LOSS=no | ILOSS=yes | reused=no
  - BISECT: search=LOSS | stage=A | k=0 | m=42 | LOSS=no | ILOSS=no | reused=yes
  - BISECT: search=LOSS | stage=A | k=238 | m=42 | LOSS=yes | ILOSS=no | reused=yes
  - BISECT: search=LOSS | stage=A | k=119 | m=42 | LOSS=no | ILOSS=no | reused=yes
  - BISECT: search=LOSS | stage=A | k=178 | m=42 | LOSS=no | ILOSS=yes | reused=yes
  - BISECT: search=LOSS | stage=A | k=208 | m=42 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=A | k=223 | m=42 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=A | k=230 | m=42 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=A | k=234 | m=42 | LOSS=yes | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=A | k=232 | m=42 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=A | k=233 | m=42 | LOSS=no | ILOSS=no | reused=no
  - LOOP-END: search=LOSS | stage=A | lo=233 | hi=234
  - BISECT: search=LOSS | stage=B | k=234 | m=42 | LOSS=yes | ILOSS=no | reused=yes
  - BISECT: search=LOSS | stage=B | k=234 | m=0 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=B | k=234 | m=21 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=B | k=234 | m=31 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=B | k=234 | m=36 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=B | k=234 | m=39 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=B | k=234 | m=40 | LOSS=no | ILOSS=no | reused=no
  - BISECT: search=LOSS | stage=B | k=234 | m=41 | LOSS=no | ILOSS=no | reused=no
  - LOOP-END: search=LOSS | stage=B | lo=41 | hi=42
- Diagnosis evidence: the H2 probe reproduces the R-PESTER control exactly (X1 per-file values equal C0; HOSTING-PARITY yes). The loss needs both confirmed culprits, which only parse hook text (p_234) and read one workflow YAML file (q_42, the last container). Neither creates or leaves a module instance, and module or function cleanup does not remove the loss. The only applicable fix trial, E4, leaves the lost-line set unchanged. Containers p_235 to p_238 contribute a further part of the X1 loss that the single-predicate bisection does not isolate. The plan does not select a measurement route.
- OPERATOR-DECISION-REQUIRED: AC-24 coverage measurement route

## Remediation cycle 1: AC-24 decision

Timestamp: 2026-10-10T17-36

OPERATOR-DECISION-RESOLVED: AC-24 coverage measurement route | evidence/other/r1-ac24-decision.md

## Remediation cycle 1: [P6-T6] check-off commit

Timestamp: 2026-10-10T18-47

- [P6-T6] commits commits.md alone after its r1-p6 record and requires an empty porcelain after that push (verified: empty after cf6645a5f284fc5163d2ce7f7ac919f80611ed08). Marking the [P6-T6] box on disk afterwards modifies the plan, so the check-off and this note are committed in one further commit (operator rule: commit and push at any pause). No production or test file is part of it.

## Remediation cycle 2: execution notes

Timestamp: 2026-10-10T21-47

- [P0-T5]: the R-CIARTIFACT download was run as `gh run download 38093728445 --repo drmoisan/drm-copilot --name poshqc-linux-hook-test-results --dir <SCRATCHPAD>/r2-ci-linux`; the `--repo` flag was added so the run identifier resolves against the PR repository. The download branch was taken (exit 0); the fallback was not used.
- [P0-T9] to [P0-T12] and the [P1-T1] scripts were prepared while the [P0-T8] R-PESTER run was in progress; each was checked off only after [P0-T8] passed, so the plan file records the tasks in order. No repository file changed between those runs.
- [P3-T6] to [P3-T9] of pass 1 were executed while the [P3-T3] R-PESTER run and the [P3-T4] current-tree probe were in progress, and before [P3-T5]; they were checked off after [P3-T5], so the plan file records the tasks in order. No repository file outside the feature folder changed during pass 1 (the [P3-T5] porcelain and 149 SHA pairs were equal before and after the MCP calls), so every pass 1 row observes the same tree.
- Initial evidence timestamps of [P0-T2] to [P0-T7] were estimates that ran ahead of the clock; they were corrected to the observed file modification times before the [P0-T14] commit.
- [P1-T4]: the `## [P1-T4] Row 6 census` section contains the `INSTANCE-MISMATCH:` line twice (once in the extracted census lines and once in the required full output); the census run printed it once.

## Remediation cycle 2: [P4-T3] check-off commit

Timestamp: 2026-10-10T22-14

- [P4-T3] check-off commit (plan file alone, subject `docs(786): check off the remediation cycle 2 final task`): 23d8eb660f015b485dddfdd8491ddf18d64be1b9, pushed with `git push origin HEAD:bug/hook-preexisting-imports-fail-open-exec-786` (exit 0). Not appended to commits.md, as [P4-T3] specifies.
- Recording this SHA modifies deviations.md after that commit, so this note is committed and pushed in one further documentation-only commit (operator rule: commit and push at any pause). Its code tree equals CHECKED-HEAD d83e7af6117fed48fa3cf3df1d133143f5548064.
