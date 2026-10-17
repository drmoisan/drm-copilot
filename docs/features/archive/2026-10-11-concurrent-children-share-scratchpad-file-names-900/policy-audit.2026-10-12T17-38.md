# Policy Audit: concurrent-children-share-scratchpad-file-names (Issue #900)

- Timestamp: 2026-10-12T17-38
- Branch: bug/concurrent-children-share-scratchpad-file-names-900
- Head: eb365f9f4 (pushed)
- Base: origin/main (diff `origin/main...HEAD`; origin/main is merged into the branch)
- Work Mode: minor-audit
- Review scope: full branch diff against origin/main (45 files, 1733 insertions, 0 deletions)
- Template note: the bundled policy-audit template asset was not retrievable by this agent; the canonical section headings, the checklist labels, and the per-language comparison section required by the artifact validator are preserved manually. Template retrieval is recorded as a limitation, not a policy failure of the change.

## Rejected Scope Narrowing

None applied. The caller described the run as a reduced small-audit and listed two follow-ups as out of scope (a plan-validator check for bare scratch paths, and the `.codex/agents` TOML update). Those items are deferred work that the issue itself records under Dependencies / Risks. They are not exclusions of changed files or of any language with changed files. The full branch diff was audited and every required section was produced.

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` exited 0 with no output (run during this review).
- No branch-diff file is under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All evidence is under `<FEATURE>/evidence/baseline/`, `evidence/qa-gates/`, or `evidence/regression-testing/`.
- Verdict: PASS. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events.

## Executive Summary

Overall verdict: PASS. Blocking findings: 0 (FAIL: 0, blocking-PARTIAL: 0). One acceptance criterion (AC-11, PR CI green) is pending CI and is classified non-blocking at this stage.

The change adds a `## Scratch Location` section to four persona and skill sources (`.claude/agents/atomic-planner.md`, `.claude/agents/atomic-executor.md`, `.agents/skills/atomic-planner/SKILL.md`, `.agents/skills/atomic-executor/SKILL.md`), insertion-only (10, 11, 10, 11 lines). It adds byte-identical bundled copies of those four files and one new pytest contract module (275 lines). The remaining 36 changed files are feature-folder documents and evidence.

Verified during this review:

- `cmp` reported all four bundled copies identical to their primary sources.
- `git diff --name-only origin/main...HEAD` contains no file under `.claude/rules/`, `.github/instructions/`, `.codex/agents/`, the orchestrator and orchestrate sources, the remediation-handoff skill, the conventions skills, any child-prompt template, or any plan-validator source, and no file under `docs/features/` outside this feature folder.
- `git ls-files --eol` shows all five changed code and persona files as LF in the index and the working tree.
- `poetry run pytest` on the new module: 15 passed. The five neighbouring contract modules (both push-down parity modules, planning-integrity, TypeScript toolchain mirror, Codex handoff parity): 49 passed, including the issue #510 node.
- `poetry run black --check`, `poetry run ruff check`, and `poetry run pyright` on the new module: black reports 1 file unchanged, ruff reports all checks passed, pyright reports 0 errors, 0 warnings.

## 1. General Unit Test Policy Compliance

- Independence, isolation, determinism: PASS. The module reads checked-in repository files only; no clock, randomness, network, process, or shared mutable state is used.
- Temporary files: PASS. None created or used.
- Arrange-Act-Assert structure: PASS. Each test carries `# Arrange`, `# Act`, `# Assert` comments and assertion messages that name the file and the missing phrase.
- Scenario completeness: PASS. Positive (rule phrases present), negative (forbidden shapes absent), placement (neighbouring headings), and pre-rule-plan handling are each asserted per source; parametrized across four sources.
- Test file location: PASS. `tests/scripts/dev_tools/test_scratch_location_contracts.py` lives in the `tests/` tree that mirrors `scripts/dev_tools/`; no test is colocated with production source.
- Red-before-green: PASS. `scratch-contract-red` records 14 failed, 1 passed against pre-change sources; `scratch-contract-green` records 15 passed.

