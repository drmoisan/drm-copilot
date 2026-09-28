# Policy Compliance Audit: Codex push-down payload self-sufficiency (Issue #697)

---

**Audit Date:** 2026-09-26
**Branch:** `bug/codex-pushdown-self-sufficiency-697` @ `59c4fda88023355353d0802c826d62347f7d4662`
**Resolved base branch:** `main` (merge base `26d57cb37f91e6a695f4ab4c1f57366229756fdc`, committed 2026-09-25T08:03:58-04:00; `origin/main` resolved to `d754f83f714b087e404577cb7a1b02f48d2023bb` in the PR context)
**Scope:** full branch diff `26d57cb3..59c4fda8` (152 files; 46 outside `docs/features/**/evidence/`)
**Code Under Test:**

- PowerShell production: `.codex/hooks/enforce-epic-planning-only.ps1` (M), `.claude/lib/codex-routing/CodexDeployment.psm1` (M), `.codex/scripts/codex-routing-cli-common.ps1` (A), `.codex/scripts/Resolve-CodexTopology.ps1` (A), `.codex/scripts/Resolve-CodexDeployment.ps1` (A); byte mirrors under `extensions/drm-copilot/resources/` (6 files); `pester.runsettings.psd1` (2 copies, data)
- Python production: `scripts/dev_tools/push_down_codex_and_agents_customizations.py` (M)
- TypeScript / CommonJS production: `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` (M), `packages/mcp-server/prepack.cjs` (M, packaging script), `extensions/drm-copilot/jest.config.cjs` (M, config)
- Data: `pack-manifests/core.json`, `csharp-legacy/agents/csharp-typed-engineer.toml`, `tests/fixtures/codex_routing/{topology,deployment}.json`, `tests/fixtures/codex-hooks/invalid-orchestration-handoff-registry.json`, `codex-model-routing/SKILL.md` (2 copies)
- Tests: 6 new or modified Python test files, 5 new or modified Pester files, 4 new or modified Jest files

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 1 production, 6 test files | 5042 collected (full suite) | ✅ 5036 pass, 1 fail (pre-existing #510, identical at baseline), 5 skip | 92.90% lines repo-wide; changed file 97.98% lines, 85.71% branches | 92.90% lines, 85.52% branches repo-wide; changed file 98.04% lines, 85.71% branches | 100% of changed executable lines covered |
| TypeScript | 1 production TS, 1 CommonJS script, 1 config, 4 test files | 3021 (full suite) | ✅ 3021 pass, 0 fail | changed file 97.97% lines, 90.16% branches | 96.86% lines, 90.64% branches repo-wide; changed file 98.87% lines, 95.31% branches | 100% of changed lines covered |
| PowerShell | 5 production, 6 mirrors, 2 settings, 5 test files | 5090 (full suite) | ✅ 5081 pass, 0 fail, 9 skip | 95.77% lines repo-wide | 95.88% lines repo-wide | 100% of new and changed lines covered (new files 100%, modified hook 93.87%, CodexDeployment.psm1 100%) |
| C# | 0 files | N/A | N/A | N/A (no changed files) | N/A (no changed files) | N/A |
| JSON | 5 files | N/A | ✅ parsed by the passing guard and corpus tests | N/A (data files) | N/A (data files) | N/A |

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/baseline/phase0-ts-jest-coverage.2026-09-25T20-24.md`
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (read by this reviewer) and `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/coverage/typescript-coverage-delta.2026-09-26T00-25.md`
- PowerShell baseline coverage artifact: `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/baseline/phase0-ps-pester-coverage.2026-09-25T20-40.md`
- PowerShell post-change coverage artifact: `artifacts/pester/powershell-coverage.xml` (read by this reviewer) and `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/coverage/powershell-coverage-delta.2026-09-26T00-07.md`
- Per-language comparison summary: section 1.2.1 of this document

---

## Executive Summary

The branch fixes the four reproduced defects of issue #697 (load-time registry dependency in `enforce-epic-planning-only.ps1`, an invalid `variant` key in the `csharp-legacy` role file, undelivered topology and deployment resolvers, and an incomplete `core.json`) and the three research findings (TypeScript publisher config gap, unanchored `prepack.cjs` exclusion, `commit-steward` omission in the PowerShell deployment port). The audit covered the full branch diff against `main`. No policy FAIL was found. All four languages with changed files (Python, TypeScript/CommonJS, PowerShell; C# has none) meet the uniform coverage thresholds, and no changed line is uncovered.

**Policy documents evaluated:**
- ✅ `.claude/rules/general-code-change.md` (mirror of `general-code-change.instructions.md`)
- ✅ `.claude/rules/general-unit-test.md` (mirror of `general-unit-test.instructions.md`)
- ✅ `.claude/rules/quality-tiers.md`
- ✅ `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/tonality.md`

**Language-specific policies evaluated:**
- ✅ `python-code-change.instructions.md` + `python-unit-test.instructions.md` (via `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`)
- ✅ `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` (via `.claude/rules/powershell.md`)
- ✅ TypeScript (via `.claude/rules/typescript.md`)
- N/A C#: no changed files
- N/A Bash: no changed files
- ✅ JSON: data files validated by the passing tests that parse them

Reviewer re-verification (check-only, no file mutation): Black, Ruff, and Pyright clean on the 7 changed Python files; 657 targeted pytest cases pass; Prettier, ESLint, and `tsc --noEmit` clean; 19 targeted Jest cases pass; PSScriptAnalyzer (repo settings) reports 0 findings and `Invoke-Formatter` reports no drift on the 10 changed PowerShell files; 215 targeted Pester cases pass. The worktree remained clean after every run.

Template source: the review artifact structure was taken from the bundled asset file `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, which is the file the MCP template-asset tool serves; MCP tools are not in this agent's tool set.

**Temporary artifacts cleanup:**
- ✅ No temporary script is committed on the branch. The executor's corpus generator ran from its scratchpad (`evidence/other/corpus-generator-*.md`) and is not in the diff.
- ✅ Reviewer measurement scripts were written only to the session scratchpad.

---

## Rejected Scope Narrowing

None detected. The caller prompt supplied the base branch, merge base, feature folder, PR-context artifacts, and work mode, and did not narrow scope to a plan, phase, file subset, or language.

## Evidence Location Compliance

- `git diff --name-only 26d57cb3..HEAD` contains no path under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root <repo>` exited 0.
- All executor evidence is under `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/<kind>/`.
- Observation (non-blocking, pre-existing): `.gitignore:59` (`coverage/`) ignores the canonical `evidence/coverage/` folder. The seven coverage-delta artifacts exist on disk but are not in the branch diff; `git ls-files` finds zero tracked `evidence/coverage/` files anywhere in the repository. See section 8.

## Modified-Workflow Rule

`modified-workflow-needs-green-run` does not fire: the diff changes no path under `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** - Tests run in any order | ✅ PASS | New pytest modules use module-level constants and parametrization with no shared mutable state. Pester files use `BeforeAll` per `Describe`. Jest integration test builds a fresh in-memory destination per `it`. |
| **Isolation** - Each test targets single behavior | ✅ PASS | One behavior per test, for example `test_unmapped_config_file_is_not_published`, `'allows mcp__ tool with a missing registry on a non-preparation route'`, `'excludes Python files at every depth'`. |
| **Fast Execution** - Tests complete quickly | ✅ PASS | Targeted runs: 657 pytest cases in 0.85 s; 19 Jest cases in 0.40 s; 215 Pester cases, including 41 hook processes and per-case wrapper processes, completed within the command timeout. |
| **Determinism** - Consistent results | ✅ PASS | No clock, randomness, or network. Parity corpus is committed. Process-spawning Pester tests resolve `pwsh` through `Get-Command` (pre-existing pattern from `legacy-codex-hook-contracts.Tests.ps1`); see section 8. |
| **Readability & Maintainability** - Clear structure | ✅ PASS | Descriptive names, module docstrings citing issue #697, AAA comments in Jest files. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | ✅ PASS | Baselines recorded before changes: `evidence/baseline/phase0-python-pytest-coverage.2026-09-25T20-19.md`, `phase0-ts-jest-coverage.2026-09-25T20-24.md`, `phase0-ps-pester-coverage.2026-09-25T20-40.md`. |
| **No Coverage Regression** | ✅ PASS | Python changed file 97.98% -> 98.04% lines, 85.71% -> 85.71% branches. TypeScript changed file 97.97% -> 98.87% lines, 90.16% -> 95.31% branches. PowerShell repo 95.77% -> 95.88%; hook 91.82% -> 93.87%. Reviewer cross-check of uncovered lines against diff hunks: 0 changed lines uncovered in each language. |
| **New Code Coverage** (uniform: >= 85% line, >= 75% branch where measurable) | ✅ PASS | New PowerShell files: `codex-routing-cli-common.ps1` 113/113, `Resolve-CodexTopology.ps1` 39/39, `Resolve-CodexDeployment.ps1` 31/31 (100%). |
| **Comprehensive Coverage** | ✅ PASS | Every new function in the three wrapper files is exercised in process and through `pwsh -File`; `_RoutingConfigFileSystem` and `RoutingConfigFileSystem` virtual-root paths covered in full-tree and pack mode. |
| **Positive Flows** - Valid inputs | ✅ PASS | Corpus success cases for every `--execution-context`, `--cross-cutting`, both `--root-persona` values, repeated and non-ASCII `--language`, `commit-steward`; publisher publishes all 5 virtual pairs. |
| **Negative Flows** - Invalid inputs | ✅ PASS | Corpus exit-2 cases (missing flag, invalid choice, non-integer) and exit-1 cases (empty language, persona with non-standalone context, ceiling below band, unsupported agent); in-memory `variant = "legacy"` role; unmapped `config/` file not published; `.py` excluded by `shouldCopy`. |
| **Edge Cases** - Boundary conditions | ✅ PASS | Negative-number and option-like value tokens, `--` separator, empty argument list, astral-plane JSON escaping, lifecycle tool with mismatched `workspace_root`. |
| **Error Handling** - Error paths | ✅ PASS | Missing registry denies semantic MCP (AC-3.6); malformed registry fixture throws (AC-3.8); no module candidate yields exit 1 with candidate list; unsupported JSON type throws `ArgumentException`. |
| **Concurrency** - If applicable | N/A | No concurrent code paths were added. |
| **State Transitions** - If applicable | ✅ PASS | Hook preparation vs. non-preparation route decisions tested with and without a registry. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.90% lines repo-wide; changed file 97.98% lines, 85.71% branches -> Post-change: 92.90% lines and 85.52% branches repo-wide; changed file 98.04% lines, 85.71% branches. Change: +0.06% lines and +0.00% branches on the changed file. New/changed-code coverage: 100% (0 of the changed executable lines appear in the coverage.json uncovered-line list, which holds only pre-existing lines 211 and 396). Disposition: PASS. Evidence: `artifacts/python/coverage.json`, `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/coverage/python-coverage-delta.2026-09-26T00-20.md`.
- TypeScript: Baseline: changed file 97.97% lines, 90.16% branches -> Post-change: 96.86% lines and 90.64% branches repo-wide; changed file 98.87% lines, 95.31% branches. Change: +0.90% lines and +5.15% branches on the changed file. New/changed-code coverage: 100% (zero-hit lines 125, 126, 134, 135 and zero-hit branch lines 124, 133, 304 are all outside the diff hunks). `packages/mcp-server/prepack.cjs` sits outside the Jest collection root; reviewer V8 block coverage over the four test path families shows one unexecuted block (the `require.main === module` copy call, lines 55-61, which runs only under `node prepack.cjs`), so `shouldCopy` is fully executed. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/coverage/typescript-coverage-delta.2026-09-26T00-25.md`.
- PowerShell: Baseline: 95.77% lines repo-wide (9603 of 10027) -> Post-change: 95.88% lines repo-wide (9793 of 10214). Change: +0.11% lines repo-wide; hook 91.82% -> 93.87%; `CodexDeployment.psm1` 100% -> 100%. New/changed-code coverage: 100% (hook uncovered lines 58, 72, 77, 307, 336, 343-345, 350, 359 are all outside the diff hunks; new files 100%). Pester measures line coverage only, so no branch threshold applies. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml`, `docs/features/active/2026-09-25-codex-pushdown-self-sufficiency-697/evidence/coverage/powershell-coverage-delta.2026-09-26T00-07.md`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | ✅ PASS | The hook probe collects every failing hook/tool pair with exit code, stdout, and stderr into one assertion message; Pester `-Because` clauses on file-existence checks; pytest assertions name the offending key or path. |
| **Arrange-Act-Assert Pattern** | ✅ PASS | Jest tests carry explicit Arrange / Act / Assert comments; pytest and Pester tests follow the same order. |
| **Document Intent** | ✅ PASS | Each new test file opens with a docstring or comment block citing issue #697 and the AC it proves. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | ✅ PASS (with note) | No network or database. `codex-bundle-hook-probe.Tests.ps1` and `Resolve-CodexRouting.Parity.Tests.ps1` start `pwsh` child processes; AC-2.4 and AC-4.7 require this, and it follows the existing `legacy-codex-hook-contracts.Tests.ps1` pattern. |
| **Use Mocks/Stubs** | ✅ PASS | Python uses the in-memory doubles in `push_down_customizations_test_support.py`; Jest uses an in-memory destination over a read-only real-bundle source; `prepack.cjs` test installs a no-op `cpSync` spy. |
| **Environment Stability** | ✅ PASS | Search of every new test file for `tempfile`, `tmp_path`, `TestDrive`, `mkdtemp`, `os.tmpdir`, `writeFileSync`, `Set-Content`, `Out-File` returned no match. `git status --porcelain` was empty after reviewer runs. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | ✅ PASS | This document is the policy review for the branch; companion artifacts: `code-review.2026-09-26T01-30.md`, `feature-audit.2026-09-26T01-30.md`. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | ✅ PASS | `issue.md`, `spec.md` (full-bug), and research artifact `research/2026-09-25T09-40-codex-pushdown-self-sufficiency-research.md`. |
| **Read existing change plans** | ✅ PASS | `evidence/baseline/phase0-instructions-read.2026-09-25T20-13.md` lists the 14 policy files read in order. |
| **Document the plan** | ✅ PASS | `plan.2026-09-25T08-22.md` committed in `35ef73a3`. |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | ✅ PASS | The hook fix moves one registry read into the single branch that consumes it. The publisher change replaces a single virtual path with a pair map. |
| **Reusability** | ✅ PASS | Both wrappers share `codex-routing-cli-common.ps1`; wrappers import the existing `.claude/lib/codex-routing` modules rather than reimplementing them. |
| **Extensibility** | ✅ PASS | `VIRTUAL_RESOURCE_PAIRS` / `VIRTUAL_ROOT_FOLDERS` allow further renamed resources without code change. |
| **Separation of concerns** | ✅ PASS | Wrappers separate parsing, module resolution, resolver call, and serialization; I/O limited to the entry block (`[Console]::Out.Write`). |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | ✅ PASS | One helper file for CLI concerns; one wrapper per resolver. |
| **Under 500 lines** | ✅ PASS | Largest changed non-doc files: `push_down_codex_and_agents_customizations.py` 428, `codex-agents-customizations.test.ts` 413, `CodexTopology.psm1` mirror 394, `codex-routing-cli-common.ps1` 370, `enforce-epic-planning-only.ps1` 365, `codex-agents-customizations.ts` 355. |
| **Public vs internal** | ✅ PASS | Python class stays `_RoutingConfigFileSystem`; TypeScript class stays unexported; new TS constants exported for tests and parity. |
| **No circular dependencies** | ✅ PASS | Wrappers dot-source the helper and import modules; no reverse reference. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | ✅ PASS | `Resolve-CodexRoutingModulePath`, `ConvertFrom-CodexRoutingArgument`, `VIRTUAL_RESOURCE_PAIRS`. |
| **Docs/docstrings** | ✅ PASS | Every new PowerShell function has comment-based help; `_RoutingConfigFileSystem` gained a full Google-style class docstring. |
| **Comment why, not what** | ✅ PASS (Nit recorded) | Decision comments on the lazy registry read and the virtual-root listing. The module-level filtered generator for `SHARED_CONFIG_RELATIVE_PATHS` has no immediate intent comment (Nit in the code review). |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | ✅ PASS | Executor: `evidence/qa-gates/final-python-black.2026-09-26T00-17.md`, `final-ts-prettier.2026-09-26T00-22.md`, `final-ps-format.2026-09-26T00-02.md`. Reviewer: `black --check` 7 files unchanged; `prettier --check` clean; `Invoke-Formatter` no drift. |
| **2. Linting** | ✅ PASS | Executor: `final-python-ruff.2026-09-26T00-17.md`, `final-ts-eslint.2026-09-26T00-23.md`, `final-ps-analyze.2026-09-26T00-03.md`. Reviewer: Ruff `All checks passed!`; ESLint exit 0; PSScriptAnalyzer 0 findings. |
| **3. Type checking** | ✅ PASS | Executor: `final-python-pyright.2026-09-26T00-18.md`, `final-ts-tsc.2026-09-26T00-23.md`. Reviewer: Pyright exit 0; `tsc -p ./ --noEmit` exit 0. PowerShell N/A. |
| **4. Testing** | ✅ PASS | Executor full suites: Python 5036 pass / 1 pre-existing fail; TypeScript 3021/3021; PowerShell 5081 pass / 0 fail. Reviewer targeted: 657 + 19 + 215 pass. |
| **Full toolchain loop** | ✅ PASS | `evidence/qa-gates/final-toolchain-single-pass.2026-09-26T00-26.md`: last iterations (Python 4, TypeScript 3, PowerShell 3) changed no file. |
| **Explicit reporting** | ✅ PASS | Each command recorded with timestamp and exit code under `evidence/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | ✅ PASS | Commit `59c4fda8` message and section 9 below. |
| **Design choices explained** | ✅ PASS | `spec.md` Proposed Fix and research sections 2-7. |
| **Update supporting documents** | ✅ PASS | `codex-model-routing/SKILL.md` repointed (both copies); follow-up entry `docs/features/potential/2026-09-25-codex-pushdown-live-verification.md`. |
| **Provide next steps** | ✅ PASS | Live destination verification deferred to the potential entry after the next package release. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | ✅ PASS | `poetry run black --check <7 changed files>`: `7 files would be left unchanged.` |
| **Linting with Ruff** | ✅ PASS | `poetry run ruff check scripts/dev_tools/push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/`: `All checks passed!` |
| **Type checking with Pyright** | ✅ PASS | `poetry run pyright --project <repo> <7 files>`: exit 0. |
| **Testing with Pytest** | ✅ PASS | 657 targeted cases pass; executor full suite 5036 pass with the single pre-existing #510 failure. |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | ✅ PASS | `VIRTUAL_RESOURCE_PAIRS: tuple[tuple[Path, Path], ...]`; no `Any` introduced. |
| **Dataclasses for value objects** | N/A | No new value object in production code. |
| **Protocols/ABCs for interfaces** | N/A | Existing file-system duck type retained. |
| **Avoid utility classes** | ✅ PASS | No static-only class added. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | ✅ PASS | No exception handling added or broadened. |
| **Logging over print** | ✅ PASS | No `print` added. |
| **Invariants at construction** | ✅ PASS | Pair map and virtual roots built once in `__init__`. |

No `# noqa` or `# type: ignore` was added in Python (reviewer diff inspection).

### Section 3B: PowerShell Code Change Policy Compliance

#### 3B.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Invoke-Formatter** | ✅ PASS | Reviewer: `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` produced identical text for all 10 changed files. Executor: `final-ps-format-mcp.2026-09-26T00-01.md`. |
| **Linting with PSScriptAnalyzer** | ✅ PASS | Reviewer: `Invoke-ScriptAnalyzer -Settings pssa.settings.psd1` 0 findings across 10 files. Executor: `final-ps-analyze-mcp.2026-09-26T00-03.md`. |
| **Fix all findings** | ✅ PASS | Iteration-1 analyzer findings were fixed before iteration 3 (`final-ps-analyze-iteration1.2026-09-25T23-45.md`). |
| **PowerShell 7+ compatible** | ✅ PASS | New scripts declare `#Requires -Version 7.0`; tests ran under pwsh 7.6.6. |

#### 3B.2 PowerShell Design & Safety

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Advanced functions** | ✅ PASS | All new functions use `[CmdletBinding()]` and `[OutputType()]`. |
| **Parameter validation** | ✅ PASS | `Mandatory`, `AllowEmptyCollection`, `AllowEmptyString` attributes applied. |
| **Avoid global state** | ✅ PASS | The fix removed the script-scoped `$script:AllowedPreparationSemanticMcpTools`. |
| **Error handling** | ✅ PASS | Missing registry returns an explicit deny; malformed registry still throws to the top-level catch (exit 2); wrapper catches only `ArgumentException` and maps it to exit 1. |

#### 3B.3 Structure, Naming, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive and under 500 lines** | ✅ PASS | 370, 97, 88, 365, 315 lines. |
| **Approved verbs** | ✅ PASS | `Get`, `Resolve`, `Test`, `ConvertFrom`, `ConvertTo`, `New`, `Invoke`; PSScriptAnalyzer `PSUseApprovedVerbs` reported nothing. |
| **Comment why** | ✅ PASS | Lazy-registry and routing-table comments explain decision order. |

#### 3B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Step 1: Format** | ✅ PASS | See 3B.1. |
| **Step 2: Analyze** | ✅ PASS | See 3B.1. |
| **Step 3: Type check** | N/A | Not applicable for PowerShell. |
| **Step 4: Test** | ✅ PASS | Reviewer targeted Pester: 215 passed, 0 failed. Executor full run: 5081 passed, 0 failed, 9 skipped. |
| **Rerun loop if needed** | ✅ PASS | Three executor iterations; iteration 2 added four cases to close uncovered new lines (`powershell-coverage-delta-iteration2.2026-09-25T23-58.md`). |

### Section 3C: TypeScript and CommonJS Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Prettier** | ✅ PASS | Reviewer `prettier --check` over 5 TS files, `jest.config.cjs`, and `prepack.cjs`: all use Prettier style. |
| **Linting with ESLint** | ✅ PASS | Reviewer ESLint over 5 TS files: exit 0. Two `@typescript-eslint/no-require-imports` disables in `mcp-server-prepack.test.ts` carry rationale comments. |
| **Type checking with tsc** | ✅ PASS | `npm --prefix extensions/drm-copilot run typecheck`: exit 0. |
| **Untyped escape hatches** | ✅ PASS | No `any` introduced in production TypeScript. |
| **Coverage exclusions** | ✅ PASS | `jest.config.cjs` adds only a per-file `coverageThreshold` entry; no `collectCoverageFrom` exclusion added. |

### Section 3D: JSON Configuration Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Generator-canonical form** | ✅ PASS | `test_generator_check_mode_reports_no_drift` passed in the reviewer run; `evidence/qa-gates/generator-check.2026-09-25T22-51.md`. |
| **Strict JSON only** | ✅ PASS | `core.json` and corpus fixtures are parsed by passing tests. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | All Python tests are pytest functions with `parametrize`. |
| **Coverage expectation** | ✅ PASS | Changed file 98.04% lines, 85.71% branches; repo 92.90% / 85.52%. |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | ✅ PASS | For example `test_closure_follows_variable_dot_source` tests one dot-source form. |
| **Mocking sparingly** | ✅ PASS | In-memory file-system doubles only. |
| **Organization** | ✅ PASS | Under `tests/scripts/dev_tools/`, mirroring `scripts/dev_tools/`. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | ✅ PASS | `test_<behavior>` names throughout. |
| **Docstrings/comments** | ✅ PASS | Module docstrings cite #697 and the AC proved. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | ✅ PASS | `poetry run pytest --rootdir <repo> -q <11 files>`: 657 passed. |
| **No Alternative Test Runners** | ✅ PASS | Pytest only. |

### Section 4B: PowerShell Unit Test Policy Compliance

#### 4B.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pester v5.x** | ✅ PASS | `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`; `BeforeAll`, `-ForEach`, `Should -Be`. |
| **Use PoshQC Configuration** | ✅ PASS | Executor ran `Invoke-PoshQCTest -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; the three new scripts were added to `CodeCoverage.Path` in both runsettings copies. |
| **PowerShell 7+ Compatible** | ✅ PASS | pwsh 7.6.6, Pester 5.6.1. |

#### 4B.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused Unit Tests** | ✅ PASS | 12 `It` blocks in `codex-planning-only-registry.Tests.ps1`, each one decision path. |
| **Test Behavior Over Implementation** | ✅ PASS | AC-3.1 AST test is structural by design (asserts no top-level registry call); all other cases assert decisions. |
| **Mocking Used Sparingly** | ✅ PASS | No `Mock` used; real functions with explicit `-RegistryPath`. |
| **Organization** | ✅ PASS | `tests/scripts/codex-hooks/` for `.codex/hooks/`; `tests/scripts/codex-scripts/` for `.codex/scripts/`; `tests/scripts/claude-lib/codex-routing/` for `.claude/lib/codex-routing/`. |

#### 4B.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **File Naming** - *.Tests.ps1 | ✅ PASS | All five PowerShell test files end in `.Tests.ps1`. |
| **Describe/Context/It Structure** | ✅ PASS | One `Describe` per file; `Context` blocks in `codex-routing-cli-common.Tests.ps1`. |
| **Logical Grouping** | ✅ PASS | Grouped by candidate resolution, token parser, JSON serializer. |
| **Docstrings/Comments** | ✅ PASS | Header comment blocks cite the AC. |

#### 4B.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use PoshQCTest Command** | ✅ PASS | `evidence/qa-gates/final-ps-pester-coverage.2026-09-26T00-06.md`: 5081 passed, 0 failed. |
| **No Alternative Test Runners** | ✅ PASS | Pester only (reviewer used `Invoke-Pester` directly for the targeted re-run). |

### Section 4C: TypeScript Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Jest** | ✅ PASS | `npm --prefix extensions/drm-copilot run test -- <3 files>`: 3 suites, 19 tests passed. |
| **No temporary files** | ✅ PASS | In-memory destination; `git status --porcelain` empty after run. |
| **Location** | ✅ PASS | `test/lib/push-down/` mirrors `src/lib/push-down/`; `test/packaging/` for the packaging script. |

---

## 5. Test Coverage Detail

### `.codex/hooks/enforce-epic-planning-only.ps1` (codex-planning-only-registry.Tests.ps1, 12 It blocks, parametrized)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| invokes Get-EpicPlanningRegisteredMcpTool from no top-level statement | Positive (structure) | script scope | ✅ |
| allows mcp__ tool with a missing registry on a non-preparation route | Positive | 209-210 (parameter default) | ✅ |
| denies `<Tool>` with a reason naming the missing registry in preparation mode | Negative | 273-277 | ✅ |
| allows semantic tool `<Tool>` with the committed registry in preparation mode | Positive | 279-284 | ✅ |
| throws for a semantic tool when the registry fixture is invalid | Error Handling | 279-281 | ✅ |

**Coverage:** 93.87% of file (153 of 163 lines); changed lines 209-210, 270-283 all covered.

**Not covered:** lines 58, 72, 77, 307, 336, 343-345, 350, 359 (unchanged registry-validation throws and entrypoint branches).

### `.codex/scripts/*.ps1` (codex-routing-cli-common.Tests.ps1 and Resolve-CodexRouting.Parity.Tests.ps1)

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| selects the first / second candidate; returns non-zero when no candidate exists | Positive / Negative | helper 18-70; topology wrapper 65-68; deployment wrapper 58-61 | ✅ |
| parses `<Label>` (negative number, option-like value, double-dash separator) | Edge Case | helper 72-218 | ✅ |
| serializes `<Label>` like Python json.dumps; rejects an unsupported value type | Positive / Error Handling | helper 220-337 | ✅ |
| matches the Python CLI for topology / deployment case `<id>` through pwsh -File | Positive / Negative | wrappers end to end | ✅ |

**Coverage:** 100% of all three files.

### `scripts/dev_tools/push_down_codex_and_agents_customizations.py` and `codex-agents-customizations.ts`

| Test Name | Scenario Type | Lines Covered | Status |
|-----------|--------------|---------------|--------|
| test_module_pairs_publish_renamed_resources_in_full_tree_mode / pack_mode | Positive | `_RoutingConfigFileSystem.__init__`, `list_files`, `read_text` | ✅ |
| test_unmapped_config_file_is_not_published | Negative | `list_files` virtual-root branch | ✅ |
| RoutingConfigFileSystem publishes 5 destinations, full-tree and pack mode; omits unmapped virtual-root file (Jest) | Positive / Negative | `VIRTUAL_RESOURCE_PAIRS`, `RoutingConfigFileSystem` constructor, `listFiles`, `isFile`, `readTextFile` | ✅ |

**Coverage:** Python file 98.04% lines / 85.71% branches; TS file 98.87% lines / 95.31% branches.

**Not covered:** Python lines 211 and 396 and TS lines 125-126, 134-135 (pre-existing, unchanged).

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (executor full suites) | Python 5042, TypeScript 3021, PowerShell 5090 | ✅ |
| Tests Passed | Python 5036, TypeScript 3021, PowerShell 5081 | ✅ |
| Tests Failed | 1 (Python, pre-existing #510 `.claude/state/current-session-id`, identical at baseline) | ✅ (not attributable to the branch) |
| Reviewer targeted runs | 657 pytest + 19 Jest + 215 Pester, all passed | ✅ |
| Execution Time (reviewer) | pytest 0.85 s; Jest 0.40 s | ✅ Fast |
| Test File Size | largest 413 lines | ✅ Maintainable |
| Code Coverage | Python 92.90% lines / 85.52% branches; TypeScript 96.86% / 90.64%; PowerShell 95.88% lines | ✅ |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check <7 files>` | 7 files unchanged | ✅ |
| Ruff Linting | `poetry run ruff check <files>` | All checks passed | ✅ |
| Pyright Type Checking | `poetry run pyright --project <repo> <7 files>` | exit 0 | ✅ |
| Pytest Tests | `poetry run pytest --rootdir <repo> -q <11 files>` | 657 passed | ✅ |

**For PowerShell:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Invoke-Formatter | `Invoke-Formatter -ScriptDefinition <text> -Settings pssa.settings.psd1` per file | no drift (10 files) | ✅ |
| PSScriptAnalyzer | `Invoke-ScriptAnalyzer -Path <file> -Settings pssa.settings.psd1` | 0 findings (10 files) | ✅ |
| Pester Tests | `Invoke-Pester` with 7 paths | 215 passed | ✅ |

**For TypeScript / CommonJS:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Prettier | `node node_modules/prettier/bin/prettier.cjs --check <7 files>` | clean | ✅ |
| ESLint | `node node_modules/eslint/bin/eslint.js -c eslint.config.mjs <5 files>` | exit 0 | ✅ |
| tsc | `npm --prefix extensions/drm-copilot run typecheck` | exit 0 | ✅ |
| Jest | `npm --prefix extensions/drm-copilot run test -- <3 files>` | 19 passed | ✅ |

**Notes:** The single Python full-suite failure (`test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, issue #510) is recorded identically in the Phase 0 baseline and names only a gitignored `.claude/state/` file.

---

## 8. Gaps and Exceptions

### Identified Gaps

No policy FAIL. Non-blocking observations:

- **Coverage evidence is gitignored (pre-existing, repository-wide).** `.gitignore:59` `coverage/` matches `docs/features/**/evidence/coverage/`. The seven files the executor wrote there (for AC-6.3) exist on disk but will not reach the PR. Zero `evidence/coverage/` files are tracked anywhere in the repository, so the gap predates this branch. Recommended follow-up: add a negation such as `!docs/features/**/evidence/coverage/` in a separate change.
- **`packages/mcp-server/prepack.cjs` is outside every coverage collection root.** Its behavior is fully tested by `mcp-server-prepack.test.ts`; reviewer V8 measurement shows only the main-module copy block unexecuted. The file is a packaging script (T4) and is not under `src/`, so this is not a prohibited exclusion.
- **Process-spawning Pester tests** depend on `pwsh` resolved through `Get-Command`; this is required by AC-2.4 and AC-4.7 and follows an existing repository pattern.

### Approved Exceptions

**None.** No exceptions needed.

### Removed/Skipped Tests

**None.** All planned tests implemented; the 9 skipped Pester and 5 skipped pytest cases match the baseline counts.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **35ef73a3** - docs(codex-pushdown): add research, spec, and preflight-cleared plan (#697)
2. **59c4fda8** - fix(codex-pushdown): make Codex push-down payload self-sufficient (#697)

### Files Modified

1. **`.codex/hooks/enforce-epic-planning-only.ps1`** (MODIFIED) and bundle mirror - registry read moved into the semantic-MCP branch; `-RegistryPath` parameter; missing registry denies with a named reason.
2. **`.codex/scripts/{codex-routing-cli-common,Resolve-CodexTopology,Resolve-CodexDeployment}.ps1`** (NEW) and bundle mirrors - PowerShell CLI equivalents of the Python resolvers.
3. **`.claude/lib/codex-routing/CodexDeployment.psm1`** (MODIFIED), Claude bundle mirror, and new shared mirrors `extensions/drm-copilot/resources/lib/codex-routing/*.psm1` (NEW) - `commit-steward` family added.
4. **`scripts/dev_tools/push_down_codex_and_agents_customizations.py`** and **`extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`** (MODIFIED) - destination-to-resource pair map with virtual roots `config` and `.codex/lib/codex-routing`.
5. **`packages/mcp-server/prepack.cjs`** (MODIFIED) - `scripts` exclusion anchored to the resources root; `shouldCopy` exported; copy only when run as main.
6. **`pack-manifests/core.json`** (MODIFIED) - 12 hooks/dependency and 5 routing paths added.
7. **`csharp-legacy/agents/csharp-typed-engineer.toml`** (MODIFIED) - `variant` replaced by `model` and `model_reasoning_effort`.
8. **`.agents/skills/codex-model-routing/SKILL.md`** (MODIFIED) and bundle mirror - Python invocations replaced by `pwsh -File` wrappers and MCP validation.
9. **Tests and fixtures** (NEW/MODIFIED) - listed in Appendix A.
10. **`jest.config.cjs`, `pester.runsettings.psd1` x2** (MODIFIED) - threshold entry and coverage paths.

---

## 10. Compliance Verdict

### Overall Status: ✅ FULLY COMPLIANT

All evaluated policies pass. Coverage meets the uniform thresholds for every language with changed files, with baseline and post-change numbers recorded and changed-line coverage independently cross-checked. The observations in section 8 are pre-existing or structural and do not require remediation on this branch.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Before Making Changes: spec, research, and plan committed
- ✅ Design Principles: minimal, reusable changes
- ✅ Module & File Structure: all files under 500 lines
- ✅ Naming, Docs, Comments: one Nit
- ✅ Toolchain Execution: clean single pass recorded and re-verified
- ✅ Summarize & Document: follow-up entry recorded

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- ✅ Tooling & Baseline: clean
- ✅ Python Design & Typing: typed, no suppressions
- ✅ Error Handling: unchanged

**For PowerShell:**
- ✅ Tooling & Baseline: 0 analyzer findings, no format drift
- ✅ PowerShell Design & Safety: script-scoped state removed
- ✅ Structure & Naming: approved verbs
- ✅ Toolchain: 3 iterations, final clean

**For TypeScript:**
- ✅ Prettier, ESLint, tsc, Jest clean

#### General Unit Test Policy (Section 1)
- ✅ Core Principles
- ✅ Coverage & Scenarios
- ✅ Test Structure
- ✅ External Dependencies (process spawning noted)
- ✅ Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- ✅ Framework & Scope
- ✅ Test Style & Structure
- ✅ Naming & Readability
- ✅ Toolchain

**For PowerShell:**
- ✅ Framework & Scope
- ✅ Test Style & Structure
- ✅ Naming & Readability
- ✅ Toolchain

---

### Metrics Summary

- ✅ Reviewer targeted runs: 891 of 891 passing
- ✅ Executor full suites: 13138 passing; 1 pre-existing failure unrelated to the branch
- ✅ Line coverage: Python 92.90%, TypeScript 96.86%, PowerShell 95.88%
- ✅ Branch coverage: Python 85.52%, TypeScript 90.64% (PowerShell not measurable)
- ✅ 0 changed lines uncovered in any language
- ✅ All code quality checks passing

---

### Recommendation

**Ready for merge** (subject to the CI green gate).

No remediation is required. Optional follow-ups: un-ignore `evidence/coverage/` repository-wide; consider bringing `packages/mcp-server/prepack.cjs` into a coverage collection root.

---

## Appendix A: Test Inventory

- `tests/scripts/dev_tools/test_codex_agent_role_schema.py`: `test_role_file_top_level_keys_are_allowlisted`, `test_allowlist_rule_reports_variant_key_in_memory`, `test_role_file_declares_identity_keys`, `test_routed_role_file_declares_model_pins`, `test_routed_role_file_counts_per_set`, `test_model_pins_not_required_for_unrouted_role`, `test_variant_role_file_matches_canonical_keys_and_pins`
- `tests/scripts/dev_tools/test_codex_core_manifest_closure.py`: `test_closure_follows_join_path_dot_source`, `test_closure_follows_variable_dot_source`, `test_closure_follows_parent_scripts_join_path`, `test_guard_reports_hook_absent_from_manifest`, `test_core_manifest_contains_registered_hook_closure_and_resolver_paths`
- `tests/scripts/dev_tools/test_codex_model_routing_skill.py`: `test_skill_contains_no_python_resolver_invocation`, `test_skill_instructs_powershell_wrappers`, `test_skill_directs_validation_to_mcp_tool`
- `tests/scripts/dev_tools/test_codex_routing_cli_corpus.py`: `test_topology_corpus_matches_python_cli`, `test_deployment_corpus_matches_python_cli`, `test_corpus_covers_required_cases`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py`: `test_module_pairs_publish_renamed_resources_in_full_tree_mode`, `test_module_pairs_publish_renamed_resources_in_pack_mode`, `test_unmapped_config_file_is_not_published`, `test_codex_routing_lib_is_walked_as_published_root`, `test_shared_codex_routing_modules_match_claude_lib_sources`, `test_no_physical_codex_lib_directory_exists`
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`: hook exception set emptied
- `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`: 3 `It` blocks (17 PreToolUse hooks, 41 invocations)
- `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1`: 12 `It` blocks
- `tests/scripts/codex-scripts/Resolve-CodexRouting.Parity.Tests.ps1`: 7 `It` blocks, corpus-parametrized
- `tests/scripts/codex-scripts/codex-routing-cli-common.Tests.ps1`: 10 `It` blocks in 3 `Context` blocks
- `tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1`: family list extended; `resolves commit-steward to the Python resolver receipt` added
- `extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts`: 3 tests
- `extensions/drm-copilot/test/lib/push-down/codex-agents-customizations.test.ts`: virtual-pair tests added, ordering test updated
- `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts`: 4 tests

---

## Appendix B: Toolchain Commands Reference

**For Python** (the shared Poetry venv resolves `scripts.*` to another worktree through its `.pth`, so the pytest and validator runs were repeated with `PYTHONPATH=<repo>` and module origins were confirmed to be this worktree; results were identical):
```bash
poetry -C <repo> run black --check <changed .py files>
poetry -C <repo> run ruff check scripts/dev_tools/push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/
poetry -C <repo> run pyright --project <repo> <changed .py files>
poetry -C <repo> run pytest --rootdir <repo> -c <repo>/pyproject.toml -q -p no:cacheprovider <11 test files>
poetry -C <repo> run python scripts/dev_tools/validate_evidence_locations.py --root <repo>
```

**For PowerShell:**
```powershell
Invoke-Formatter -ScriptDefinition (Get-Content -Raw <file>) -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1
$c = New-PesterConfiguration; $c.Run.Path = @(<7 test paths>); $c.Run.PassThru = $true; Invoke-Pester -Configuration $c
```

**For TypeScript / CommonJS:**
```bash
node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check <7 files>
node extensions/drm-copilot/node_modules/eslint/bin/eslint.js -c extensions/drm-copilot/eslint.config.mjs <5 files>
npm --prefix extensions/drm-copilot run typecheck
npm --prefix extensions/drm-copilot run test -- test/lib/push-down/codex-agents-customizations.test.ts test/lib/push-down/codex-bundle-publish.integration.test.ts test/packaging/mcp-server-prepack.test.ts
NODE_V8_COVERAGE=<scratchpad> node <scratchpad>/drive.cjs packages/mcp-server/prepack.cjs
```

**Coverage artifact parsing (reviewer, read-only):** `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/coverage.json`, `artifacts/pester/powershell-coverage.xml`, cross-checked against `git diff -U0 26d57cb3..HEAD` hunks.

---

**Audit Completed By:** feature-review agent
**Audit Date:** 2026-09-26
**Policy Version:** Current (as of audit date)
