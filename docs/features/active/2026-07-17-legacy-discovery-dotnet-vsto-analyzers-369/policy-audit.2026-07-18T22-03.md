# Policy Compliance Audit — legacy-discovery-dotnet-vsto-analyzers (Issue #369)

- Timestamp: 2026-07-18T22-03
- Reviewer: feature-review agent
- Work mode: full-feature (marker `- Work Mode: full-feature` in `issue.md`)
- Feature folder: `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369`

## Scope and Baseline

- Base branch (resolved): `epic/legacy-discovery-and-parity-integration`
- Merge-base SHA: `3a4985fa904da7b5925091b393f9551c874ab006`
- Head SHA: `31965bd00a703cc90c173f0f6de7b308b6be9df8`
- Diff range: `3a4985fa904da7b5925091b393f9551c874ab006..31965bd00a703cc90c173f0f6de7b308b6be9df8`
- Evidence sources: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, branch diff, source inspection, `artifacts/python/lcov.info`, feature `evidence/` artifacts.
- Audit scope: the full branch diff versus the resolved base. Scope was not narrowed to any plan, task, phase, or file subset.

Languages with changed files in the branch diff:

- Python (production and test modules): in scope, toolchain and coverage mandatory.
- No TypeScript, PowerShell, or C# source files are changed. The `.cs.txt` / `.xmlproj.txt` / `.xml.txt` files under `tests/fixtures/discovery_dotnet_vsto/` are raw text fixtures (`.txt` suffix, exempt from the 500-line limit and not compiled), not C# source; C# toolchain and coverage are correctly not applicable.

## Rejected Scope Narrowing

None detected. No caller instruction attempted to narrow the audit scope, mark any language "informational only," or skip a coverage/toolchain check.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. Python: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/self-explanatory-code-commenting.md`
5. Supporting: `.claude/rules/quality-tiers.md`, `.claude/skills/feature-review-workflow/SKILL.md`

No policy document was modified during this review.

## Toolchain Verdicts (Python — the only language with changed files)

| Stage | Command | Result | Verdict |
|---|---|---|---|
| Formatting (Black) | `poetry run black --check <changed analyzer + test files>` | 18 files unchanged; exit 0 | PASS |
| Linting (Ruff) | `poetry run ruff check <changed analyzer + test files>` | All checks passed; exit 0 | PASS |
| Type checking (Pyright) | `poetry run pyright <5 new modules>` | 0 errors, 0 warnings, 0 informations; exit 0 | PASS |
| Unit tests (Pytest, targeted) | `poetry run pytest tests/scripts/dev_tools/discovery/analyzer/... -q` | 144 passed | PASS |
| Coverage (lcov artifact) | inspected `artifacts/python/lcov.info` | see Coverage Verification | PASS |

Independent re-run confirms the feature `evidence/qa-gates/final-qc-*.md` artifacts (Black exit 0, Ruff exit 0, Pyright 0 errors, Pytest 1975 passed).

## Coverage Verification (mandatory for Python)

Coverage verified by inspecting the pre-existing artifact `artifacts/python/lcov.info` (present, 345 KB). Coverage generation was not re-run; values below are parsed from the artifact and corroborated by `evidence/qa-gates/coverage-delta.2026-07-18T21-15.md`.

Repo-wide (Python):

- Line coverage: 89.22% (10986/12314 from lcov) >= 85% required → PASS
- Branch coverage: 87.50% (from `final-qc-pytest` and `coverage-delta` evidence) >= 75% required → PASS
- No regression: line rose 88.87% → 89.21%; branch rose 87.28% → 87.50%.

New files (added this feature) — line coverage parsed from lcov (all >= 85% and above the 90% new-file target):

| Module (new) | Line coverage (lcov) | Verdict |
|---|---|---|
| `scripts/dev_tools/discovery/analyzer/source_text.py` | 100.0% (144/144) | PASS |
| `scripts/dev_tools/discovery/analyzer/dotnet_inventory.py` | 96.8% (122/126) | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_office.py` | 97.8% (131/134) | PASS |
| `scripts/dev_tools/discovery/analyzer/vsto_patterns.py` | 100.0% (16/16) | PASS |
| `scripts/dev_tools/discovery/analyzer/stack_cli.py` | 94.2% (49/52) | PASS |

