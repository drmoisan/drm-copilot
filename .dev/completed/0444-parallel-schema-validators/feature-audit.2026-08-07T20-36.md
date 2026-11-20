# Feature Audit — parallel-schema-validators (Issue #444)

- **Date:** 2026-08-07T20-36
- **Feature folder:** `docs/features/active/2026-08-07-parallel-schema-validators-444`
- **Epic:** `parallel-orchestration`, child feature F3, wave 1

## Scope and Baseline

- **Branch under review:** `feature/parallel-schema-validators-444`
- **Base branch:** `epic/parallel-orchestration-integration` (the epic integration branch, not `main`)
- **Merge base:** `ae6331f7693fb7c05e2c5c7f8416c46c469929fa`
- **Feature commit:** `3eb6b348` — `feat(parallel): add parallel manifest and checkpoint schemas with validators`
- **Diff command:** `git diff ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD`
- **Diff size:** 64 files changed, +11538 / -114
- **Work mode:** `full-feature`, read from the persisted marker at `issue.md` line 12
  (`- Work Mode: full-feature`). Under this mode the authoritative acceptance-criteria sources are
  `spec.md` and `user-story.md`.
- **PR context artifacts:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`
  were absent at review start and were regenerated against the resolved merge base with
  `poetry run python -m scripts.dev_tools.pr_context.collector --base ae6331f7693fb7c05e2c5c7f8416c46c469929fa --head HEAD --repo-root .`
- **Evidence discovered:** 21 artifacts under
  `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/{baseline,other,qa-gates}/`,
  all in canonical locations.

Scope is the full feature-versus-base diff. No caller instruction narrowed it, and no language with
changed files was excluded from verification.

## Acceptance Criteria Inventory

| Source | Section | Items |
| --- | --- | --- |
| `spec.md` | `## Acceptance Criteria` | 19 (SA1-SA19) |
| `user-story.md` | `## Acceptance Criteria` | 13 (UA1-UA13) |
| **Total** | | **32** |

Other checkbox sections were not treated as acceptance criteria, consistent with the repository
convention: `spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)`, and
`issue.md` `## Acceptance Criteria (early draft)` and `## Test Conditions to Consider`, remain
unchecked. The same convention is observed in the already-merged wave-0 sibling
`docs/features/active/2026-08-07-parallel-cohort-scheduler-445/spec.md`, whose Definition of Done is
likewise unchecked.

## Acceptance Criteria Evaluation

