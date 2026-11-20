# Policy Compliance Audit: blast-radius bundled truth-table correction (Issue #500)

**Audit Date:** 2026-08-22
**Auditor:** feature-review
**Cycle:** remediation cycle 2 re-audit
**Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `fc9a3a26`
**Base:** `main` @ `fb30a9a58b8422e610a09b07361421e97367807a` (merge base, identical to the base tip)
**Work Mode:** `full-bug`, read from the `- Work Mode: full-bug` marker in `issue.md`. The acceptance-criteria source is `spec.md` only.
**Code Under Test:** `.claude/rules/parallel-orchestration.md`; `config/blast-radius.json`; `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`; `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`; `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`; `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts`; `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts`; `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts`; `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts`; `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`; `tests/scripts/dev_tools/blast_radius_parity_test_support.py`; `tests/scripts/dev_tools/test_blast_radius_config_parity.py`; plus 104 documentation and evidence Markdown files under the feature folder.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 2 files | 4078 tests | 4078 pass, 0 fail, 5 skipped | 92.60% statements, 85.19% branches | 92.60% statements, 85.19% branches | 100.00% of changed production lines, of which there are zero |
| TypeScript | 5 files | 2656 tests | 2656 pass, 0 fail | 96.66% lines, 90.04% branches | 96.66% lines, 90.04% branches | 100.00% lines and 95.83% branches on the one changed production module |
| PowerShell | 1 file | 3122 tests | 3113 pass, 0 fail, 9 skipped | 96.21% lines | 96.21% lines | 100.00% of changed lines, of which zero are production lines |
| JSON | 2 files | 48 tests | 48 pass, 0 fail | N/A (configuration data, no coverage tooling) | N/A (configuration data, no coverage tooling) | N/A (configuration data, no coverage tooling) |
| Markdown | 106 files | N/A | N/A (no executable behavior) | N/A (documentation, no coverage tooling) | N/A (documentation, no coverage tooling) | N/A (documentation, no coverage tooling) |

Every language that has changed files in the branch diff appears in the table with an explicit disposition. C#, shell, and YAML are absent from the table because the branch changes zero files in each.

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/baseline/typescript-jest-coverage.2026-08-21T22-52.md`, recording 96.66% lines and 90.04% branches captured in Phase 0
- TypeScript post-change coverage artifact: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T04-46.md`, which regenerated `extensions/drm-copilot/coverage/lcov.info` at branch head `fc9a3a26`
- PowerShell baseline coverage artifact: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/baseline/powershell-poshqc-test.2026-08-21T23-03.md`, recording 96.21% line coverage captured in Phase 0
- PowerShell post-change coverage artifact: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T04-46.md`, which regenerated `artifacts/pester/powershell-coverage.xml` at branch head `fc9a3a26`
- Per-language comparison summary: section 1.2.1 of this audit, cross-referenced to `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T04-46.md`

**Verdict rule applied:** numeric baseline and post-change coverage are recorded for every coverage language that has changed files, and every such language carries an explicit PASS or FAIL. No language with changed files is recorded as out of scope.

### Template Source

The MCP server tool `resolve_policy_audit_template_asset` is not present in this review session's tool allowlist, so it could not be invoked. The three review artifacts were built from the bundled asset files the tool serves, read directly at `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `.../code-review.yyyy-MM-ddTHH-mm.md`, and `.../feature-audit.yyyy-MM-ddTHH-mm.md`. Those files are the authoritative asset source, and the selector mapping in `extensions/drm-copilot/src/policy-audit-template-assets.ts` confirms they are the assets the selectors `template`, `code-review-template`, and `feature-audit-template` resolve to. Each artifact was validated after writing with `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts`. This is a tool-availability limitation of the review session, not a repository defect.

---

## Rejected Scope Narrowing

None detected in the delegating prompt.

The delegating prompt supplied six scrutiny questions and stated verbatim that they are "Orientation, not scope limits or conclusions to ratify." It separately directed that "Every language with changed files in the branch diff is in scope for its full toolchain and coverage check," and that the audit must cover "the full branch diff against the merge base, not only the cycle 2 delta." No instruction attempted to narrow the audit to a plan, task, phase, or file subset, and no instruction marked any language's coverage as out of scope, informational only, or not applicable.

Two in-repository artifacts assert a language-scope narrowing. They are recorded here verbatim rather than acted on.

`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/remediation-baseline/typescript-out-of-scope.2026-08-22T03-37.md` states:

> "TypeScript, C#, and shell are not re-baselined in this remediation cycle. No file under extensions/drm-copilot/src/** or extensions/drm-copilot/test/** is touched by any of R7 through R12; nothing in this cycle changes TypeScript-visible behavior. This follows the precedent accepted by the cycle-1 re-audit, which found the identical TypeScript-exclusion note sufficient."

Its cycle-1 predecessor at `.../evidence/remediation-baseline/typescript-out-of-scope.2026-08-21T21-49.md` states:

> "TypeScript is not re-baselined in this remediation cycle. No file under extensions/drm-copilot/src/** or extensions/drm-copilot/test/** is touched by R1 through R6 in this cycle."

Both are executor-side scoping records for a remediation cycle, not instructions to this agent, and the audit treats them as non-binding regardless. The cycle-2 note additionally cites this reviewer's cycle-1 re-audit as precedent; that reading is corrected here. The cycle-1 re-audit did not accept the exclusion. It reran the full TypeScript toolchain and coverage at branch head and issued an explicit PASS. This re-audit does the same: TypeScript has five changed files in the branch diff against the merge base, so Prettier, ESLint, `tsc`, and Jest with coverage were all rerun by the reviewer at head `fc9a3a26`, and TypeScript carries an explicit PASS in section 1.2.1. C# and shell have zero changed files, so their absence is a genuine non-applicability rather than a narrowing.

The audit was performed as a full feature-versus-base review of `fb30a9a5..fc9a3a26`.

---

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited `0` with no output.

