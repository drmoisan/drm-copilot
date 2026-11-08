# Code Review: epic wave-computation push-down (#1129)

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-epic-plan-cites-unshipped-wave-computation-script-1129`
**Feature Folder Selection Rule:** Named by the caller and matching the issue number 1129.
**Base Branch:** `origin/main` (merge base `cdcff3871765396183590128e142a929cf78327b`)
**Head Branch:** `bug/epic-wave-computation-pushdown` (`df8d43daaf9b617c8fbee844021919f1c2c70af8`)
**Review Type:** Reaudit after remediation cycle 1

---

## Executive Summary

Cycle 1 fixed the two Minor findings that bore on delivered behavior. F1: the PowerShell CLI now parses the manifest with `ConvertFrom-Json -AsHashtable`, and `ConvertTo-EpicWaveManifest` accepts an `IDictionary`, so keys that differ only by case stay distinct as in the Python reference. F2: the citation test now normalizes `scripts.dev_tools.<module>` and `./`-prefixed citations, scans eight Claude and seven Codex epic surfaces, and pins those sets to a glob of the tree. The wider scan found one real unshipped citation in `.claude/skills/epic-progress-report/SKILL.md`, which the cycle repaired with a two-line edit.

I verified by execution: the real CLI under `pwsh` on `{"a":[],"A":["a"],"b":["A"]}` (exit 0, `{"A":1,"a":0,"b":2}`) and on a dangling reference (exit 1 with the unresolved message); the two cycle-1 Python test files (19 passed); `cmp` equality of the three `EpicWave.psm1` copies and the two `epic-progress-report` copies; `validate_evidence_locations.py` (exit 0); and `git merge-tree --write-tree origin/main HEAD` (exit 0). No blocking finding was found.

**What changed in cycle 1:** `EpicWave.psm1` (parse and shape check, 17 lines) and both byte-equal copies; the `epic-progress-report` SKILL last bullet and its bundle copy; one corpus case, one CLI fixture, three Pester cases, and the citation test (extractor, surfaces, three tests).

**Top 3 risks:**
1. AC11 (full toolchain on CI and the PR statement about refreshing the push-down) cannot be verified until the pull request exists.
2. The error precedence for a manifest holding both a cycle and an unresolved reference still differs between the implementations; it was deliberately left out of cycle 1.
3. An absolute-path citation such as `/repo/scripts/x.py` is still not seen by the extractor because the lookbehind excludes `/`.

**PR readiness recommendation:** **Go** — all verifiable ACs are met with execution-level evidence, and the remaining observations are non-blocking.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/lib/epic-wave/EpicWave.psm1` | `Invoke-EpicWaveCommand` lines 201-204; `ConvertTo-EpicWaveManifest` lines 155-165 | Prior F1 is closed. `-AsHashtable` yields a case-sensitive map; the shape checks (non-object, non-array value, non-string item) are preserved against `IDictionary`; keys are copied into an ordinal dictionary. The help text now states that keys are parsed case-sensitively. | None. | The module help claim now holds for the CLI route as well as `Get-EpicWaveNumber`. | Reviewer probe: `{"a":[],"A":["a"],"b":["A"]}` printed `{"A":1,"a":0,"b":2}` with exit 0; the corpus case `case-variant-keys` expects `{"a":0,"A":1}` in both lanes; Pester cases and fixture `cli-case-variant-manifest.json` added; `rem1-ps-pester` EXIT_CODE 0. |
| Info | `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` | `_PATH_PATTERN`, `_MODULE_PATTERN`, `CLAUDE_SURFACES`, `CODEX_SURFACES`, `test_epic_surface_sets_cover_every_epic_surface_in_tree` | Prior F2 is closed. The extractor was only broadened: an optional `(?:\./)?` prefix and a new module-form pattern; the lookbehind, character classes, allowlist, reason test, and stale test are unchanged. The surface tuples equal the glob expansion of `epic-*` skills, `review-epic`, and `epic-*` agents for each runtime, and the new test fails when a surface exists that a tuple omits. | None. | Nothing was narrowed; the guard now reaches the defect class named by the spec. | Diff `ef5f602e2..HEAD`; two new in-memory tests for the module form and the `./` prefix (including `../scripts/up.py` still ignored); the 19-test focused run passed. |
| Info | `.claude/skills/epic-progress-report/SKILL.md` | last bullet, lines 454-455 | The edit is confined to one bullet. It replaces the repository path `scripts/dev-tools/Get-EpicProgressReport.ps1` (not shipped in the pack) with "a repository-only wrapper", keeping the statement that the skill always invokes the canonical script. The bundle copy is `cmp` equal. | None. | The skill still names the canonical script elsewhere; only the unshipped path was removed. No test or script reads the removed sentence: a repository search for the old text and for `forwards every argument` returns nothing outside `docs/`, and the wrapper's own Pester file targets the script, not the skill text. `EpicProgressReport.SkillContract.Tests.ps1` (22 tests) is green in `rem1-ps-pester` and asserts the tool grants and structure, which this bullet does not touch. | `git diff ef5f602e2..HEAD -- .claude/skills/epic-progress-report/SKILL.md`; Grep result; `cmp` against the bundle copy. |
| Minor | `.claude/lib/epic-wave/EpicWave.psm1` and `scripts/dev_tools/epic_wave_computation.py` | `Get-EpicWaveNumber` and `compute_wave_numbers` | Carried from the prior review (its second Minor finding). PowerShell checks every self-loop, then every unresolved reference, then cycles. Python checks references lazily during traversal, so `{"b":["a"],"a":["b"],"c":["ghost"]}` yields a cycle error in Python and the unresolved-reference error in PowerShell. Remediation inputs for cycle 1 excluded it. | Either validate all references before recursing in Python or add a mixed-error corpus case with an agreed expectation. | Both reject the manifest, so safety holds; only the message differs. | Prior reviewer probe; unchanged code. Non-blocking. |
| Minor | `tests/scripts/dev_tools/test_epic_skill_script_citations_shipped.py` | `_PATH_PATTERN` lookbehind | An absolute-path citation (`/repo/scripts/x.py`) remains invisible because the lookbehind excludes `/`. Cycle 1 closed the `./` and module forms named in the remediation inputs. | Optionally accept an absolute prefix if a surface ever cites one. | No scanned surface cites an absolute script path today (the test passes on all 15 surfaces); the omission is narrower than the original finding. | Pattern source; focused test run. Non-blocking. |
| Info | `tests/fixtures/epic_wave/wave-computation-cases.json`, `tests/scripts/dev_tools/test_epic_wave_corpus_parity.py`, `tests/scripts/claude-lib/epic-wave/EpicWave.Parity.Tests.ps1` | corpus and required-case lists | The corpus gains `case-variant-keys`; the required-case list and the Pester minimum count move from eight to nine in step. Existing assertions are unchanged or stronger. | None. | No test was removed or loosened. | Cycle diff. |

