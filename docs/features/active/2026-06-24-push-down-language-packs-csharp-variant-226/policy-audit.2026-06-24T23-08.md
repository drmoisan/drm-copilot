# Policy Compliance Audit: push-down-language-packs-csharp-variant (Issue #226)

**Audit Date:** 2026-06-24
**Code Under Test:**
- Python (production): `scripts/dev_tools/push_down_claude_customizations.py`, `scripts/dev_tools/push_down_claude_filesystem.py`, `scripts/dev_tools/push_down_claude_pack_selection.py` (and byte-identical bundle mirrors under `extensions/drm-copilot/resources/scripts/dev_tools/`); `extensions/drm-copilot/resources/templates/push_down_claude_customizations.py`
- Python (tests): `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py`, `test_push_down_claude_pack_end_to_end.py`, `test_push_down_claude_pack_memory_modes.py`, `test_push_down_claude_bundled_parity.py`, `test_push_down_claude_resource_contracts.py`
- TypeScript (production): `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts`, `mcp-tool-inputs.ts`, `repo-automation-command-registration-admin.ts`, `repo-automation-service.ts`
- TypeScript (tests): `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts`, `mcp-tools.push-down-claude.test.ts`, `push-down-claude-handler.test.ts`, `repo-automation-service.push-down-claude.test.ts`
- Bundle data/docs (non-source): `extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json` (6 files), `.claude-variants/csharp-legacy/**` (4 Markdown files); `extensions/drm-copilot/package.json`, `package-lock.json`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 3 prod + 1 template + 5 test | 1127 pass / 19 skip | ✅ 1127 pass, 0 fail | 83% line (tests/scripts/dev_tools scope) | 85.63% line, 74.77% branch (repo-wide measured) | 90.7–93.2% line on feature modules |
| TypeScript | 5 prod + 4 test | 415 pass | ✅ 415 pass, 0 fail | 95.78% line, 87.55% branch | 95.87% line, 88.05% branch | 93.7–100% line on touched files |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

PowerShell and C# rows are N/A because the branch diff contains zero PowerShell (`.ps1`) and zero C# (`.cs`/`.csproj`) source files. The `.claude-variants/csharp-legacy/*.md` files are Markdown documentation bundle assets (Claude rules/skills/agent prose), not compilable C# source, and the `pack-manifests/*.json` files are data. No language toolchain or coverage gate applies to these.

### Coverage Evidence Checklist