The branch diff was scanned for files written under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, and `artifacts/post-change/`. Zero matches were found. All 81 evidence artifacts added by the branch live under `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/` in the `baseline`, `qa-gates`, `regression-testing`, `remediation-baseline`, `other`, and `issue-updates` sub-folders, which is the canonical scheme in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose. The delegating prompt directed evidence to `<FEATURE>/evidence/<kind>/` only, which is the canonical location. This reviewer's two evidence artifacts were written to `evidence/qa-gates/`.

The timestamp-convention defect that cycle 1 introduced is a naming matter rather than a location matter and is recorded in section 8.

---

## Executive Summary

This is the re-audit of remediation cycle 2 at head `fc9a3a26`. The branch corrects the blast-radius truth table the Claude push-down publishes into a destination workspace, corrects the exported constant that supplies a destination's payload modules, adds four read-by-mandate exclusions to both committed copies, amends the governing rule with its byte-identical bundled mirror, and adds a key-partition drift gate in Python mirrored in PowerShell and complemented by two TypeScript assertions. Cycle 2 added the key-set exhaustiveness assertion in both languages, corrected the AC4 verification pointer, qualified the Class 2 mitigation clause, retired five stale line anchors, added a Pester non-vacuity case, and recorded the feature folder's timestamp convention.

Every cycle-2 claim was verified independently by perturbation rather than by reading. The battery and its measured outputs are recorded in `evidence/qa-gates/reviewer-perturbation-battery.2026-08-22T04-46.md`.

- **R7 is delivered, and the sweep claim holds.** `spec.md` AC4 now cites `tests/scripts/dev_tools/test_blast_radius_config_parity.py`. `grep -c -F "tests/scripts/dev_tools/test_blast_radius_config.py"` over `spec.md` returns 6 and `grep -c -F "test_blast_radius_config_parity.py"` returns 5. Of the six references to the non-parity file, exactly one, at line 470, falls inside the acceptance-criteria section spanning lines 419 to 520, and that one is AC9's import-source citation, which is accurate: `blast_radius_parity_test_support.py` imports `BUNDLED_CONFIG_PATH`, `CONFIG_PATH`, `load_config_file`, and `load_module_globs` from it. Every one of the seventeen criteria was read and its cited construct resolved against the named file. No further instance of the defect class exists inside the criteria.
- **R8 is delivered and is genuinely falsifiable in both halves and both languages.** Injecting a new top-level key into the self-hosted copy alone fails the first relation in Python, naming the symmetric difference, and fails the mirrored Pester case, naming the key. Injecting the same key into both copies fails the second relation in Python, naming the unclassified key, and again fails the Pester case. The pre-existing R4 directional invariant continues to fire independently on a separator-free injection.
- **R9, R10, and R11 are delivered as specified.** The Class 2 mitigation clause now reads "the separator-free portion of the residual gap", which matches the measured behaviour: a separator-bearing self-hosted addition fires nothing. The five stale anchors in AC1, AC2, AC3, AC5, and AC12 are replaced by construct names that resolve. The one remaining anchor inside the criteria, AC8's "lines 101-126", still resolves exactly to `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and its body. R11's convention note is present and its count correction from twenty to eighteen is accurate.
- **R12 is delivered in form but not in effect.** The Pester non-vacuity floor cannot fail for the condition its own comment names. This is the principal finding of this re-audit and is recorded as a Major, not a Blocker, because the Python floor covers the same condition and both suites run in the same pipeline.

Seventeen of seventeen acceptance criteria evaluate PASS. The full toolchain passes in a single uninterrupted eleven-stage pass across all three languages with changed files, and coverage is unchanged in all three coverage languages against the Phase 0 baselines.

Two Major findings and four Minor findings remain, all recorded in the code review and in section 8. None of them falsifies an acceptance criterion, fails a toolchain stage, regresses coverage, or creates a detection hole in the pipeline as a whole. No remediation-triggering condition from `.claude/skills/feature-review-workflow/SKILL.md` step 8 fired, so no remediation-inputs artifact was produced and no third remediation cycle was opened. The two Major findings are specified in full so a follow-up can act on them without re-deriving anything.

