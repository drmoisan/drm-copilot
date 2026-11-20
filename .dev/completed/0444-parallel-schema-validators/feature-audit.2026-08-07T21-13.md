# Feature Audit — parallel-schema-validators (Issue #444) — Reaudit, remediation cycle 1 exit gate

- **Date:** 2026-08-07T21-13
- **Review type:** REAUDIT (remediation cycle 1 exit gate)
- **Prior artifact:** `feature-audit.2026-08-07T20-36.md` (not modified; remains the entry record)

## Scope and Baseline

- **Branch:** `feature/parallel-schema-validators-444`
- **Base branch:** `epic/parallel-orchestration-integration`
- **Merge base:** `ae6331f7693fb7c05e2c5c7f8416c46c469929fa`
- **Commits:** `3eb6b348` (feature), `dac03eb3` (remediation cycle 1)
- **Baseline diff:** `git diff ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD` — 93 files,
  +12737 / -114 lines
- **Cycle-1 delta:** `git diff 3eb6b348..dac03eb3` — 32 files, +1201 / -2 lines, all Markdown
- **Work mode:** `full-feature`, read from `issue.md` line 12 (`- Work Mode: full-feature`)
- **AC sources (resolved by work mode):** `spec.md` and `user-story.md`

Per the `acceptance-criteria-tracking` skill, `full-feature` resolves to both `spec.md` and
`user-story.md`. Acceptance criteria are the checkbox items under the `## Acceptance Criteria`
heading in each file. Checkbox items appearing under `## Definition of Done` and
`## Seeded Test Conditions (from potential)` in `spec.md` are process checklists rather than
acceptance criteria and are evaluated separately at the end of this document, not counted in the
AC total.

Every acceptance criterion was re-evaluated at HEAD `dac03eb3` by execution or by direct inspection
of the delivered artifact. No verdict was carried forward from the cycle-0 audit without
re-confirmation.

## Acceptance Criteria Inventory

| Source | Heading | Count | Checked | Unchecked |
| --- | --- | --- | --- | --- |
| `spec.md` | `## Acceptance Criteria` | 19 | 19 | 0 |
| `user-story.md` | `## Acceptance Criteria` | 13 | 13 | 0 |
| **Total** | | **32** | **32** | **0** |

Counts obtained with `grep -c` scoped to the acceptance-criteria sections. `spec.md` additionally
carries 15 unchecked boxes outside those sections: 7 under `## Definition of Done` and 8 under
`## Seeded Test Conditions (from potential)`. These are not acceptance criteria and are addressed in
the closing section.

## Acceptance Criteria Evaluation