- Python post-change coverage artifact: `artifacts/python/lcov.info` (present; repo-wide line 85.63%, branch 74.77%)
- Python baseline coverage evidence: `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/baseline/python-pytest.2026-06-24T22-12.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (present; repo-wide line 95.87%, branch 88.05%). Note: the TS project lives under `extensions/drm-copilot/`; its coverage artifact is `extensions/drm-copilot/coverage/lcov.info`, the project-local equivalent of the skill's `coverage/lcov.info`.
- TypeScript baseline coverage evidence: `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/baseline/ts-test.2026-06-24T22-12.md`
- Per-language comparison summary: Section 1.2.1 below.

---

## Executive Summary

This feature adds opt-in, manifest-driven language-pack selection, two C# toolchain variants (modern default and bundle-only legacy), three agent-memory push-down modes (overwrite/merge/skip), a VS Code selection UI, and corresponding MCP tool schema fields to the "Push Down Claude Customizations" workflow. The change spans Python (push-down engine and pure pack-selection/filesystem helpers) and TypeScript (command registration, service arg construction, MCP tool definitions/inputs). All additions are designed to be backward-compatible: a no-argument invocation publishes the full tree and overwrites general-scoped memories.

The full per-language toolchain was verified from pre-existing QA-gate and coverage artifacts (skill model: inspect existing artifacts rather than re-run generation). Python format/lint/type/test gates all recorded EXIT_CODE 0; TypeScript format/lint/type/test gates all recorded EXIT_CODE 0. Coverage artifacts exist for both languages with changed files. The new and modified feature modules all exceed the >= 85% line and >= 75% branch thresholds, with no regression on changed lines.

One policy finding is recorded as PARTIAL: two TypeScript production files (`mcp-tool-inputs.ts` 557 lines, `repo-automation-service.ts` 507 lines) now exceed the 500-line file-size limit defined in `general-code-change.md`; both were under the limit at the merge base (496 and 488). One coverage observation is recorded: repo-wide Python branch coverage is 74.77% (0.23 points below the 75% repo-wide policy threshold), entirely attributable to pre-existing out-of-scope modules untouched by this feature; the feature's own modules all pass branch coverage.

**Policy documents evaluated:**
- ✅ `general-code-change.md`
- ✅ `general-unit-test.md`
- ✅ `quality-tiers.md` (uniform coverage thresholds)

**Language-specific policies evaluated:**
- ✅ Python: `python.md`, `python-suppressions.md`, `self-explanatory-code-commenting.md`
- ✅ TypeScript: `typescript.md`, `typescript-suppressions.md`, `architecture-boundaries.md`
- N/A PowerShell (zero changed `.ps1` files)
- N/A C# (zero changed `.cs`/`.csproj` files)

**Temporary artifacts cleanup:**
- ✅ No throwaway scripts detected in the branch diff.
- ✅ No `.env` or secrets files added.

---

## Rejected Scope Narrowing

No caller instruction attempted to narrow the audit scope to a plan subset, a file subset, or to mark any language with changed files as out of scope. The caller supplied the resolved base branch, merge-base SHA, head SHA, the active feature folder, and refreshed PR-context artifacts, and explicitly instructed: "Determine review scope yourself per the workflow contract and the branch diff." The audit therefore proceeded as a full feature-vs-base audit. No verbatim narrowing text is recorded because none was supplied.

---

## Base-Ref Discrepancy Note

The supplied merge-base SHA `ea94a068e0a071940858a0694c47e204244c09af` (treated as authoritative per caller inputs) differs from the base resolved inside `artifacts/pr_context.summary.txt` (`origin/main @ 041e45bbbe44101378486d28f74294ddf44460aa`, merge base `ea94a06...`). The merge base recorded in both sources is `ea94a06`, so the diff range `ea94a06..b7274bc` is consistent. The audit used the caller-supplied merge base `ea94a068e0a071940858a0694c47e204244c09af`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | ✅ PASS | Python tests use the in-memory filesystem double (`FakePushDownFileSystem`-style) and pure helpers; no shared mutable global state. TS tests reset mocks per case. |
| **Isolation** | ✅ PASS | Each test targets a single behavior (pack filtering, variant routing, memory mode, CLI parse, service arg vector, MCP schema). |
| **Fast Execution** | ✅ PASS | Pure-logic and in-memory FS tests; no I/O. Python suite 1127 pass; TS suite 415 pass (per QA-gate artifacts). |
| **Determinism** | ✅ PASS | No wall-clock, RNG, network, or filesystem-temp dependencies. `read_memory_scope` is a pure regex parser; manifests read via injected adapter. |
| **Readability & Maintainability** | ✅ PASS | Descriptive `test_...` names; AAA structure; docstrings on contract tests. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Python: `evidence/baseline/python-pytest.2026-06-24T22-12.md` (83% line). TS: `evidence/baseline/ts-test.2026-06-24T22-12.md` (95.78% line, 87.55% branch). |
| **No Coverage Regression (changed lines)** | ✅ PASS | Python feature modules improved (88% → 92.4% on the main module); new modules 90.7%/93.2% line. TS line/branch both increased. No regression on changed lines. |
| **New Code Coverage** | ✅ PASS | New Python modules `push_down_claude_filesystem.py` 90.7% line / 84.6% branch and `push_down_claude_pack_selection.py` 93.2% line / 82.1% branch (≥85%/≥75%). New TS handler `push-down-handlers.ts` 100%. |
| **Repo-wide branch threshold** | ⚠️ PARTIAL | Python repo-wide branch 74.77% (lcov), 0.23pp below the 75% repo-wide policy threshold. Attributable to pre-existing out-of-scope modules (e.g., `shell_qc.py` 0%); feature modules all pass. See Section 8. |
| **Comprehensive Coverage** | ✅ PASS | Positive, negative (ManifestError paths), edge (empty packs, trailing commas), and mutual-exclusion error paths covered. |
| **Positive / Negative / Edge / Error** | ✅ PASS | `test_push_down_claude_pack_selection.py`, `_pack_memory_modes.py`, `_pack_end_to_end.py`, `_resource_contracts.py`. |
| **Concurrency / State Transitions** | N/A | No concurrency or stateful transitions introduced. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline 83% line (tests/scripts/dev_tools scope) -> Post-change 85.63% line, 74.77% branch (repo-wide measured denominator). New/changed-code coverage: feature modules 90.7–93.2% line, 75.0–84.6% branch. Disposition: PASS for feature modules and repo-wide line; PARTIAL for repo-wide branch (-0.23pp, out-of-scope). Evidence: `artifacts/python/lcov.info`.
- TypeScript: Baseline 95.78% line, 87.55% branch -> Post-change 95.87% line, 88.05% branch. New/changed-code coverage: touched files 93.7–100% line, 81.2–100% branch. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`.
- PowerShell: N/A - zero changed files on branch.
- C#: N/A - zero changed files on branch.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | Contract-test asserts carry explicit messages (e.g., "Variant file is byte-identical to its root counterpart"). |
| **Arrange-Act-Assert** | ✅ PASS | Tests follow AAA. |
| **Document Intent** | ✅ PASS | Test docstrings describe scenario and expected outcome. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS | No network/DB/process. In-memory FS double; no runtime temp files. |
| **Use Mocks/Stubs** | ✅ PASS | TS mocks `vscode.window.showQuickPick`/`promptForChoice`; Python injects FS adapter. |
| **Environment Stability** | ✅ PASS | No temp-file creation; deterministic inputs. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This audit is the required review. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | Issue #226, `spec.md`, `user-story.md` document the objective. |
| **Read existing change plans** | ✅ PASS | `plan.2026-06-24T13-04.md` and research doc present in feature folder. |
| **Document the plan** | ✅ PASS | Plan file with phased tasks. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | Pack selection reduced to pure functions over manifests; engine reuse via shared publisher. |
| **Reusability** | ✅ PASS | New work reuses `push_down_copilot_customizations` engine and `PushDownFileSystem` protocol; no duplication of copy logic. |
| **Extensibility** | ✅ PASS | Manifest-driven packs and `Literal`-typed variant/memory-mode enums allow extension; keyword-only public params with defaults. |
| **Separation of concerns** | ✅ PASS | Pure selection logic (`push_down_claude_pack_selection.py`) separated from filtering FS wrapper (`push_down_claude_filesystem.py`) separated from CLI entry point. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | Each new module has a single clear purpose with a module docstring. |
| **Under 500 lines** | ⚠️ PARTIAL | Python: all files under 500 (403/472/401 prod; 180–348 tests). TypeScript: `mcp-tool-inputs.ts` 557 and `repo-automation-service.ts` 507 exceed the 500-line limit (baseline 496/488). See Finding TS-1. |
| **Public vs internal** | ✅ PASS | Private helpers `_`-prefixed; `__all__` declared in the Python entry point. |
| **No circular dependencies** | ✅ PASS | TYPE_CHECKING-only imports of `PushDownFileSystem`; runtime import fallbacks guarded by `ModuleNotFoundError`. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `compute_published_paths`, `resolve_variant_source_path`, `assert_single_csharp_toolchain`, `CLAUDE_PUSH_DOWN_PACK_ITEMS`. |
| **Docs/docstrings** | ✅ PASS | All Python classes/functions carry Google-style docstrings with Args/Returns/Raises/Side Effects per `self-explanatory-code-commenting.md`. |
| **Comment why, not what** | ✅ PASS | Loops and branches carry intent comments (e.g., legacy-redirect rationale, fail-safe scope default). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Python `poetry run black --check .` EXIT 0 (`evidence/qa-gates/python-black.2026-06-24T22-58.md`); TS `npm run format` EXIT 0 (`ts-format.2026-06-24T22-58.md`). |
| **2. Linting** | ✅ PASS | Python `poetry run ruff check .` EXIT 0 (`python-ruff.*`); TS `npm run lint` EXIT 0 (`ts-lint.*`). |
| **3. Type checking** | ✅ PASS | Python `poetry run pyright` EXIT 0 (`python-pyright.*`); TS `npm run typecheck` EXIT 0 (`ts-typecheck.*`). |
| **4. Testing** | ✅ PASS | Python pytest EXIT 0, 1127 pass (`python-pytest.*`); TS tests EXIT 0, 415 pass (`ts-test.*`). |
| **Full toolchain loop** | ✅ PASS | All gate artifacts at the 22-58 QA pass; baseline at 22-12. |
| **Explicit reporting** | ✅ PASS | Commands and EXIT codes recorded in QA-gate evidence and `pr_context.summary.txt`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | spec.md, issue.md, plan document the change. |
| **Design choices explained** | ✅ PASS | spec.md Data & State invariants; legacy-variant routing rationale in docstrings. |
| **Update supporting documents** | ✅ PASS | Feature folder scoping docs updated. |
| **Provide next steps** | ✅ PASS | This audit set. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | `poetry run black --check .` EXIT 0. |
| **Linting with Ruff** | ✅ PASS | `poetry run ruff check .` EXIT 0; no suppressions added (grep for `# noqa`/`# type: ignore` in new modules: none beyond `# pragma: no cover` on guarded import fallbacks). |
| **Type checking with Pyright** | ✅ PASS | `poetry run pyright` EXIT 0. |
| **Testing with Pytest** | ✅ PASS | `poetry run pytest --cov --cov-branch` EXIT 0. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | Full annotations; `Literal["modern","legacy"]` and `Literal[...]` memory modes; `cast` used narrowly when decoding untyped JSON with explicit per-leaf narrowing. |
| **Dataclasses for value objects** | ✅ PASS | `@dataclass(frozen=True, slots=True) PackManifest`. |
| **Protocols/ABCs for interfaces** | ✅ PASS | Reuses `PushDownFileSystem` Protocol; `ExcludingFileSystem` implements it structurally. |
| **Avoid utility classes** | ✅ PASS | Pure functions in `push_down_claude_pack_selection.py`; the one class (`ExcludingFileSystem`) is a stateful adapter, justified. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | `ManifestError(ValueError)` for missing/malformed manifests and C# mutual-exclusion; no broad `except Exception`. |
| **Logging over print** | ✅ PASS | Only the CLI entry point `print`s the summary artifact path (acceptable CLI output); no ad-hoc debug prints. |
| **Invariants at construction** | ✅ PASS | `_parse_manifest` validates required keys before constructing `PackManifest`; `assert_single_csharp_toolchain` enforces mutual exclusion before publish. |