### `spec.md` — 19 criteria

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| SA1 | `parallel_manifest_contract.py` exposes `validate_parallel_manifest_text` plus both accessors and enforces M1-M7 with LF/CRLF/CR tolerance | PASS | File exists, 312 lines. `validate_parallel_manifest_text` at line 274; `manifest_mode` at 182 returns `DEFAULT_MODE = "closed"`; `manifest_max_concurrency` at 206 returns `DEFAULT_MAX_CONCURRENCY = 4`. `LINE_ENDING_PATTERN = re.compile(r"\r\n|\n|\r")` at line 80 with the alternation ordered so `\r\n` is consumed as one terminator. 28 tests in `test_parallel_manifest_contract.py` pass. |
| SA2 | `validate_parallel_orchestrator_state.py` exposes the keyword-only entry point and enforces 1-19 unconditionally, 20-21 only under `require_complete` | PASS | Signature at line 285: `(text: str, *, require_complete: bool = False) -> list[str]`. `_validate_completion` is called only inside `if require_complete:` at line 334. Verified by execution: the same valid document returns `[]` with the flag off and the completion errors with it on. |
| SA3 | The entry point contains a delimited, appendable F7 seam for the Layer-2 cohort-ordering invariant | PASS | Lines 325-332: `# BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` through `# END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION`, with an interior comment stating that F7's edit is one appended `errors.extend(...)` call. All existing helper calls sit above the block. The TypeScript core carries the matching seam at lines 307-314. |
| SA4 | `validate_parallel_planner_state.py` enforces P1-P4 unconditionally and P6-P9 only under `require_ready_for_execution`, including the sentinel and the kickoff path | PASS | Signature at line 406. `_validate_ready_gate` is called only inside `if require_ready_for_execution:` at line 447. `READY_NEXT_STEP = "PARALLEL_EXECUTION_READY"` at line 91; `KICKOFF_PATH_TEMPLATE = "artifacts/orchestration/parallel-kickoff-{slug}.md"` at line 104. Verified by execution across 8 planner documents. |
| SA5 | `_parallel_state_common.py` and `_parallel_state_structures.py` exist and hold the S4 enums and shared validators; every new production and test file is at or under 500 lines | PASS | Both exist (495 and 496 lines). All nine S4 enums are declared in `_parallel_state_common.py` lines 39-88. `wc -l` over all 34 non-Markdown files in the diff gives a maximum of 499. The record validators live in `_parallel_state_records.py` for the size cap and are re-exported by `_parallel_state_structures.py` (`__all__` at lines 50-62), so the named module remains the caller-facing surface. |
| SA6 | All nine S4 enums are enforced with exactly the specified member sets | PASS | Counts verified against the source tuples: item `state` 8, `merge_status` 8, `mode` 2, `kind` 2, `blast_radius.source` 3, `conflict_edges[].reason` 4, `mutations[].op` 4, `mutations[].disposition` 2 plus null, `drift_events[].action` 2. `test_invariants_6_and_7_enums_match_the_spec_member_sets` additionally asserts the S8 replacements (`merge_conflict` and `blocked_conflict_loop_limit` absent, `blocked_drift` and `blocked_ci_loop_limit` present). |
| SA7 | `mutations[]` validated to the full S5 shape including op-specific null rules, invariant 17, and the generation bound | PASS | `_validate_mutation_item_key` (null for `close`, resolving for `add`/`remove`/`requeue`), `_validate_mutation_state_field` applied to both fields with `OPS_REQUIRING_NULL_PRIOR_STATE = ("add", "close")` and `OPS_REQUIRING_NULL_NEW_STATE = ("close",)`, `_validate_mutation_disposition`, `_validate_mutation_generation`. Executed: a `remove` with `prior_state: in_flight` and null disposition is rejected; a `close` carrying an item key, a prior state, and a new state produces three errors. |
| SA8 | `drift_events[]` validated to the full S6 shape | PASS | `validate_drift_events` checks resolving `item_key`, list-of-non-empty-string `declared` and `observed`, a non-empty `escaped_paths` list, non-empty `at`, and the A8 action enum. Executed: an event with an unresolved key, a non-list `declared`, an empty-string `observed` entry, an empty `escaped_paths`, an empty `at`, and an out-of-enum action produces six errors. |
| SA9 | `conflict_edges[]` validated to the full S7 shape | PASS | `_validate_edge_endpoints` enforces resolution, distinctness, and `a < b` normalization; `validate_conflict_edges` adds the reason enum and a duplicate-pair pass in ascending order. Executed: `(11, 10)` yields the normalization error, `(10, 10)` yields the self-edge error, and a repeated `(10, 11)` yields `has duplicate conflict_edges[] pair: (10, 11).` |
| SA10 | Both validators reject `depends_on` at any level and reject `integration_branch` / `epic_merge_pr`; the manifest rejects `depends_on` at any level and `integration_branch` at top level; negative tests cover each | PASS | `PROHIBITED_ANY_LEVEL_KEYS = ("depends_on", "integration_branch", "epic_merge_pr")` scanned depth-first over the whole document. The manifest uses `MANIFEST_DEEP_PROHIBITED_KEYS = ("depends_on",)` plus `MANIFEST_TOP_LEVEL_PROHIBITED_KEYS = ("integration_branch",)`. Executed: `depends_on` nested at `items[0]` yields `Parallel checkpoint carries prohibited key 'depends_on' at items[0].`; top-level `integration_branch` and `epic_merge_pr` each yield their own rejection. Rejection is active, not mere absence. |
| SA11 | `validate_orchestration_artifacts.py` registers both subparsers with their flags, dispatches to the new validators, and unknown types still fail | PASS | Diff adds `parallel_state_parser` with `--require-complete` and `parallel_planner_parser` with `--require-ready-for-execution`, plus two dispatch branches ahead of the unchanged `return [f"Unsupported artifact type: {args.artifact_type}"]` fallback. 15 tests in `test_validate_orchestration_artifacts_parallel_dispatch.py` cover both subparsers, both flags in both positions, exit codes, and the unknown-type fallback. |
| SA12 | The four TypeScript modules exist with error strings byte-identical to Python, and `orchestration-artifacts.ts` dispatches both new types | PASS | All five modules exist (the fifth is the size-driven `parallel-state-records.ts` split). `orchestration-artifacts.ts` gains two `case` blocks that thread the existing option flags. Byte-identity verified by execution rather than inspection: 43 documents through both implementations produced `MISMATCHED_CASES=0`, `TOTAL_STRINGS py=96 ts=96`. Three narrow divergences found by deliberate probing afterwards are recorded as Advisory A1-A3 in the code review; none is reachable from a well-formed document and one is inherent to `JSON.parse`. |
| SA13 | `mcp-tool-inputs.ts` and both definition surfaces accept both new types with updated flag descriptions; a definitions test asserts alignment | PASS | `VALID_ARTIFACT_TYPES` gains both values; both definition files gain both enum values and reword the `require_complete` and `require_ready_for_execution` descriptions to name the parallel types. `mcp-parallel-validation-definitions.test.ts` asserts both surfaces carry both values and stay aligned. |
| SA14 | `config/orchestration-routing.json` carries the `parallel` route with `requires_pr_gate: false`, and the bundled mirror is byte-identical | PASS | The route entry is added with `"requires_pr_gate": false`. `diff` between the two files reports no difference; `sha256sum` of both is `d9c6657cbdbe15413e0fb9bc1be700ce1a8f892d0db413c3bbc253ea24ea7bda`. The diff is a single hunk of added lines, so every pre-existing route entry is byte-unchanged. `test_orchestration_routing_config_parity.py` passes within the full suite. |
| SA15 | `.claude/rules/parallel-orchestration.md` records the V-O/V-P/V-M prose, the Foreign Schema Warning, the cache doctrine, the S8 table, the A7 bound, the A8 rule, and enum ownership | PASS | All seven elements present and semantically matched to `spec.md`: invariants 1-21 numbered, P1-P9 including the deliberately-absent P5, M1-M7, the restated Foreign Schema Warning naming the disqualified `$id`, "Cache Doctrine — the checkpoint is not the source of truth" with the three re-derivation commands, the eight-row omitted-epic-fields table, "Concurrency Bound (A7)" stating 1-8 inclusive with default 4, "Drift-Event Recording Rule (A8)" stating the strongest-action rule, and "Enum Ownership (F6/F7/F8 consume, never extend)" with all nine member sets. The bundled mirror is byte-identical. |
| SA16 | Python tests at the six planned files and TypeScript tests at the five planned files, covering valid, malformed, and absent-optional-key cases | PASS | All six planned Python files exist under `tests/scripts/dev_tools/` (370 tests). All five planned TypeScript files exist under `extensions/drm-copilot/test/`; three additional files were delivered, making eight total (302 tests). The superset satisfies the criterion, and the divergence is recorded in the plan's Notes with its cause (the 500-line cap and the pre-existing 508-line `orchestration-artifacts.test.ts`). Absent-optional-key cases are present, for example `test_invariant_7_absent_merge_status_yields_no_error`. |
| SA17 | Line coverage >= 85% and branch coverage >= 75% for every new Python and TypeScript module | PASS | Parsed from `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` by the reviewer. Python: 100% line and 100% branch on all four helper and contract modules; 97.56% / 94.12% on the orchestrator entry point; 100% / 100% on the planner. TypeScript: 96.91% / 96.04%, 100% / 98.21%, 100% / 100%, 99.38% / 92.11%, 100% / 97.96%. Lowest line figure across all eleven new modules is 96.91%; lowest branch figure is 92.11%. |
| SA18 | The diff contains no hunks under `validate_epic_*`, `_epic_*`, `epic-*`, or their tests | PASS | `git diff --name-only <base>..HEAD \| grep -iE "epic"` returns exactly one path, `evidence/qa-gates/epic-unchanged.2026-08-07T19-58.md`, which is a Markdown evidence artifact. Zero source or test hunks under any epic validator path. |
| SA19 | The full seven-stage toolchain loop passes in a single pass for both surfaces | PASS with one pre-existing gap | Reviewer-executed: Black `360 files would be left unchanged`; Ruff `All checks passed!`; Pyright `0 errors, 0 warnings, 0 informations`; Pytest `2835 passed`; Prettier `All matched files use Prettier code style!`; ESLint clean; `tsc --noEmit` clean; Jest `177 passed, 177 total` / `2363 passed`. Stage 4 (architecture-boundary) cannot execute because the repository has no `.dependency-cruiser.cjs`; this is a pre-existing repository condition recorded as Informational I1, not a defect of this branch, and boundary compliance was confirmed by inspection. Stage 6 is satisfied by the definitions-alignment test and stage 7 by the in-memory MCP round trip. |