### 1.2 Coverage Evidence Checklist

- TypeScript baseline coverage artifact: N/A (no TypeScript file changed; no baseline figure applies)
- TypeScript post-change coverage artifact: N/A (no TypeScript file changed; no post-change figure applies)
- PowerShell baseline coverage artifact: N/A (no PowerShell file changed; the Pester suite is a CI-gated regression guard only)
- PowerShell post-change coverage artifact: N/A (no PowerShell file changed; no post-change figure applies)
- Per-language comparison summary: Python is the only language with a changed file (one new test module); see 1.2.1

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 0 | 0 | N/A (no change) | N/A (no source changed) | N/A (no source changed) | N/A (no new code) |
| Python | 1 (test module only) | 15 | PASS (15 passed) | 39.24% (single-module slice) | 39.24% (single-module slice) | N/A (test module is omitted from coverage by configuration) |
| PowerShell | 0 | 0 | N/A (no change) | N/A (no source changed) | N/A (no source changed) | N/A (no new code) |
| C# | 0 | 0 | N/A (no change) | N/A (no source changed) | N/A (no source changed) | N/A (no new code) |

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: N/A. Zero changed files. Disposition: N/A. Evidence: branch diff contains no TypeScript file.
- Python: Baseline: 39.24% (31 of 79 lines, `scripts/dev_tools/push_down_claude_customizations.py`). Post-change: 39.24% (identical totals: 79 statements, 48 not covered, 16 branches, 0 partial). Change: 0.00 percentage points; no production Python line changed. Disposition: PASS (no regression; see 5). Evidence: `evidence/baseline/pytest-coverage-baseline.2026-10-11T10-38.md`, `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`, `evidence/qa-gates/coverage-comparison.2026-10-11T10-38.md`.
- PowerShell: N/A. Zero changed files. Disposition: N/A. Evidence: branch diff contains no PowerShell file.
- C#: N/A. Zero changed files. Disposition: N/A. Evidence: branch diff contains no C# file.

## 2. General Code Change Policy Compliance

- Simplicity and separation of concerns: PASS. Persona changes are plain prose insertions. The test separates pure helpers (`scratch_section`, `neighbouring_headings`, `normative_surface_paths`) from the assertions.
- Scope and blast radius: PASS. Changed paths outside the feature folder are exactly the four primary sources, their four bundled copies, and the one new test module. No excluded path from the issue appears in the diff.
- File size limit (500 lines): PASS. The test module is 275 lines; the largest persona edit is a 11-line insertion. Markdown documentation is exempt.
- Insertion-only edits: PASS. `git diff --numstat` on the eight persona and bundled files shows additions only (10 or 11 per file) and 0 deletions; `insertion-only-numstat` evidence agrees.
- Dependencies: PASS. None added. The test imports only `re`, `pathlib`, `pytest`.
- Public API compatibility: PASS. No code API changed; child-prompt templates are untouched, so the closed five-element kickoff contract is preserved.
- Error handling: PASS. The helpers return empty values for an absent section so the assertions fail with a named message instead of raising an unrelated exception.
- Exclusion policy (`general-unit-test.md` Coverage Exclusion Policy): PASS. No coverage `exclude` or `omit` entry was added or changed; `pyproject.toml` is not in the diff.
- Path hygiene in persona text: PASS. The new rule text contains no backticked `npm run` token, no `issue number: <digits>` shape, and no `docs/features/active/` path (asserted by the test and checked by reading the diff). The text instructs artifacts to record the literal token `SCRATCH`, never a host path.

## 3. Language-Specific Code Change Policy Compliance

- Changed files by language: TypeScript 0, Python 1 (test module), PowerShell 0, C# 0, GitHub Actions 0. Persona and skill files are Markdown.
- Python (`.claude/rules/python.md`): PASS. Annotated signatures, `from __future__ import annotations`, module and function docstrings, `snake_case` helpers, constants in upper case, and no untyped escape hatches. Pyright reports 0 errors.
- Line endings: PASS. The four primary sources and the new module are `i/lf w/lf` with `eol=lf` attribute.
- Bundled-copy parity: PASS. `cmp` reports byte identity for all four pairs; both push-down parity modules pass.