### Section 3B: PowerShell — N/A (zero changed `.ps1` files)

### Section 3C/3D: Bash/JSON

The six `pack-manifests/*.json` files are data resources. They are strict JSON (parsed by `json.loads` in tests and at runtime). No `$schema`-governed validation pipeline applies to these resource manifests; they are validated structurally by `load_pack_manifests` and exercised by `test_push_down_claude_pack_selection.py`. Status: ✅ PASS (structurally validated).

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | Pytest with `--cov --cov-branch`. |
| **Coverage expectation** | ✅ PASS | Feature modules 90.7–93.2% line, 75.0–84.6% branch (≥85%/≥75%). |
| **Focused unit tests** | ✅ PASS | One behavior per test. |
| **Mocking sparingly** | ✅ PASS | In-memory FS double; pure helpers tested directly. |
| **Organization** | ✅ PASS | Tests under `tests/scripts/dev_tools/` mirror `scripts/dev_tools/`. |
| **Naming/Docstrings** | ✅ PASS | Descriptive names and docstrings. |
| **No alternative runners / temp files** | ✅ PASS | Pytest only; no runtime temp files. |

### Section 4B: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Framework** | ✅ PASS (clarified) | TS tests run via Jest (`jest.config.cjs`); the `typescript.md` rule names Vitest. The repository's established runner for this extension package is Jest per the wired `test` script and `ts-test` evidence. This is a pre-existing repo convention, not introduced by this feature. Recorded as an informational deviation, not a feature defect. |
| **Test naming `*.test.ts`** | ✅ PASS | All four test files use `.test.ts`. |
| **No host runtime / external deps** | ✅ PASS | `vscode` mocked; no network/FS-temp. |
| **Coverage thresholds** | ✅ PASS | Touched files 93.7–100% line, 81.2–100% branch. |

