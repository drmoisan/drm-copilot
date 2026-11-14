# Remediation Inputs: parallel-only-test-gates-and-leak-scan (#1094)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: design

Timestamp: 2026-11-07T03-22
Branch: `feature/parallel-only-test-gates-and-leak-scan-1094`, head `f59b9caab5344611ee11008dc2af5bd3fb924fb5`
Base for diffs: `9a19be8e72ea479212e2e43c3ad766afb270fae6` (merge base with `origin/main`)

Audit artifacts:

- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/policy-audit.2026-11-07T03-22.md`
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/code-review.2026-11-07T03-22.md`
- `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/feature-audit.2026-11-07T03-22.md`

## RF-1: coverage and failure comparisons remain in Copilot agents

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Text edits to files already in the branch diff and their bundle copies; no owner input or external system is involved.

Criteria affected: 1 and 8.

Files, each with its copy under `extensions/drm-copilot/resources/customizations/.github/agents/`:

- `.github/agents/powershell-typed-engineer.agent.md`: `Confirm coverage does not regress for touched files.`
- `.github/agents/csharp-typed-engineer.agent.md`: the same sentence.
- `.github/agents/pytest-unit-test-coding.agent.md`: `Coverage does not regress for any file you touch (and overall thresholds remain satisfied)`
- `.github/agents/Powershell DI Unit Test Engineer.agent.md`: `Any failure in the single gate run compared to baseline`, in `## 4) Quality gates (hard stop)`.

Expected behavior: each passage states the coverage rule (a touched file meets the thresholds, read from the single gate run) or any failure in the single gate run, with no comparison. Check `.codex/agents/` for the same class after the edit.

## RF-2: per-batch targeted test runs remain required

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Text edits to base agents and mirrors, plus a generator run for Codex variants; every file is already in the branch diff or is a generated or bundle copy of one.

Criterion affected: 1. Related: criterion 8, through per-batch coverage confirmation.

Passages:

- `.claude/agents/powershell-typed-engineer.md`, `.claude/agents/python-typed-engineer.md`, `.claude/agents/csharp-typed-engineer.md`: step 4, `Implement in batches`.
- `.codex/agents/powershell-typed-engineer.toml`, `.codex/agents/python-typed-engineer.toml`, `.codex/agents/csharp-typed-engineer.toml`: the same step. Edit base agents only and run `scripts/dev_tools/generate_codex_agent_variants.py` in write mode.
- `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/csharp-typed-engineer.agent.md`, `.github/agents/python-typed-engineer.agent.md`, `.github/agents/python-execution-only-typed.agent.md`: the batch bullets.
- `.github/agents/pytest-unit-test-coding.agent.md`: `## Phase C`, `Run targeted tests for the impacted area`.
- `.github/agents/Powershell DI Unit Test Engineer.agent.md`: `### Iteration runs (required after each batch)`, `Targeted Pester tests for the impacted area`.
- All bundle copies, including the `csharp-legacy` variants under `.claude-variants` and `.codex-variants`.

Expected behavior: per-batch steps keep static tools only. A focused run stays available for debugging one failure, stated as debugging only. Coverage is read from the single gate run.

## RF-3: no contract test covers the TypeScript policy-audit validator

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: A test-only addition to an existing Jest file; the validator source stays unchanged, as the spec requires.

Criterion affected: 9.

File: `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts`.

Expected behavior: mirror the two Python tests. One case passes an audit filled in with `N/A - no pre-change run` through `validatePolicyAuditSubstantiveRequirements` and asserts no errors. One case pins that the comparison line is accepted only through the later `Post-change:` percentage. The file `extensions/drm-copilot/src/lib/validate/policy-audit-artifact.ts` is not edited.

Note: this makes TypeScript a changed language, so the next audit requires `coverage/lcov.info` from `npm run test:unit:coverage`.

## RF-4: Python coverage artifact below the repo-wide thresholds

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The cause is an import path of the item worktree, confirmed by a probe; the gate re-run that RF-1 to RF-3 already require can correct the measurement in the worktree.

Recorded figures: `artifacts/python/lcov.info`, 49.52% line and 45.29% branch, against 85% and 75%. `scripts/dev_tools` measures 94.27% line and 89.10% branch. `packages/discovery-runtime` measures 0% over 140 files, because `drm_copilot_discovery` resolves to the main checkout through the shared `.venv`.

Expected behavior: after the fixes above, run the one pytest gate with `PYTHONPATH` set to the worktree `packages/discovery-runtime/src`, so that the configured coverage source is the code executed. A probe confirmed that this setting moves the import into the worktree; the full coverage effect has not been measured. Record the totals in a new `evidence/qa-gates/pytest-parallel.<timestamp>.md` and confirm `artifacts/python/lcov.info` at or above the thresholds. If the totals stay below the thresholds, report the per-root breakdown.

## Verification

- One `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run after the fixes. These also cover merge commit `f59b9caab`, which postdates the current gate evidence.
- Add sweep tokens to `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` for the RF-1 and RF-2 wording, keeping the debugging exception and the retained policy-audit anchors unmatched. Update the expected token count in `PGW-SWEEP-HELPER`.
- `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`.
- Re-check criteria 1, 8, and 9 after reaudit. The review reverted them to unchecked in `spec.md` and `user-story.md`.

## Do Not

- Do not edit `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, or `.agents/skills/python`.
- Do not change the policy-audit validators, CI workflows, `scripts/powershell/PoshQC/`, `.vscode/tasks.json`, or the Python tools deferred to #1096.
- Do not add a leak scan or a serial, shuffled, reversed-order, comparison, or pre-change run.
- Do not remove tool-permission entries.
- Do not exclude `packages/discovery-runtime` from coverage to reach the thresholds.
