# Policy Compliance Audit — legacy-discovery-acceptance-scenarios (#364)

- Timestamp: 2026-07-18T11-52
- Reviewer: feature-review agent
- Branch: `feature/legacy-discovery-acceptance-scenarios-364` (head `688c99dd`)
- Base: `origin/epic/legacy-discovery-and-parity-integration` (merge base `f18c1c16`)
- Work mode: `full-feature` (marker in `issue.md`, line 12)
- Scope: full branch diff vs base — 21 files, +1214/−56. Changed surface: 1 new production module, 1 new test file, 1 additive `pyproject.toml` line, feature docs and evidence artifacts. No workflow-file changes; `.claude/rules/ci-workflows.md` and `.claude/rules/benchmark-baselines.md` are not applicable (zero changed files in their scope).
- PR context artifacts: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent at review start and were regenerated from the resolved base before auditing.

## Rejected Scope Narrowing

None. The caller prompt requested a full branch-diff review against the epic integration base; no narrowing was attempted.

## Verdict Summary

| Policy | Verdict |
|---|---|
| `.claude/rules/general-code-change.md` | PASS |
| `.claude/rules/general-unit-test.md` | PASS |
| `.claude/rules/python.md` (toolchain + coding standards) | PASS |
| `.claude/rules/quality-tiers.md` (uniform coverage gates) | PASS |
| Coverage exclusion policy | PASS |
| Evidence location and timestamp conventions | PASS |
| Tonality policy (`.claude/rules/tonality.md`) | PASS |
| Language coverage — Python (changed files present) | PASS |
| Language coverage — TypeScript / PowerShell / C# | N/A (zero changed files on branch) |

Blocking findings in this artifact: 0.

## 1. General Code Change Policy — PASS

- **Simplicity / separation of concerns**: pure transform functions (`project_*`, `assemble_scenarios`, `build_document`, `format_document`) are separated from I/O (`_load_json_document`, `_generate_from_args`, `main`) in `scripts/dev_tools/generate_acceptance_scenarios.py`. Verified by reading the module: no filesystem access occurs in the projection/assembly/serialize functions.
- **Keyword-style parameters**: `resolve_discovery_schema(schema_name, *, root, version=None)` (line 36) and `build_document(..., *, root)` (line 328) use keyword-only parameters per policy preference.
- **File size limit (500 lines)**: `scripts/dev_tools/generate_acceptance_scenarios.py` = 492 lines; `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` = 488 lines. Verified against the working tree and consistent with `evidence/other/file-size-check.2026-07-17T14-37.md`. PASS.
- **Fail fast and explicitly**: a single specific exception type `GenerationError` (line 28) is raised for missing/malformed/incomplete input; the only broad-boundary handler is the CLI entry point (`main`, lines 472–476), which catches `GenerationError` specifically (not `Exception`) and translates to exit code 1 with a message. PASS.
- **Dependencies**: none added. The module uses only stdlib (`argparse`, `hashlib`, `json`, `sys`, `dataclasses`, `pathlib`, `typing`). Verified in the diff. PASS.
- **Naming**: `snake_case` functions, `PascalCase` dataclasses, `CONSTANT_CASE` module constants (`GENERATOR_ID`, `SCHEMA_VERSION`, `SCHEMA_SELF_REF`). PASS.
- **Toolchain loop**: final clean-pass evidence at `evidence/qa-gates/black-final.2026-07-17T14-37.md` (EXIT_CODE 0, 0 reformatted), `ruff-final...` (EXIT_CODE 0, 0 errors), `pyright-final...` (EXIT_CODE 0, 0 errors/warnings), `pytest-final...` (EXIT_CODE 0, 1713 passed). The ruff and pyright artifacts record loop restarts after auto-fixes, satisfying the restart-from-step-1 requirement. Architecture-boundary, contract, and integration stages have no applicable Python gate for a standalone `scripts/dev_tools` CLI module; no boundary or contract surface changed in the diff. PASS.

## 2. General Unit Test Policy — PASS

- **Test file location**: `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` mirrors `scripts/dev_tools/generate_acceptance_scenarios.py`. No colocation. PASS.
- **No temporary files**: the test file contains no `tmp_path` or `tempfile` usage; all read/write goes through the in-memory `mem_fs_path` fixture (defined in `tests/conftest.py`, line 146). Verified by reading the test file. PASS.
- **Independence / isolation / determinism**: tests build fresh in-memory documents per test via `_feature_doc`/`_parity_doc`/`_characterization_doc` helpers; no shared mutable state; no sleeps, retries, or wall-clock reads. Re-run verification: `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py -q` → 34 passed in 0.06s (executed during this review). PASS.
- **Determinism infrastructure**: no seeded RNG or injected clock is required because the generator is a pure transform with no nondeterministic input (spec, "No seeded RNG or injected clock"). The module contains no `datetime`, `time`, or `random` import (verified by reading the import block, lines 10–21). Banned test APIs (`setTimeout`-equivalents, sleeps, `Date.now()`-equivalents) are absent. PASS.
- **Scenario completeness**: positive flows, negative flows (4 parametrized failure modes), edge cases (empty parity rows / empty characterization → null refs, non-list string field, unknown fields), error handling (exit code 1 with message), and CLI state (`--check` match/mismatch/missing-output/absent-target). Concurrency and stateful transitions are not applicable to a pure transform. PASS.
- **Arrange–Act–Assert and naming**: descriptive `test_...` names grouped by category (seam, projection, positive, determinism, negative, cli); module docstring documents the categories. PASS.
- **Property-based tests**: the module is a `scripts/dev_tools` dev-tooling CLI (T4 scaffolding class per `quality-tiers.md` examples: "build scripts, dev tooling"); property-test density is required only for T1/T2. Not required. PASS.