---

## 5. Test Coverage Detail

### push_down_claude_pack_selection.py (covered by test_push_down_claude_pack_selection.py)

| Test focus | Scenario Type | Status |
|-----------|--------------|--------|
| `compute_published_paths` always includes core | Positive | ✅ |
| manifest missing / not JSON / wrong type / bad paths | Negative/Error | ✅ |
| `resolve_variant_source_path` legacy redirect vs modern passthrough | Positive/Edge | ✅ |
| `assert_single_csharp_toolchain` both variants raises | Error | ✅ |

**Coverage:** 93.2% line (69/74), 82.1% branch (23/28).

### push_down_claude_filesystem.py (covered by _pack_memory_modes.py, _pack_end_to_end.py)

| Test focus | Scenario Type | Status |
|-----------|--------------|--------|
| memory mode overwrite/merge/skip | Positive/Edge | ✅ |
| `read_memory_scope` general vs repo fail-safe | Positive/Negative/Edge | ✅ |
| legacy variant read redirection | Positive | ✅ |

**Coverage:** 90.7% line (97/107), 84.6% branch (22/26).

### push_down_claude_customizations.py (entry point)

**Coverage:** 92.4% line (61/66), 75.0% branch (6/8). Uncovered lines are the bundled-import `except` fallback exercised only under the bundled sys.path (separately tested).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Python Total Tests | 1127 passed, 19 skipped | ✅ |
| TypeScript Total Tests | 415 passed | ✅ |
| Tests Failed | 0 | ✅ |
| Python repo-wide line coverage | 85.63% | ✅ |
| Python repo-wide branch coverage | 74.77% | ⚠️ (-0.23pp vs 75% policy; out-of-scope modules) |
| TypeScript line / branch coverage | 95.87% / 88.05% | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black | `poetry run black --check .` | EXIT 0 | ✅ |
| Ruff | `poetry run ruff check .` | EXIT 0 | ✅ |
| Pyright | `poetry run pyright` | EXIT 0 | ✅ |
| Pytest | `poetry run pytest --cov --cov-branch --cov-report=term-missing tests/scripts/dev_tools` | EXIT 0, 1127 pass | ✅ |

