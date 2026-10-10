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