**Blocking findings: 0.**

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | The Python cases read the two committed files at module import and assert over frozensets; no case mutates shared state or depends on ordering. The two Pester cases added this cycle read `$script:CommittedConfig` and `$script:BundledConfig` from the Describe-level `BeforeAll` and accumulate into locally constructed lists. Running the parity module alone reports `16 passed`, and running it with `test_blast_radius_config.py` reports `48 passed`; the counts are additive. |
| **Isolation** | PASS | Each case targets one relation. `test_every_top_level_key_is_classified_and_shared_by_both_copies` asserts key-set equality and then class coverage, and nothing else. Perturbation P1 and P2 each fired that case alone out of 48, and neither disturbed any other case. |
| **Fast execution** | PASS | The 16-case parity module runs in 0.08s. The 20-case Pester file completes in about 1.2s inside a full-suite run of 131.83s. Both figures were measured in this review. |
| **Determinism** | PASS | `COMPUTED_AT` is the fixed constant `"2026-08-15T09-48"` rather than a clock read. No added case reads wall-clock time, introduces randomness, or calls `Start-Sleep`, `setTimeout`, or `Thread.Sleep`. |
| **Readability** | PASS | Every added case carries a docstring or comment block naming the invariant, the direction of the failure it detects, and its cross-language counterpart by name. The Pester exhaustiveness case names `test_every_top_level_key_is_classified_and_shared_by_both_copies` explicitly as the construct it mirrors. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | Python baseline 92.60% statements and 85.19% branches in `evidence/baseline/python-pytest-coverage.2026-08-21T22-51.md`. TypeScript baseline 96.66% lines and 90.04% branches in `evidence/baseline/typescript-jest-coverage.2026-08-21T22-52.md`. PowerShell baseline 96.21% lines in `evidence/baseline/powershell-poshqc-test.2026-08-21T23-03.md`. All three were captured in Phase 0 before any edit. |
| **No Coverage Regression** | PASS | The reviewer reran all three coverage commands at head `fc9a3a26`. Python post-change 92.60% statements and 85.19% branches from `artifacts/python/coverage.json` `totals.percent_statements_covered = 92.6032532298012` and `totals.percent_branches_covered = 85.18586005830903`, delta 0.00 and 0.00. TypeScript post-change 96.66% lines and 90.04% branches, delta 0.00 and 0.00. PowerShell post-change 96.21% lines from the root JaCoCo counter `LINE missed="228" covered="5792"`, delta 0.00. |
| **New Code Coverage** | PASS | The only changed production file is `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`, whose lcov record at head reads lines 468 of 468, that is 100.00%, and branches 46 of 48, that is 95.83%. The two Python modules and the changed PowerShell file are test code and sit outside the coverage denominator by construction. |
| **Comprehensive Coverage** | PASS | The 16 parity cases cover both contention directions against the published table, all three Class 1 keys, both Class 2 keys, Class 3, key-set exhaustiveness in both relations, the directional separator-free invariant, the five-name umbrella denylist across both copies, the separator-free wildcard constraint, the non-vacuity floor, and parse plus schema version across both copies. The 20 Pester cases mirror Class 1, Class 3, the denylist across both copies, the separator-free constraint, the directional invariant, and exhaustiveness. Two Jest cases cover the payload-module negative property and a layout-free publish. The residual scenario gaps in the PowerShell mirror are recorded in section 8 as CR-1 and CR-2. |
| **Positive Flows** — valid inputs | PASS | `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` asserts the positive contention verdict and additionally asserts presence of the `("shared_surface_overlap", "package-lock.json")` reason pair rather than only the boolean. Perturbation P8 confirmed it fails against the merge-base bundled document and passes at head. |
| **Negative Flows** — invalid inputs | PASS | `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table` asserts the negative verdict and prints the reason tuple on failure. Perturbation P8 confirmed the same fail-before and pass-after behaviour. The umbrella-denylist, payload-subset, exhaustiveness, and directional cases assert absence properties. |
| **Edge Cases** — boundary conditions | PASS | `test_every_separator_free_bundled_shared_surface_is_wildcard_free` first asserts the separator-free selection is non-empty so the wildcard loop cannot pass vacuously. `test_the_gate_compares_non_empty_collections` pins `len(COMMITTED_CONFIGS) == 2`, asserts six named collections are non-empty, and separately checks `mandate_reads` is a non-empty list because that key is compared by equality where two empty lists would agree. Perturbation P5 fired it. |
| **Error Handling** — error paths | PASS | `load_config_file` raises `TypeError` on a non-object root and `load_module_globs` raises `TypeError` on an absent or malformed `modules` key. Perturbation P3 demonstrated the raise path: renaming `shared_surfaces` produced `TypeError: config["shared_surfaces"] must be a list, got NoneType.` at import, failing the whole module loudly rather than passing vacuously. The change introduces no new failure path. |
| **Concurrency** — if applicable | N/A | No concurrent code path is introduced. The blast-radius library is pure and the push-down derivation is single-threaded. |
| **State Transitions** — if applicable | N/A | No stateful component is introduced. The change is read-only configuration data, one exported constant, and test code. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline: 92.60% statements -> Post-change: 92.60% statements. Change: 0.00 points on statements and 0.00 points on branches, branches holding at 85.19%. New/changed-code coverage: 100.00% of changed production lines, of which there are zero. Disposition: PASS. Evidence: `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T04-46.md` and `artifacts/python/coverage.json` regenerated at head `fc9a3a26`.
- TypeScript: Baseline: 96.66% lines -> Post-change: 96.66% lines. Change: 0.00 points on lines and 0.00 points on branches, branches holding at 90.04%. New/changed-code coverage: 100.00% lines and 95.83% branches on `claude-blast-radius-derive-core.ts`. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info` regenerated at head, record `SF:src\lib\push-down\claude-blast-radius-derive-core.ts` reading lines 468 of 468 and branches 46 of 48.
- PowerShell: Baseline: 96.21% lines -> Post-change: 96.21% lines. Change: 0.00 points on lines, with no branch figure because Pester measures command and line coverage only and no branch threshold applies to it. New/changed-code coverage: 100.00% of changed lines, of which zero are production lines. Disposition: PASS. Evidence: `artifacts/pester/powershell-coverage.xml` regenerated at head, root counter `LINE missed="228" covered="5792"`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Arrange-Act-Assert** | PASS | Every added Python and PowerShell case carries explicit `# Arrange`, `# Act`, and `# Assert` comments delimiting the three sections. The Pester exhaustiveness case uses two `# Act` blocks, one per accumulated list, which is a legible extension of the pattern rather than a departure from it. |
| **Actionable failure messages** | PASS | Measured, not inferred. The Python exhaustiveness case rendered `symmetric difference ['new_top_level_key']` under P1 and `unclassified keys ['new_top_level_key']` under P2. The Pester mirror rendered `Expected $null or empty, but got 'new_top_level_key'.` under both. Both accumulate into a list before asserting, so one run reports the whole delta. |
| **Descriptive names** | PASS | `test_every_top_level_key_is_classified_and_shared_by_both_copies` and its Pester counterpart `requires every top-level key in both copies to be classified and shared` both state the two relations they assert. |
| **Logical grouping** | PASS | Both new Pester cases sit in the existing `Context 'Cross-copy key partition'` block alongside the Class 1 and directional cases, which is the correct grouping for a cross-copy relation. |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **No external services** | PASS | Both Python modules read two committed JSON files at import time and start no process. The support module's docstring states this explicitly. The Pester file reads the same two committed files in `BeforeAll`. |
| **No temporary files** | PASS | `git diff fb30a9a5...HEAD -- tests/` matched no added line containing `tempfile`, `TestDrive`, `New-TemporaryFile`, `mkdtemp`, `os.tmp`, or `tmp_path`. |
| **No mutable global state** | PASS | The parsed configurations are module-level mappings read once. `PORTABLE_SHARED_SURFACES`, `PAYLOAD_MODULE_NAMES`, and `DECLARED_TOP_LEVEL_KEYS` are frozensets; `UMBRELLA_MODULE_NAMES` and `BYTE_EQUAL_KEYS` are tuples. |
| **Test file location** | PASS | `tests/scripts/dev_tools/test_blast_radius_config_parity.py` and `tests/scripts/dev_tools/blast_radius_parity_test_support.py` mirror `scripts/dev_tools/`. `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` mirrors `.claude/lib/blast-radius/`. The TypeScript test files mirror `src/lib/push-down/` under `test/lib/push-down/`. No test file is colocated in a production tree. |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Coverage exclusion policy** | PASS | The branch diff adds no `exclude`, `omit`, or `coveragePathIgnorePatterns` entry. No configuration file governing coverage is touched by the branch. |
| **Non-vacuity of added assertions** | PARTIAL | Six of the seven added assertions were driven to failure by a perturbation in this review. The seventh, the Pester non-vacuity floor added by R12, could not be driven to failure by the condition its comment names, because `@($null).Count` evaluates to `1` in PowerShell. Recorded as CR-1. |

