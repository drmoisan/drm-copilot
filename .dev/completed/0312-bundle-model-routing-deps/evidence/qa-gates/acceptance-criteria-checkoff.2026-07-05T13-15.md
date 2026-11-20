# Acceptance-Criteria Checkoff — Issue #312

Timestamp: 2026-07-05T13-15
Source: spec.md ## Acceptance Criteria (lines 148-154). Work Mode: full-bug (spec-driven).

| AC | Criterion (abridged) | Verifying evidence | Verdict |
|----|----------------------|--------------------|---------|
| AC1 | Get-ComplexityFloor and Resolve-DelegationModel exist in ModelRouting.psm1 and match the Python references across shared cases | P1-T1/T2 manual verification (empty->C1, signal->C3; C1->haiku, planner/C3/preferred->fable, C4/disabled->opus clamp with clamped_from=fable/clamp_reason=fable_disabled, exec/C3/preferred->opus, out-of-band throw); P3-T5/P6-T3 (41 behavioral tests translate the pytest matrices and pass); coverage-delta-powershell (100%) | PASS |
| AC2 | Pester tests exist at the two mirrored paths, translate the pytest cases, and pass | tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 and Resolve-DelegationModel.Tests.ps1 present; P6-T3 poshqc-test (41 pass, 0 fail) | PASS |
| AC3 | A config-parity test pins the module constants to config/orchestration-routing.json (model_policy / model_budget) and passes | ModelRouting.Parity.Tests.ps1 (InModuleScope asserts BASE_COMPLEXITY_TO_MODEL, PREFERRED_OVERLAY_AGENTS/BAND/MODEL, FLOOR_CANDIDATE/CEILING_BAND, DISABLED_POLICY against the config); P6-T3 pass | PASS |
| AC4 | Module listed in core.json paths[] and present in the byte-mirror; delivered under both no-selection and --packs core | pushdown-delivery (membership=True, both trees present); byte-mirror-parity (IDENTICAL); ModelRouting.Manifest.Tests.ps1 (P3-T4); Python pack-selection + resource-contract tests pass (P7-T4). Note: .gitignore negation exception added so the module is tracked/deliverable to fresh clones. | PASS |
| AC5 | orchestrate/epic-orchestrate references for the two formulas resolve to the PowerShell module/functions with no broken references, mirrored in the bundle | reference-resolution (P5-T1): lines repointed in source + byte-identical mirror; no dangling orchestrator-runs reference; validator-authority Python citations retained | PASS |
| AC6 | PowerShell toolchain single clean pass: format 100%, analyze 0 findings, Pester line >= 85% / branch >= 75% | poshqc-format (100%), poshqc-analyze (0 findings), poshqc-test (1029 pass, new module 100% line/command); coverage-delta-powershell | PASS |
| AC7 | No changes to the Python modules, validate_orchestrator_state.py CLI, TS validator port, pyproject.toml, or config/orchestration-routing.json; existing tests/scripts/dev_tools/ suite passes unchanged | scope-guard (no forbidden path modified); python-pytest final (1298 pass, contract tests 24 pass) | PASS |

Result: all seven acceptance criteria map to passing evidence. Verdict: PASS.

Deviations recorded (outside spec AC, escalated): two non-forbidden files were modified to make the deliverable real and policy-compliant — `.gitignore` (untrack `.claude/lib/` so the module is deliverable; mirrors the existing src/lib exception) and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (append the new production module to the coverage allowlist per the coverage-exclusion policy and the file's per-issue convention). Neither is a forbidden path; both are documented in scope-guard.2026-07-05T13-15.md.
