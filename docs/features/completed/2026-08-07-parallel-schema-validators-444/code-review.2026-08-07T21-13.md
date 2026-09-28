# Code Review — parallel-schema-validators (Issue #444) — Reaudit, remediation cycle 1 exit gate

- **Date:** 2026-08-07T21-13
- **Review type:** REAUDIT (remediation cycle 1 exit gate)
- **Branch:** `feature/parallel-schema-validators-444`
- **Base:** `epic/parallel-orchestration-integration` (merge base `ae6331f7693fb7c05e2c5c7f8416c46c469929fa`)
- **Commits:** `3eb6b348` (feature), `dac03eb3` (remediation cycle 1)
- **Full-feature diff:** `git diff ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD`
- **Cycle-1 delta:** `git diff 3eb6b348..dac03eb3`
- **Prior artifact:** `code-review.2026-08-07T20-36.md` (not modified; remains the entry record)

## Executive Summary

**Blocking findings: 0. Advisory findings: 6. Informational findings: 5.**

The cycle-1 delta is documentation-only. This was established before reading the delta's contents,
by filtering the changed-path list rather than by accepting the executor's claim.
`git diff --name-only 3eb6b348..dac03eb3` returns 32 paths; `grep -vE '\.md$'` over that list
returns nothing, and an explicit scan for `\.(py|ts|tsx|cjs|mjs|js|json|ps1|psm1|cs|ya?ml)$`
returns nothing with grep exit 1. No executable file changed.

The R1 rewrite is correct in substance. It retains the parity statement rather than deleting it,
adds a verified-scope qualifier, and names three divergence classes with their causes. Each of the
three was independently reproduced by executing both runtimes against the same constructed
documents, and both source line references it cites were checked against the actual code and are
exact. The two rule-file copies remain byte-identical after the rewrite.

The R2 plan edit added exactly one prose bullet and altered no task checkbox. Both revisions carry
78 checked and 0 unchecked boxes.

One new Advisory (A1) arises from this cycle. The corrected rule text names three divergence
classes, but a fourth exists and is easier to reach than any of the three: the invalid-JSON parser
detail message differs between the CPython and V8 JSON parsers. Cycle-0's R7 finding explicitly
named this class as one of three exceptions. The cycle-1 remediation-inputs document restated the
scope with a different set of three, dropping the invalid-JSON class and substituting the
boolean/integer class, and the delivered rule text inherited that omission. This is Advisory rather
than Blocking: the delivered sentence says three classes "are known", which is a true statement and
not an exhaustiveness claim, and the executor delivered exactly the scope the remediation inputs
defined. Both test suites already handle this class correctly by asserting the message prefix only.

Five findings from cycle 0 are carried forward unchanged (A2 through A6) and five Informational
observations are restated for continuity. No finding requires a further remediation cycle.

## Cycle-1 Delta Verification

| Check | Method | Result |
| --- | --- | --- |
| Delta is documentation-only | `git diff --name-only 3eb6b348..dac03eb3 \| grep -vE '\.md$'` | No output. All 32 changed paths end in `.md`. |
| No code-extension file changed | `git diff --name-only 3eb6b348..dac03eb3 \| grep -E '\.(py\|ts\|tsx\|cjs\|mjs\|js\|json\|ps1\|psm1\|cs\|ya?ml)$'` | No output, grep exit 1. |
| Rule-file copies byte-identical | `cmp`, `sha256sum`, `git rev-parse` on both paths | `cmp` exit 0. Both hash `6d1e82c572ea5fa2a5c86f1221becfa468dc3192394ab3adf0aec3abe60f2d8e`. Both blob `7063d2dabf0126bae3eb837e7ba0a6faa34e11ce`. |
| Rewrite is in place, not a deletion | `git diff 3eb6b348..dac03eb3 -- .claude/rules/parallel-orchestration.md` | One line removed, one line added, at the same position in the Enforcement section. The parity statement is retained; the phrase "reproduces the same invariants" survives verbatim. |
| `pythonRepr` line reference is exact | Read `parallel-state-shared.ts:112-132` | Line 112 is `export function pythonRepr(value: unknown): string {`; line 132 is the closing brace. The cited range is the whole function and nothing else. |
| `parallel-state-structures.ts:228` reference is exact | Read `parallel-state-structures.ts:200-249` | Line 228 is `.filter((entry) => entry["generation"] === recolorGeneration);`. The cited line is precisely the `===` comparison the text describes. |
| Python counterpart uses `==` | `grep -n "generation" scripts/dev_tools/_parallel_state_structures.py` | Line 254: `return [r for r in records if r.get("generation") == recolor_generation]`. Confirms the asserted `True == 1` asymmetry. |
| Plan checkboxes unaltered | Checkbox counts and line-set comparison across both revisions | 78 checked / 0 unchecked in both. File diff is `+1` line, a prose bullet under `## Open Questions / Notes`. |
| Potential entry exists | `wc -l docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md` | 67 lines. Present and non-empty. |

