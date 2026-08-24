# Code Review: parallel-lane-scale-and-barrier-semantics (#479)

---

**Review Date:** 2026-08-17
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `eb4ce14c245ecff8a4491e4a8fda3e43e14356e3`)
**Head Branch:** `bug/parallel-lane-scale-and-barrier-semantics-479` (`e304f000b8f186643fb77c08adaa2c08847feeed`)
**Review Type:** Initial review

---

## Executive Summary

This branch fixes four defects that prevented the `parallel` orchestration surface from scheduling a 13-lane, 69-item work organization. D1 replaces the documented global cohort barrier with the per-edge rule both enforcement layers already implement, and generalizes the mutation engine's pinned-barrier offset (`highest_pinned_cohort + 1`) so recoloring stays sound when in-flight items span multiple cohort indices. D2 raises the `max_concurrency` ceiling from 8 to 32 across all three runtimes (Python, TypeScript, bash) with symmetric boundary tests and migrated out-of-range exemplars. D3 adds the optional, key-gated manifest invariant M8 (`expected_conflict_components`) with Python and bash parity plus a new pure diagnostic module `scripts/dev_tools/parallel_lane_assertion.py`. D4 is a prose-only bounded preparation fan-out. The scope is 110 files; production code changes are small and surgical, with the one new module at 499 lines carrying 100% line and branch coverage.

Evidence reviewed: full branch diff against the merge base, reviewer-executed toolchain runs (black, ruff, pyright, pytest, prettier, eslint, tsc, jest), direct parsing of the Python and TypeScript lcov artifacts, the CI shell-coverage run evidence (head-equivalent, verified), and per-AC mechanical gates. Implementation quality is high: consistent docstring discipline, key-gated backward compatibility proven by a byte-identity test, and deliberate separation of the advisory diagnostic from every scheduling path.

**What changed:**
Six bound constants (Python x3, TypeScript x2, bash x1) move from 8 to 32 with error-string parity; `recolor_unstarted` gains a required keyword-only `highest_pinned_cohort` parameter; `parallel_manifest_contract.py` gains three `_prefixed` M8 helpers appended after the existing M1-M7 pipeline; `parallel_lane_assertion.py` is new; eight `.claude` prose files are reworded to the per-edge barrier and re-synced byte-identically to their mirrors; test pins (`COHORT_BARRIER_FRAGMENTS`) move in the same commit as the prose they pin.

**Top 3 risks:**
1. The per-edge barrier prose now spans many restatements (skill, agent, add/remove skills, template); a future edit to one site can drift from the others. Mitigated by the `COHORT_BARRIER_FRAGMENTS` pin and the AC4 grep gate, but only the primary sentence is pinned.
2. `parallel_lane_assertion.py` sits at 499 of 500 lines; any future addition forces a split. Not a defect today.
3. The bash M8 implementation and the Python implementation are kept identical only by the shared 54-fixture corpus; a new M8 edge case added to one runtime without a fixture would not be caught. The corpus-floor test (bats ok 87) partially mitigates.

**PR readiness recommendation:** **Go** — zero Blockers and zero Majors; all toolchain gates pass and coverage is at or above every threshold.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/rules/parallel-orchestration.md` | `## Concurrency Bound (A7)`, second paragraph | Grammar: "The findings recorded here so that downstream features do not re-litigate them:" lacks a verb ("are recorded here"). | Optional one-word fix in a future prose pass; also re-sync the mirror if edited. | Cosmetic only; meaning is recoverable. Not worth a remediation cycle. | File inspection of the A7 section at HEAD. |
| Info | `.claude/worktrees/agent-afc9f4fd25ec235a5/` | machine state, not in diff | Live gitignored worktree (branch `feature/enforcement-hooks-must-not-invoke-python-475`, merged) causes the one local pytest failure in `test_push_down_claude_resource_contracts.py`. | Housekeeping outside the branch: `git worktree remove` the stale worktree. | The failure is environmental, absent in CI, and the test file is not in the diff; leaving the worktree will keep failing local full-suite runs. | Reviewer reproduction: assertion names `.agent_logs/atomic_executor_2026-08-15_151958.log`; `git worktree list` confirms the worktree. |
| Info | `artifacts/research/` | two untracked files | Standing evidence-location violations reported by `validate_evidence_locations.py` (untracked, predate the branch). | Delete or relocate to `docs/research/` as machine housekeeping. | Cannot ship in any PR; recorded per the established #331 disposition. | Validator run 2026-08-17, exit 1 with the two known paths. |