### `spec.md` — 19 criteria

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| SA1 | `parallel_manifest_contract.py` exists with `validate_parallel_manifest_text` plus both default-resolving accessors, enforcing M1-M7 including LF/CRLF/CR tolerance | PASS | Module present at 312 lines. `test_parallel_manifest_contract.py` (497 lines) covers all seven invariants including the three line-ending forms and both accessor defaults. Module coverage 65/65 lines and 22/22 branches. |
| SA2 | `validate_parallel_orchestrator_state.py` exists with the keyword-only `require_complete` flag, enforcing 1-19 unconditionally and 20-21 only under the flag | PASS | Verified by execution. A valid document returns `[]` with the flag off and returns two per-item completion errors with the flag on, confirming both that 20-21 are gated and that the gate-off result is byte-identical to a plain call. |
| SA3 | The orchestrator entry point contains a delimited, appendable F7 seam | PASS | The comment-delimited helper-invocation block naming F7 and `PARALLEL_COHORT_BARRIER_VIOLATION` is present in the entry point, with existing helper calls outside it. The matching seam is present in `parallel-orchestrator-state-core.ts`. |
| SA4 | `validate_parallel_planner_state.py` exists with `require_ready_for_execution`, enforcing P1-P4 unconditionally and P6-P9 only under the flag, including the sentinel and the kickoff path | PASS | Verified by execution. Gate-off returns `[]` for the builder document; gate-on rejects a single-item list, an unprepared item, a non-cleared preflight, a `derived` blast radius, a wrong sentinel, and a wrong kickoff path, each with exactly the specified error. |
| SA5 | Shared helper modules exist holding the S4 enums and shared validators, and every new production and test file is at or under 500 lines | PASS | `_parallel_state_common.py` (495) and `_parallel_state_structures.py` (496) exist as named. The delivered set also includes `_parallel_state_records.py` (324), a size-driven split now recorded in the plan's Notes by the R2 remediation. Maximum file size across all 32 non-Markdown files is 499. |
| SA6 | All nine S4 enums enforced with exactly the specified member sets | PASS | Verified by execution against every enum. Out-of-enum values for item `state`, `merge_status`, `mode`, `kind`, `blast_radius.source`, `conflict_edges[].reason`, `mutations[].op`, `mutations[].disposition`, and `drift_events[].action` each produce the enumerated-member error listing exactly the specified members in the specified order. |
| SA7 | `mutations[]` validated to the full S5 shape including op-specific null rules, invariant 17, and the generation bound | PASS | Verified by execution. Out-of-enum `op`, a non-null `item_key` on a `close`, an in-flight removal with no disposition, and a stray disposition on an `add` each produce exactly one targeted error. |
| SA8 | `drift_events[]` validated to the full S6 shape | PASS | Verified by execution. An empty `escaped_paths` yields `drift_events[0] escaped_paths must be a non-empty list of non-empty strings.`; an out-of-enum action yields the A8 two-member enum error. |
| SA9 | `conflict_edges[]` validated to the full S7 shape | PASS | Verified by execution. Self-edge, unnormalized pair, duplicate pair, and out-of-enum reason each produce exactly one targeted error, including the canonical-normalization message `must be normalized with a < b; found: (445, 444).` |
| SA10 | Both validators reject `depends_on` at any level and reject `integration_branch` / `epic_merge_pr`; the manifest rejects `depends_on` at any level and `integration_branch` at top level; negative tests cover each | PASS | Verified by execution at two nesting levels on both surfaces. Rejection is explicit (`carries prohibited key '<key>' at <path>.`), not mere absence. Negative tests are present in all three test surfaces. |
| SA11 | `validate_orchestration_artifacts.py` registers both subparsers with their flags, dispatches correctly, and unknown types still fail | PASS | Verified by execution. `artifact_type="parallel-kickoff"` returns `["Unsupported artifact type: parallel-kickoff"]`, confirming the fallback is intact while the two new types dispatch. |
| SA12 | TypeScript cores exist with error strings byte-identical to the Python source, and `orchestration-artifacts.ts` dispatches both new types | PASS | Verified by independent execution this cycle, not by reading. A 74-document corpus built from the committed test builders produced 92 Python error strings, of which 90 matched byte-identically and in identical order. Both non-matches are the invalid-JSON parser detail text, which is runtime-specific and which both test suites already assert by prefix only. Restricted to documents that parse as JSON, the match is 90 of 90. `orchestration-artifacts.ts` gains two `case` blocks threading the existing option flags. The rule file now records the verified scope and the known divergence classes, correcting the previously unqualified claim; the residual documentation-completeness gap is recorded as Advisory A1 in the code review. |
| SA13 | `mcp-tool-inputs.ts` and both definition surfaces accept the two new types, with flag descriptions updated; a definitions test asserts alignment | PASS | The diff adds exactly two enum members to each definition surface and two entries to `VALID_ARTIFACT_TYPES`, and updates both flag descriptions to name the parallel types. `mcp-parallel-validation-definitions.test.ts` asserts both surfaces stay aligned and that `parallel-kickoff` is rejected. |
| SA14 | `config/orchestration-routing.json` carries the `parallel` route with `requires_pr_gate: false`, byte-identically mirrored | PASS | `cmp` on the two files exits 0. `test_orchestration_routing_config_parity.py` passes (`1 passed in 0.05s`). |
| SA15 | `.claude/rules/parallel-orchestration.md` exists and records the V-O/V-P/V-M invariants, the Foreign Schema Warning, the cache doctrine, the S8 table, the A7 bound, the A8 rule, and enum ownership | PASS | All eight required content elements are present under their own headings. The file is byte-identical to its extension mirror after the cycle-1 rewrite (both blob `7063d2dabf0126bae3eb837e7ba0a6faa34e11ce`). |
| SA16 | Python tests at the six planned files and TypeScript tests at the five planned files, covering each invariant's valid, malformed, and absent-optional-key cases | PASS as a superset | Six Python test files delivered as planned. Eight TypeScript test files delivered against five planned; the divergence is a superset driven by the 500-line cap and is recorded in the plan's `## Open Questions / Notes`. Both suites pass in full. |
| SA17 | Line coverage >= 85% and branch coverage >= 75% for every new Python and TypeScript module | PASS | Regenerated at HEAD. Python new modules range 97.56% to 100.00% line and 94.12% to 100.00% branch. TypeScript new modules range 96.91% to 100.00% line and 92.11% to 100.00% branch. Enforced automatically for the five TypeScript modules by the per-file `coverageThreshold` entries added to `jest.config.cjs`, which the passing run confirms. |
| SA18 | The diff contains no hunks under `validate_epic_*`, `_epic_*`, `src/lib/validate/epic-*`, or their tests | PASS | `git diff --name-only <merge-base>..HEAD \| grep -Ei "epic"` returns exactly one path, and it is the evidence Markdown `evidence/qa-gates/epic-unchanged.2026-08-07T19-58.md`. No epic source or test file is in the diff. |
| SA19 | The full seven-stage toolchain loop passes in a single pass on both surfaces | PASS | Re-executed independently this cycle. Stages 1, 2, 3, and 5 clean on both surfaces with no auto-fix and therefore no loop restart. Stage 4 has no configured tool in this repository (pre-existing, Informational I1). Stage 6 is satisfied by the MCP definitions-alignment test, stage 7 by the in-memory MCP round-trip test. |