## Findings Table

| ID | Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | Advisory (new this cycle) | `.claude/rules/parallel-orchestration.md` and its mirror | Enforcement section, TypeScript parity bullet, final sentence | The corrected text states "Three divergence classes are known outside that verified scope" and enumerates `pythonRepr` quote selection, integral-float erasure, and boolean/integer equality. A fourth class exists and is reachable more easily than any of the three: for text that does not parse as JSON, both validators interpolate their own runtime's parser message, and CPython and V8 produce different text. Cycle-0's finding R7 named this class explicitly ("the two preceding runtime divergences **and the invalid-JSON parser text**"). The cycle-1 `remediation-inputs.2026-08-07T20-45.md` restated the scope as a different set of three, dropping the invalid-JSON class and substituting the boolean/integer class; the delivered rule text follows the remediation inputs faithfully. | Add a fourth clause to the same sentence at the next touch of this file, for example: "(4) **unparseable input** — when the text does not parse as JSON, each validator interpolates its own runtime's parser message, so only the `<context> is not valid JSON: ` prefix is common; both test suites assert the prefix only." No code change is required. | Advisory, not Blocking, on three grounds. First, the delivered sentence is not false: it says three classes "are known", which is true, and does not claim the list is exhaustive. Second, the divergence is architecturally unavoidable in the same way as the integral-float class, and is identical in every pre-existing orchestration validator pair in this repository, so it is not introduced by this feature. Third, both test suites already treat it correctly by asserting the prefix only, so no test pins a runtime-specific string. | Reproduced by execution. Input `{not json` to the orchestrator validator. Python: `Parallel checkpoint is not valid JSON: Expecting property name enclosed in double quotes: line 1 column 2 (char 1).` TypeScript: `Parallel checkpoint is not valid JSON: Expected property name or '}' in JSON at position 1 (line 1 column 2).` Input `}{` to the planner validator. Python: `... Expecting value: line 1 column 1 (char 0).` TypeScript: `... Unexpected token '}', "}{" is not valid JSON.` Pre-existing parity: `validate_epic_orchestrator_state.py:439` interpolates `{exc}` while `epic-orchestrator-state-core.ts:404` interpolates `exc.message`; the same pattern appears in `validate_orchestrator_state.py:408` versus `orchestrator-state-core.ts:346` and in both epic planner cores. Correct test handling: `test_validate_parallel_orchestrator_state.py:130` uses `startswith`, and `parallel-orchestrator-state-core.test.ts:58` uses `toMatch(/^Parallel checkpoint is not valid JSON: /)`. |
| A2 | Advisory (carried forward, cycle 0) | `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts` | lines 112-132, `pythonRepr` | `pythonRepr` always emits single quotes with a backslash escape. CPython `repr` switches to double quotes when the string contains a `'` and no `"`. A rejected string value containing an apostrophe therefore renders differently on the two surfaces. Reachable through any rejected string field: `mode`, `state`, `merge_status`, `feature_folder`, `at`, `computed_at`, `preflight_status`, and others. | No change on this branch. The defect is now correctly documented in the rule file by R1 and recorded repo-wide at `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md`. Correct all copies together in that separate work item. | Fixing it only here would desynchronize the parallel port from the epic surface it was told to mirror. The identical implementation exists in `epic-planner-state-core.ts`, `epic-orchestrator-state-resolution.ts`, `codex-topology-resolver.ts`, and `orchestrator-state-codex-model-routing.ts`. Caller-designated out of scope for code changes on this branch. | Re-reproduced this cycle. Input `{"mode": "it's open", ...}`. Python: `Parallel checkpoint mode must be one of closed, open; found: "it's open".` TypeScript: `Parallel checkpoint mode must be one of closed, open; found: 'it\'s open'.` Also reproduced through a nested field: `items[0].state = "it's scheduled"` diverges identically. |
| A3 | Advisory (carried forward, cycle 0) | `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts` | header note and `isIntegral` | An integral float such as JSON `10.0` is rejected by Python (`isinstance(10.0, int)` is `False`) and accepted by TypeScript, because `JSON.parse` cannot distinguish `10.0` from `10`. The two surfaces produce different error counts for the same document. | No change. Not correctable within the JavaScript runtime. The cycle-0 recommendation was to record the asymmetry in the prose rule file, which R1 has now done. | The module header already documented the cause honestly. R1 closed the documentation-reach gap the cycle-0 finding identified. | Re-reproduced this cycle. `max_concurrency = 4.0`: Python emits `Parallel checkpoint max_concurrency must be an integer from 1 through 8; found: 4.0.`, TypeScript emits nothing. `recolor_generation = 0.0`: Python emits 3 errors (the counter error plus two cohort-coverage errors), TypeScript emits none. |
| A4 | Advisory (carried forward, cycle 0) | `extensions/drm-copilot/src/lib/validate/parallel-state-structures.ts` | line 228, `currentGenerationCohorts` | Python's `r.get("generation") == recolor_generation` treats `True == 1` as equal, so a cohort with `"generation": true` is selected as current-generation when `recolor_generation` is `1`. TypeScript's `===` does not, so the cohort is excluded and additional coverage errors are emitted. | No change, or optionally coerce a boolean to its numeric value before comparison. Accepting is defensible: the TypeScript behavior is arguably the more correct one, and a boolean in a numeric slot is already reported as malformed by invariant 12. Now documented in the rule file by R1. | A Python-language semantic with no JavaScript equivalent, reachable only with a boolean in a numeric slot. It does not change whether the document is rejected, only how many errors describe the rejection. | Re-reproduced this cycle. `cohorts[0].generation = true` with `recolor_generation = 1`: Python emits 1 error, TypeScript emits 3, the two extra being `Parallel checkpoint item 444 in state 'scheduled' must appear in exactly one current-generation cohort; found 0.` and the same for item 445. |
| A5 | Advisory (carried forward, cycle 0) | `scripts/dev_tools/validate_parallel_orchestrator_state.py` | `_validate_identity` | Spec table S2 marks `parallel_slug`, `parallel_manifest_path`, and `parallel_status_doc_path` required and non-empty, but no V-O invariant enforces the non-empty part, and `_validate_identity` checks only `route_id`, `mode`, and `max_concurrency`. A checkpoint carrying `"parallel_slug": ""` validates clean on the orchestrator surface. The planner enforces non-empty for the first two under P2, so the two surfaces disagree on the same field. | Either add the non-empty check to the orchestrator validator and to invariant 2 in the rule file, or record in the rule file that the orchestrator checks presence only for these three identity fields. Prefer the former, for symmetry with P2. | The implementation matches the numbered invariant list exactly, so the acceptance criterion is met. The gap is between the S2 schema table and the V-O invariant list, which disagree. A downstream consumer reading S2 would reasonably expect the constraint to be enforced. | `_validate_identity` contains exactly three checks. Compare `validate_parallel_planner_state.py:158-160`, which loops over `("parallel_slug", "parallel_manifest_path")` calling `is_non_empty_string`. Re-confirmed unchanged at HEAD. |
| A6 | Advisory (carried forward, cycle 0; caller-designated spec-review item) | `docs/features/active/2026-08-07-parallel-schema-validators-444/spec.md` | S5 table versus invariant 17 | The S5 `disposition` row says the field "must be null unless `op == 'remove'`", which permits a disposition on a `remove` whose `prior_state` is not `in_flight`. Invariant 17 forbids it. The implementation follows invariant 17. | Correct the S5 row at the next spec review so the schema table and the invariant list agree. No code change is needed. | Recorded for continuity only. The caller designated spec-internal contradictions out of scope for this reaudit, and the code correctly follows the numbered invariants. | `_parallel_state_records.py` module docstring states "Invariant 17 is stricter than the S5 table's `disposition` row and is the behavior implemented". Verified by execution: a stray `disposition` on an `add` yields `Parallel checkpoint mutations[0] disposition must be null unless op is 'remove' with prior_state 'in_flight'; found: 'detach'.` |
| I1 | Informational | repo root and `extensions/drm-copilot/` | `.dependency-cruiser.cjs` | Toolchain stage 4 has no configured tool, so it cannot be executed for this or any branch. Boundary compliance was confirmed by inspection: the five new modules import only from each other and reference no Office.js, Graph, VSTO, or COM surface. | No action for this feature. Repository-level gap. | `.claude/rules/architecture-boundaries.md` names `dependency-cruiser` with configuration file `.dependency-cruiser.cjs` as the TypeScript enforcement tool. | Both candidate config paths are absent; `package.json` scripts contain no `depcruise` entry. |
| I2 | Informational | repo root | `quality-tiers.yml` | The tier-classification file is absent, so no tier attaches to the new modules and the tier-dependent property-test-density gate does not fire. | No action for this feature. Pre-existing and separately documented. | `.claude/rules/quality-tiers.md` makes property-test density tier-dependent. | Recorded at `docs/features/potential/promoted/2026-07-09-quality-tiers-yml-missing-at-repo-root.md`; the branch decision is at `evidence/other/property-test-decision.2026-08-07T19-58.md`. |
| I3 | Informational | worktree environment | Pyright venv resolution | `poetry run pyright` prints `venv .venv subdirectory not found in venv path <worktree>` before reporting `0 errors, 0 warnings, 0 informations`. The type check ran and was clean. | No action. Recorded so the notice is not mistaken for a diagnostic. | Evidence-first audit writing requires recording exact tool output, including non-fatal notices. | `poetry run pyright` output, first line, reproduced this cycle. |
| I4 | Informational | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py` | import block | The dispatch test imports builder functions from three sibling test modules, coupling four test files. | No action. The pattern is explicitly planned in the spec and matches the existing epic dispatch tests. Independence in the ordering sense is preserved: every builder returns a freshly constructed dict. | `.claude/rules/general-unit-test.md` requires independence and isolation, both of which hold; the coupling is a maintenance consideration, not a policy violation. | The file's own docstring states the rationale, including that the split keeps both files under the 500-line limit. |
| I5 | Informational | `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` | whole file | The file is 508 lines, over the 500-line cap. | No action for this feature. | `.claude/rules/general-code-change.md` file-size limit. | `wc -l` reports 508. The path does not appear in `git diff --name-only ae6331f7693fb7c05e2c5c7f8416c46c469929fa..HEAD`, confirming the branch did not touch it. The branch instead added `orchestration-artifacts-parallel-dispatch.test.ts` specifically to avoid growing it, which is the correct response. Not attributable to this feature. |

## Cross-Runtime Parity Verification (method and result)

Parity was verified by execution, not by reading. Reading both files side by side is insufficient
here, because enum member order is rendered into message text and several Python-specific semantics
diverge in ways inspection misses.

Method:

1. Bundle both TypeScript cores with the repository's own esbuild into CommonJS in the scratchpad.
2. Build a corpus in Python from the same builders the committed test suites use, so the documents
   are representative rather than invented. 74 corpus documents covering the valid case and one
   targeted mutation per rejection branch across all 21 orchestrator invariants, all nine planner
   invariants, and both parse-failure paths, plus five deliberate divergence probes.
3. Serialize the corpus once and feed the identical strings to both runtimes.
4. Diff the two result arrays element-wise, comparing both content and order.

Result on the corpus (parseable documents):

```
CORPUS: 90/92 error strings matched across 74 documents; mismatches=2
```

Both mismatches are the invalid-JSON parser detail text described in finding A1. Restricting the
corpus to documents that parse as JSON yields 90 of 90 matched, in identical order, with zero
mismatches. This is consistent with, and independently corroborates, the cycle-0 measurement of 96
of 96 across 43 documents that the corrected rule text cites, and it confirms the scope qualifier
the rewrite added.

Result on the deliberate probes:

```
PROBES: 1/9 matched across 5 documents
```

Each probe reproduces exactly one of the three named divergence classes, confirming that the
corrected rule text describes real, currently-present behavior rather than a hypothetical:

| Probe | Class | Python | TypeScript |
| --- | --- | --- | --- |
| `mode = "it's open"` | `pythonRepr` quote selection | `found: "it's open".` | `found: 'it\'s open'.` |
| `items[0].state = "it's scheduled"` | `pythonRepr` quote selection, nested | `found: "it's scheduled".` | `found: 'it\'s scheduled'.` |
| `max_concurrency = 4.0` | integral float | 1 error | 0 errors |
| `recolor_generation = 0.0` | integral float, cascading | 3 errors | 0 errors |
| `cohorts[0].generation = true`, `recolor_generation = 1` | boolean/integer equality | 1 error | 3 errors |

## Scope-Boundary Re-Verification (execution evidence)

The prohibited-key and record-shape boundaries were re-verified by running the validators rather
than by reading them. Selected outputs:

```
depends_on at root        -> Parallel checkpoint carries prohibited key 'depends_on' at <root>.
depends_on at items[0]    -> Parallel checkpoint carries prohibited key 'depends_on' at items[0].
integration_branch        -> Parallel checkpoint carries prohibited key 'integration_branch' at <root>.
epic_merge_pr at root     -> Parallel checkpoint carries prohibited key 'epic_merge_pr' at <root>.
epic_merge_pr at items[0] -> Parallel checkpoint carries prohibited key 'epic_merge_pr' at items[0].
planner depends_on        -> Parallel planner checkpoint carries prohibited key 'depends_on' at items[0].
```

Rejection is explicit at any nesting level on both the orchestrator and planner surfaces, and the
manifest surface enforces the same rule. This satisfies the "actively rejected, not merely absent"
requirement.

Record shapes were exercised the same way. `mutations[]` rejects an out-of-enum `op`, a non-null
`item_key` on a `close`, an in-flight removal with no disposition, and a stray disposition on an
`add`. `drift_events[]` rejects an empty `escaped_paths` and an out-of-enum `action`.
`conflict_edges[]` rejects a self-edge, an unnormalized pair, a duplicate pair, and an out-of-enum
reason. The closed-mode completion gate reports per-item terminal-state failures, and the open-mode
gate additionally requires the run-close mutation record.

## Positive Observations

- The R1 rewrite resolved three of the seven cycle-0 Advisory findings at once. A3 and A4 asked
  specifically for the divergence to be recorded in the prose rule file, and A2's documentation
  component is satisfied by naming the class and linking the repo-wide potential entry.
- The remediation was correctly scoped to documentation. Changing `pythonRepr` here would have
  desynchronized the parallel port from the epic surface it mirrors; routing that fix to a separate
  potential entry is the right disposition, and the entry was actually written rather than merely
  promised.
- The mirror discipline held under edit. It would have been easy to update the source rule file and
  forget the extension mirror; both were changed in the same commit and remain byte-identical at the
  blob level.
- The R2 edit is a model of a low-risk documentation change: one appended prose bullet, zero
  checkbox mutations, and the divergence recorded in the same section and the same style as the
  pre-existing SA16 divergence note.
- The `jest.config.cjs` change adds a per-file coverage gate for every new module, including the
  `parallel-state-records.ts` split, at the uniform 85/75 thresholds. The passing run is therefore
  itself the coverage evidence for those five modules, not a separate claim.
- Both test suites already assert the invalid-JSON message by prefix rather than by full string.
  That is the correct design under the constraint described in A1, and it means no test pins a
  runtime-specific message.

## Verdict

**PASS. Blocking findings: 0.**

The cycle-1 remediation delivered its stated scope correctly and introduced no executable change.
The corrected parity claim is accurate in everything it asserts, and its two source line references
are exact. The six Advisory and five Informational findings are documentation-completeness items,
carried-forward runtime asymmetries that cannot be corrected on this branch, or pre-existing
repository conditions. None requires a further remediation cycle.
