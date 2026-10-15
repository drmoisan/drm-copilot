# 2026-10-11-ci-green-gate-all-checks-and-codex-parity

- Work Mode: minor-audit
- Issue: #899
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/899
- Also resolves: #891 (https://github.com/drmoisan/drm-copilot/issues/891)
- Branch: bug/ci-green-gate-all-checks-and-codex-parity-899
- Lifecycle records (cited by ref on `origin/docs/followups-2026-10-11`, not copied): `docs/features/potential/promoted/2026-10-11-ci-green-gate-ignores-non-required-check-failures.md` (#899), `docs/features/potential/promoted/2026-10-11-codex-ci-green-gate-parity-and-parser-uncovered-line.md` (#891)
- Research: `research/research.2026-10-11T09-50.md`

## Problem / Why

#899: The orchestrate skill S9 CI Green Gate (`.claude/skills/orchestrate/SKILL.md`, `## Step S9 — CI Green Gate`) queries `gh pr checks --required` for non-epic PRs, so a failing non-required check (observed: both `NPM Audit Gate / npm audit` jobs of the `CI` workflow on PRs #859-#862) does not prevent a "CI green" report. The parallel orchestrator (`.claude/skills/parallel-orchestrate/SKILL.md`, Merge-on-Green steps 1-2) accepts the child's DONE as green and re-reads checks only "when the check conclusion must be re-read". A PR could be merged with failing security-audit checks while orchestration recorded it as green.

#891: The Codex orchestrate skill `.agents/skills/orchestrate/SKILL.md` `## CI Green Gate` and its bundled mirror lack the epic-child guard and the `-RequireWorkflow CI` invocation of `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` that #841 added to the Claude surface. Separately, the default `$NowProvider` delegate in the `Invoke-CiGateParser` function param block (`.claude/lib/ci-gate/Invoke-CiGateParser.ps1:338`) is the only uncovered executable line, and the script-level default (near line 104) is not exercised by any test.

## Implementation Intent

- "CI green" means every check on the PR head SHA passed or was skipped. S9 queries every check (no `--required`) for every PR; the parser already evaluates every check it receives, so no parser behavior, `ci_gate` schema, validator, or hook change is made (research section 5).
- The parallel parent always re-reads every check on the child head through `Invoke-CiGateParser.ps1` before recording `merge_status: ci_green` and merging.
- The Codex `## CI Green Gate` (source and bundle mirror) states the same rules as the Claude S9: all-checks population, epic-child guard keyed on an `epic/<slug>-integration` base, `-RequireWorkflow CI` through `Invoke-CiGateParser.ps1`, the `no checks reported` rule, and fail-closed blocked state when the parser file is absent.
- Surfaces that restate a required-only population are aligned: `.claude/agents/orchestrator.md`, `.codex/agents/orchestrator*.toml` (via `generate_codex_agent_variants`), `.agents/skills/orchestrator-workflow/SKILL.md`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, and the parser help comments; each with its bundle mirror byte-identical.
- Two Pester tests execute both default clock delegates deterministically through `Mock Get-Date`.
- Out of scope and left unedited: `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` (hash-pinned), `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, policy files under `.claude/rules/` and `.github/instructions/`, and the parallel-orchestrate passages owned by #890 (Python engine-call text near lines 665-666, 821, 829).

## Acceptance Criteria

- [x] AC-1: The Claude S9 CI Green Gate (source and bundle mirror) queries every check for every PR and contains no `--required` flag; verified by `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`.
- [x] AC-2: The S9 epic-child guard and its pinned wording are preserved; `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` passes.
- [x] AC-3: S9 states that a `no checks reported` error is never green for any PR; verified by `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`.
- [x] AC-4: The parallel-orchestrate Merge-on-Green steps (source and bundle mirror) always re-read every check on the child head through `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`, record `ci_green` only on `success`, and no longer contain "when the check conclusion must be re-read"; verified by `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`.
- [x] AC-5: The Codex `## CI Green Gate` (source and bundle mirror) invokes `Invoke-CiGateParser.ps1`, passes `-RequireWorkflow CI` for an `epic/<slug>-integration` base, evaluates every check, and fails closed when the parser file is absent; verified by `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, and `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` still passes.
- [x] AC-6: No orchestrator surface in scope restates a required-only CI population (`.claude/agents/orchestrator.md`, `.codex/agents/orchestrator*.toml`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, and their mirrors); verified by `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`.
- [x] AC-7: Codex agent variants are in sync: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` exits 0.
- [x] AC-8: Both default clock delegates of `Invoke-CiGateParser.ps1` execute under test: the two new Pester tests in `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` pass through `run_poshqc_test`, with no failed tests.
- [x] AC-9 (CI-dependent): The PR `CI` run artifact `poshqc-test-results` reports zero missed lines for `Invoke-CiGateParser.ps1` in `artifacts/pester/powershell-coverage.xml`.
- [x] AC-10: Every edited surface is byte-identical to its bundle mirror; the Claude and Codex push-down resource contract tests and the completion-gate mirror parity test pass.
- [x] AC-11: The hash-pinned epic surfaces are unchanged; `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` passes.

## Dependencies / Risks

- After this change a failing check the PR did not cause (for example a new npm advisory) blocks DONE and the parallel merge and enters the remediation loop. This is the behavior #899 requests.
- A repository with no workflows ends S9 in a poll timeout (`awaiting_ci`) rather than green.
- Codex-only consumers do not receive `.claude/lib/` through push-down; the Codex gate fails closed when the parser is absent. Bundling the parser for Codex consumers is a follow-up candidate.
- Concurrent items: #890 edits parallel-orchestrate text near lines 665-666, 821, 829; #900 may edit scratch-file guidance. Edits here stay within the CI-gate passages.

## Verification Steps

- PowerShell: PoshQC MCP tools only (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`); per-file coverage from the PR `CI` run artifact.
- Python contract tests via `poetry run pytest` on the named test files.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