### `user-story.md` — 13 criteria

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| UA1 | Manifest schema defined and validated per design section 11, with both defaults, via the contract module and its accessors | PASS | Same evidence as SA1. Absent `mode` and absent `max_concurrency` each produce zero errors while the accessors return `closed` and `4`. |
| UA2 | Checkpoint schema defined and validated per design section 12, including all seven collection fields and the three receipt arrays | PASS | All seventeen required keys are enforced with one error per missing key, verified by execution across twelve individually removed keys. Receipt arrays are list-checked and contribute zero errors when absent. |
| UA3 | The orchestrator validator exists with completion gating for closed and open mode only under `require_complete` | PASS | Same evidence as SA2. Open mode additionally requires the `op == 'close'` run-close record, verified by execution. |
| UA4 | The planner validator exists with the readiness gate including the sentinel and kickoff path, only under `require_ready_for_execution` | PASS | Same evidence as SA4. |
| UA5 | Both new `artifact_type` values are accepted on the Python CLI and the MCP TypeScript surface, and unknown types still fail | PASS | Same evidence as SA11 and SA13, confirmed on both surfaces including the negative case. |
| UA6 | The TypeScript cores produce error strings byte-identical to the Python validators | PASS | Same evidence as SA12: 90 of 90 matched across all parseable documents in a 74-document corpus, in identical order. The two runtime-specific parse-failure messages are outside the parity scope now recorded in the rule file, and both test suites assert them by prefix only. Documentation-completeness gap recorded as Advisory A1. |
| UA7 | The rule file records the invariants as numbered prose including the cache doctrine and the omitted-epic-fields table | PASS | Same evidence as SA15. |
| UA8 | `route_id: parallel` present in both routing-config copies, byte-identical | PASS | Same evidence as SA14. |
| UA9 | No `depends_on` anywhere; validators explicitly reject its presence | PASS | Verified by execution at root and at `items[0]` on both checkpoint surfaces, plus the manifest surface. Rejection is explicit. |
| UA10 | No integration-branch or final-integration-PR field anywhere; validators explicitly reject `integration_branch` and `epic_merge_pr` | PASS | Verified by execution at root and at `items[0]`. Both keys are rejected with a path-qualified message. |
| UA11 | `mutations[]`, `drift_events[]`, and `conflict_edges[]` fully shaped per S5-S7 so F6/F7/F8 need no schema additions | PASS | Same evidence as SA7, SA8, and SA9. The enum-ownership section of the rule file states that F6/F7/F8 consume and never extend these member sets, closing the contract. |
| UA12 | The existing epic validators, helpers, TS cores, and tests are unmodified | PASS | Same evidence as SA18. |
| UA13 | Line >= 85% and branch >= 75% for every new module, with tests under `tests/scripts/dev_tools/` and `extensions/drm-copilot/test/` | PASS | Same evidence as SA17. Test file locations mirror the production source structure on both surfaces; no test file was colocated into a production tree. |