## 4. Language-Specific Unit Test Policy Compliance

- Python test policy: PASS. Pytest function-style tests, `pytest.param` ids for readable failures, parametrization instead of loops with shared state, no fixtures that touch the filesystem outside read-only repository files, no banned wait or clock APIs.
- Property-based test density: not required. The module is a T4 contract test with no pure production function under test.
- Verdict: PASS.

## 5. Test Coverage Detail

| Language | Changed files | Coverage artifact | Verdict |
|---|---|---|---|
| TypeScript | 0 | not required | PASS (zero changed files) |
| Python | 1 (new test module) | `artifacts/python/lcov.info` (exists, gitignored; 1 source file, 79 lines found, 31 hit, 16 branches found, 0 hit) | PASS (delta basis; see note) |
| PowerShell | 0 | not required | PASS (zero changed files) |
| C# | 0 | not required | PASS (zero changed files) |

Python note. The only changed Python file is a new test module under `tests/`. `[tool.coverage.run] omit` lists `tests/*` and `*/tests/*`, which is a permitted exclusion of test infrastructure, so the new file is not in the coverage denominator and has no line or branch figure of its own. No production Python file was modified (`git diff --name-only origin/main...HEAD -- scripts src` is empty). Baseline and post-change coverage totals are identical, so there is no regression on changed lines (there are none). The coverage artifact the executor produced is a single-module slice (`push_down_claude_customizations`, 39.24% line, 0 of 16 branches), selected to prove the totals did not move; it is not a repo-wide Python figure and is not evidence that the repository meets the 85% line and 75% branch thresholds. The repo-wide Python threshold is therefore evaluated on the change delta, which is zero, and not on that slice. This is recorded as advisory finding G-1 in section 8 and is not blocking because the change cannot alter the repo-wide figure.

## 6. Test Execution Metrics