No Blockers, Majors, Minors, or Nits. The two housekeeping Info findings concern machine-local state outside the branch diff.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- **M8 is genuinely key-gated.** `_validate_expected_conflict_components` returns `[]` on key absence before any other work, and `test_the_error_list_is_byte_identical_to_the_pre_change_expectation` pins the byte-identity contract rather than merely asserting emptiness.
- **Single-report discipline.** `_declared_issue_nums` deliberately excludes malformed items so M6 reports each defect once and M8 does not duplicate it — with an intent comment explaining exactly that decision.
- **The offset generalization is minimal and honest.** `cohort_offset = highest_pinned_cohort + 1 if crosses_pinned else current_cohort` (`parallel_mutation_protocol.py:321`) is the entire behavioral change; the docstrings were rewritten to stop citing the global rule, and the required keyword-only parameter placement prevents silent transposition with the other `int` parameters.
- **The diagnostic module documents a module-wide purity contract** (every function except `main` is pure) instead of repeating boilerplate Raises/Side Effects sections, and honors it — the one mutation (`claimed`) is explicitly documented as MUTATED in its docstring.

#### Typing and API notes

- Full annotations throughout; `TypeGuard[int]` narrows positive ints; `cast("list[object]", ...)` is confined to the untyped-YAML boundary, matching the module's pre-existing pattern. Frozen dataclasses (`ExpectedComponent`, `LaneAssertionFinding`, `LaneAssertionReport`) model the report as values. Report classes are exposed as stable string tokens so consumers can group findings without parsing detail text.

#### Error handling and logging

- Validators accumulate error strings per the established contract; no exceptions are raised on malformed input, and no broad handlers were added. The CLI exits 0 whether or not findings exist — deliberate and documented, since the diagnostic is advisory and must never block a planning run. `print` appears only in `main`, the documented I/O boundary.

### TypeScript implementation audit

#### What changed well

- The change is exactly two one-line constant edits (`MAX_CONCURRENCY = 32` in each core), with error strings already templated on the constant so parity followed automatically. No new module, no `jest.config.cjs` threshold change needed.

#### Type safety and maintainability

- No suppression added; `tsc --noEmit` and ESLint clean. The three known Python/TS divergence classes (`pythonRepr` quote selection, integral floats, boolean `===`) are neither entered nor modified: `parallel-state-shared.ts` and `parallel-state-structures.ts` are absent from the diff, and the new boundary exemplars (33, "33") avoid all three divergence shapes.

#### Error handling and logging

- Unchanged beyond the embedded bound value; the templated error string keeps Python parity byte-exact over the shared corpus.

### Bash implementation audit (in place of an unused language subsection)

#### What changed well

- `PM_MAX_CONCURRENCY=32` plus an M8 leg that mirrors the Python error list fixture-for-fixture; the block-sequence-only value shape keeps M8 inside the bash YAML subset parser's capabilities (flow collections are rejected by design), and the acceptance case (bats ok 110) proves the mandated form parses.

#### API and safety notes

- shfmt and shellcheck green in CI with no suppression added; the library keeps the existing `pc_error_add` accumulation contract and field ordering.

#### Error handling and logging

- Parity verified by the corpus-wide bats case (ok 89: the bash lane reproduces every manifest corpus fixture) plus the Python-side parity suite (104 passed).

---

## Test Quality Audit