**For TypeScript:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `npm run format` | EXIT 0 | ✅ |
| ESLint | `npm run lint` | EXIT 0 | ✅ |
| tsc | `npm run typecheck` | EXIT 0 | ✅ |
| Tests | `npm run test -- --coverage` | EXIT 0, 415 pass | ✅ |

**Notes:** Repo-wide Python branch 74.77% is dominated by out-of-scope modules untouched by this feature (`shell_qc.py` 0%, `tk_dialog_helpers.py` ~45%). No regression on changed lines.

---

## 8. Gaps and Exceptions

### Identified Gaps

- **TS-1 (file-size limit):** `extensions/drm-copilot/src/mcp-tool-inputs.ts` (557 lines) and `extensions/drm-copilot/src/repo-automation-service.ts` (507 lines) exceed the 500-line limit in `general-code-change.md`. Both were under the limit at the merge base (496 and 488 lines); this feature pushed them over. The 500-line limit has no exception for production TypeScript. Disposition: PARTIAL — remediation recommended (extract the new push-down input resolution / service arg construction into a small dedicated module). Not a runtime-correctness blocker.
- **Python repo-wide branch coverage:** 74.77% vs the 75% repo-wide policy threshold (-0.23pp). Entirely caused by pre-existing out-of-scope modules; the feature's own modules all meet the branch threshold and there is no regression on changed lines. Disposition: PARTIAL observation; not feature-introduced.

### Approved Exceptions

- **None.**

### Removed/Skipped Tests

- 19 skipped Python tests are pre-existing `.codex`/`.agents` gitignored-in-CI contract tests, unrelated to this feature.

---

## Evidence Location Compliance

