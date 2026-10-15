# RI-2 coverage attribution investigation (remediation cycle 1, P1-T1 to P1-T5)

Timestamp: 2026-10-13T15-21
Command: P1-T1: poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_line_dump_903.py <worktree>/artifacts/scratch-903/ci-final2-903/powershell-coverage.xml .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 1 210; the same with <worktree>/artifacts/pester/powershell-coverage.xml; the CI XML command with .codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1 1 500; Grep tool pattern `sessioninfo` over <worktree>/artifacts/pester/powershell-coverage.xml. P1-T2: Grep tool over <worktree>/tests, pattern `Get-OrchestrationEpicScopeDecision|Get-OrchestrationEpicScopeSelector|Get-EpicCommandLegReadinessFailure|enforce-orchestration-preimplementation-gate-epic-scope\.ps1`; Read of tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 and .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1. P1-T3: Grep tool over artifacts/scratch-903/ci-final2-903/pester-junit.xml and pester-junit-linux-hooks.xml, pattern `returns null without resolving|epic scope allows the apply_patch leg|epic scope denies the apply_patch leg|the epic-scope decision names|epic scope denies the command leg of a production path` (no regex metacharacters required escaping), -A 3 (Linux) and -A 1 (Windows, a pattern also including `the epic-scope selector returns|epic scope denies the|epic scope allows the`). P1-T4: Grep tool over scripts/powershell/PoshQC, patterns `UseBreakpoints|MinimumVersion|RequiredVersion|MaximumVersion` and `Pester'?\s*[;=,]|PesterVersion|'5\.\d`; Read of scripts/powershell/PoshQC/settings/pester.runsettings.psd1.
EXIT_CODE: 0
Output Summary: All three dump commands exited 0. The CI and local Codex epic-scope dumps are identical row by row (55 rows each; `cmp` of the two saved outputs exit 0). CI dump contains 183 0, 190 0, 191 0, 206 0, 207 0 (and 209 0). Every test row that must execute those lines is in tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 and passes on Windows and Linux in run 38410234897. UseBreakpoints is not set; Pester 5.6.1 is pinned. Cause: UNDETERMINED.

## Facts

### P1-T1 dumps

Local `sessioninfo` element (line 4): `<sessioninfo id="this" start="1791885058164" dump="1791885568958" />`.

Codex epic-scope, CI XML (run 38410234897) versus local XML, `<nr> <ci>`; the two columns are identical on every row:

| nr | CI ci | local ci |
|---|---|---|
| 37 | 2 | 2 |
| 38 | 2 | 2 |
| 42 | 1 | 1 |
| 52 | 1 | 1 |
| 53 | 2 | 2 |
| 54 | 1 | 1 |
| 56 | 1 | 1 |
| 64 | 1 | 1 |
| 65 | 2 | 2 |
| 66 | 1 | 1 |
| 68 | 1 | 1 |
| 88 | 1 | 1 |
| 89 | 2 | 2 |
| 90 | 1 | 1 |
| 92 | 4 | 4 |
| 93 | 1 | 1 |
| 94 | 1 | 1 |
| 96 | 1 | 1 |
| 127 | 1 | 1 |
| 128 | 1 | 1 |
| 130 | 2 | 2 |
| 131 | 1 | 1 |
| 133 | 2 | 2 |
| 134 | 1 | 1 |
| 136 | 3 | 3 |
| 137 | 1 | 1 |
| 138 | 1 | 1 |
| 140 | 2 | 2 |
| 141 | 1 | 1 |
| 144 | 1 | 1 |
| 145 | 2 | 2 |
| 146 | 1 | 1 |
| 148 | 1 | 1 |
| 149 | 1 | 1 |
| 151 | 1 | 1 |
| 182 | 1 | 1 |
| 183 | 0 | 0 |
| 185 | 2 | 2 |
| 186 | 1 | 1 |
| 187 | 2 | 2 |
| 188 | 2 | 2 |
| 189 | 1 | 1 |
| 190 | 0 | 0 |
| 191 | 0 | 0 |
| 193 | 1 | 1 |
| 194 | 1 | 1 |
| 196 | 1 | 1 |
| 198 | 1 | 1 |
| 199 | 1 | 1 |
| 201 | 1 | 1 |
| 203 | 1 | 1 |
| 204 | 1 | 1 |
| 206 | 0 | 0 |
| 207 | 0 | 0 |
| 209 | 0 | 0 |

Codex epic-resolution, CI XML (147 rows, `<nr> <ci>` separated by `;`): 25 1;28 1;31 1;35 1;36 1;37 1;38 1;41 1;44 1;60 1;61 1;63 0;64 0;66 0;83 0;98 1;99 0;101 1;102 2;103 2;104 1;105 0;107 1;108 1;110 1;111 0;113 1;121 2;129 2;130 1;140 1;141 1;142 1;144 1;152 1;153 0;155 2;164 1;165 1;166 1;168 0;181 1;182 1;183 0;185 1;186 1;187 1;188 2;190 0;191 0;208 1;209 2;210 0;212 4;213 1;214 1;216 0;218 0;233 1;234 1;235 0;237 1;238 1;239 0;241 2;242 1;251 1;252 0;254 1;255 1;256 1;258 1;275 1;276 1;277 1;278 1;279 1;280 1;281 1;282 1;292 1;309 2;310 1;312 2;327 1;328 1;331 0;334 0;335 0;337 0;338 0;340 0;354 1;355 1;356 1;358 1;359 1;362 1;363 1;364 1;365 1;367 2;368 1;369 1;371 1;372 1;373 1;375 2;393 1;394 1;395 0;397 1;398 2;399 1;400 1;402 1;403 1;404 0;406 1;424 1;425 1;426 1;428 1;429 3;453 0;460 1;461 1;462 0;464 2;465 2;466 1;467 2;469 0;470 0;472 0;473 0;474 0;479 0;480 0;481 0;483 0;484 0;486 0;487 0;488 0;491 0;492 0.