Modified files: the only non-test modified source file is `pyproject.toml` (two console-script lines; not executable Python measured by coverage) and `tests/.../test_domain_neutrality.py` (test file, excluded from the coverage denominator by policy). No modified production source file regressed on changed lines.

Python coverage verdict: PASS.

Languages with zero changed files (TypeScript, PowerShell, C#): coverage N/A (no changed files on the branch).

## Evidence Location Compliance

- Branch diff scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: none found.
- All feature evidence is under the canonical `<FEATURE>/evidence/<kind>/` tree (`evidence/baseline/`, `evidence/qa-gates/`, `evidence/other/`).
- `scripts/dev_tools/validate_evidence_locations.py --root .` executed: exit 0 (no violations).

Verdict: PASS.

## Modified-Workflow-Needs-Green-Run Rule

The branch diff modifies no path matching `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. The rule does not fire. No Blocking finding on this basis.

Verdict: PASS (rule not triggered).

## File-Size Limit (<= 500 lines)

All new production and test files are within the limit (largest: `source_text.py` at 476 lines; `test_vsto_office.py` at 474; `dotnet_inventory.py` at 457; `vsto_office.py` at 451). Raw text fixtures are exempt. Verdict: PASS.

## Dependency Policy

`pyproject.toml` adds only two `[tool.poetry.scripts]` console-entry lines (`dev.discovery.dotnet`, `dev.discovery.vsto`). No new runtime or dev dependency was added. The implementation uses the Python standard library only. Verdict: PASS.

## Suppression Policy

No `# noqa` or `# type: ignore` suppressions appear in the five new production modules. Verdict: PASS.

## Coverage-Exclusion Policy

No coverage `exclude` entry matching a `src/`-equivalent production path was added; the new `scripts/dev_tools/discovery/analyzer/` modules remain in the coverage denominator. Verdict: PASS.

## Consumer-Neutrality (feature-scoped)

Per the spec's Constraints & Risks scoping nuance, the feature-scoped domain-neutrality contract test (`tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py`) bans consumer identifiers (`taskmaster`, `tmw`) and per-Office-application hardcoding while permitting generic stack literals (`csharp`, `vsto`, `Microsoft.Office.*`, `.csproj`, `.sln`, customUI URIs). Test present and passing. The Office interop application name is captured as data into `metadata.interop_target` (`INTEROP_USING_RE` named group `app`) and never branched on. Verdict: PASS.

## Overall Verdict

PASS. No FAIL or PARTIAL findings. No blocking findings. Remediation is not required.

## Appendix A — Findings

No policy findings requiring remediation. Informational observations are recorded in `code-review.2026-07-18T22-03.md`.

## Appendix B — Command Reference

```
git diff --stat 3a4985fa904da7b5925091b393f9551c874ab006..31965bd00a703cc90c173f0f6de7b308b6be9df8
poetry run black --check scripts/dev_tools/discovery/analyzer/{source_text,dotnet_inventory,vsto_office,vsto_patterns,stack_cli}.py tests/scripts/dev_tools/discovery/analyzer/
poetry run ruff check scripts/dev_tools/discovery/analyzer/{source_text,dotnet_inventory,vsto_office,vsto_patterns,stack_cli}.py tests/scripts/dev_tools/discovery/analyzer/
poetry run pyright scripts/dev_tools/discovery/analyzer/{source_text,dotnet_inventory,vsto_office,vsto_patterns,stack_cli}.py
poetry run pytest tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py tests/scripts/dev_tools/discovery/analyzer/test_source_text.py tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py -q
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# coverage inspected, not regenerated:
#   artifacts/python/lcov.info
```
