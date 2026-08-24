# Phase 0 — Policy Instructions Read (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P0-T1]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-25T21-03.md`

Timestamp: 2026-07-26T11-41

Policy Order: the seven files below were read in the exact order listed, per `.claude/skills/policy-compliance-order/SKILL.md` and plan task [P0-T1].

## Files Read

1. `CLAUDE.md` — repository standing instructions: tone policy, policy compliance reading order, four-layer runtime architecture, orchestration checkpoint path.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design principles, module rigor tiers, mandatory seven-stage toolchain loop, 500-line file limit, error handling, naming, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: five core test properties, coverage requirements (line >= 85%, branch >= 75%), coverage exclusion policy (no production file may be excluded from measurement), scenario completeness, Arrange–Act–Assert structure, prohibition on temporary files in tests, test file location (`tests/` tree mirroring production), determinism infrastructure.
4. `.claude/rules/powershell.md` — PowerShell toolchain (`run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`), PowerShell 7+ compatibility, coding standards, change budget (per-batch cap: at most 3 production files and 3 test files), design seams, Pester testing standards, deterministic test requirements, mocking rules, prohibited behaviors.
5. `.claude/rules/python.md` — Python toolchain (black → ruff → pyright → pytest with `--cov --cov-branch --cov-report=term-missing`), PEP 8 naming, strong typing, design rules, pytest rules, coverage thresholds, prohibited behaviors.
6. `.claude/rules/python-suppressions.md` — suppression authorization requirement, pre-authorized `# noqa` and `# type: ignore` patterns, explicitly unauthorized suppressions and their required workarounds, enforcement checklist.
7. `.claude/rules/quality-tiers.md` — T1–T4 module rigor tiers, `quality-tiers.yml` as source of truth, uniform-versus-tier-dependent gate matrix, rationale for uniform coverage thresholds.

## Additional Policy Context Loaded

The following rule files were also present in the loaded standing-instruction context and bind this execution:

- `.claude/rules/tonality.md` — required professional tone.
- `.claude/rules/orchestrator-state.md` — checkpoint invariants (not modified by this plan).
- `.claude/rules/benchmark-baselines.md`, `.claude/rules/ci-workflows.md` — not in scope for this remediation.

## Binding Constraints Acknowledged

- No file under `.claude/` may be created, modified, or deleted by this plan (Hard Constraint 1).
- No coverage threshold may be lowered, no production file removed from `CodeCoverage.Path`, no denominator shrunk (Hard Constraint 6).
- No temporary files in tests (Hard Constraint 4 / `.claude/rules/general-unit-test.md`).
- No file over 500 lines (Hard Constraint 5).
- PowerShell per-batch cap of 3 production / 3 test files, satisfied by per-phase batching (RI-6).

EXIT_CODE: 0

Output Summary: All seven policy files read in the prescribed order. No policy file was modified. Execution proceeds under the constraints listed above.

---

# Phase 0 — Policy Instructions Read (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P0-T1]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Note:** This section is appended, not overwriting, the cycle-1 record above. The cycle-2 plan names the same
  un-timestamped artifact path (`FEATURE/evidence/remediation-baseline/phase0-instructions-read.md`); appending
  preserves the cycle-1 audit record while satisfying the cycle-2 [P0-T1] acceptance criteria.

Timestamp: 2026-07-26T14-37

Policy Order: the five files named by cycle-2 plan task [P0-T1] were read in the exact order listed below, per
`.claude/skills/policy-compliance-order/SKILL.md`. The cycle-2 delta is PowerShell-only (RD-6), so the Python
rule files read in cycle 1 are not re-listed as required reads; `.claude/rules/python.md` remains loaded standing
context and no Python production change is made.

## Files Read (Cycle 2, explicit list, in order)

1. `CLAUDE.md` — standing instructions: tone policy, policy-compliance reading order, language-specific rule routing, four-layer runtime architecture, orchestration checkpoint path.
2. `.claude/rules/general-code-change.md` — design principles, module rigor tier reference, mandatory seven-stage toolchain loop with restart-from-step-1 semantics, 500-line file limit, fail-fast error handling, naming, public API compatibility, I/O boundaries, prohibition on temporary files in tests.
3. `.claude/rules/general-unit-test.md` — five core unit-test properties, coverage requirements (line >= 85%, branch >= 75%), coverage-exclusion policy (no production file may be excluded from measurement — the policy basis for the R-COV finding closed by Phase 4), scenario completeness, Arrange–Act–Assert, external-dependency and temp-file prohibitions, `tests/` tree layout requirement, determinism infrastructure.
4. `.claude/rules/powershell.md` — PoshQC toolchain order (`run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`, restart from step 1 on failure or file change), PowerShell 7+ compatibility, advanced-function coding standards, change budget (per-batch cap: 3 production and 3 test files), design seams (wrapper function seam preferred, signature `Invoke-<Tool>Exe -<Tool>Args <string[]>`, parameter must not be named `Args`), Pester standards, deterministic test requirements, mocking rules (never mock `git` directly; mock the wrapper with signature parity `param([string[]]$GitArgs)`), prohibited behaviors.
5. `.claude/rules/quality-tiers.md` — T1–T4 tiers, `quality-tiers.yml` as source of truth, uniform-versus-tier-dependent gate matrix (line >= 85% / branch >= 75% uniform, no regression on changed lines), rationale.

