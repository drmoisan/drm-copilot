# Code Review: Parallel planner ready-gate invariant P10 routing record (#532)

---

**Review Date:** 2026-10-02
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-23-parallel-parent-routes-on-a-band-nothing-produces-532`
**Feature Folder Selection Rule:** Only active feature folder changed on the branch; its `-532` suffix matches the branch issue number.
**Base Branch:** `main` (merge-base `74e1d6741485aa38c28fecbbc77ea169f31df0ef`; current `origin/main` `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`)
**Head Branch:** `bug/parallel-parent-routes-on-a-band-nothing-produces-532` @ `601675fbd23a17cfb5a95f390d91569fcbb05f38`
**Review Type:** Initial review (pass 1)

---

## Executive Summary

The branch closes the gap described in issue #532: the parallel parent was required to spawn each child orchestrator with the model from an item routing receipt that no stage produced. It adds ready-gate invariant P10 to the parallel planner checkpoint validators in Python (authoritative) and TypeScript (structural subset), a `## Complexity Assessment` procedure in the `parallel-plan` skill, and named band and receipt sources in the `parallel-orchestrate` skill and `parallel-orchestrator` agent. The production delta is small (two new modules of 251 and 225 lines, two call-site edits of four executable lines each); most of the diff is tests, runtime Markdown with mirrors, and evidence.