No Blockers or Major findings. No covered file reaches 700 logical lines (largest edited: citation test, 344), so no file-size Warning applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Cycle 1 changed no production Python file. The test helper `_glob_surfaces` has a docstring, an intent comment above its comprehension, and no suppression.

#### Typing and API notes

- Full annotations; `Mapping` and `Sequence` imported under `TYPE_CHECKING`; Pyright and Ruff record EXIT_CODE 0.

#### Error handling and logging

- Assertion messages name the unshipped citations and the allowlist entry.

### TypeScript implementation audit

No TypeScript file changed in cycle 1. The cycle-0 review stands: the `VIRTUAL_RESOURCE_DIRECTORIES` entry mirrors the Python constant and has a Jest test.

### PowerShell implementation audit

#### What changed well

- The case-sensitive parse is a two-line change in `Invoke-EpicWaveCommand` and a type test change in `ConvertTo-EpicWaveManifest`; the ordinal dictionary and shape checks are unchanged.
- The comment above `ConvertFrom-Json` states why `-AsHashtable` is used.

#### API and safety notes

- `-AsHashtable` requires PowerShell 7+, which the module already requires. The exit code contract (0, 1, 2) is unchanged and tested.

#### Error handling and logging

- Invalid JSON still maps to exit 2 with the `EPIC_WAVE_USAGE:` prefix.

---

## Test Quality Audit

Cycle 1 tests discriminate. The case-variant case fails against the pre-fix parser (which exits 2 on such input, per the prior probe), the module-form and `./` tests fail against the old extractor (it returned no paths for those forms), and the glob test fails when a tuple omits a surface.

### Reviewed test and QA artifacts

- `evidence/qa-gates/rem1-py-pytest.2026-11-08T15-39.md` — 16559 passed, 0 failed; named tests green.
- `evidence/qa-gates/rem1-ps-pester.2026-11-08T15-34.md` — 19708 tests, 0 failures; `EpicWave.Tests.ps1` 27, `EpicWave.Parity.Tests.ps1` 10.
- `evidence/qa-gates/rem1-coverage-delta.2026-11-08T15-39.md` — `EpicWave.psm1` 100% (56/56); repo-wide Pester 95.57%, Python 97.11% lines and 94.36% branches against baselines 95.56% and 97.11% / 94.37%.
- `evidence/qa-gates/self-review.2026-11-08T15-39.md`.

### Quality assessment prompts

- **Determinism:** committed fixtures and in-memory strings only; no temp file, clock, or network.
- **Isolation:** one behavior per test.
- **Speed:** in-memory; gates ran in parallel.
- **Diagnostics:** failure messages name offending paths.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | `rem1-ps-leak-scan` EXIT_CODE 0. |
| No unsafe subprocess or command construction | ✅ PASS | The module spawns nothing; the hook pattern is unchanged this cycle. |
| Input validation at boundaries | ✅ PASS | Non-object, non-array, and non-string inputs still exit 2; the hashtable type check replaces the object type check. |
| Error handling remains explicit | ✅ PASS | Prefixes and exit codes unchanged. |
| Mirror and bundle parity | ✅ PASS | `cmp` equal for `EpicWave.psm1` in the Claude bundle and `resources/lib/epic-wave/`, and for the `epic-progress-report` SKILL. |
| No gate weakened, extractor and allowlist not narrowed | ✅ PASS | Cycle diff shows additions only to the extractor, surfaces, corpus, and tests. |
| Branch currency | ✅ PASS | `origin/main` equals the merge base; `git merge-tree --write-tree origin/main HEAD` exited 0. |

---

## Research Log

No external research was required; the review relied on repository files, `git diff`, and local execution.

---

## Verdict

F1 and F2 are fully closed. The `epic-progress-report` edit is confined to one bullet, correct (the canonical script remains the invoked path), and its skill-contract test is unaffected and green. The extractor and allowlist were broadened, not narrowed; mirrors are byte-equal; no gate was weakened. Two Minor observations remain and do not block. The pull request must carry the statement that destinations refresh the push-down after an extension rebuild and reinstall, and CI must be green before AC11 is checked.
