# QA Gate — Routing-Matrix Constants and Completion Checks (P7-T6) — Issue #475

Timestamp: 2026-08-15T22-40

Command:

1. `mcp__drm-copilot__run_poshqc_format` with `scan_folders: [".claude/lib/orchestrator-state", "tests/scripts/claude-lib/orchestrator-state"]`
2. `mcp__drm-copilot__run_poshqc_analyze` with the same narrowing
3. `mcp__drm-copilot__run_poshqc_test` with `scan_folders: ["tests/scripts/claude-lib/orchestrator-state"]`
4. `Import-Module ./scripts/powershell/PoshQC -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib/orchestrator-state') -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`

`scan_folders` is narrowed to the orchestrator-state test folder so the guard's
repository-scan `It`s — legitimately red from Phase 1 until Phase 11 — are not pulled
into this gate.

EXIT_CODE: 0

Output Summary:

- **Format**: clean and idempotent on re-run (zero files changed on the second pass).
- **Analyze**: **0 findings**. One finding raised during authoring was corrected, not
  suppressed: `PSUseSingularNouns` on `Get-OrchestratorStateRoutingMatrixRoutes`, renamed
  to `Get-OrchestratorStateRoutingMatrixRouteMap`.
- **Tests**: **304 passed, 0 failed, 0 skipped** across the ten suites in the folder. Of
  these, 72 are new in this phase: 27 in `OrchestratorStateRoutingMatrix.Tests.ps1`
  (including the six static config-parity `It`s) and 45 in
  `OrchestratorStateCompletionChecks.Tests.ps1`. Every suite from Phases 4 and 6 remains
  green.
- **Coverage** (read from `artifacts/pester/powershell-coverage.xml`, not inferred from
  the exit code):

| File | Metric | Covered | Missed | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` | LINE | 73 | 0 | **100.00%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` | INSTRUCTION | 115 | 2 | 98.29% | — | — |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | LINE | 98 | 1 | **98.99%** | >= 85% | Met |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | INSTRUCTION | 147 | 1 | 99.32% | — | — |

Branch coverage is NOT emitted by this toolchain (Pester 5's JaCoCo exporter records no
`BRANCH` counter), established with proof in
`evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md`. No threshold is relaxed.

The numeric coverage was produced by the repository's own PoshQC entry point (command 4)
for the reason recorded at `[P2-T8]`. The registration was mirrored into the bundled
settings resource; `diff` confirms the two settings files remain byte-identical.

File sizes are within the 500-line cap: `OrchestratorStateRoutingMatrix.psm1` 377 lines,
`OrchestratorStateCompletionChecks.psm1` 416 lines. No production split was required.

## Gate Hashes:

SHA-256 for every production module verified by this gate. These are the baseline
reference points P15-T10 compares against.

```
.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1 = 20D33729C0307439341AE60F326DC7F2919F640F83279804DC35D508FEEDCA91
.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1 = C782501864A187B09309658E6482198E1F73A7F50472D0134C80270C75118777
```

## Parity Coverage — 11 of 11 inventory rows in scope for this phase

| Row | Check | Failing fixture asserting the exact string | Passing fixture |
| --- | --- | --- | --- |
| C1.1 | completion-blocking step statuses | yes, plus one fixture per blocking value (5 of 5) and a report-order fixture | yes |
| C2.1 | `blocked_reason` not `none` | yes, backtick quoting asserted | yes (absent, null, and literal `none`) |
| C3.1 | `pr_gate` must be an object | yes, plus a proof it does not additionally list fields | yes |
| C3.2 | `pr_gate` missing required fields | yes, blank and null both counted as missing | yes |
| C4.1 | `ci_gate` must be an object | yes, plus a proof it stops there | yes |
| C4.2 | `ci_gate` missing required fields | yes | yes |
| C4.3 | `ci_gate.conclusion` must be success | yes | yes |
| C4.4 | `ci_gate.head_sha` must match `pr_gate.head_sha` | yes, plus a null-`pr_gate.head_sha` non-firing fixture | yes |
| C5.1 | mandatory route phases | yes, for both mapped routes, plus a malformed-`completed_steps` fixture | yes |
| C7.1 | preparation terminal `next_step` | yes, with `repr()` rendering and a `None` rendering fixture | yes |
| C7.2 | preparation terminal step statuses | yes, with `repr()` rendering and an all-six fixture | yes |

No row is deferred, scoped out, or recorded as a follow-up.

Route gating is asserted in both directions rather than assumed. C3 has three
gate-off fixtures (flag absent, flag false, no route selected) and a gate-on passing
fixture. C4 has two gate-on fixtures (flag absent, no route selected) and one gate-off
fixture (flag exactly false). That asymmetry — the PR gate requires an explicit `true`
while the CI gate requires an explicit `false` to opt out — is the Python reference's
behavior and is now pinned by test.

## PD-1 Implementation — pinned constants, no disk read, config-parity test

`OrchestratorStateRoutingMatrix.psm1` embeds the routing-matrix subset the checks consume
(per-route `requires_pr_gate`, `requires_ci_gate`, `required_agents`, `required_skills`,
`required_mcp_tools`) as pinned constants following the `ModelRouting.psm1:33-39` pattern.
The module contains no file-reading command on any code path: verified by inspection and
by the fact that its suite passes with no filesystem mock.

`OrchestratorStateRoutingMatrix.Tests.ps1` carries the static config-parity test. It reads
`config/orchestration-routing.json` at TEST time only, as the oracle, and pins six
properties of the constants against it: the exact route set (6 routes), `requires_pr_gate`
per route preserving the absent-versus-false distinction, `requires_ci_gate` per route with
the same distinction, all three required-name lists per route in matrix order, and both
resolved gate decisions per route. If the config changes and the module does not, this
suite fails.

The absent-versus-false distinction is load-bearing and is why the pinned entries store
`$null` rather than `$false` for an omitted flag: an absent `requires_ci_gate` keeps the
CI gate REQUIRED, whereas `requires_ci_gate: false` opts the route out. Collapsing the two
would silently disable the CI gate for four of the six routes.

The module's header records why fail-closed-on-missing-config was rejected: the Python
reference crashes with an uncaught `FileNotFoundError` in a repository lacking the config,
even on a plain validator call, and that crash is the portability failure this feature
exists to remove.

## Uncovered lines

One line in `OrchestratorStateCompletionChecks.psm1` is uncovered (98.99% line coverage,
15.99 points above the 85% floor). It is inside the `Get-MissingGateKey` non-object early
return, which is reachable only through a path the two callers short-circuit before
reaching it. The line is retained rather than removed because it preserves exact parity
with the Python `_missing_object_keys` helper, which computes the missing-key list before
the object-shape branch. No assertion was weakened and no threshold was relaxed.

## Acceptance

- Suites green: yes (304/304, zero failures).
- Numeric coverage recorded from the coverage XML: yes (100.00% and 98.99% line).
- Floors met: line floor met with at least 13.99 points of headroom on both modules;
  branch unmeasurable by this instrument, recorded with proof.
- `Gate Hashes:` block present with one SHA-256 line per production module verified by
  this gate: yes (two lines).