---

## 2. General Code Change Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | The exhaustiveness gate is two set comparisons over the two parsed key sets. It introduces no new abstraction, no new accessor, and no new parsing path. |
| **Reusability** | PASS | `DECLARED_TOP_LEVEL_KEYS` reuses `BYTE_EQUAL_KEYS` rather than restating the Class 1 names. The gate imports `BUNDLED_CONFIG_LABEL`, `COMMITTED_CONFIGS`, and `load_config_file` from the pre-existing module rather than duplicating them. |
| **Extensibility** | PASS | The Class 3 relation is a subset rather than an equality, so shrinking `PAYLOAD_MODULES` does not require a lockstep test edit. The rationale is stated in the case docstring. |
| **Separation of concerns** | PASS | Plan deviation PD-1 holds the declared constants and the four accessors in `blast_radius_parity_test_support.py` and every assertion in `test_blast_radius_config_parity.py`. No assertion lives in the support module. |
| **File size limit (500 lines)** | PASS | Measured at head: `claude-blast-radius-derive-core.ts` 468; `blast-radius-derive-core.test.ts` 482; `blast-radius-derive.test.ts` 472; `claude-config-carriage.test.ts` 434; `config-carriage.test-helpers.ts` 224; `BlastRadius.TruthTable.Tests.ps1` 446; `blast_radius_parity_test_support.py` 180; `test_blast_radius_config_parity.py` 461. The untouched `test_blast_radius_config.py` remains at 499, which is what forced PD-1. |
| **Error handling and logging** | PASS | No new failure path is introduced. The gate's assertions fail with messages that name the repo-relative label of the offending copy, matching the established pattern. |
| **Naming** | PASS | Python names are `snake_case` for functions and `UPPER_SNAKE` for module constants. PowerShell locals use `camelCase`. TypeScript exports use `UPPER_SNAKE` for constants. |
| **Public API compatibility** | PASS | `PAYLOAD_MODULES` remains an exported `Readonly<Record<string, ReadonlyArray<string>>>`. Its value changed but its type and every call site are unchanged; `assembleModules` iterates `Object.entries(PAYLOAD_MODULES)` exactly as before. |
| **Dependencies** | PASS | No dependency is added. `package.json`, `package-lock.json`, `pyproject.toml`, and `poetry.lock` are untouched by the branch. |
| **I/O boundaries** | PASS | The only I/O added is reading two committed JSON files at test-module import. The contention relation itself remains pure. |
| **Mandatory toolchain loop** | PASS | Eleven stages executed in one uninterrupted sequence at head with no failure and no file rewritten, so no restart from formatting was required. Recorded in `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T04-46.md`. |
| **No policy-document modification beyond the sanctioned amendment** | PASS | The only file under `.claude/rules/` the branch touches is `parallel-orchestration.md`, which spec AC7 sanctions, together with its byte-identical bundled mirror. `cmp` over the pair exits 0. No file under `.github/instructions/` is touched. |

---

## 3. Language-Specific Code Change Policy Compliance

### Python

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Black formatting** | PASS | `poetry run black --check .` exit 0, `440 files would be left unchanged.` |
| **Ruff lint** | PASS | `poetry run ruff check .` exit 0, `All checks passed!` |
| **Pyright strict typing** | PASS | `poetry run pyright` exit 0, `0 errors, 0 warnings, 0 informations`. |
| **No suppressions added** | PASS | The branch diff contains no added line matching `noqa`, `type: ignore`, or `pyright: ignore`. |
| **Typed public surface** | PASS | The two new modules annotate every constant and every function signature. `DECLARED_TOP_LEVEL_KEYS` is a `frozenset[str]` by inference from two `frozenset` operands; the four accessors declare explicit parameter and return types. `cast("list[object]", value)` is used only after an `isinstance` narrowing. |
| **Docstring completeness** | PASS | Every added function and module carries a docstring with Purpose, Args, Returns, and where relevant Raises and Side Effects, matching the surrounding convention. |

### TypeScript

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Prettier formatting** | PASS | `npx prettier --check` over `src`, `test`, `*.json`, `*.cjs` exit 0, `All matched files use Prettier code style!` |
| **ESLint** | PASS | `npm run lint` exit 0, no output. |
| **tsc strict typecheck** | PASS | `npm run typecheck` exit 0, no output. |
| **No suppressions added** | PASS | The branch diff contains no added `eslint-disable`, `@ts-expect-error`, or `@ts-ignore`. |
| **No untyped escape hatch** | PASS | No `any` is introduced. The one changed production declaration retains its `Readonly<Record<string, ReadonlyArray<string>>>` annotation. |

### PowerShell

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Invoke-Formatter clean** | PASS | `Invoke-PoshQCFormat -Root .` exit 0; every scanned file reported `Already formatted:` and `git status --porcelain` was empty immediately afterwards. |
| **PSScriptAnalyzer clean** | PASS | `Invoke-PoshQCAnalyze -Root .` exit 0, `PSScriptAnalyzer passed: no findings under .` |
| **No analyzer suppression added** | PASS | The branch diff contains no added `SuppressMessage` attribute. |
| **Type checking** | N/A | PowerShell is exempt from the type-check stage by `.claude/rules/general-code-change.md`. |