Comparison read (not gating): the Claude copy's decision tail in the same CI XML (`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` 245-266) is covered on every line, including the no-leg `return $null` (246, ci 1), the deny return (264, ci 1), and the allow return (266, ci 1).

### P1-T2 test-caller map (Codex epic-scope)

Test callers found: `Get-OrchestrationEpicScopeDecision` is called directly at `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:195` and `:373`; `Get-OrchestrationEpicScopeSelector` at `:388`; the Codex gate calls `Get-OrchestrationEpicScopeDecision` at `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:419`, reached by the gate-driven rows of the same suite (`:129`, `:144`, `:163`, `:211`, `:230`, `:255`, `:271`). `Get-EpicCommandLegReadinessFailure` is called directly at `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1:403, 427, 439, 450` (and the Claude library suite `tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1:68, 87`, a different file). The Codex epic-scope file is dot-sourced directly by `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1:31` and through the Codex gate (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:32`) by the epic-scope suite (`:31`). No production file calls `Get-OrchestrationEpicScopeSelector`.

| Line(s) | Statement | Test rows that must execute it |
|---|---|---|
| 88-96 | selector body | `the epic-scope selector returns <Display> for <Label>` (epic-scope.Tests.ps1:388, three data rows) |
| 182 | no-leg guard `if` | every decision call: :195 rows, :373 row, and every gate-driven row with a production operand |
| 183 | `return $null` (no leg) | `the epic-scope decision returns null without resolving when the call carries neither a command nor a path` (epic-scope.Tests.ps1:373) |
| 185-189, 193-201 | target resolution and verdict | :195 rows (`the epic-scope decision names <Conjunct> ...`, five data rows); gate rows :129, :144, :163, :211, :230, :255 |
| 190, 191 | apply_patch marker branch | `epic scope allows the apply_patch leg ...` (:120/:129 apply_patch row); `epic scope denies the apply_patch leg ...` (:135/:144 apply_patch row); `with <Label> the apply_patch leg ...` (:237/:255 apply_patch rows) |
| 203, 204 | `none` outcome | :255 rows (`with <Label> the <Leg> leg returns the unchanged single-feature decision and reason`) |
| 206 | deny test | every row whose outcome is not `none`: :195 rows, :144 rows, :163 rows, :230 row, :129 rows, :211 row |
| 207 | deny return | `the epic-scope decision names <Conjunct> ...` (:195, five rows); `epic scope denies the <Leg> leg ... when no merge is in progress ...` (:144, three rows); `epic scope denies the command leg when <Conjunct> is missing ...` (:163, three rows); `a -C selector command whose selector HEAD differs is denied as target-mixed ...` (:230) |
| 209 | allow return | `epic scope allows the <Leg> leg ...` (:129, three rows); `epic scope decides a -C selector command ... and allows it` (:211) |

### P1-T3 junit outcomes (run 38410234897)

| Row (token) | Windows `pester-junit.xml` | Linux `pester-junit-linux-hooks.xml` |
|---|---|---|
| `returns null without resolving` (Codex, :373) | line 12423, status="Passed", self-closing (no failure or skipped child) | line 7933, Passed |
| `epic scope allows the apply_patch leg` (:129) | line 12387, Passed | line 7897, Passed |
| `epic scope denies the apply_patch leg` (:144) | line 12390, Passed | line 7900, Passed |
| `epic scope denies the command leg of a production path` (:144) | line 12389, Passed | line 7899, Passed |
| `the epic-scope decision names` (:195, five rows) | lines 12395-12399, all Passed | lines 7905-7909, all Passed |
| `the epic-scope selector returns` (:388, three rows) | lines 12424-12426, all Passed | lines 7934-7936, all Passed |

The token `returns null without resolving` also matches the Claude EpicScope suite row (Windows line 2495, Linux line 2473, both Passed); that row targets the Claude copy.

### P1-T4 coverage-mode configuration

- `UseBreakpoints: not set` (Grep over scripts/powershell/PoshQC returned no match).
- Pester version: `scripts/powershell/PoshQC/PoshQC.psm1:57` pins `@{ Name = 'Pester'; Version = '5.6.1' }`; the only `RequiredVersion` match is the installer call at `PoshQC.psm1:25`. No `MinimumVersion` or `MaximumVersion` match.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27`: `CodeCoverage = @{ Enabled = $true; OutputFormat = 'CoverageGutters'; OutputPath = 'artifacts/pester/powershell-coverage.xml'; CoveragePercentTarget = 0 }`, no `Path` list (population from `config/poshqc-coverage.json`, which lists `.codex/hooks` as a folder).

## Cause

Cause: UNDETERMINED - the evidence rules out a failing or skipped row (every row that must execute 183, 190, 191, 206, 207 passes on Windows), a suite outside the coverage run (the same suite's selector rows are the only callers of lines 88-96, and those lines are covered), a coverage population gap (other lines of the same function are covered and `.codex/hooks` is in the population), a definition loaded from another file (the Codex gate dot-sources only `.codex/hooks` siblings), and a CI-only effect (the local XML is identical row by row); it does not identify why direct and gate-driven `Get-OrchestrationEpicScopeDecision` calls from the Codex epic-scope suite record no hits while the Claude suite's equivalent calls on the Claude copy do.

## Placement

Placement: new suite tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 dot-sourcing the Codex epic-scope file directly
