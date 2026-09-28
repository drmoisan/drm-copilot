# Code Review — Issue #452 v2 Regression Cycle

- Timestamp: 2026-09-27T16-03
- Branch: `bug/blast-radius-under-reporting-regression-452`
- Head: `f7b1acadf21bf9f510f294be2c8cde668eb1498a`
- Base: `origin/main`, merge-base `beae3f021674e64fa6662097fe48a332d8da62b8`
- Files reviewed in full:
  - `tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json` (605 lines)
  - `tests/scripts/dev_tools/test_blast_radius_regression_452.py` (487 lines)
  - `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` (290 lines)
- Production files changed: none (verified with `git diff --name-only origin/main...HEAD -- .claude scripts extensions config pyproject.toml .github`, which returned no output)

## Executive Summary

The change adds one shared regression corpus and two thin consumers, one per runtime that evaluates blast-radius contention. The corpus encodes the 17 cases of the spec Case List exactly: the reviewer compared ids, gap, kind, direction, `paired_case_id`, `doctrine_pin`, config source, plan lines, and expected reasons against `v2/spec.md` "Case List". The consumers assert only detection-level results (`conflicts` / `Test-BlastRadiusConflict`), which keeps the corpus valid whichever of #452 and #722 merges first.

The reviewer verified both consumers by execution:

- Python: 25 passed and 1 pre-authorized skip. black, ruff, and pyright are clean.
- Pester: 25 passed and 1 pre-authorized skip. PSScriptAnalyzer reports 0 findings.

The reviewer also confirmed the consumers detect regressions: flipping the expected verdict in memory for four cases not used in the executor's demonstration made the per-case test fail and name the flipped case each time.

Verdict: PASS. Blocking findings: 0. Minor findings: 3. Informational findings: 3.

## Correctness

### Corpus

- **Top-level shape.** `schema_version` 1, `issue` 452, a non-empty `description`, and 17 cases.
- **Gap 1 plan cases.** All five use `config_ref: self_hosted`. The four write cases use `- [ ] [P1-T1] Edit \`<path>\`.`. The doctrine pin uses `Read`. This matches the plan-line intent rule, so each harvested path is identical under the current extraction and under a write-intent-only extraction.
- **Gap 1 radius cases.** Both use inline `{"version": 1}`. The expected reasons match the spec: `path_overlap` "quality-tiers.yml ~ quality-tiers.yml" and `shared_surface_overlap` "quality-tiers.yml". The contention relation does not apply `mandate_reads`, so the declared-radius case conflicts while the Read-verb plan case does not. The corpus pins both behaviours.
- **Gap 2 cases.**
  - Both argument orders are covered for `scripts/dev_tools` and `artifacts/orchestration`.
  - Sibling-prefix controls (`dev_tools_extra/**`, `orchestration-archive/**`, `PoshQCExtra/**`) exercise the path-segment boundary.
  - The detail string is ordinal-smaller-first in both orders (`scripts/dev_tools ~ scripts/dev_tools/**`), which pins the canonical ordering of the reason detail.
- **Empty-modules case.** It supplies a module map that would match both radii, but the radii carry empty `modules` lists, and the expected reasons contain `path_overlap` only. This pins the property that the path level reports the overlap independently of the module level.

### Python consumer

- Repository-root resolution (`Path(__file__).resolve().parents[3]`) is correct for `tests/scripts/dev_tools/<file>.py` and does not depend on the working directory.
- The guard helpers narrow `object` values from `json.loads` to typed values without `Any`. This keeps pyright strict-clean with no suppression.
- `test_case_verdict_matches_corpus` asserts the verdict first, then the exact ordered `(kind, detail)` list. A reordering of reasons in a later rewrite would be detected.
- The pairing test enforces reciprocity for every must-conflict case. It also requires that the set of non-reciprocated controls equals the set of doctrine pins exactly, which is stricter than the spec's minimum.
- The plan-line intent regex builds the backtick from `chr(96)`, which avoids escaping ambiguity inside an f-string.

### Pester consumer

- The case list is built at discovery time and wrapped as `@{ CaseId; Case }`, which avoids a collision between the corpus `input` key and the automatic `$input` variable. The comment explains this.
- The verdict is read from `$result['conflict']`, not from the truthiness of the hashtable, which follows the spec note.
- Reasons are compared as one ordered `kind|detail` string with `-BeExactly`, so order and case are both enforced.
- The import order (facade first, then `BlastRadiusConfig.psm1`) is deliberate and commented. It prevents the facade's `-Force` sibling import from removing the config module's exported `Get-ConfigRootSurface`.

## Best-Practices Assessment

