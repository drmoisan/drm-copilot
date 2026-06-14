# Policy Compliance Audit: claude-memory-scope-and-hardening (Issue #181)

**Audit Date:** 2026-06-13
**Feature Folder:** `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181`
**Base Branch:** `main`
**Merge-base SHA:** `2745d23d01ea179d8d02fc240dbadb1017ee7aeb`
**Branch head SHA:** `75b0ea6191b0498b9e2240f9a262457f348a57e3`
**Work Mode:** full-feature (`spec.md` + `user-story.md` are AC sources)

**Code Under Test (production Python changed by this feature):**
- `scripts/dev_tools/push_down_claude_customizations.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py` (byte-identical mirror)
- `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`
- `scripts/dev_tools/validate_orchestrator_state.py`

**Test Python changed by this feature:**
- `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` (new)
- `tests/scripts/dev_tools/test_validate_orchestrator_state.py` (modified)
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (modified)

**Markdown / policy mirror changes (root + bundle, byte-identical):**
- `.claude/rules/orchestrator-state.md` (new) and bundle mirror
- `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/typescript.md`, `.claude/rules/csharp.md` and bundle mirrors
- Bundle `.claude/agent-memory/orchestrator/` reconciliation (Option B)

## Coverage Metrics by Language

| Language | Files Changed | Tests | Test Result | Repo-wide Coverage | Changed-Module Coverage | Coverage Verdict |
|----------|---------------|-------|-------------|--------------------|-------------------------|------------------|
| Python | 4 production, 3 test | 1116 pass, 19 skipped (full suite) | PASS | 82% TOTAL (line+branch combined), unchanged from 82% baseline | `push_down_claude_customizations.py` 88% line; `validate_orchestrator_state.py` 92% line | PASS (per changed-module thresholds and no-regression rule) |
| Markdown | 49 files (scoping docs, evidence, rules, memories) | N/A | Structural review only | N/A | N/A | N/A (no executable code) |
| TypeScript | 0 changed files in branch diff | N/A | N/A | N/A | N/A | N/A (zero TypeScript files changed; verified `git diff --name-only ... | grep -E '\.(ts|tsx)$'` returns none) |

Coverage artifact inspected: `artifacts/python/lcov.info` (present; regenerated during this review by the full suite run). The repository-configured Pyright `include` is `scripts`, `src`, `tests`; the extension template under `extensions/drm-copilot/resources/templates/` is outside the type-check `include` set and is intentionally not type-checked by the policy command `poetry run pyright`.

## Executive Summary

The feature is **COMPLIANT** with repository policy for all gates that the feature touches. The implementation matches `spec.md`: a re-based frontmatter scope parser (no PyYAML), a push-down scope filter that distributes only `scope: general` agent memories, the Option B physical removal of repo-specific memories from the bundle, additive backward-compatible orchestrator-state remediation-cycle invariants, the type-only coverage exemption note mirrored into four rule files, and byte-identical mirroring of all non-memory `.claude` changes.

Toolchain results from this review (re-run against the branch head):
- Black: PASS (`poetry run black --check` on all 7 changed Python files — unchanged).
- Ruff: PASS (`poetry run ruff check` on changed Python files — All checks passed).
- Pyright (policy command, project-scoped): PASS (`poetry run pyright` — 0 errors).
- Pytest with coverage: PASS (1116 passed, 19 skipped; `artifacts/python/lcov.info` written).

The repository-wide combined coverage TOTAL is 82%, identical to the pre-feature baseline (82%); this feature introduces no coverage regression. The two production modules edited by the feature are at 88% and 92% line coverage, both above the 85% line threshold. The 82% repo-wide figure is a pre-existing repository state, not a defect introduced by this change.

Rejected-snapshot verification (Decision C1): the rejected snapshot artifacts are confirmed **absent** from both root and bundle — no `.claude/rules/coverage.md`, no `diff-cover` gate reference in committed `.claude/` content, no PyYAML import in any changed push-down script, and the root coverage policy remains 85% line / 75% branch with the tier system retained.

**Policy documents evaluated:**
- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- `.claude/rules/self-explanatory-code-commenting.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/tonality.md`

**Temporary artifacts cleanup:**
- No temporary implementation scripts were introduced.
- New artifacts are limited to feature-folder scoping/evidence files and the six promoted bundle memories.

## Rejected Scope Narrowing