### C#

| Requirement | Status | Evidence |
|------------|--------|----------|
| **All C# gates** | N/A | The branch changes zero C# files. `git diff --name-only fb30a9a5...HEAD` returns no path with a `.cs`, `.csproj`, or `.sln` extension. |

---

## 4. Language-Specific Unit Test Policy Compliance

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pytest naming and layout** | PASS | The parity module is `test_*.py` under `tests/scripts/dev_tools/`; the support module is `*_test_support.py`, which pytest does not collect, matching the `parallel_drift_test_support.py` convention already in that directory. |
| **Pytest parametrization over both copies** | PASS | `test_no_committed_copy_declares_an_umbrella_module` and `test_every_committed_copy_parses_and_declares_schema_version_one` are parametrized over `COMMITTED_CONFIGS`, and the non-vacuity floor pins `len(COMMITTED_CONFIGS) == 2` so the parametrization cannot silently narrow. |
| **Pester naming and layout** | PASS | `BlastRadius.TruthTable.Tests.ps1` sits under `tests/scripts/claude-lib/blast-radius/`, mirroring `.claude/lib/blast-radius/`, and uses the `Describe` / `Context` / `It` structure already established in the file. |
| **Pester ordinal comparison parity** | PASS | The added case uses `-cnotcontains`, matching the case-sensitive semantics of the Python frozenset comparison it mirrors, and consistent with the `-ccontains` and `-cne` forms the surrounding cases already use. |
| **Jest naming and layout** | PASS | The four changed TypeScript test files sit under `test/lib/push-down/`, mirroring `src/lib/push-down/`. |
| **Property-based tests** | N/A | `quality-tiers.yml` does not classify the changed modules as T1 or T2 pure-function modules requiring property density. The changed production surface is one exported constant. |
| **Mirror fidelity between language pairs** | PARTIAL | The Pester mirror asserts the same two relations as the Python exhaustiveness case, verified by perturbation. It does not reproduce the Python non-vacuity floor's coverage: an empty bundled `modules` map fires the Python floor and no Pester case, and an absent `shared_surfaces` key fires the Python floor and not the Pester floor. Recorded as CR-1 and CR-2. |

---

## 5. Test Coverage Detail

| Scope | Metric | Threshold | Observed | Status |
|---|---|---|---|---|
| Python repo-wide | line/statement | >= 85% | 92.60% | PASS |
| Python repo-wide | branch | >= 75% | 85.19% | PASS |
| TypeScript repo-wide | line | >= 85% | 96.66% | PASS |
| TypeScript repo-wide | branch | >= 75% | 90.04% | PASS |
| PowerShell repo-wide | line | >= 85% | 96.21% | PASS |
| PowerShell repo-wide | branch | no threshold applies | not measured by Pester | PASS |
| `claude-blast-radius-derive-core.ts` (modified production file) | line | >= 85% | 100.00% (468 of 468) | PASS |
| `claude-blast-radius-derive-core.ts` (modified production file) | branch | >= 75% | 95.83% (46 of 48) | PASS |
| New files added by the branch | line | >= 85% | not applicable; both added files are test code and are outside the coverage denominator | PASS |
| Changed lines, all languages | no regression | delta >= 0.00 | 0.00 in every language | PASS |

The branch adds two files, `tests/scripts/dev_tools/blast_radius_parity_test_support.py` and `tests/scripts/dev_tools/test_blast_radius_config_parity.py`. Both are test code, which `.claude/rules/general-unit-test.md` requires to be excluded from the coverage denominator. The new-file coverage threshold therefore has no production file to apply to on this branch.

Coverage artifacts inspected, all regenerated at head `fc9a3a26` during this review:

- Python: `artifacts/python/lcov.info` and `artifacts/python/coverage.json`
- TypeScript: `extensions/drm-copilot/coverage/lcov.info`
- PowerShell: `artifacts/pester/powershell-coverage.xml`
- C#: not applicable; zero changed C# files

The TypeScript coverage artifact resides at `extensions/drm-copilot/coverage/lcov.info` rather than at the repository root, because the TypeScript project root is `extensions/drm-copilot`. That is the path `npm run test:coverage` writes and the path the two prior audits in this feature folder used.

---

## 6. Test Execution Metrics

| Suite | Command | Result | Duration |
|---|---|---|---|
| Python, full | `poetry run pytest --cov=scripts.dev_tools --cov-branch ... -q` | 4078 passed, 5 skipped, 0 failed | 19.44s |
| Python, parity module alone | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py -q` | 16 passed | 0.08s |
| Python, parity plus base module | `poetry run pytest ...config_parity.py ...config.py -q` | 48 passed | 0.08s |
| Python, push-down contracts | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | 10 passed | 0.12s |
| TypeScript, full | `npm run test:coverage` | 195 suites, 2656 passed, 0 failed | 6.96s |
| PowerShell, full | `Invoke-PoshQCTest -Root .` | 3113 passed, 0 failed, 9 skipped | 131.83s |
| PowerShell, truth-table file alone | `Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 20 passed, 0 failed | about 1.2s |
| PowerShell, blast-radius folder | `Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/` | 383 passed, 0 failed | about 9s |

The five skipped Python tests are pre-existing parametrized manifest-accessor cases in `test_parallel_manifest_bash_parity.py` that declare no accessor expectation; none is related to this branch. The nine skipped Pester tests are likewise pre-existing.

The cycle-2 executor evidence records 4078 Python tests and 3122 Pester tests including disabled ones; both figures were reproduced exactly in this review.

---

## 7. Code Quality Checks