Evidence reviewed: the branch diff against the merge-base, the regenerated PR context (`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, head `601675fb`, 36 verification rows all `pass`), all feature evidence artifacts, and check-only re-runs of Black, Ruff, Pyright, Prettier, the targeted Pytest suites (217 passed), and the targeted Jest suites (110 passed). The implementation is correct against the spec FR2 table, reuses only the Claude helpers, preserves P7 ordering, and emits strings that match the plan's Fixed Values byte for byte.

**What changed:**
- `scripts/dev_tools/_parallel_planner_state_routing.py` (new): `validate_ready_item_routing` runs FR2 checks 1 to 10, delegating checks 3 and 7 to `_validate_complexity_assessments` and `_validate_model_routing_receipts` on a one-element list and rewriting the `Checkpoint ... #0` prefix. `_hashable_entry` (DEV-8) stringifies list/object band values so the helpers' `frozenset` membership tests cannot raise.
- `scripts/dev_tools/validate_parallel_planner_state.py`: `_validate_ready_gate` computes `entry_context` once and appends P10 errors after P7 errors for each item; comment and docstrings now qualify band optionality to "outside the ready gate".
- `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` (new) and `parallel-planner-state-core.ts`: the same call order with the FR3 subset.
- Six `.claude` runtime files plus mirrors; Python builders moved to a support module with a re-export; TS builders carry the three routing fields; a per-file Jest coverage threshold for the routing module.

**Top 3 risks:**
1. The Pester suites that read `.claude/skills/parallel-orchestrate/SKILL.md` have not produced a counted local run (DEV-2); confirmation depends on the CI poshqc job. Static inspection indicates the marker-binding constraints are intact.
2. An item admitted through `/parallel-add` records only `complexity_band` on the orchestrator checkpoint, while the parent-routing text names only the planner checkpoint and the kickoff `complexity` column as sources; the routing source for a mid-run admission is therefore not named in `parallel-orchestrate`.
3. The MCP (TypeScript) path does not enforce floor equality, resolved-model equality, or the disabled clamp. This is documented and pinned by tests, and Python remains authoritative, but a planner that validates only through MCP can still record a wrong `floor` or `model` (spec Risks row 2; Follow-up 2).

**PR readiness recommendation:** **Conditional Go** — no Blocker or Major finding; merge after the CI poshqc job is green on the PR head and the branch is updated against current `origin/main`.

**Blocking findings in this artifact: 0.**

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (Non-blocking) | `.claude/skills/parallel-orchestrate/SKILL.md` | lines 265-271 and 312-319; cross-ref `.claude/skills/parallel-add/SKILL.md` lines 59-62 | `parallel-add` step 2 records the admitted item's `complexity_band` on the orchestrator checkpoint "so ... the parent's model routing read[s] the same band", but `parallel-orchestrate` names only the planner checkpoint and the kickoff `## Item Summary` `complexity` column as band sources. An admitted item appears in neither, and it carries no `model_routing_receipt`. | File a follow-up to name the orchestrator-checkpoint `items[].complexity_band` as the band source for admitted items (with spawn-time `Resolve-DelegationModel` re-resolution), or record a receipt at admission. Not required by spec FR6/FR7 as written. | Without a named source the parent may fall back to the `opus` frontmatter default for admitted items, which is the defect class this issue addresses. | Diff inspection of both skills; `grep` of `parallel-add/SKILL.md` for `parallel-planner-state`, `kickoff`, `model_routing_receipt` returns no match. |
| Minor (Non-blocking) | `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts`; `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py` | n/a (missing case); production `parallel-planner-state-routing.ts` line 60 | No case covers an item whose `complexity_band` is absent while `complexity_assessment` and `model_routing_receipt` are present (expected: check 1 `found: None.` plus checks 5 and 9 with `complexity_band None.`). The two uncovered branch arms of `sameValue` (line 60) correspond to this input shape. | Add one shared-literal row per suite for the absent-band-with-objects case. | Pins the `None` rendering of checks 5 and 9 in both runtimes; branch coverage is already 92.59%, so this is a parity-pinning gap, not a threshold gap. | `evidence/qa-gates/ts-jest-coverage.2026-10-02T05-19.md` (uncovered line 60); test file inspection. |
| Info | `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` | lines 59-61 (`sameValue`) | Equality via `JSON.stringify` differs from Python `!=` for objects with different key order and for boolean/integer pairs (`True == 1`). Both are outside the verified JSON-round-trip scope. | Optionally note this under the existing divergence classes in `.claude/rules/parallel-orchestration.md` Enforcement bullet. No code change required. | Consistent with divergence class (3) already recorded for the parity port; affects only malformed band values. | Code inspection; rule text at `.claude/rules/parallel-orchestration.md` Enforcement section. |
| Nit | `.claude/skills/parallel-orchestrate/SKILL.md` | lines 265-271 and 312-319 | The band-and-receipt-source paragraph is duplicated verbatim in two sections. | Keep as is (plan P5-T4 requires both sections to state it); consider a cross-reference in a later edit. | Two copies must be kept in sync by hand. | Diff inspection. |
| Nit | `.claude/agents/parallel-planner.md`; `.claude/skills/parallel-plan/SKILL.md` | parallel-planner.md line 117; parallel-plan SKILL.md lines 489-490 | Field-list insertions were not reflowed: one line exceeds the file's prevailing wrap width, the other leaves `preparation_status`, on a line by itself. | Reflow in a later documentation edit (and copy to the mirrors). | Readability only; contract tests collapse whitespace and are unaffected. | Diff inspection. |
| Nit | `extensions/drm-copilot/test/lib/validate/parallel-state-test-support.ts`; `parallel-planner-state-core.test.ts`; `parallel-state-tolerated-edge-fields.test.ts` | support lines 39-121; core.test `buildItem`; tolerated-edge `buildPlannerItem` | Three copies of the planner-item builder now exist (shared support plus two local builders). | Consolidate onto the shared `buildPlannerItem`/`buildValidPlannerState` in a later test refactor. | Plan P2-T1 deliberately kept the local builders to avoid import collisions; duplication is test-only. | Diff inspection. |
| Info | `extensions/drm-copilot/src/lib/validate/parallel-planner-state-routing.ts` | line 40 | Local `BAND_ORDER` duplicates `VALID_COMPLEXITY_BANDS` in the core module. | None required; plan P4-T1 chose this to avoid an import cycle. A shared constant in `parallel-state-shared.ts` would remove the duplicate. | Two sources for the band enum in TS. | Code inspection. |
| Info | branch | n/a | Merge-base `74e1d674` is behind current `origin/main` `ef80c57d`. | Update the branch against `origin/main` before opening the PR and re-run CI. | PR diff and CI should reflect the current base. | `artifacts/pr_context.summary.txt` Base/Head section. |
| Info (pending CI) | `.claude/skills/parallel-orchestrate/SKILL.md` | lines 239-271 | Pester suites `enforce-parallel-drift-gate.Tests.ps1` and `checkpoint-hygiene-skill-contract.Tests.ps1` read this file; local counted run replaced by PoshQC MCP plus CI (DEV-2). Static check: the marker line (line 246) remains the first `parallel_checkpoint_path` line in `## Parallel-Mode Kickoff Parameter`, and no added line begins with `## `. | Confirm the CI poshqc job on the PR head, then check off AC-30, AC-35, P5-T24, P6-T32, P7-T10, P7-T17. | Authoritative Pester evidence is CI-only by operator rule. | `evidence/qa-gates/pester-parallel-skill-readers.2026-10-02T05-03.md`; `evidence/qa-gates/final-pester-parallel-skill-readers.2026-10-02T05-19.md`; `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` lines 238-261. |

No Blocker or Major findings. Blocking count: 0.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Checks 3 and 7 delegate to the existing Claude helpers, so the floor and resolver formulas exist in one place. `test_routing_helper_reuses_claude_helpers_only` asserts the imported objects are identical (`is`) to the defining modules' attributes and that neither Codex name appears in the module source.
- The error order matches the FR2 table: band enum; assessment object (helper errors, `assessed_at`, band mismatch); receipt object (helper errors, agent, band mismatch, `fable_policy`). Skip rules for checks 3-5 and 7-10 are implemented by the `isinstance(..., dict)` branches.
- `_validate_ready_gate` places `validate_ready_item_routing` immediately after `_validate_ready_item` for each item (`validate_parallel_planner_state.py` lines 397-400), so P7 ordering is unchanged and P10 follows P7. `REQUIRED_ITEM_KEYS` is unchanged and pinned by `test_required_item_keys_unchanged`.
- DEV-8 is a correct, minimal fix: `_hashable_entry` copies the entry and stringifies only list or dict values of the keys the helpers test by `frozenset` membership. `str(['C3'])` renders identically to the helper's f-string, and the result is never a valid band.
- All 17 plan Fixed Values literals occur verbatim in the Python suite (verified programmatically by this review).

#### Typing and API notes

- One new public function, `validate_ready_item_routing(record: dict[str, object], entry_context: str) -> list[str]`. No `Any`, no suppressions; Pyright reports 0 errors. Constants are typed (`tuple[str, ...]`).

#### Error handling and logging

- The helper performs no I/O and raises nothing for malformed input. The reused `resolve_delegation_model` contains no `raise`, so unknown `agent` or `fable_policy` strings produce error strings rather than exceptions.

### TypeScript implementation audit

#### What changed well

- The structural subset emits the same strings as Python for every shared check; all 15 shared literals in the TS suite equal the Python constants byte for byte (verified programmatically). The three Python-only checks are pinned as divergences that yield no TS error.
- The module imports only `./parallel-state-shared`, avoiding a cycle with the core validator. A header comment records the deliberate divergence and names Python as authoritative.

#### Type safety and maintainability

- Inputs are `unknown` and narrowed through `isObject` and `isEnumMember`; no `any`, no casts in production code, no ESLint suppression. File length 225 lines.

#### Error handling and logging

- Never throws; returns an array. `pythonRepr` renders `undefined` as `None`, matching Python for absent keys.

---

## Test Quality Audit

Fail-before evidence exists for both runtimes against the unmodified validators (`evidence/regression-testing/python-fail-before.2026-10-02T04-33.md`, `ts-fail-before.2026-10-02T04-35.md`, each showing an empty error list and an empty `git diff --stat` for the validator), followed by pass-after runs. Coverage of new production code is 100% lines in both languages, with 100% (Python) and 92.59% (TS) branches.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_parallel_planner_state_routing.py` — 18 functions, 29 cases; every FR2 check has an exact-string assertion; ordering and skip-rule tests use precise counts rather than substring presence alone.
- `extensions/drm-copilot/test/lib/validate/parallel-planner-state-routing.test.ts` — 22 cases mirroring the Python suite, plus direct calls and three divergence pins.
- `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py` — 7 text-contract tests with section extraction and whitespace collapse.
- `tests/scripts/dev_tools/parallel_planner_state_builders.py` — deep-copied routing fields; the importers `test_validate_parallel_planner_state_bounds.py`, `test_validate_parallel_state_tolerated_edge_fields.py`, and `test_validate_orchestration_artifacts_parallel_dispatch.py` are unedited and pass.
- `evidence/qa-gates/python-coverage-delta.2026-10-02T05-19.md`, `ts-coverage-delta.2026-10-02T05-19.md` — no regression; zero changed executable lines uncovered.

### Quality assessment prompts

- **Determinism:** Pure functions over literal fixtures; no time, randomness, network, or temporary files.
- **Isolation:** One behavior per test or parametrized row; fresh fixtures per test.
- **Speed:** 29 Python cases in 0.08s; 110 Jest cases in 0.394s.
- **Diagnostics:** Assertions print the full error list on failure; literal constants make string drift visible.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials or tokens added. |
| No unsafe subprocess or command construction | N/A | No subprocess use in the changed code. |
| Input validation at boundaries | PASS | All checkpoint values are treated as untrusted JSON; type narrowing precedes every comparison; unhashable values are neutralized before helper calls. |
| Error handling remains explicit | PASS | Validators return explicit error strings; no silent catch. |
| Configuration / path handling is safe | PASS | No path or file I/O added to production code; contract tests read committed files relative to the repository root. |
| No Codex receipt family | PASS | `grep` for `validate_codex_model_routing_receipts` and `resolve_codex_deployment` matches only the module docstring sentence and the test assertions. |

---

## Research Log

No external research was required. All conclusions derive from the repository diff, the feature evidence, the regenerated PR context, and the check-only re-runs listed in the policy audit Appendix B.

---

## Verdict

The change is correct and well tested. The Python helper implements the FR2 table in order with the required skip and cross-check semantics, reuses only the Claude helpers, and cannot raise on malformed input. The TypeScript subset matches Python strings exactly for the checks it performs and pins the documented divergence. File sizes, typing, docstrings, mirror parity, and coverage meet policy.

The PR is ready for normal flow after the CI poshqc job confirms the two Pester suites and the branch is updated against current `origin/main`. The two Minor findings (admitted-item routing source; absent-band parity case) are suitable for follow-up and do not block this issue's acceptance criteria.