## 3. Python Rules — PASS

- **Toolchain order and clean pass**: see section 1; all four stages recorded with EXIT_CODE 0.
- **Typing**: all public functions carry full parameter and return annotations; `Any` appears only in JSON-boundary positions (`dict[str, Any]`) with `cast()` isolation at parse boundaries (`_load_json_document`, line 388; `_string_tuple`, line 139), matching the pyright-final evidence note. No `# type: ignore` in the production module; one `# type: ignore[misc]` in the test file (line 112) with an intentional-TypeError justification implicit in the test name (`test_seam_keyword_only_parameters`). PASS.
- **Dataclasses**: frozen dataclasses for the four projection value objects (lines 77–121). PASS.
- **Error handling**: specific `GenerationError`/`FileNotFoundError`; no bare or broad `except`. PASS.
- **`print` usage**: status messages in `main`/`_run_check` only, consistent with the reference CLI modules (`validate_json.py`, `format_json.py`) and the spec's "Logging/telemetry" section. Not ad-hoc permanent-behavior printing. PASS.
- **Suppressions**: no new lint/type suppressions in the production module. PASS.

## 4. Quality Tiers and Coverage — PASS

Coverage verified from the pre-existing artifact `artifacts/python/lcov.info` (present; record for the module at `SF:scripts\dev_tools\generate_acceptance_scenarios.py`, line 9385). Parsed during this review:

| Metric | Value | Threshold | Verdict |
|---|---|---|---|
| Repo-wide line coverage (Python) | 88.27% (10052/11388) | >= 85% | PASS |
| Repo-wide branch coverage (Python) | 79.08% (3364/4254, LCOV BRH/BRF) | >= 75% | PASS |
| New file `generate_acceptance_scenarios.py` line coverage | 100.00% (LF=186, LH=186) | >= 85% | PASS |
| New file branch coverage | 100.00% (BRF=42, BRH=42) | >= 75% | PASS |
| Modified-file regression | No pre-existing production file modified (only additive `pyproject.toml` line) | no regression | PASS |

Cross-check against feature evidence: `evidence/regression-testing/coverage-delta.2026-07-17T14-37.md` reports baseline 88.07%/86.94% → post-change 88.27%/87.07% with module 100%/100%, outcome PASS. Note: the evidence computes branch coverage as (BRF−BrPart)/BRF (87.07%), which treats partially-hit branch lines as covered; the stricter LCOV BRH/BRF computation yields 79.08%. Both computations exceed the 75% threshold, so the verdict is unaffected. Non-blocking observation only.

TypeScript, PowerShell, and C#: zero changed files in the branch diff (verified via `git diff --name-only`); coverage verification not applicable for those languages.

## 5. Coverage Exclusion Policy — PASS

The diff contains no changes to any coverage configuration (`pyproject.toml` change is one console-script line only; no `[tool.coverage]` edits, no `exclude` entries). No production path is excluded from measurement. PASS.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` → exit 0 (no violations).
- Branch-diff scan for files under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: zero matches.
- All 15 evidence artifacts in the diff are under `docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/evidence/<kind>/` using the canonical kinds `baseline/`, `qa-gates/`, `regression-testing/`, `other/`. PASS.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no caller instruction supplied a non-canonical path.

## 6. Timestamp Conventions — PASS (with non-blocking observation)

Evidence filenames use the ISO-8601 `yyyy-MM-ddTHH-mm` form. Non-blocking observation: filenames carry the plan timestamp `2026-07-17T14-37` while the internal `Timestamp:` lines record the actual run time `2026-07-18T11-12`. The filename suffix functions as the plan-batch identifier and each artifact records its true execution timestamp internally, so traceability is preserved. Severity: Non-blocking.

## 7. Tonality — PASS

Spec, user-story, plan, and evidence artifacts sampled during this review use neutral, factual language; no humor, hyperbole, or decorative metaphor observed.

## Findings Register

| # | Severity | Finding | Location | Rule |
|---|---|---|---|---|
| PA-1 | Non-blocking | Evidence filename timestamp (`2026-07-17T14-37`) differs from internal `Timestamp:` (`2026-07-18T11-12`); batch-id usage, traceability preserved | `evidence/**/*.2026-07-17T14-37.md` | evidence-and-timestamp conventions |
| PA-2 | Non-blocking | Coverage-delta evidence computes branch coverage as (BRF−BrPart)/BRF = 87.07%; strict LCOV BRH/BRF = 79.08%. Both exceed the 75% gate | `evidence/regression-testing/coverage-delta.2026-07-17T14-37.md` line 12 | quality-tiers coverage gate (reporting method only) |

Blocking findings: 0.