| Check | Status | Evidence |
|---|---|---|
| Formatting, all three languages | PASS | Black, Prettier, and `Invoke-PoshQCFormat` each exit 0 with zero files rewritten. |
| Linting, all three languages | PASS | Ruff, ESLint, and PSScriptAnalyzer each exit 0 with zero findings. |
| Type checking | PASS | Pyright 0 errors; `tsc --noEmit` exit 0. PowerShell is exempt. |
| Architecture-boundary tests | PASS | `test_push_down_claude_resource_contracts.py` reports `10 passed`, which is the boundary contract governing the bundled `.claude` payload. No dependency-cruiser or NetArchTest surface is touched. |
| Contract and schema compatibility | PASS | No JSON Schema file is authored, imported, or read for either truth table, as `.claude/rules/parallel-orchestration.md` requires. The two `orchestration-routing.json` copies are byte-identical, confirmed by `cmp` exit 0. |
| `modified-workflow-needs-green-run` | N/A, rule did not fire | Zero changed paths match `.github/workflows/**`, `scripts/benchmarks/**`, or `.github/actions/**`. |
| Orchestrator-state checkpoint | PASS | `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state artifacts/orchestration/orchestrator-state.json` exit 0, `orchestrator-state validation passed`. |
| Evidence-location validator | PASS | `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exit 0, no output. |
| Secrets | PASS | The branch adds no credential, token, connection string, or `.env` file. The two configuration files contain only path globs and a numeric fraction. |
| Unsafe subprocess or command construction | PASS | No added line invokes a subprocess, shell, or process-start API in any language. |
| Rule-mirror byte identity | PASS | `cmp .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` exit 0. |

---

## 8. Gaps and Exceptions

Six findings remain. None is Blocking. Each is stated with the corrective action a follow-up would take, so no re-derivation is needed.

### CR-1 — Major. The Pester non-vacuity floor cannot fail for the condition it names

`tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, the case `requires the shared-surface lists compared by the directional invariant to be non-empty` at lines 345 to 362. Its comment states that "A renamed shared_surfaces key would make the ... case above pass vacuously" and that the case guards against it. It does not. The guard reads `@($script:CommittedConfig['shared_surfaces']).Count` and asserts `Should -BeGreaterThan 0`. A hashtable index on an absent key yields `$null`, and `@($null).Count` is `1` in PowerShell, so the assertion holds for exactly the input it claims to reject. Measured under perturbation P4: with `shared_surfaces` renamed in the bundled copy, three other cases failed and this floor was among the seventeen that passed. The case can fail only for a key whose value is an explicitly empty list.

Corrective action: replace the count expression with a type-and-emptiness test that distinguishes an absent key from an empty list, for example asserting `$script:CommittedConfig.ContainsKey('shared_surfaces')` and that the value is an `IEnumerable` with at least one element, then re-verify by re-running perturbation P4 and observing the case fail.

Not Blocking because the Python floor `test_the_gate_compares_non_empty_collections` covers the renamed-key condition, the Python and PowerShell suites run in the same pipeline, and perturbation P4 showed three other Pester cases already fail loudly on the same input. The defect is a mirror-fidelity and comment-accuracy defect, not a detection hole.

### CR-2 — Major. The Pester mirror carries no non-vacuity floor for the bundled module map

Same file. Under perturbation P5, replacing the bundled `modules` value with an empty object fired the Python floor with `assert ()` and left the Pester file at 20 passed, 0 failed. `declares only payload modules in the bundled copy` passes because the empty set is a subset of `{config}`; `maps every module to a non-empty glob list` passes because it iterates zero modules. Divergence direction 13 from the cycle-1 enumeration, "a gate key is renamed so an accessor returns empty and the gate passes vacuously", therefore remains covered in Python only, which is the condition R12 was opened to remove.

Corrective action: extend the same floor case, or add one alongside it, asserting that both copies' `modules` maps declare at least one module.

Not Blocking for the same reason as CR-1.

### CR-3 — Minor. `DECLARED_TOP_LEVEL_KEYS` is one-third derived, and its Pester mirror is not derived at all

`tests/scripts/dev_tools/blast_radius_parity_test_support.py` lines 106 to 112. The constant is `frozenset(BYTE_EQUAL_KEYS) | frozenset({"shared_surfaces", "shared_surface_globs", "modules"})`. Only the Class 1 third is derived. The Class 2 and Class 3 key names are string literals restated in the constant and bound to no assertion, so adding a name to that literal set silences the exhaustiveness gate with no compensating check anywhere. The Pester mirror at line 311 restates all six names in `$declaredTopLevelKey`, so the "cannot go stale" property the commit message claims does not hold on the PowerShell side at all.

The failure modes are nevertheless safe rather than silent. Removing a name from `BYTE_EQUAL_KEYS` shrinks the derived set and makes the removed key unclassified, which fails loudly. Adding a name to `BYTE_EQUAL_KEYS` adds a real parametrized equality assertion for it. A key renamed in the schema becomes unclassified in both languages, which perturbation P2 confirmed fails loudly. The residual is therefore confined to a deliberate one-line edit of the Class 2 and Class 3 literal set.

Corrective action, if taken: derive the Class 2 and Class 3 names from module-level tuples that the Class 2 and Class 3 assertions themselves consume, so a name cannot appear in the declared set without an assertion reading it.

### CR-4 — Minor. `SOURCE_BLAST_RADIUS` claims a mirror relation nothing enforces

`extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` lines 61 to 110. The doc comment states the constant "mirrors the corrected bundled copy at `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` key for key". No test reads the committed resource. Under perturbation P9, appending an entry to the bundled `shared_surfaces` left all 15 push-down suites and all 195 suites of the full Jest run passing. This is a divergence direction outside the sixteen the cycle-1 re-audit enumerated.

Corrective action: assert equality between `JSON.parse(SOURCE_BLAST_RADIUS)` and the parsed committed resource in one Jest case, or read the resource file at test time instead of duplicating it.

The shipped document itself is not at risk: the Python and Pester gates pin the bundled file directly. What is unenforced is the fixture's claim to represent it.

### CR-5 — Minor. Two stale pointers survive in `spec.md` outside the acceptance-criteria section