| Check | Result | Evidence |
|---|---|---|
| New module, executor run (red, pre-change sources) | 14 failed, 1 passed, exit 1 (expected) | `evidence/regression-testing/scratch-contract-red.2026-10-11T10-38.md` |
| New module, executor run (green) | 15 passed | `evidence/regression-testing/scratch-contract-green.2026-10-11T10-38.md` |
| New module, reviewer re-run at head | 15 passed | `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py -q` |
| Six AC-listed modules, executor run | 63 passed, 1 deselected (#510 node run alone) | `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`, `evidence/regression-testing/issue-510-node-after.2026-10-11T10-38.md` |
| Five neighbouring modules, reviewer re-run at head | 49 passed, 0 failed (the #510 node passes in this environment) | `poetry run pytest <five modules> -q` |
| Black, Ruff, Pyright on new module, reviewer re-run | unchanged / all checks passed / 0 errors | executor evidence `new-module-black-check`, `new-module-ruff`, `new-module-pyright` agree |
| PoshQC claude-runtime call | `ok: true`; returns no per-test output | `evidence/qa-gates/final-poshqc-claude-runtime.2026-10-11T10-38.md` |
| Pester `claude-architecture-doc.Tests.ps1` (reads `atomic-executor.md`) | Not locally attributable; taken from PR CI | pending-CI (AC-11) |

## 7. Code Quality Checks

- Formatting: PASS. `black --check` reports 1 file would be left unchanged.
- Lint: PASS. `ruff check` reports all checks passed.
- Type check: PASS. `pyright` reports 0 errors, 0 warnings, 0 informations.
- Architecture-boundary and contract checks: PASS. Push-down parity (Claude and Codex/agents), planning-integrity, TypeScript toolchain mirror, and Codex handoff parity modules pass.
- Unit tests: PASS (see section 6).
- Integration tests: not applicable to this change; no adapter or external system is touched.
- QC loop: PASS. `final-qc-loop-pass` records restart count 0.

## 8. Gaps and Exceptions

1. G-1 (advisory, non-blocking): the Python coverage artifact is a single-module slice, not a repo-wide measurement (see section 5). The change adds no production line, so the repo-wide figure is unchanged. No action is required for this change; a repo-wide Python coverage run belongs to the pipeline that owns the 85% and 75% gates.
2. G-2 (known deferral, not a finding): no plan-validator check rejects a bare scratchpad `SCRATCH` definition. It would require a `.claude/rules/plan-acceptance-gates.md` edit that needs operator approval, plus validator and parity-suite work. The persona rule is enforced by the contract test and agent compliance until that follow-up lands. Recorded in the issue under Dependencies / Risks.
3. G-3 (known deferral, not a finding): `.codex/agents/atomic-planner.toml` and `atomic-executor.toml` are unchanged by design; the `.agents/skills/` edits cover the Codex skill surface. Recorded in the issue.
4. G-4 (pending CI): AC-11 requires PR CI to be green, including the Pester suite that reads `atomic-executor.md`. The diff changes no PowerShell file and inserts only Markdown prose between existing sections, so a regression in that suite is unlikely, but this is not verified until the CI run exists. Classified pending-CI, non-blocking. The workflow-gate rule `modified-workflow-needs-green-run` does not fire: no `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**` path is in the diff.
5. Tier classification: not evaluated as a finding. No project entry was added; the change touches no project under `quality-tiers.yml`.

## 9. Summary of Changes

- Added: `## Scratch Location` section in `.claude/agents/atomic-planner.md` (10 lines), `.claude/agents/atomic-executor.md` (11), `.agents/skills/atomic-planner/SKILL.md` (10), `.agents/skills/atomic-executor/SKILL.md` (11).
- Added: four byte-identical bundled copies under `extensions/drm-copilot/resources/claude-customizations/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- Added: `tests/scripts/dev_tools/test_scratch_location_contracts.py` (275 lines, 15 test cases).
- Added: feature folder `issue.md`, plan, research note, and 33 evidence artifacts.
- No deletions. No modification to any pre-existing file other than the four persona or skill sources and their bundled copies.

## 10. Compliance Verdict

PASS. Blocking findings: 0 (FAIL: 0, blocking-PARTIAL: 0). Remediation inputs are not required. AC-11 remains pending CI and is non-blocking at this review. The PR should not be reported ready until the CI run is cited.

## Appendix A: Test Inventory

Added: `tests/scripts/dev_tools/test_scratch_location_contracts.py`, 15 test cases.

- `test_scratch_location_section_states_the_rule` (4 sources)
- `test_scratch_location_section_avoids_forbidden_shapes` (4 sources)
- `test_planner_scratch_location_placement` (2 planner sources)
- `test_executor_scratch_location_placement` (2 executor sources)
- `test_executor_scratch_location_handles_pre_rule_plans` (2 executor sources)
- `test_normative_surfaces_name_no_bare_fixed_scratch_path` (1 scan across `.claude/agents/*.md`, `.claude/skills/**/SKILL.md`, `.agents/skills/**/SKILL.md`)

Regression modules run: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_claude_planning_integrity_contracts.py`, `test_typescript_toolchain_instruction_contracts.py`, `test_codex_handoff_contract_parity.py`.

## Appendix B: Toolchain Commands Reference

- `git diff --name-only origin/main...HEAD`
- `git diff origin/main...HEAD -- .claude/agents .agents`
- `git ls-files --eol <changed persona and test files>`
- `cmp <bundled copy> <primary source>` (four pairs)
- `poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py -q`
- `poetry run pytest <five neighbouring contract modules> -q`
- `poetry run black --check tests/scripts/dev_tools/test_scratch_location_contracts.py`
- `poetry run ruff check tests/scripts/dev_tools/test_scratch_location_contracts.py`
- `poetry run pyright tests/scripts/dev_tools/test_scratch_location_contracts.py`
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