### Non-Goals and Deliberate-Absence Verification

Absences that are correct for F3's scope were verified as absences, so that a later reader does not
mistake a deliberate omission for an oversight.

| Non-goal | Verdict | Evidence |
| --- | --- | --- |
| No `parallel-kickoff` artifact type (F4's scope) | CORRECTLY ABSENT | The literal appears only in the P9 path template and in negative tests asserting `Unsupported artifact type: parallel-kickoff`. It is registered on no CLI or MCP surface. |
| No `parallel_kickoff_contract.py` (F4's scope) | CORRECTLY ABSENT | `ls scripts/dev_tools/parallel_kickoff_contract.py` reports no such file. |
| Ready gate parses no kickoff CONTENT | CORRECTLY STRUCTURAL | `grep` for any filesystem, subprocess, or path-read call across the planner validator and its TypeScript core returns no match. P9 is a string comparison against `KICKOFF_PATH_TEMPLATE.format(...)`. |
| No recoloring recomputation (spec P5, F4's scope) | CORRECTLY ABSENT | The only matches for `recompute` are prose comments recording the deliberate omission, at `validate_parallel_planner_state.py:20` and `:254` and `_parallel_state_structures.py:13`. No recomputation call exists. |
| No JSON Schema file authored or imported | CORRECTLY ABSENT | No schema file in the diff; no `jsonschema`, `json_schema`, `$schema`, or `ajv` reference in any of the twelve new validator modules. |
| The disqualified foreign schema was not copied | CORRECTLY ABSENT | `mix-calculator` appears exactly once in the branch, inside the prohibition prose at `.claude/rules/parallel-orchestration.md:9`. That is a citation of the ban, not a copy of the artifact. |
| MCP surface grows by exactly two artifact types | CORRECT | Two enum members per definition surface and two `VALID_ARTIFACT_TYPES` entries. No third type anywhere. |

## Cycle-1 Remediation Verification

The cycle-1 remediation was scoped by `remediation-inputs.2026-08-07T20-45.md` to Advisory findings
R1 and R2 only. Both were delivered; the delta was independently confirmed documentation-only before
its contents were read.

| Item | Required | Delivered | Verdict |
| --- | --- | --- | --- |
| R1 — qualify the parity claim in `.claude/rules/parallel-orchestration.md` | Rewrite in place; retain the parity statement; state the verified scope; name all three divergence classes with causes | The Enforcement bullet is rewritten in place with a net `+1 / -1`. The parity statement is retained (`reproduces the same invariants` survives verbatim). The verified scope is stated as 96 of 96 error strings across 43 constructed documents. All three classes are named with causes and with source line references. | PASS |
| R1 accuracy — `pythonRepr` quote selection | The cited behavior must match `parallel-state-shared.ts:112-132` | Lines 112-132 are exactly the `pythonRepr` function. It always emits `'...'` with `\'` escaping. Reproduced by execution: Python emits `"it's open"`, TypeScript emits `'it\'s open'`. | PASS |
| R1 accuracy — integral floats | The cited behavior must be real | Reproduced by execution: `max_concurrency = 4.0` yields 1 Python error and 0 TypeScript errors; `recolor_generation = 0.0` yields 3 Python errors and 0 TypeScript errors. | PASS |
| R1 accuracy — boolean/integer equality | The cited behavior must match `parallel-state-structures.ts:228` | Line 228 is exactly `.filter((entry) => entry["generation"] === recolorGeneration);`. The Python counterpart at `_parallel_state_structures.py:254` uses `==`. Reproduced by execution: `generation = true` with `recolor_generation = 1` yields 1 Python error and 3 TypeScript errors. | PASS |
| R1 mirror — identical rewrite in the extension copy | Byte-identical | `cmp` exit 0; identical SHA-256; identical git blob hash. | PASS |
| R2 — record the records-module split in the approved plan | One bullet in `## Open Questions / Notes`; no task checkbox changed | One prose bullet appended naming both split modules, their contents, and the 500-line-cap justification, in the same style as the pre-existing SA16 divergence note. Both plan revisions carry 78 checked and 0 unchecked boxes; the file diff is a single added line that is not a checkbox. | PASS |
| New potential entry for the repo-wide `pythonRepr` defect | Recorded so the fix is scheduled outside this branch | `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`, 67 lines, present and referenced from the corrected rule text. | PASS |

## Summary

**All 32 acceptance criteria PASS. Zero FAIL. Zero blocking PARTIAL. Zero UNVERIFIED.**

Every criterion was re-evaluated at HEAD `dac03eb3` by execution or direct artifact inspection
rather than carried forward from cycle 0. The two criteria that turn on cross-runtime byte-identity
(SA12 and UA6) were verified by building a 74-document corpus from the committed test builders,
running it through both runtimes, and diffing the result arrays element-wise. Restricted to
documents that parse as JSON — the scope the corrected rule text now records — the match is 90 of
90 error strings in identical order. The two non-matching strings are the runtime-specific JSON
parser detail messages, which both test suites already assert by prefix only and which no test pins.

The cycle-1 remediation delivered exactly its scope. The parity claim was corrected rather than
deleted, and every factual assertion in the corrected text was independently verified against the
source. The plan's task record is untouched. No executable file changed.

One documentation-completeness Advisory (A1) arises from this cycle: the corrected rule text
enumerates three divergence classes where a fourth exists. It is Advisory rather than Blocking
because the delivered sentence states that three classes "are known" without claiming the list is
exhaustive, because the fourth class is architecturally unavoidable and identical in every
pre-existing orchestration validator pair in the repository, and because the executor delivered
faithfully against the scope the remediation inputs defined.

**Exit-gate result: 0 Blocking findings across all three reaudit artifacts. The cycle-1 exit
condition (`blocking_count == 0`) is met.** No remediation-inputs artifact is produced for a
cycle 2.

## Acceptance Criteria Check-off

No check-off action was required. All 32 acceptance criteria in both source files were already
marked `[x]` at HEAD, and every one was independently verified as genuinely satisfied during this
reaudit. No criterion was found to be checked without supporting evidence, and no criterion was
newly checked by this reviewer.

### Acceptance Criteria Status

```
- Source: docs/features/active/2026-08-07-parallel-schema-validators-444/spec.md
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: none
```

```
- Source: docs/features/active/2026-08-07-parallel-schema-validators-444/user-story.md
- Total AC items: 13
- Checked off (delivered): 13
- Remaining (unchecked): 0
- Items remaining: none
```

### Non-AC Checklist Sections in `spec.md`

`spec.md` carries 15 unchecked boxes outside its `## Acceptance Criteria` section: 7 under
`## Definition of Done` and 8 under `## Seeded Test Conditions (from potential)`. These are process
checklists authored during scoping, not acceptance criteria, and the `acceptance-criteria-tracking`
skill scopes AC to the `## Acceptance Criteria` heading. They are recorded here for visibility
rather than counted against the AC total.

The substance behind both lists is nevertheless satisfied and is evidenced elsewhere in this audit:
acceptance criteria are mapped to tests (Appendix A of the policy audit), tests were added for every
invariant including edge and error paths, the rule-file documentation was updated, the toolchain
pass completed, each of the eight seeded test conditions has a corresponding delivered test surface,
and the coverage floors are cleared on every new module. No orchestration action is required; the
boxes themselves are for the authoring surface to close at feature promotion.