- **Simplicity.** Each consumer is flat: data load, a few validation helpers, and parametrized tests. No abstraction is introduced beyond what the two runtimes require.
- **Reusability.** One corpus drives both runtimes, so a single edit to an expected value is enforced in both.
- **Determinism.** All inputs are committed literals. `computed_at` values use the non-ISO `YYYY-MM-DDTHH-MM` shape and are validated by regex in both consumers.
- **Isolation from the environment.** There is no working-directory dependency, no git call, no subprocess, no temporary file, and no `artifacts/` read. The reviewer confirmed this with a grep; see the policy audit, section 1.
- **Merge-order independence.** Neither consumer references `compute_cohorts`, `pcoh_*`, drift detection, or the mutation protocol (reviewer grep returned no match).
- **File size.** Both consumers are under 500 lines. The Python consumer is at 487 (see CR-2).

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/dev_tools/test_blast_radius_regression_452.py`; `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` | Python `build_radii` / `contention_config` (lines 237-282); Pester `Detection-level verdicts` block (lines 252-267) | CR-1: The two consumers resolve the configuration differently for combinations the current corpus does not use. Python derives plan radii with the self-hosted table even when a plan case carries an inline `config`, while passing that inline table to `conflicts`. Pester reads `$Case['config']` for radius pairs, which would be `$null` for a radius pair using `config_ref`, and ignores an inline `config` on plan pairs. The case-shape meta-tests in both consumers accept either config source for either kind. | Add one meta-assertion in both consumers that pins the combinations in use (`plan_pair` requires `config_ref`; `radius_pair` requires inline `config`), or resolve the table through one helper per consumer that treats both kinds identically. | With the current corpus (every plan case uses `config_ref`; every radius case uses inline `config`), both consumers are correct and agree. The divergence would surface only if a later corpus edit used a new combination, and the two runtimes could then evaluate the same case under different tables. | Reviewer read of both files and of the corpus config fields for all 17 cases |
| Minor | `tests/scripts/dev_tools/test_blast_radius_regression_452.py` | whole file | CR-2: The file is 487 lines, 13 below the 500-line limit. The spec anticipates call-site updates here if #722 changes the `conflicts` or `derive_blast_radius` signature. | If #722 requires call-site changes that push the file over the limit, move the guard helpers (`require_mapping`, `require_list`, `require_text`, `load_json_object`) into a shared test-support module rather than compressing the tests. | Leaves headroom for the anticipated follow-up without a file-size violation. | `v2/evidence/qa-gates/final-line-counts.2026-09-27T15-55.md`; reviewer `wc -l` |
| Minor | `artifacts/python/lcov.info`, `artifacts/python/coverage.json` (untracked, not in diff) | plan tasks P6-T5, P6-T6, P6-T7 | CR-3: The canonical Python coverage artifacts on disk were last written by the narrower P6-T7 consumer-only run (lcov.info: 73.60% line, 48.55% branch over five modules) and the P6-T6 targeted run (coverage.json: 99.75% line, 99.28% branch). The repository-wide P6-T5 figures (92.97% / 85.68%) survive only in evidence text. | In future plans, run the repository-wide coverage command last, or send narrower runs to a non-canonical report path. | A reviewer reading the canonical artifact without the plan context would see a subset measurement. This does not affect the verdict here because no production file changed. | Reviewer parse of both artifacts; `v2/evidence/qa-gates/final-python-consumer-coverage.2026-09-27T15-41.md` |
| Informational | `tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1` | `param([hashtable] $CorpusOverride)` (lines 20-27, 34-40) | CR-4: The Pester file exposes a test-only override parameter used by the mutation demonstration. It is documented in the comment-based help and has no effect when unset. | None required. | It enables an in-memory mutation demonstration without writing a mutated corpus to disk, which satisfies the no-temporary-file rule. | `v2/evidence/regression-testing/phase4-pester-mutation-demonstration.2026-09-27T15-30.md` |
| Informational | `tests/scripts/dev_tools/test_blast_radius_regression_452.py` | lines 160-168 | CR-5: The corpus and both configurations are loaded at import time. A malformed corpus therefore surfaces as a collection error rather than as a named test failure. | None required. | The guard helpers name the corpus location in the error, so the failure is explicit. Loading at import is required for `parametrize` ids. | Reviewer read |
| Informational | both consumers | radius-pair routing | CR-6: Python deserializes declared radii through `BlastRadius.from_dict` (validating them), while Pester passes the raw hashtables to `Test-BlastRadiusConflict`. | None required. | Each consumer follows its runtime's production input contract; the Phase 0 three-way comparison shows identical verdicts for all 17 cases. | `v2/evidence/baseline/phase0-three-way-comparison.2026-09-27T14-59.md` |

## Toolchain Evidence

| Check | Result | Source |
|---|---|---|
| black `--check` (Python consumer) | 1 file unchanged | Reviewer run |
| ruff check (Python consumer) | All checks passed | Reviewer run |
| pyright (Python consumer) | 0 errors, 0 warnings | Reviewer run |
| pytest (Python consumer) | 25 passed, 1 skipped | Reviewer run |
| PSScriptAnalyzer (Pester consumer, repository settings) | 0 findings | Reviewer run through an `sh` wrapper |
| Invoke-Pester (Pester consumer) | 25 passed, 1 skipped, 0 failed | Reviewer run through an `sh` wrapper |
| PoshQC format | Hash unchanged across three runs | `v2/evidence/qa-gates/final-powershell-format.2026-09-27T15-43.md` |
| In-memory verdict flips (4 cases not used by the executor) | All 4 detected; the failure message names the case | Reviewer run of a scratchpad driver against `test_case_verdict_matches_corpus` |

## Overall Code-Review Verdict

PASS. The corpus and both consumers are correct, deterministic, isolated from the environment, and consistent with the spec's corpus contract. No production code is touched, and no enforcement hook, workflow, or configuration is changed.

Blocking finding count: 0.
