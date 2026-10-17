# Post-Merge Brief Refresh: CI Shape After Merging Main (#964)

Timestamp: 2026-10-17T04-35
Command: poetry run pytest tests -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: 7335 passed, 6 skipped. The execution-environment brief's `## CI Shape and Required Checks` section now names the `Change scope` and `CI full run` jobs and states the docs-only change-scope behavior merged from issue #962; the required-context list is unchanged. All six brief copies are byte-identical. Pester over `tests/scripts` (self-hosted PoshQC): 11203 tests, 0 failures, 0 errors, 10 skipped, read from `artifacts/pester/pester-junit.xml`.

## Merge

`origin/main` was merged into `bug/planning-process-churn-964` before this pass. The merge brought issue #962 (PR #968): a `changes` job (check `Change scope`) and a `full-run-marker` job (check `CI full run`) in `.github/workflows/ci.yml`; the `run-heavy` input with step gating in `_quality-checks.yml`, `_security-scan.yml`, `_build-check.yml`, `_poshqc.yml`, `_shell-coverage.yml`, and `_drm-copilot-extension-tests.yml`; job-level skips for `root-typescript-tests` and `npm-audit-gate` under a docs-only scope; the allowlist `config/ci-docs-only-paths.json`; a non-blocking `safety check` step in `_security-scan.yml`; and the `## Change-Scope Decision (Issue #962)` section of `.github/workflows/README.md`.

## Changes

- `.claude/skills/execution-environment/SKILL.md`, heading `## CI Shape and Required Checks`: the job bullet now lists `Change scope` and `CI full run`, the four Python versions, the two `root-typescript-tests` operating systems, and the non-blocking `safety check` step. Three new bullets state the change-scope decision (inputs, allowlist, fail-closed cases), the docs-only behavior (which jobs run with skipped steps and report `success`, which are skipped at job level, that `docs-validation` runs in full, and that a docs-only `success` is not evidence that the heavy suites pass), and that a commit touching any non-allowlisted path runs the full set. The required-context list of ruleset 15241672 is unchanged. `## CI-Only Failure Classes` was reviewed and is unaffected: `_shell-coverage.yml` still checks out at the default depth, and no stated class changed.
- The five other brief copies (`.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and the three bundle copies under `extensions/drm-copilot/resources/`) were written by `SCRATCH/issue-964-brief-mirror.py`.
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, test `test_brief_ci_section_names_jobs_and_required_contexts`: now also pins `Change scope`, `CI full run`, `root-typescript-tests / Root TypeScript Tests (<os>)`, `NPM Audit Gate / npm audit (<manifest>)`, `scripts/ci/Invoke-CiChangeScope.ps1`, `config/ci-docs-only-paths.json`, `run-heavy: false`, and the docs-only reporting sentence. The token `Change scope` is absent from the brief at the parent commit, so the extended test fails against the pre-change text.
- Other surfaces: `SCRATCH/issue-964-ci-fact-scan.py` searched every non-feature-folder file this item changed (list from `git diff --name-only` between the pre-merge main and pre-merge item heads) for job check names, `run-heavy`, `merge_group`, required-check wording, and statements that every heavy job runs on every commit. The matches are either unaffected (the atomic-plan-contract Pester-runner bullet describes the full-run job shape and defers to the brief as authoritative; `SKIPPED` and "skipped" matches concern plan tasks and delegation) or are this item's own tests. No other surface states a CI fact that #962 changed, so no other file was edited.

## Verifying Commands

| Command | EXIT_CODE | Result |
|---|---|---|
| `poetry run python SCRATCH/issue-964-brief-mirror.py .` | 0 | five copies `OK` (byte-identical to the canonical brief) |
| `poetry run python -m scripts.dev_tools.generate_codex_agent_variants` | 0 | no file changed (porcelain status identical before and after) |
| `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | 0 | generated outputs current |
| `poetry run black --check scripts tests` | 0 | `620 files would be left unchanged.` |
| `poetry run ruff check scripts tests` | 0 | `All checks passed!` |
| `poetry run pyright` | 0 | `0 errors, 0 warnings, 0 informations` |
| `sh SCRATCH/issue-964-contracts.sh` (17 Python contract suites, then the three claude-runtime Pester suites) | 0 | Python 242 passed; Pester Passed=636 Failed=0 |
| `poetry run pytest tests -q -p no:cacheprovider` | 0 | 7335 passed, 6 skipped |
| `sh SCRATCH/issue-964-pm-pester.sh` (`Invoke-PoshQCTest -Root <worktree> -ScanFolders "tests/scripts"` from the branch-current `scripts/powershell/PoshQC/PoshQC.psd1`, one fresh process) | 0 | JUnit: tests 11203, failures 0, errors 0, disabled 10; includes `CiChangeScope.Tests.ps1` (88 cases) and `CiChangeScopeWorkflow.Tests.ps1` (41 cases); merged line coverage 17610 of 19095 (92.22%) |
| `sh SCRATCH/issue-964-sizes.sh` | 0 | `OVER_500=0`; largest is 500 lines; the edited test file is 451 lines |

Jest was not run: no TypeScript file was touched.

## Tonality

The new brief text was checked against `.claude/rules/tonality.md`: it is declarative and states each behavior and its limit without humor, hyperbole, or metaphor. It carries no line numbers and no commit identifiers.