### `user-story.md` — 13 criteria

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| UA1 | Manifest schema validated per design section 11, `mode` defaulting to `closed` and `max_concurrency` to 4, via the module and its accessors | PASS | Same evidence as SA1. Both defaults are module constants and both accessors return them for an absent key; the validator emits no error for absence, so the documented authoring shape is valid. |
| UA2 | Checkpoint schema validated per design section 12, including `current_cohort`, `recolor_generation`, `cohorts[]`, `items[]`, `conflict_edges[]`, `mutations[]`, `drift_events[]`, and the three receipt arrays | PASS | All seven named collections plus `current_cohort` and `recolor_generation` appear in `REQUIRED_KEYS` (lines 71-78) and each has a dedicated validator. `RECEIPT_ARRAY_KEYS = ("delegation_receipts", "skill_receipts", "mcp_call_receipts")` are checked for list type when present and contribute zero errors when absent. |
| UA3 | The orchestrator validator enforces the checkpoint invariants with completion gating in both modes only under `require_complete` | PASS | Same evidence as SA2. Closed mode requires every non-withdrawn item to reach `merged` or `worktree_removed`; open mode adds the `op: "close"` mutation requirement. Verified by execution in both modes, including the withdrawn-item exemption. |
| UA4 | The planner validator enforces the planner invariants with the readiness gate, including the sentinel and kickoff path, only under `require_ready_for_execution` | PASS | Same evidence as SA4. Executed: a document with `next_step` wrong, kickoff path wrong, one item unprepared, and only one item produces the cardinality error, the four per-item readiness errors, the sentinel error, and the kickoff-path error. |
| UA5 | Both artifact types accepted on the Python CLI and the MCP TypeScript surface; unknown types still fail | PASS | Same evidence as SA11 and SA13. The `Unsupported artifact type` fallback is asserted on both surfaces by new tests, and the pre-existing epic dispatch test is untouched. |
| UA6 | The TypeScript cores produce error strings byte-identical to the Python validators | PASS | Same evidence as SA12: 43 documents, 96 strings, zero mismatches, order preserved. Three narrow probe-discovered divergences are recorded as Advisory. |
| UA7 | `.claude/rules/parallel-orchestration.md` records the invariants as numbered prose including the cache doctrine and the omitted-epic-fields table | PASS | Same evidence as SA15. Both named elements are present as dedicated sections. |
| UA8 | `route_id: parallel` present in `config/orchestration-routing.json` and its byte-identical bundled mirror | PASS | Same evidence as SA14, including matching SHA-256 digests. |
| UA9 | No `depends_on` anywhere in the manifest or checkpoint schema; the validators explicitly reject its presence | PASS | Same evidence as SA10. `grep` confirms `depends_on` appears in the new code only as a member of the prohibited-key tuples, never as a schema field. Rejection demonstrated at nested level. |
| UA10 | No integration-branch or final-integration-PR field anywhere; the validators explicitly reject `integration_branch` and `epic_merge_pr` | PASS | Same evidence as SA10. Neither key appears as a schema field; both are prohibited-key tuple members and both rejections were demonstrated by execution. The S8 table in the rule file records the disposition of every omitted epic field. |
| UA11 | `mutations[]`, `drift_events[]`, and `conflict_edges[]` fully shaped per S5-S7 so F6, F7, and F8 need no schema additions | PASS | Same evidence as SA7, SA8, SA9. Every field of all three record types is validated. Nothing is deferred: the only deliberate omissions are behavioral (transition legality to F6, the Layer-2 ordering invariant to F7, drift detection to F8), each recorded in the rule file and each backed by a seam or an enum rather than a schema gap. |
| UA12 | The existing epic validators, their helpers, TS cores, and tests are unmodified | PASS | Same evidence as SA18. |
| UA13 | Line coverage >= 85% and branch coverage >= 75% for every new module, with tests under `tests/scripts/dev_tools/` and `extensions/drm-copilot/test/` | PASS | Same coverage evidence as SA17. Placement verified: all six new Python test files are under `tests/scripts/dev_tools/` and all eight new Jest files under `extensions/drm-copilot/test/`. No test file was added under any production source tree. |