Automated evidence is comprehensive across all three affected runtimes and was independently re-executed where the environment allows (Python, TypeScript) and verified from head-equivalent CI evidence for bash. Coverage artifacts were parsed directly rather than trusted from summaries; the numbers matched the executor's recorded values exactly.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` — the AC12 regression discriminates the fix: with the pre-change `current_cohort + 1` expression the arranged state (pinned at indices {0,1}, `current_cohort == 0`) yields offset 1 and the `> 1` assertion fails; the delivered expression yields offset 2. Verified arithmetically against `parallel_mutation_protocol.py:321`. The AC13 identity regression pins the single-frontier equivalence.
- `tests/scripts/dev_tools/test_parallel_manifest_contract_m8.py` — full negative-path matrix plus the key-absent byte-identity test; three added tests cover the resolution-target degradation path that transiently dropped coverage during execution.
- `tests/scripts/dev_tools/test_parallel_lane_assertion.py` — isolated vertices, chains, the 13-lane transpose, and all four report classes; 100%/100% coverage on the module.
- `tests/fixtures/parallel_manifest_bash/` (54-fixture corpus) + `tests/shell/parallel_manifest_parity.bats` + `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` — the two-runtime byte-parity demonstration, including the corpus-floor guard against silent truncation.
- `evidence/qa-gates/final-shell-qc.2026-08-17T03-05.md` — CI run 31998496925, conclusion success, head SHA verified equal to the then-branch-head; the subsequent commits are documentation-only (reviewer-verified diff).
- `evidence/qa-gates/final-coverage-delta.2026-08-17T03-08.md` — per-language and per-file coverage deltas; every value re-derived by the reviewer from the lcov artifacts matched.

### Quality assessment prompts

- **Determinism:** all new tests are pure-function tests over constructed inputs; property tests use seeded Hypothesis strategies; no clock, RNG outside Hypothesis, network, or temp files.
- **Isolation:** one behavior per test; regression tests name the defective expression they discriminate against in their docstrings.
- **Speed:** 3887 Python tests in 8.37 s and 2555 Jest tests in 3.1 s on the reviewer's run.
- **Diagnostics:** list-equality assertions print both expected and actual error lists; cohort-index assertions compare small integers with scenario docstrings supplying context.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: constants, validators, prose, fixtures only; no credentials, tokens, or endpoints. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess use added; the diagnostic CLI reads a manifest path and an edge string via argparse only. |
| Input validation at boundaries | ✅ PASS | M8 validates shape, resolution, and duplication with one error per violated condition; `parse_edges` and `read_manifest_inputs` reject malformed CLI input with specific messages; booleans remain rejected for `max_concurrency` in all three runtimes. |
| Error handling remains explicit | ✅ PASS | No broad exception handlers added; validator error-list contract preserved; `recolor_unstarted` raises specific `ValueError`s on contract violations. |
| Configuration / path handling is safe | ✅ PASS | The diagnostic accepts an explicit manifest path and performs no directory traversal or writes; mirrors were re-synced byte-identically (hash-verified per pair). |
| Scheduling-influence isolation (D3 invariant) | ✅ PASS | `parallel_cohort_computation.py` unmodified; `parallel_lane_assertion` imported by no cohort-computation, validation, or mutation module; no checkpoint validator carries M8 logic. |

---

## Research Log

No external research was required. All review inputs were repository-internal: the branch diff, the feature folder's spec/plan/research/evidence set, the PR context artifacts, the policy rule files, and reviewer-executed toolchain runs.

---

## Verdict

The change is ready for the normal PR flow. All four defects are fixed in the smallest form the spec ratified: prose aligned to the already-enforced per-edge predicate with the one real code consequence (the pinned-offset generalization) handled and regression-locked in both directions; a symmetric three-runtime bound raise with exemplar migration; a strictly additive, assertion-only manifest seam with two-runtime parity; and a prose-only fan-out bound. The reviewer independently re-ran the Python and TypeScript toolchains, re-derived every coverage number from the artifacts, hash-verified all eight mirror pairs, and re-executed the mechanical AC gates; nothing disagreed with the executor's evidence. The three Info findings are a cosmetic grammar nit and two machine-local housekeeping items outside the branch diff; none warrants remediation. Recommendation: Go.
