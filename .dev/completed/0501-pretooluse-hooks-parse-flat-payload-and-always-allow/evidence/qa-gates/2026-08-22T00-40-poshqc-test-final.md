# QA gate — Final PowerShell tests and coverage (AC-1, AC-4, AC-5, AC-6, AC-7, AC-11, AC-14) (#501)

Timestamp: 2026-08-22T00-40

Task: [P7-T3]

## Run 1 — the mandated MCP toolchain run

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-18`

EXIT_CODE: 0

MCP result: `{"ok":true,"tool":"run_poshqc_test",...,"summary":"Ran bundled PoshQC test against '...2026-08-21T17-18'."}`

Numeric source: `artifacts/pester/pester-junit.xml` (root `testsuites` attributes) and `artifacts/pester/powershell-coverage.xml` (report-level `LINE` counters).

- Tests: `tests="3330"`, `errors="0"`, `failures="0"`, `disabled="9"`, `time="133.997"`. All executed tests pass.
- Coverage (line): `<counter type="LINE" missed="233" covered="5722" />` = **96.0873%** over 5955 measured lines.
- Coverage (instruction, informational only, no threshold): `missed="351" covered="8029"` = 95.8115% over 8380.

Test-count delta against the [P0-T4] baseline: 3116 -> 3330, **+214 tests**, 0 failures in both.

## The MCP run measures a stale coverage denominator

`mcp__drm-copilot__run_poshqc_test` executes the PoshQC copy bundled inside the published npx package, resolved at
`C:\Users\DanMoisan\AppData\Local\npm-cache\_npx\bc9f2e765aac2c41\node_modules\@danmoisan\drm-copilot-mcp\resources\powershell\PoshQC\settings\pester.runsettings.psd1`
(cached 2026-08-21 15:08). That file is identical to this repository's bundled copy **except** that it predates the nine `CodeCoverage.Path` entries added in [P5-T6]: `grep -c "hook-payload/HookPayload.psm1"` against it returns 0.

Consequence: run 1's denominator cannot contain the nine newly-registered production paths, so run 1 alone cannot discharge AC-11's clause "with `.claude/lib/hook-payload/HookPayload.psm1` and every modified hook in the coverage denominator". This is a package-publication lag in the local environment, not a defect in the change: the repository copy and its bundled mirror are byte-identical to each other and the parity gate `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes ([P5-T6]). The MCP tool will pick the entries up on the next package publish.

## Run 2 — supplementary measurement against the repository runsettings

To make AC-11's denominator claim measurable now, the same suites were run with the repository's own `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, reproducing PoshQC's path resolution (relative `CodeCoverage.Path` entries joined to the workspace root; nonexistent entries pruned first).

Command: `pwsh -NoProfile -File scratchpad/p7t3_repo_coverage.ps1` (builds a `PesterConfiguration` from the repo `.psd1` and calls `Invoke-Pester -Configuration`)

EXIT_CODE: 0

Numeric source: `artifacts/pester/powershell-coverage.repo-runsettings.xml` (JaCoCo, report-level counters).

- `configured coverage paths: 80` — every entry resolved; nothing pruned.
- `TOTAL_TESTS=3330 PASSED=3321 FAILED=0 SKIPPED=9` — identical test outcome to run 1.
- Coverage (line): `<counter type="LINE" missed="275" covered="6308" />` = **95.8226%** over 6583 measured lines.
- Coverage (instruction, informational only): `missed="420" covered="8761"` = 95.4253% over 9181.
- 79 classes measured, up from 70 in run 1: the nine added files.

### Per-file coverage of the nine newly-registered denominator entries

| File | Lines missed | Lines covered | Line coverage |
| --- | --- | --- | --- |
| `.claude/lib/hook-payload/HookPayload.psm1` | 4 | 99 | 96.12% |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 4 | 47 | 92.16% |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 10 | 76 | 88.37% |
| `.claude/hooks/enforce-evidence-locations.ps1` | 4 | 36 | 90.00% |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 4 | 41 | 91.11% |
| `.claude/hooks/enforce-checkpoint-monotonic.ps1` | 4 | 90 | 95.74% |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 9 | 59 | 86.76% |
| `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` | 0 | 77 | 100.00% |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 3 | 61 | 95.31% |

Every one of the nine clears the 85% line threshold individually, and the whole-run figure of 95.8226% clears it with margin. No coverage exclusion was added for any production PowerShell file; the [P5-T6] change is purely additive to the denominator.

Denominator scope note: "every modified hook" means the `.claude/**` originals only. The `extensions/drm-copilot/resources/claude-customizations/.claude/**` byte-copies are not, and have never been, in `CodeCoverage.Path`; their absence is a pre-existing scoping decision, not a coverage exclusion introduced here.

## Suites required by the acceptance criteria

All present and passing in both runs:

- `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1` — 53 tests (AC-1: stdin precedence over both environment variables, fallback order, throwing-stdin fallback, both redirect-guard polarities, the default-seam tripwire, anomaly classification, nested extraction, CRLF and BOM, Edit-shaped `tool_input`, Agent envelope with root `agent_type`).
- `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` — 77 tests (AC-8: 24 registered hooks x 3 assertions, plus 5 suite-level).
- Every migrated suite under `tests/scripts/claude-hooks/` with at least one nested-envelope deny test per hook (AC-7).
- AC-4 anomaly tests asserting the entry-point `[int]` return is 0 and never 1 across empty payload on all three transports, unparseable JSON, missing `tool_input` (including the legacy flat root shape), null `tool_input`, and non-object `tool_input`.
- AC-5 exception tests pinning `validate-bash.ps1`'s allow-on-empty and unparseable-raw-as-command behaviours.
- AC-6 tolerance test: a well-formed nested Bash envelope with no `file_path` still allows in `enforce-orchestration-preimplementation-gate.ps1`.

Output Summary: 3330 tests, 0 failures, 9 skipped, in both the mandated MCP run and the supplementary repository-runsettings run (baseline was 3116 tests, 0 failures; delta +214). Line coverage is **96.0873%** on the MCP run's stale denominator and **95.8226%** on the repository denominator that includes all nine newly-registered production files, both far above the 85% threshold. Every one of the nine new denominator entries individually exceeds 85%. No branch-coverage criterion applies (Pester does not measure branch coverage). No coverage exclusion was added.