### Non-Goals Verification

The user story's `## Non-Goals` section names nine exclusions. Each was checked to confirm the code
did not cross the boundary, and each absence is correct rather than a gap.

| Non-goal | Status |
| --- | --- |
| A `parallel-manifest` MCP artifact type | Correctly absent. The MCP surface grew by exactly two values; manifest validation is a library call with no CLI subcommand. |
| F7's `PARALLEL_COHORT_BARRIER_VIOLATION` invariant | Correctly absent. Only the delimited seam is provided, in both runtimes. |
| Recoloring recomputation parity (P5) | Correctly absent. Neither validator imports `parallel_cohort_computation`; the omission is stated in the planner module docstring and as P5 in the rule file. |
| Deep readiness-integrity machinery | Correctly absent. The ready gate performs no file read and no repository call. P9 compares the kickoff PATH string only and never parses kickoff CONTENT. |
| State-transition legality | Correctly absent. `_parallel_state_records.py` states that transition legality is F6 behavior; only shape, enum membership, and null rules are checked. |
| Drift detection behavior | Correctly absent. Only the `drift_events[]` record shape is defined. |
| Key-level partitioning of shared surfaces | Correctly absent. |
| Modifying epic validators, the atomic-plan contract, or any `.github/` policy file | Correctly absent. Zero epic hunks; no `.github/` path appears in the diff. |
| Authoring or importing any JSON Schema file | Correctly absent. No schema file added; `grep` for `$schema` and `additionalProperties` over the eleven new modules returns no match; the disqualified foreign `$id` appears only in the prose warning that restates the prohibition. |