`spec.md:388` states that the natural home for the fail-open regression is `tests/scripts/dev_tools/test_blast_radius_config.py`, and `spec.md:412` gives a Test Strategy toolchain command that selects `test_blast_radius_config.py` and `test_push_down_claude_resource_contracts.py` but not the parity module that carries the gate. Both predate plan deviation PD-1, which moved the gate into the parity module. Neither falsifies an acceptance criterion, because both sit in `## Test Strategy` and the criteria span lines 419 to 520. They are the same pointer-staleness class as R7 and would mislead a reader who follows the Test Strategy rather than the criteria.

By contrast `spec.md:391`, which cites `test_blast_radius_config.py:474-499`, is accurate: those lines hold `COMMITTED_CONFIGS` and the location-bucket case the gate extends.

Corrective action: point line 412's command at `tests/scripts/dev_tools/test_blast_radius_config_parity.py` alongside the other two modules, and qualify line 388 as the pre-PD-1 intent.

### CR-6 — Minor. The eighteen local-clock artifacts still sort before the work they postdate

`evidence/other/timestamp-clock-convention.2026-08-22T03-37.md` records the convention, the discrepancy, and the corrected count of eighteen, all of which this review confirmed by enumeration. The disposition is adequate for its stated purpose and R11 asked for exactly this. Two residuals persist. First, the eighteen filenames stamped `2026-08-21T21-49` sort before the Phase 0 baselines stamped `2026-08-21T22-47` through `22-52` that they in fact postdate by roughly three hours, so a reader ordering the evidence tree by filename reconstructs the cycle backwards. Second, the `Timestamp:` field inside each of the eighteen carries the same local value, so the discrepancy is not visible from any one artifact, and none of the eighteen points at the convention note.

Corrective action, if taken: add a one-line pointer to the convention note in each of the eighteen, which preserves every existing cross-reference by name.

### Accepted, previously recorded exceptions

- Divergence direction 5, a separator-bearing portable surface added to the self-hosted copy alone, remains uncovered. Confirmed still uncovered by perturbation P6. The decision remains defensible: `PORTABLE_SHARED_SURFACES` is a deliberate declaration, an unmatched surface entry is inert in a destination, and R9 has now qualified the mitigation sentence so the spec no longer overclaims.
- Divergence direction 8, a change to the self-hosted `shared_surface_globs`, remains uncovered in both languages. Confirmed by perturbation P7. Every self-hosted glob is a `scripts/dev_tools` pattern describing no destination, so an empty bundled list stays correct however the self-hosted list changes. Still defensible.
- Divergence direction 10 was recorded by the cycle-1 re-audit as uncovered by design. That entry was inaccurate. Perturbation P7 showed the pre-existing Pester case `retains exactly the seven ratified subsystem modules` fires on a self-hosted module addition. The correction is recorded here and in the code review.

### Correction to this reviewer's cycle-1 remediation inputs

R11 stated the local-clock artifact count as twenty. The measured count is eighteen. The cycle-2 convention note recorded the correction, and this review independently confirmed eighteen by enumerating `evidence/*/*2026-08-21T21-49*`. The error was this reviewer's.

---

## 9. Summary of Changes

The branch changes 12 non-documentation files and 104 documentation and evidence files.

| Area | Files | Substance |
|---|---|---|
| Published truth table | `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | `modules` reduced to `{"config": ["config/**"]}`, removing the `claude-runtime` umbrella; `shared_surfaces` widened from 3 to the 6-entry destination-portable set including three separator-free root filenames; `mandate_reads` widened from 6 to 10 entries to match the self-hosted copy |
| Self-hosted truth table | `config/blast-radius.json` | four `mandate_reads` entries added; `shared_surfaces`, `shared_surface_globs`, and `modules` unchanged, confirmed by the diff against the merge base |
| Payload modules | `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | `PAYLOAD_MODULES` reduced to `config` only, with an `@remarks` block stating why the `.claude` tree is not a module |
| Governing rule and its mirror | `.claude/rules/parallel-orchestration.md` and the bundled copy | new subsection "The published truth table is not a copy of this one", 63 added lines, byte-identical across the pair |
| Python drift gate | `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | 641 added lines carrying 16 cases: two contention regressions, three Class 1 parametrized cases, key-set exhaustiveness, two Class 2 cases, the directional separator-free invariant, Class 3, the umbrella denylist over both copies, the separator-free wildcard constraint, the non-vacuity floor, and the parse-and-version pin over both copies |
| PowerShell mirror | `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | 197 added lines carrying the Class 1, Class 3, denylist, separator-free, directional, exhaustiveness, and non-vacuity cases, plus the AC12 comment correction |
| TypeScript tests | four files under `test/lib/push-down/` | seeded module-map expectations updated, a negative payload-module property added, the AC8 forbidden-substring list corrected for ecosystem-standard lockfile names, and `SOURCE_BLAST_RADIUS` updated to the corrected bundled shape |
| Feature documentation and evidence | 104 files | issue, research, spec, three plans, two prior audit sets, and 81 evidence artifacts |

---

## 10. Compliance Verdict

**Verdict: PASS.**

Every mandatory gate is satisfied at head `fc9a3a26`:

- All eleven toolchain stages pass in a single uninterrupted pass across the three languages with changed files.
- Repo-wide line coverage is at or above 85% in all three coverage languages, and repo-wide branch coverage is at or above 75% in both branch-capable languages with changed files.
- The one modified production file reads 100.00% lines and 95.83% branches.
- Coverage delta against the Phase 0 baseline is 0.00 in every language and every metric.
- Every language with changed files carries an explicit PASS. No language with changed files is recorded as out of scope.
- All seventeen acceptance criteria in `spec.md` evaluate PASS, and all seventeen checkboxes are correctly checked. None was unchecked by this review.
- The `modified-workflow-needs-green-run` rule did not fire.
- The evidence-location validator and the orchestrator-state validator both exit 0.

**Blocking findings: 0.**