- `validate_evidence_locations.py --root .` executed: EXIT 0 (no violations).
- Branch-diff scan for forbidden evidence paths (`artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, `artifacts/post-change/`): no matches.
- All feature evidence is written under the canonical `docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/evidence/<kind>/` scheme (`baseline/`, `qa-gates/`).
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries: no caller supplied a non-canonical evidence path.

Status: ✅ PASS.

## Workflow / Benchmark Gate Compliance (modified-workflow-needs-green-run)

- Branch-diff scan for `.github/workflows/**`, `scripts/benchmarks/**`, `.github/actions/**`: zero matches. The `modified-workflow-needs-green-run` policy rule does NOT fire. No green-run evidence is required.

---

## 9. Summary of Changes

### Commits in This Branch
1. **b7274bc** — feat(push-down): add opt-in language packs, dual C# toolchain variants, and memory modes (#226)

### Files Modified (selected)
1. `scripts/dev_tools/push_down_claude_pack_selection.py` (NEW) — pure pack-manifest loading, path computation, variant routing, C# mutual-exclusion assertion.
2. `scripts/dev_tools/push_down_claude_filesystem.py` (NEW) — filtering FS wrapper applying scope/pack/variant/memory-mode filters.
3. `scripts/dev_tools/push_down_claude_customizations.py` (MODIFIED) — CLI args `--packs`/`--csharp-variant`/`--memory-mode`; composition of helpers; backward-compatible defaults.
4. Bundle mirrors under `extensions/drm-copilot/resources/scripts/dev_tools/` — byte-identical to the repo copies (verified).
5. `extensions/drm-copilot/src/repo-automation-command-registration-admin.ts` (MODIFIED) — three QuickPick steps with cancellation handling.
6. `extensions/drm-copilot/src/mcp-tool-definitions.ts` and `mcp-repo-automation-tool-definitions.ts` (MODIFIED) — optional `packs`/`csharp_variant`/`memory_mode` schema fields; identical blocks (verified).
7. `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `repo-automation-service.ts` (MODIFIED) — input resolution and CLI arg construction (file-size finding TS-1).
8. `pack-manifests/*.json` (6 NEW), `.claude-variants/csharp-legacy/**` (4 NEW Markdown) — bundle data/profile.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The feature is functionally complete with green toolchains and coverage that meets thresholds for all feature-owned files. Two non-blocking policy gaps are recorded: the 500-line file-size limit is exceeded by two TypeScript production files this feature grew past the limit (TS-1), and repo-wide Python branch coverage is 0.23pp below the policy floor due solely to pre-existing out-of-scope modules.

**Fail-closed reminder:** All required baseline, QA, and coverage artifacts are present; no required artifact is missing.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes / Design Principles / Naming-Docs-Comments / Toolchain / Summarize
- ⚠️ Module & File Structure: 500-line limit exceeded by two TS files (TS-1)

#### Language-Specific Code Change Policy (Section 3)
- ✅ Python: Tooling, Design & Typing, Error Handling
- ⚠️ TypeScript: file-size limit (TS-1); otherwise typing, schema, and arg-construction compliant

#### General Unit Test Policy (Section 1)
- ✅ Core Principles / Test Structure / External Dependencies / Policy Audit
- ⚠️ Coverage & Scenarios: repo-wide Python branch -0.23pp (out-of-scope)

#### Language-Specific Unit Test Policy (Section 4)
- ✅ Python and TypeScript framework/style/naming/toolchain (TS Jest noted as pre-existing repo convention)

### Metrics Summary
- ✅ 1127/1127 Python tests passing; 415/415 TS tests passing
- ✅ Python feature modules 90.7–93.2% line; TS touched files 93.7–100% line
- ✅ Python repo-wide line 85.63%; TS repo-wide line 95.87%
- ⚠️ Python repo-wide branch 74.77% (-0.23pp); ⚠️ two TS files over 500 lines

### Recommendation

**Conditional Go.** The feature meets acceptance criteria and all toolchains are green. Recommend addressing TS-1 (split `mcp-tool-inputs.ts` and `repo-automation-service.ts` below 500 lines) as a follow-up. The Python repo-wide branch shortfall is pre-existing and out of this feature's scope; no remediation of feature code is required for it.

---

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_push_down_claude_pack_selection.py` — manifest parsing, core-always-included, variant routing, mutual exclusion.
- `tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py` — overwrite/merge/skip.
- `tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` — full push-down with packs+variant; single-C#-toolchain destination; no-arg full-tree backward compatibility.
- `tests/scripts/dev_tools/test_push_down_claude_bundled_parity.py` — bundled vs repo parity (variant subtree excluded).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — variant bundle-only/non-colliding; parity-scope exclusion; agent-memory scope well-formedness.
- `extensions/drm-copilot/test/extension.push-down-claude-customizations.test.ts` — QuickPick flow, conditional C# step, cancellation, CLI-arg mapping.
- `extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts` — service arg vector, no-field backward compatibility.
- `extensions/drm-copilot/test/push-down-claude-handler.test.ts` — MCP handler input resolution.
- `extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts` — schema and definition-file parity, dispatch.

## Appendix B: Toolchain Commands Reference

**Python:**
```bash
poetry run black --check .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing tests/scripts/dev_tools
```

**TypeScript (from extensions/drm-copilot/):**
```bash
npm run format
npm run lint
npm run typecheck
npm run test -- --coverage
```

**Review-only verification commands used in this audit:**
```bash
git diff --name-status ea94a068e0a071940858a0694c47e204244c09af..b7274bcb83ca291f766ad5d58f6f3653e162666a
python scripts/dev_tools/validate_evidence_locations.py --root .   # EXIT 0
```

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-06-24
**Policy Version:** Current (as of audit date)