## Summary

- **Acceptance criteria evaluated:** 32 (19 in `spec.md`, 13 in `user-story.md`).
- **PASS:** 32. **PARTIAL:** 0. **FAIL:** 0. **UNVERIFIED:** 0.
- **Blocking findings:** 0.
- **Advisory findings:** 7. **Informational findings:** 5. All detailed in
  `code-review.2026-08-07T20-36.md`.
- **Coverage verdicts:** Python **PASS**, TypeScript **PASS**, PowerShell N/A (zero changed files),
  C# N/A (zero changed files).
- **Remediation:** not triggered. No `remediation-inputs` artifact is produced.

Two executor report claims were independently re-verified rather than accepted. The claim of 2835
Python tests, 177 TypeScript suites / 2363 tests, 72 changed lines with zero uncovered, and the
stated coverage percentages all reproduced exactly. The Phase 7 report's assertion that
`parallel-state-records.ts` lacks a `coverageThreshold` entry is confirmed inaccurate: the entry is
present at `extensions/drm-copilot/jest.config.cjs:175`, with an explanatory comment.

**Recommendation: GO.** The branch is ready for a pull request against
`epic/parallel-orchestration-integration`. The seven Advisory findings should be dispositioned at
epic fan-in or logged as potential-feature entries; the three parity divergences in particular are
worth a repository-wide entry because the `pythonRepr` behavior is shared with four pre-existing
epic and codex TypeScript validators and should be corrected in one place rather than only here.

## Acceptance Criteria Check-off

All 32 criteria were already marked `- [x]` in their source files by the executor. The reviewer
independently evaluated each as PASS, so no checkbox required a change and none was altered. No
criterion was marked PARTIAL, FAIL, or UNVERIFIED, so no checkbox needed to be reverted.

No new acceptance criteria were added; reviewers do not author criteria.

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-schema-validators-444/spec.md
          docs/features/active/2026-08-07-parallel-schema-validators-444/user-story.md
- Total AC items: 32
- Checked off (delivered): 32
- Remaining (unchecked): 0
- Items remaining: none
```

Sections deliberately left unchecked and not treated as acceptance criteria, per the repository
convention observed in the merged wave-0 sibling `2026-08-07-parallel-cohort-scheduler-445`:
`spec.md` `## Definition of Done`, `spec.md` `## Seeded Test Conditions (from potential)`,
`issue.md` `## Acceptance Criteria (early draft)`, and `issue.md` `## Test Conditions to Consider`.