Two Major and four Minor findings remain, all recorded in section 8 and in the code review with concrete corrective actions. None of the remediation-triggering conditions in `.claude/skills/feature-review-workflow/SKILL.md` step 8 fired: the policy audit records no FAIL, the two PARTIAL entries are scenario-completeness observations already itemized as CR-1 and CR-2 rather than unmet mandatory gates, no toolchain check failed, the code review contains no Blocker, no acceptance criterion is FAIL or PARTIAL, no coverage threshold is breached, and no coverage artifact is absent. No remediation-inputs artifact was therefore produced and no third remediation cycle was opened. The decision to open one for CR-1 and CR-2 is available to the orchestrator; both are specified in full.

Cycle 2's five stated exit conditions are all met, including condition 5, `blocking_count == 0`.

**PR readiness: Go.**

---

## Appendix A: Test Inventory

### Added in this branch, Python (16 cases in `test_blast_radius_config_parity.py`)

| Case | Relation asserted | Driven to failure in this review |
|---|---|---|
| `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table` | fail-closed regression | Yes, P8 |
| `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table` | fail-open regression | Yes, P8 |
| `test_class_one_keys_are_equal_across_both_committed_copies[version]` | Class 1 equality | Yes, P8 for the `mandate_reads` parameter |
| `test_class_one_keys_are_equal_across_both_committed_copies[over_breadth_fraction]` | Class 1 equality | Covered by the same parametrization |
| `test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]` | Class 1 equality | Yes, P8 |
| `test_every_top_level_key_is_classified_and_shared_by_both_copies` | key-set equality and class coverage | Yes, P1 and P2 |
| `test_class_two_bundled_shared_surfaces_are_the_portable_set` | portable-set equality and subset | Yes, P8 |
| `test_class_two_bundled_shared_surface_globs_are_empty` | emptiness and subset | Not fired in this review; fires on a non-empty bundled glob list |
| `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` | reverse containment, separator-free | Yes, P4 and P8 |
| `test_class_three_bundled_modules_are_payload_modules_only` | Class 3 subset | Yes, P8 |
| `test_no_committed_copy_declares_an_umbrella_module[self-hosted]` | five-name denylist | Covered by the same parametrization |
| `test_no_committed_copy_declares_an_umbrella_module[bundled]` | five-name denylist | Yes, P8 |
| `test_every_separator_free_bundled_shared_surface_is_wildcard_free` | non-empty selection and no wildcard | Yes, P4 and P8 |
| `test_the_gate_compares_non_empty_collections` | non-vacuity floor | Yes, P5 |
| `test_every_committed_copy_parses_and_declares_schema_version_one[self-hosted]` | parse and version pin | Covered by the same parametrization |
| `test_every_committed_copy_parses_and_declares_schema_version_one[bundled]` | parse and version pin | Not fired in this review; fires on an unparseable or wrong-version copy |

### Added or extended in this branch, PowerShell (`BlastRadius.TruthTable.Tests.ps1`, 20 cases total)

| Case | Relation asserted | Driven to failure in this review |
|---|---|---|
| `declares equal values for the runtime-describing keys in both copies` | Class 1 equality | Yes, P8 |
| `declares only payload modules in the bundled copy` | Class 3 subset | Yes, P8 |
| `declares no removed umbrella module in either committed copy` | five-name denylist over both copies | Yes, P8 |
| `gives every separator-free bundled shared surface no wildcard` | no wildcard, bundled | Yes, P4 and P8 |
| `requires every separator-free self-hosted shared surface to reach the bundled copy` | reverse containment, separator-free | Yes, P3, P4, and P8 |
| `requires every top-level key in both copies to be classified and shared` | key-set equality and class coverage | Yes, P1, P2, P3, and P4 |
| `requires the shared-surface lists compared by the directional invariant to be non-empty` | non-vacuity floor | No. Recorded as CR-1 |

### Added in this branch, TypeScript

| Case | File | Relation asserted |
|---|---|---|
| `declares no umbrella or forbidden glob in the payload module set` | `blast-radius-derive-core.test.ts:466` | `PAYLOAD_MODULES` key set excludes `claude-runtime` and its glob set contains no `FORBIDDEN_GLOBS` member |
| `publishes no claude-runtime module into a layout-free destination` | `claude-config-carriage.test.ts:310` | a layout-free publish emits a module map whose keys exclude `claude-runtime` |

### Pre-existing suites exercised as regression evidence

- `tests/scripts/dev_tools/test_blast_radius_config.py`, 32 cases, unmodified by the branch and still passing.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, 10 cases, which enforce the byte-identical `.claude` payload mirror that AC8 depends on.

---

## Appendix B: Toolchain Commands Reference

All commands were executed from the worktree root `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-21T17-16` at head `fc9a3a26`, except the four TypeScript commands, which were executed from `extensions/drm-copilot`.

### Formatting

```
poetry run black --check .
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root ."
```

### Linting

```
poetry run ruff check .
npm run lint
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root ."
```

### Type checking

```
poetry run pyright
npm run typecheck
```

### Tests and coverage

```
poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json --cov-report=lcov:artifacts/python/lcov.info -q
npm run test:coverage
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root ."
```

### Targeted verification

```
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/test_blast_radius_config.py -q
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 -PassThru -Output None"
pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/blast-radius/ -PassThru -Output None"
node run-jest.cjs test/lib/push-down
```

### Validators and gates

```
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
poetry run python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state artifacts/orchestration/orchestrator-state.json
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts policy-audit docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T04-46-audit/policy-audit.2026-08-22T04-46.md
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts code-review docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T04-46-audit/code-review.2026-08-22T04-46.md
poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T04-46-audit/feature-audit.2026-08-22T04-46.md
```

### Byte-identity checks

```
cmp .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
cmp config/orchestration-routing.json extensions/drm-copilot/resources/config/orchestration-routing.json
```

### Perturbation battery

Each injection was applied with a short non-interactive Python edit of one committed JSON file, followed by the relevant suite, then `git checkout -- <path>` and `git status --porcelain` to prove the restore. The nine perturbations and their measured outputs are recorded in `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/qa-gates/reviewer-perturbation-battery.2026-08-22T04-46.md`. The tree was clean before the battery and clean after it.
