# Policy Audit — legacy-discovery-skills (Issue #367)

- Timestamp: 2026-07-18T21-26
- Branch: `feature/legacy-discovery-skills-367`
- Base: `origin/epic/legacy-discovery-and-parity-integration`
- Feature commit: `13234ea0`
- Work Mode: `full-feature` (from `issue.md`)
- Diff scope: full branch diff against the epic integration base (32 files, +1751/-61; the only non-additive entries are checkbox/status updates in the feature folder's own `plan.2026-07-17T15-03.md`, `spec.md`, and `user-story.md`)

## Change Set Summary

- 7 new skills: `.claude/skills/discovery-{workflow,repo-inventory,coverage-ledger,runtime-characterization,parity-matrix,behavior-reconciliation,validate-artifacts}/SKILL.md`
- 7 bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`
- 1 pytest contract module: `tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py` (415 lines)
- Feature-folder docs and evidence under `docs/features/active/2026-07-17-legacy-discovery-skills-367/`

## Verdicts

| # | Policy | Verdict | Evidence |
|---|---|---|---|
| 1 | CLAUDE.md / tonality (professional, factual, no humor/hyperbole) | PASS | All seven `SKILL.md` files and the test module docstrings read in full; language is neutral, literal, and factual. No jokes, emojis, hyperbole, or decorative metaphor found. |
| 2 | Policy documents not modified (`.claude/rules/**`, `.github/instructions/**`) | PASS | `git diff <base>...HEAD --name-only` filtered for those prefixes returns zero matches (grep exit 1). |
| 3 | general-code-change: 500-line file cap | PASS | `wc -l`: skills 63–146 lines each; test module 415 lines. All under 500. |
| 4 | general-code-change: simplicity, no new dependencies | PASS | Spec `## Implementation Strategy` declares no dependency changes; diff contains no `pyproject.toml` or lockfile change. Test module imports only `pathlib` and `pytest` (existing). |
| 5 | Python toolchain (Black -> Ruff -> Pyright -> Pytest), re-verified at review time | PASS | `poetry run black --check` (exit 0, unchanged), `poetry run ruff check` (exit 0, "All checks passed"), `poetry run pyright` (0 errors) on the new module; `poetry run pytest tests/scripts/dev_tools/test_legacy_discovery_skills_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — 67 passed, exit 0. |
| 6 | general-unit-test: independence, isolation, determinism, no temp files, no external services | PASS | Test module reads only committed repository files via `Path.read_text`; no network, no temp files, no wall-clock/random use, parametrized single-behavior tests with actionable assertion messages. |
| 7 | Coverage — no regression, thresholds >= 85% line / >= 75% branch | PASS | `evidence/qa-gates/final-qc-coverage-delta.2026-07-18T21-09.md` and `final-qc-pytest-cov.2026-07-18T21-09.md`: line 88.87%, branch 87.28%, delta 0.00 pp vs baseline, 1899 tests passed. No production Python is added, so the coverage denominator is unchanged. |
| 8 | Coverage exclusion policy (no production file excluded) | PASS | Diff adds no coverage-config change; the only new `.py` file is a test module under `tests/`, an explicitly permitted exclusion class. |
| 9 | Domain-neutrality invariant (banned substrings, case-insensitive) | PASS | `grep -riE 'taskmaster|tmw|outlook|vsto|email|task-management|task management'` across all 7 skills and all 7 bundle mirrors: zero matches (exit 1). Enforced ongoing by `test_banned_substrings_absent` (7 parametrized cases, passing). |
| 10 | Bundle-parity invariant (byte-identical mirrors) | PASS | `cmp` of each skill against its bundle mirror: all 7 IDENTICAL. `test_push_down_claude_resource_contracts.py` passes on the branch head. |
| 11 | Name-non-collision invariant (existing skills, `code-modernization` plugin) | PASS | `.claude/skills/` holds 47 unique folder names (`uniq -d` empty) including the 7 new; no `discovery-*` name appears in the frozen `code-modernization` command/agent set (`test_skill_name_does_not_collide_with_code_modernization`, 7 cases passing). |
| 12 | SKILL.md frontmatter contract (`make-skill-template`) | PASS | All 7 have `name:` matching folder and single-quoted non-empty `description:`. `allowed-tools` present only on the two CLI-driving skills, using the space-delimited form documented in `make-skill-template/SKILL.md` line 54 ("Space-delimited list of pre-approved tools"). |
| 13 | Evidence Location Compliance | PASS | See section below. |
| 14 | python-suppressions policy | PASS | No `# noqa` or `# type: ignore` occurrences in the new module. |

## Evidence Location Compliance

- `scripts/dev_tools/validate_evidence_locations.py --root .` exit code 0 (no violations).
- Branch diff contains no files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` (name-only grep for `^artifacts/`: zero matches).
- All feature evidence resides under `docs/features/active/2026-07-17-legacy-discovery-skills-367/evidence/{baseline,qa-gates,other}/` with ISO-8601 timestamps.

## Rejected Scope Narrowing

None. The caller-stated scope (full branch diff vs the epic integration base) matches the resolved base; no narrowing was attempted.

## Coverage Verification by Language

- Python: only language with changed source files (one test module; zero production files). Verdict PASS — repo-wide line 88.87% (>= 85%), branch 87.28% (>= 75%), zero delta vs baseline per `evidence/qa-gates/final-qc-coverage-delta.2026-07-18T21-09.md`. No new or modified production files, so per-file new/modified thresholds are vacuously satisfied.
- TypeScript, PowerShell, C#: zero changed files in the branch diff; no coverage obligation.

## Assumptions

- PR context artifacts were not present in this worktree; scope was derived directly from `git diff`/`git log` against the resolved base, which the caller confirmed as the authoritative base branch.

## Blocking Findings

Blocking findings count: 0
