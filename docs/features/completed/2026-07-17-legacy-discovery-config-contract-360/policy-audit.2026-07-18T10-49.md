# Policy Audit — legacy-discovery-config-contract (#360)

- Timestamp: 2026-07-18T10-49
- Branch: `feature/legacy-discovery-config-contract-360` (HEAD `a5209a71`)
- Base: `epic/legacy-discovery-and-parity-integration`
- Audit scope: full branch diff (`git diff epic/legacy-discovery-and-parity-integration...HEAD`) — 24 files: 4 new production Python modules, 2 new test modules (+1 empty test `__init__.py`), 1 `pyproject.toml` line, and feature-folder docs/evidence.

## Language Scope

Changed files by language: Python (production + tests), TOML (`pyproject.toml` config line), Markdown (feature docs/evidence). TypeScript, PowerShell, C#, and GitHub Actions workflows: zero changed files on the branch — no coverage or toolchain verdict required for those languages. No workflow files were touched, so `.claude/rules/ci-workflows.md` and `.claude/rules/benchmark-baselines.md` do not apply to this diff.

## Domain-Neutrality Invariant (epic-wide)

**PASS.** The production modules `scripts/dev_tools/discovery/__init__.py`, `domain_profile.py`, `domain_profile_models.py`, and `profile_cli.py` contain none of the banned identifiers (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`), verified two ways:

1. Reviewer grep (case-insensitive) over `scripts/dev_tools/discovery/`: zero matches.
2. Contract test `test_production_modules_are_domain_neutral` (parametrized over all three logic modules) scans module sources for the six banned substrings; it passes in the re-run suite.

All field names, defaults, error messages, and docstrings are domain-neutral; domain specificity is supplied at runtime via the profile file, satisfying the epic invariant. Note: `issue.md` mentions TaskMaster/TMW as example consumers — that is a docs file describing the epic context, not a production module, and is compliant.

## Coverage (Python — mandatory, uniform tier rule per `.claude/rules/quality-tiers.md`)

**PASS.** Independently re-verified by the reviewer (`poetry run pytest tests/scripts/dev_tools/discovery/ --cov=scripts/dev_tools/discovery --cov-branch --cov-report=term-missing`, exit 0, 55 passed):

| Module (all new files) | Stmts | Miss | Branch | BrPart | Line cov | Branch cov |
|---|---|---|---|---|---|---|
| `discovery/__init__.py` | 3 | 0 | 0 | 0 | 100% | n/a |
| `discovery/domain_profile.py` | 189 | 1 | 78 | 1 | 99.5% | 98.7% |
| `discovery/domain_profile_models.py` | 55 | 0 | 14 | 0 | 100% | 100% |
| `discovery/profile_cli.py` | 46 | 0 | 6 | 0 | 100% | 100% |

- New-file thresholds (line >= 85%, branch >= 75%): PASS for every new file.
- Modified files: none (all production changes are net-new files plus one `pyproject.toml` config line), so changed-line regression is not possible. PASS.
- Repo-wide (from executor evidence `evidence/qa-gates/final-pytest-coverage.md`, full-suite run, exit 0, 1592 passed): line 88.1% >= 85%, branch ~80.5% >= 75%; total combined moved 85% -> 86% versus baseline (`evidence/qa-gates/coverage-delta.md`). PASS.
- Sole uncovered line: `domain_profile.py:75`, a defensive sentinel branch documented in evidence; not threshold-relevant.

Other languages: zero changed files on the branch — coverage verdicts not applicable to TypeScript, PowerShell, or C# for this diff.

## Coverage Exclusion Policy

**PASS.** The branch diff adds no coverage-tool configuration changes and no `exclude` entries. `pyproject.toml` gains only the console-script line; `scripts/dev_tools` was already in the coverage source set, so the new package is measured automatically. No production file is excluded from coverage.

## Suppressions

**PASS.** Zero `# noqa`, `# type: ignore`, `# pyright: ignore`, or `# pragma: no cover` directives in any file added by this branch (verified by grep over production and test trees). Ruff findings encountered during execution (TC002/TC003 on test imports) were resolved by refactoring into a `TYPE_CHECKING` block, not by suppression (`evidence/qa-gates/final-ruff.md`). Bandit S506 is not triggered because only `yaml.safe_load` is used.

## Test-File Location Mirroring

**PASS.** `tests/scripts/dev_tools/discovery/` exactly mirrors `scripts/dev_tools/discovery/`: `test_domain_profile.py` covers `domain_profile.py` + `domain_profile_models.py` (the models module is a size-limit split of the loader, re-exported through the same package surface), and `test_profile_cli.py` covers `profile_cli.py`. No test files are colocated in the production tree.

## No Temporary Files in Tests

**PASS.** Parse-layer tests feed inline YAML strings (no filesystem). I/O and CLI tests use the in-memory `mem_fs_path` fixture (`tests/conftest.py:146`), which patches `pathlib.Path` methods to an in-memory store. No `tmp_path`, `tempfile`, or `NamedTemporaryFile` usage anywhere in the new test modules (grep-verified).

## File-Size Limit (<= 500 lines)

**PASS.** All added files: `domain_profile.py` 408, `test_domain_profile.py` 452, `test_profile_cli.py` 180, `domain_profile_models.py` 152, `profile_cli.py` 154, `__init__.py` 37. The pre-emptive split of dataclasses into `domain_profile_models.py` follows the spec's stated strategy.

## Toolchain (Python: format -> lint -> type-check -> test)

**PASS.** Independently re-run by the reviewer on the changed scope, all exit 0:
- Black `--check`: 7 files unchanged.
- Ruff: "All checks passed!".
- Pyright (strict): 0 errors, 0 warnings, 0 informations.
- Pytest: 55 passed.
Executor evidence for the full-repo loop (`evidence/qa-gates/final-black.md`, `final-ruff.md`, `final-pyright.md`, `final-pytest-coverage.md`) records a single clean pass across all four stages (271 files unchanged; 1592 tests passed). The remaining general-policy stages (architecture-boundary, contract/schema, integration) have no Python gate configured for `scripts/dev_tools` in this repository; no boundary or contract surface was modified beyond the additive console-script line.

## Dependency Policy

**PASS.** No dependency added or changed. PyYAML>=6.0 was already declared; this branch makes it load-bearing for the first time, exactly as recorded in the spec's `## Specification Decision`. The conditional `types-PyYAML` dev dependency was evaluated and correctly not added (`evidence/other/pyyaml-stub-decision.md`).

## Evidence Location Compliance

**PASS.** All evidence produced for this feature lives under the canonical `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/<kind>/` tree (`baseline/`, `qa-gates/`, `other/`). The branch diff writes nothing under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with no reported violations.

## Rejected Scope Narrowing

None. The caller-supplied scope description ("Python only: `scripts/dev_tools/discovery/` package, one `pyproject.toml` line, mirrored tests") matches the actual full branch diff against the base — it is a description, not a narrowing. The declared out-of-scope items (JSON schemas #9002, `validate_*_text` validators #9003, path-existence checks) originate from the authoritative `spec.md` `### Out of scope` section, which is a legitimate scope source. The full branch diff was audited.

## Tone Policy

**PASS.** All agent-authored documentation and evidence in the diff use neutral, factual language consistent with `.claude/rules/tonality.md`.

## Verdict Summary

| Policy area | Verdict |
|---|---|
| Domain-neutrality invariant | PASS |
| Coverage thresholds (Python, line >= 85% / branch >= 75%) | PASS |
| No coverage exclusion of production files | PASS |
| No prohibited suppressions | PASS |
| Test-file location mirroring | PASS |
| No temp files in tests | PASS |
| File-size limit | PASS |
| Toolchain clean pass | PASS |
| Dependency policy | PASS |
| Evidence location compliance | PASS |

- FAIL findings: 0
- Blocking PARTIAL findings: 0
- Remediation required: NO — no `remediation-inputs` artifact produced.
