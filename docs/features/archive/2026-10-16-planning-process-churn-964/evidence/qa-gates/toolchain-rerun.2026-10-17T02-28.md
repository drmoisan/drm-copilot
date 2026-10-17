# QA Gate — Full Toolchain Re-run After the [P6-T12] Self-Review Fixes

Timestamp: 2026-10-17T02-28
Task: [P6-T12] (QA loop re-run from [P6-T1] after the self-review fixes)
Command: sh SCRATCH/issue-964-pystatic.sh; sh SCRATCH/issue-964-pytest.sh; sh SCRATCH/issue-964-tsstatic.sh; sh SCRATCH/issue-964-jest.sh issue-964-jest-selfreview.txt --coverage; PoshQC MCP format and analyze, then `Invoke-PoshQCAnalyze -Root <worktree root>` through SCRATCH/issue-964-pwsh.sh; sh SCRATCH/issue-964-pester.sh tests; sh SCRATCH/issue-964-contracts.sh; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; poetry run python SCRATCH/issue-964-scope.py
EXIT_CODE: 0
Output Summary:
- Run window 2026-10-17T02-16 to 2026-10-17T02-28 (UTC), one pass, no stage failed or rewrote a file.
- Scope of the re-run: the self-review fixes changed Markdown surfaces and one Python test module (`tests/scripts/dev_tools/test_single_pass_preflight_contracts.py`); every stage was re-run regardless.
- Python: `black --check scripts tests` and `black --check .`: 620 files unchanged; `ruff check scripts tests` and `ruff check`: all checks passed; `pyright`: 0 errors, 0 warnings.
- Pytest with line and branch coverage: 7325 passed, 6 skipped; total 94.11% line / 88.78% branch.
- TypeScript: Prettier check clean; ESLint 0 output lines; `tsc` source and test projects 0 diagnostics.
- Jest with coverage: 281 suites, 4103 tests passed; total 97.41% lines / 92.65% branches.
- PowerShell: the PoshQC format pass rewrote no file (`git status` shows no PowerShell change); the direct analyzer run printed "PSScriptAnalyzer passed: no findings".
- Pester over `tests` in one fresh process: Passed=11046 Failed=0 Skipped=10 Total=11056.
- Contract set: 238 Python tests passed; 636 Pester tests passed, 0 failed.
- Architecture and integration stages: unchanged from `contract-and-integration.2026-10-17T01-12.md` (no dependency-cruiser configuration exists and no integration suite covers the touched modules).
- Generator `--check`: exit 0. Scope check: 258 changed paths, 0 outside the Files Written list, 0 not-touched files changed, 0 non-Markdown files over 500 lines; the merge base equals the `origin/main` tip.

| Changed production file | Line | Branch |
|---|---|---|
| `scripts/dev_tools/plan_gate_document.py` (new) | 100.00% | 100.00% |
| `scripts/dev_tools/plan_gate_discrimination.py` | 99.26% | 98.08% |
| `scripts/dev_tools/generate_codex_agent_variants.py` | 94.53% | 89.13% |
| `scripts/dev_tools/codex_native_converter/rewrites.py` | 91.30% | 85.71% |
| `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts` (new) | 100.00% | 95.08% |
| `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` | 100.00% | 98.28% |
| `extensions/drm-copilot/src/lib/codex-native-converter/rewrites-rules.ts` | 100.00% | 100.00% |
| `.claude/hooks/premortem-section.ps1` (new) | 100.00% | n/a (Pester) |
| `.claude/hooks/validate-planner-output.ps1` | 99.52% | n/a (Pester) |
| `.claude/hooks/validate-task-researcher-output.ps1` | 98.17% | n/a (Pester) |
| `.claude/hooks/validate-executor-output.ps1` | 100.00% | n/a (Pester) |

The TypeScript figures are computed from the re-run `lcov.info` (Jest's text table prints 98.27% for `plan-gate-discrimination.ts`; the lcov ratio rounds to 98.28%). The PowerShell hook sources are unchanged since `ps-tests.2026-10-17T02-04.md`, so their per-file figures are taken from that coverage run.