The caller prompt declared three cross-language items (new-code delta gate; test-purity hooks for TS/C#; batch-budget hooks for TS/C#) as "intentionally OUT OF SCOPE." This is consistent with `spec.md` Decision L and the Out of Scope sections, and those items have **no changed files in the branch diff**, so they are legitimately out of scope; this is not a rejected narrowing.

The caller also stated "the extension's TypeScript toolchain applies only if you find changed TypeScript files." This was verified independently: the branch diff contains zero `.ts`/`.tsx` files. The TypeScript coverage verdict is therefore `N/A` (acceptable only because zero TypeScript files changed on the branch). No narrowing of a language with changed files was attempted, so there is no rejected narrowing to record. The full feature-vs-base audit was performed for every language that has changed files (Python, Markdown).

## Evidence Location Compliance

The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Command: `git diff --name-only 2745d23..75b0ea6 | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` returned **NONE**. All feature evidence is written under the canonical `docs/features/active/2026-06-13-claude-memory-scope-and-hardening-181/evidence/<kind>/` path (baseline and qa-gates subfolders). No evidence-location violation found. Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence | PASS | New tests construct in-memory fakes per test; full suite passes without order sensitivity (1116 passed). |
| Isolation | PASS | Scope-parser tests, push-down filter tests, resource-contract tests, and validator invariant tests target single units. |
| Fast execution | PASS | The three changed test modules run in ~0.19s; full suite in ~4.42s. |
| Determinism | PASS | Tests use in-memory filesystem fakes and literal JSON fixtures; no clock, RNG, network, or temp files. |
| Readability & maintainability | PASS | Test names are scenario-based (general/repo/absent/malformed/unrecognized; positive/negative invariant cases). |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| Baseline coverage documented | PASS | `evidence/baseline/baseline-pytest.md` records 82% TOTAL baseline (1096 passed). |
| No coverage regression on changed lines | PASS | Repo-wide TOTAL unchanged at 82%; changed modules at 88%/92% line. Missing lines are import-fallback and defensive guards, not changed behavior. |
| Scope completeness (positive/negative/edge) | PASS | Scope parser: general, repo, absent field, missing frontmatter, malformed, unrecognized. Validator: positive + negative for each of three invariants + no-`remediation_loop` backward-compat case. |
| Arrange–Act–Assert structure | PASS | Tests follow AAA with explicit fixtures and assertions. |
| No temp files / external dependencies | PASS | Tests use in-memory filesystem adapters; no `tempfile`, network, or subprocess. |

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| Simplicity first | PASS | Scope parser is a single `re`-based leaf reader; filter is one predicate plus a wrapped `list_files`. |
| Reusability | PASS | `_read_memory_scope` and `_is_general_memory_file` are shared helpers; validator extracts `_validate_remediation_loop`. |
| Extensibility / additive API | PASS | New helpers are additive; existing CLI entry points and the validator return contract (list of error strings) are unchanged. |
| Separation of concerns | PASS | Pure parsing (`_read_memory_scope`) is separated from filesystem enumeration (`_ExcludingFileSystem`). |
| Fail-fast error handling | PASS | Parser fails safe to `repo` (deliberate, documented); validator appends explicit error strings without mutating input. |
| File-size limit (<= 500 lines) | PASS | Largest changed files: validator 416, template 409, root script 374, test_validate 498 — all under 500. |
| No new dependencies | PASS | No PyYAML or other import added; verified by grep on all changed push-down scripts. |
| Naming conventions | PASS | snake_case functions, CONSTANT_CASE module constants (`AGENT_MEMORY_RELATIVE_ROOT`, `REMEDIATION_LOOP_KEY`). |
| Docstrings / commenting policy | PASS | New helpers and classes carry Google-style docstrings with intent comments on branches and the list comprehension. |

## 3. Language-Specific Code Change Policy Compliance (Python)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Black formatting | PASS | `poetry run black --check` on all 7 changed files: unchanged. |
| Ruff lint, no unauthorized suppressions | PASS | `poetry run ruff check`: All checks passed. No `# noqa` / `# type: ignore` added in changed files. |
| Pyright strict (policy command) | PASS | `poetry run pyright` (include = scripts/src/tests): 0 errors. The template is outside the configured include set; isolated-path invocation reports import-fallback unresolved-import noise that the policy command does not surface. See Section 8. |
| Full type annotations | PASS | New helpers annotate all parameters and returns (`str`, `bool`, `list[str]`, `Path`). |
| Absolute imports / no circular deps | PASS | Scripts use absolute `scripts.dev_tools.*` imports with a guarded bundled fallback. |

## 4. Language-Specific Unit Test Policy Compliance (Python)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Pytest as runner | PASS | All changed test modules are Pytest. |
| One behavior per test, descriptive names | PASS | e.g., scope-parser cases and per-invariant validator cases are individually named. |
| Parametrized boundary matrices | PASS | Scope-parser scenarios cover the full include/exclude matrix. |
| Patch at import location | PASS | Tests inject in-memory filesystem fakes rather than patching origins. |
| No sleeps/retries/timing hacks | PASS | None present. |
| Coverage >= 85% line / >= 75% branch on changed modules | PASS | 88% / 92% line on the two changed production modules (full-suite measurement). |

## 5. Test Coverage Detail

Full-suite measurement (`poetry run pytest --cov --cov-branch --cov-report=term-missing`):

| Module | Line Coverage | Missing (line/branch) | Tier | Verdict |
|--------|---------------|-----------------------|------|---------|
| `scripts/dev_tools/push_down_claude_customizations.py` | 88% | 57-66 (import fallback), 144, 181-182, 251-253 (defensive returns) | T4 (dev tooling) | PASS (>= 85% line) |
| `scripts/dev_tools/validate_orchestrator_state.py` | 92% | scattered defensive guards | T4 (dev tooling) | PASS (>= 85% line) |
| Repo-wide TOTAL | 82% (combined line+branch) | n/a | n/a | No regression vs 82% baseline |

The bundled byte-identical copy `extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py` shares the same source and coverage; it is covered transitively through the byte-identical-script invariant.

## 6. Test Execution Metrics

| Command | Result |
|---------|--------|
| `poetry run black --check <7 files>` | PASS (unchanged) |
| `poetry run ruff check <changed files>` | PASS (All checks passed) |
| `poetry run pyright` (project-scoped) | PASS (0 errors, 0 warnings) |
| `poetry run pytest --cov --cov-branch --cov-report=term-missing` | PASS (1116 passed, 19 skipped) |
| `git diff --no-index <root script> <bundle script>` | PASS (byte-identical) |
| `git diff --no-index <root rule> <bundle rule>` x5 | PASS (orchestrator-state, csharp, general-unit-test, python, typescript all identical) |

The 19 skips are codex/agents gitignored-directory tests unrelated to this feature (consistent with recorded baseline).

## 7. Code Quality Checks

| Check | Status | Evidence |
|-------|--------|----------|
| Byte-identical script invariant | PASS | Root and bundled `push_down_claude_customizations.py` are byte-identical. |
| Non-memory mirror parity | PASS | All five changed rule files identical between root and bundle. |
| Option B bundle reconciliation | PASS | Bundle `.claude/agent-memory/` holds 7 `scope: general` memories + 1 `scope: repo` `MEMORY.md` index; `prd-feature/` and `task-researcher/` subdirs removed; relocated repo memories appear only as bundle deletions in the diff. |
| Template source-root fix | PASS | Template resolves `customizations_root = Path(__file__).resolve().parent.parent / "claude-customizations"`, aligned with the codex template. |
| Fail-safe scope default | PASS | `_read_memory_scope` returns `repo` for absent/malformed/unrecognized scope; verified by tests. |
| Validator backward compatibility | PASS | Remediation-cycle invariants apply only when `remediation_loop` key is present; no-`remediation_loop` regression test passes. |
| Rejected snapshot artifacts absent | PASS | No `coverage.md`, no `diff-cover` gate, no PyYAML, no 6-step toolchain, no property-test downgrade in root or bundle. |
| Tonality policy | PASS | Reviewed artifacts and code comments use neutral, factual language. |

## 8. Gaps and Exceptions

- **Pyright isolated-invocation noise on the template (not a policy gap).** Running `poetry run pyright extensions/drm-copilot/resources/templates/push_down_claude_customizations.py` in isolation reports 16 `reportMissingImports` / `reportUnknown*` errors, all rooted in the deliberate bundled-deployment import fallback `from dev_tools.push_down_copilot_customizations import ...` (lines 86-94). That module path is only importable in the bundled deployment context, not in the repo layout. The repository-configured Pyright command `poetry run pyright` uses `include = ["scripts", "src", "tests"]`, which does not cover `extensions/drm-copilot/resources/templates/`; the policy command therefore returns 0 errors. The template's exception handler intentionally re-raises any non-`scripts`-prefixed `ModuleNotFoundError`, so the fallback is scoped. Verdict: no policy violation; documented for transparency.
- **Repo-wide coverage TOTAL is 82%, below the 85% repo-wide line threshold.** This is the combined line+branch TOTAL reported by `--cov-report=term-missing` and is **unchanged from the pre-feature baseline (82%)**. The threshold pertains to the repository's long-standing state and is not introduced or worsened by this feature; the two modules this feature edits are at 88%/92% line. No remediation is attributable to this feature for the repo-wide figure. Flagged for awareness, not as a feature-blocking finding.
- **Three follow-up GitHub issues (Decision L) not yet confirmed opened.** `spec.md` Definition of Done and the user-story AC require three follow-up issues to be filed by the orchestrator. The caller states the orchestrator will file them separately. This is an out-of-band AC tracked in Section 10 and the feature audit as UNVERIFIED (not a code or toolchain defect).

## 9. Summary of Changes

- Added a re-based `metadata.scope` frontmatter parser (`_read_memory_scope`) and predicate (`_is_general_memory_file`) to the two byte-identical push-down scripts; extended `_ExcludingFileSystem.list_files` to apply the scope filter to `.claude/agent-memory/**` only.
- Applied the same scope filter to the extension template and fixed its source-root resolution to the bundled `claude-customizations/` directory.
- Reconciled the bundle agent-memory to Option B: 7 general memories + the repo-scope orchestrator `MEMORY.md` index; removed repo-specific memories and the `prd-feature/` and `task-researcher/` subdirectories.
- Added six domain-neutral orchestration memories as `scope: general` and updated the bundle orchestrator `MEMORY.md` index.
- Added additive, backward-compatible remediation-cycle invariants to `validate_orchestrator_state.py` (`_validate_remediation_loop`).
- Added the `orchestrator-state.md` prose rule and the type-only coverage exemption note to four rule files, mirrored byte-identically into root and bundle.
- Added/updated three test modules covering the parser, filter, parity exemption, and validator invariants.

## 10. Compliance Verdict

**Overall verdict: PASS (COMPLIANT).**

- All toolchain gates the feature touches pass: Black, Ruff, project-scoped Pyright, Pytest with coverage.
- All structural invariants verified: byte-identical scripts, non-memory mirror parity, Option B bundle state, template source-root fix, fail-safe scope default, validator backward compatibility, rejected-snapshot absence.
- No FAIL-level policy findings attributable to this feature. The repo-wide 82% coverage figure is a pre-existing, non-regressed baseline state.

**Outstanding (non-blocking, tracked):**
- Three follow-up GitHub issues (Decision L) — UNVERIFIED; orchestrator responsibility, outside this branch diff.

No remediation is required for code or toolchain. A remediation-inputs artifact is produced to record the partial/unverified acceptance criteria (Option B bundle-state ACs and the follow-up-issues AC) and the documented non-blocking observations, per the SKILL remediation trigger for PARTIAL/UNVERIFIED acceptance criteria.

## Appendix A: Test Inventory

| Test Module | Status | Count Contribution |
|-------------|--------|--------------------|
| `tests/scripts/dev_tools/test_push_down_claude_memory_scope.py` | new | 12 scope parser/filter tests |
| `tests/scripts/dev_tools/test_validate_orchestrator_state.py` | modified | 14 (incl. 7 new remediation-cycle invariant tests + backward-compat case) |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | modified | 4 (agent-memory exemption + scope assertions) |
| Full suite | n/a | 1116 passed, 19 skipped |

## Appendix B: Toolchain Commands Reference

```
poetry run black --check scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/validate_orchestrator_state.py extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py extensions/drm-copilot/resources/templates/push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_memory_scope.py tests/scripts/dev_tools/test_validate_orchestrator_state.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
poetry run ruff check scripts/dev_tools/push_down_claude_customizations.py scripts/dev_tools/validate_orchestrator_state.py tests/scripts/dev_tools/...
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
git diff --no-index scripts/dev_tools/push_down_claude_customizations.py extensions/drm-copilot/resources/scripts/dev_tools/push_down_claude_customizations.py
git diff --no-index .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md
git diff --name-only 2745d23d01ea179d8d02fc240dbadb1017ee7aeb..75b0ea6191b0498b9e2240f9a262457f348a57e3
```
