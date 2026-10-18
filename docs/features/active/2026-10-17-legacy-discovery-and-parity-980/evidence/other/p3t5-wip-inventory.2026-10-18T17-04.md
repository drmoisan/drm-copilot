# P3-T5 checked WIP milestone

Timestamp: 2026-10-18T17-04
Status: CHECKED_WIP_FROZEN_NOT_TASK_ACCEPTANCE
Acceptance baseline: 1cc73b60cd636f186ca0269bf3942d32acd18105

The new evidence_linking module composes the accepted schema/reference/evidence validators and mutation planner/writer. Immutable EvidenceLink and EvidencePayload values select a local artifact/member, exact original digest, supplied record and create-only payloads. Only a schema-recognized evidence-reference array can change; observation, execution, approval and unrelated link content remain unchanged. Exact grants and invocation inputs are forwarded, not created.

Baseline Ruff and full Pyright passed; 90 existing evidence/revision tests passed in 19.71 seconds. Raw baseline coverage is retained. The three initial authored paths did not exist, so their baseline coverage is not applicable.

Current Black/Ruff/full Pyright pass. The corrected focused run passed 47 cases in 23.17 seconds, including a complete real runtime evidence mutation plan. Eleven pinned/checksum/composed writer cases were deliberately not part of this bounded WIP check and remain pending. Full callable coverage, reversed isolation, contracts, composed integration and final index audit remain pending. No task acceptance, plan checkoff or later-task authorization is implied.

Retained failures include two runtime-guard typing diagnostics, import/format/lint preparation findings, a duplicate-artifact fixture that omitted required captured bytes, and an assertion using the wrong accepted path-denial code. The verifier's real-planner finding exposed an incomplete transport-form link. The correction uses the accepted local artifact_kind/id form; exact payload path/checksum remain in the evidence record. The original failing probe remains available. Earlier pure projections passed 46 cases but did not establish complete graph validity; the corrected 47-case run includes that missing proof.

The coordinator-authorized fixture-only split is evidence_test_support.py. All four files are below 500 physical lines. All 251 accepted prior paths and 24 frozen v1/export paths remain unchanged. Unit stores remain in memory. This component introduces no native provider; final integration will compose the existing writer and will not repeat unrelated initialization/platform runs.

Exact hashes, completed evidence paths and pending gates are in the sibling JSON inventory. Source files are frozen for the requested progress commit; the coordinator owns staging and commit execution.