| # | Path | Read |
|---|---|---|
| 1 | `CLAUDE.md` | yes |
| 2 | `.claude/rules/general-code-change.md` | yes |
| 3 | `.claude/rules/general-unit-test.md` | yes |
| 4 | `.claude/rules/powershell.md` | yes |
| 5 | `.claude/rules/quality-tiers.md` | yes |

## Cycle-2 Binding Constraints Acknowledged

- No file under `.claude/` (including `.claude/state/` and `.claude/agent-memory/`) may be created, modified, or deleted (Hard Constraint 1).
- The config-driven integration test `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` is not weakened, skipped, or narrowed (Hard Constraint 2).
- `.codex/config.toml` remains unmodified, unstaged, and uncommitted (Hard Constraint 3).
- No decision-function logic changes in any handler (Hard Constraint 4).
- Root/bundle byte-identity for `.codex/hooks/*.ps1` and the `pester.runsettings.psd1` pair (Hard Constraint 5).
- No temporary files in committed tests; stdin fed only via `ProcessStartInfo`/`RedirectStandardInput` or in-process `[System.Console]::SetIn` with readers restored in `finally` (Hard Constraint 6).
- No production or test file over 500 lines, measured as `(Get-Content -LiteralPath $path).Count` (Hard Constraint 7).
- Never remove a file from `CodeCoverage.Path`, lower a threshold, shrink a denominator, weaken an assertion, or add an analyzer suppression (Hard Constraint 8).
- All evidence resolves to `FEATURE/evidence/<kind>/` only (Hard Constraint 9, convention C1).
- Spec acceptance-criteria text is neither unchecked nor edited (Hard Constraint 10).
- PowerShell per-batch cap of 3 production / 3 test files, satisfied by per-phase batching (Hard Constraint 11).

EXIT_CODE: 0

Output Summary: All five cycle-2 policy files read in the prescribed order. No policy file was modified. Execution proceeds under the constraints listed above.

---

# Phase 0 — Policy Instructions RE-READ (Remediation Cycle 2, post-rebase)

- **Issue:** #415
- **Task:** [P0-T1] (re-read after the branch was rebased onto `origin/main`)
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`

Timestamp: 2026-07-26T15-17

Policy Order: the same five files named by cycle-2 [P0-T1] were re-read in order against the
**rebased** tree, because 21 upstream `main` commits (issues #421, #422, #423, #426) landed between
the earlier session's read and this one, and two of those files changed.

## Files Re-Read (in order)

| # | Path | Re-read | Post-rebase delta relevant to this plan |
|---|---|---|---|
| 1 | `CLAUDE.md` | yes | none |
| 2 | `.claude/rules/general-code-change.md` | yes | the toolchain examples now name Jest (`jest.config.cjs`) where they previously named Vitest; the seven-stage loop, 500-line limit, and restart-from-step-1 semantics are unchanged |
| 3 | `.claude/rules/general-unit-test.md` | yes | determinism infrastructure now names `jest.useFakeTimers()` in place of `vi.useFakeTimers()`; coverage thresholds (line >= 85%, branch >= 75%), the no-production-file-excluded rule, the temp-file prohibition, and the `tests/` layout requirement are unchanged |
| 4 | `.claude/rules/powershell.md` | yes | none — PoshQC order, per-batch cap of 3 production / 3 test files, wrapper-seam design rule, and the signature-parity mocking rule (`param([string[]]$GitArgs)`) are unchanged |
| 5 | `.claude/rules/quality-tiers.md` | yes | none |

## Effect on This Plan

The Vitest → Jest migration does not alter any cycle-2 obligation. RD-6 scopes the cycle-2 delta to
PowerShell only (two hooks plus bundle mirrors, the mirrored `pester.runsettings.psd1` pair, and
test files under `tests/scripts/codex-hooks/`), so no TypeScript test runner is invoked by any task
in this plan. The PowerShell rule file, which governs every implementation task here, is unchanged.

All binding constraints recorded in the cycle-2 section above remain in force verbatim.

EXIT_CODE: 0

Output Summary: All five cycle-2 policy files re-read in the prescribed order against the rebased tree. Two files changed upstream (Vitest → Jest naming in `general-code-change.md` and `general-unit-test.md`); neither change affects a cycle-2 obligation. No policy file was modified.
