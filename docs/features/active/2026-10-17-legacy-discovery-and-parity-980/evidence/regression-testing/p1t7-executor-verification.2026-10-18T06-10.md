# P1-T7 independent executor verification

Timestamp: 2026-10-18T06-10
Command: poetry run python SCRATCH/issue-980-verify-p1t7.py
EXIT_CODE: 0
Output Summary: 104 independent schema cases passed; nine control schemas complete the 26-schema v2 catalog; 23 exact staged paths, 33 byte-identical packaged resources and 115 unchanged prior-task paths verified.

## Scope and acceptance

Verified the [specialist handoff](../other/p1t7-control-schemas.2026-10-18T06-09.md), all nine canonical schemas, both new test modules and their fresh in-memory fixture helper. The [machine receipt](p1t7-executor-checks.2026-10-18T06-10.json) records every owned path, staged Git blob, SHA-256, physical line count and independent case result. The maximum task-file length is 430 lines. No executable production implementation or prior schema/helper/dependency bytes changed outside the two declared resource manifests.

Activation retains exactly its four specified fields; service-result retains its ten-field result_version envelope. The other seven control documents use the exact v2 artifact header. All 26 canonical v2 schemas pass Draft 2020-12 metaschema validation, have unique versioned URNs, and resolve through the complete local resource closure. Thirty-three packaged resources comprise those 26 schemas and the seven frozen v1 schemas. Canonical bytes, packaged bytes, manifest digests and sizes match exactly.

Independent envelopes verify explicit draft initialization with omitted and empty production roots, required roots for configured initialization, exact versions, forbidden caller executables/receipt destinations, actionable errors and JSON pointers, output-manifest scope, capability prerequisites, invocation lifecycle, one-use record shape and migration activation restrictions. The probe also checks all 16 existing valid/invalid example pairs and unsupported versions of their valid examples.

Receipt principal and mode boundaries pass: native-root planning requires explicit native attribution with null analyst role/invocation/output fields; discovery-agent output requires its exact role, invocation and output manifest. Missing or local-user attribution fails. Root receipts cannot satisfy analyst stop, analyst receipts cannot authorize planning, and invalid output cannot claim a pass. A valid reviewer FAIL output remains representable without granting completion authority.

These are schema contracts. Protected-store provenance, actual native attribution, equality of repeated bindings, content/manifest truth, expiry, atomic token consumption, operation-specific service semantics and current capability enforcement remain assigned to their later implementation tasks. A schema-valid workspace document grants no permission.

## Quality evidence

| Check | Verified result | Evidence |
| --- | --- | --- |
| Black, final ordered pass 3 | Exit 0; three unchanged files | [Formatting](p1t7-format-pass3.2026-10-18T06-08.md) |
| Ruff, pass 3 | Exit 0; zero findings | [Lint](p1t7-lint-pass3.2026-10-18T06-08.md) |
| Full Pyright, pass 3 | Exit 0; zero errors/warnings | [Types](p1t7-types-pass3.2026-10-18T06-08.md) |
| Focused Pytest, pass 3 | Exit 0; 1,368 passed | [Tests](p1t7-tests-pass3.2026-10-18T06-09.md) |
| Reversed new modules | Exit 0; 294 passed | [Isolation](p1t7-tests-reversed.2026-10-18T06-07.md) |
| Resource consistency | Exit 0; 33 exact resources, no drift | [Resource check](p1t7-stage-check-final.2026-10-18T06-09.md) |
| Exact scope and prior bytes | Exit 0; 23 staged paths, 115 prior paths unchanged | [Final audit](p1t7-task-audit-final.2026-10-18T06-09.md) |
| Independent executor checks | Exit 0; 104 cases and corrected staged-byte audit | [Machine receipt](p1t7-executor-checks.2026-10-18T06-10.json) |

Raw coverage independently confirms 312/312 executable lines and 132/132 branch arcs in the unchanged resource loader/builder. Both modules retain 100% line/branch coverage with zero delta. New executable production coverage is not applicable to this schema/test-only task. TypeScript and PowerShell implementation gates are not applicable to this task; final repository-wide QA remains pending.

## Retained corrections and command provenance

The first Ruff pass reported S105 for the synthetic TOKEN name. The specialist renamed it OPAQUE_REFERENCE without adding a suppression and restarted the ordered loop. The first final audit detected terminal blank lines in eight schemas and their generated copies; the specialist removed only those blank lines, regenerated resources, and completed ordered pass 3. The final executor run confirms staged whitespace is clean. Reversed tests remain valid because their source and schema semantics did not change during terminal-whitespace normalization.

An initial executor attempt to run the independent probe through multiline `poetry run python -c` returned no output and is treated as unexecuted, as documented by execution-environment. The corrected `poetry run python SCRATCH/issue-980-probe-p1t7.py` returned explicit 104-case/26-schema/16-example-pair counts. Final verification used the file-based command above and bound the same checks to corrected staged bytes. No success was inferred from the no-output attempt, and no broad test suite was repeated by the executor.

## Acceptance-criteria assessment

- **AC-10, verified:** All required schemas exist and are versioned. The complete 26-schema v2 inventory, seven preserved v1 schemas, exact URNs, Draft 2020-12 validity, local reference closure and unsupported-version negatives are proved across P1-T3 through P1-T7. Check this criterion individually in spec.md, user-story.md and the synchronized issue.md mirror.
- **AC-11, pending:** Examples pass the schema test registry, but the traceability contract additionally requires every example through the installed public catalog entry point. That runtime path remains later work.
- **AC-12, pending:** Invalid schema data produces locations/messages, but authoritative code/path/pointer/next_action findings require the parsing/catalog implementation.
- **AC-13, pending:** Cross-artifact resolution and graph invariants remain Phase 2 work.
- **AC-14, pending:** Closed core fields and namespaced extension payload shapes are present. Authoritative expected-kind selection and configured extension-schema validation must still prove that extensions cannot bypass core validation.

P1-T7 passes its bounded acceptance criteria. Check only P1-T7 and AC-10 at this transition. This advances the plan to 11/84 and feature acceptance to 1/66 in each source; P1-T8 is the next task. No full-feature validation, authority, publishing or final QA criterion is implied.
