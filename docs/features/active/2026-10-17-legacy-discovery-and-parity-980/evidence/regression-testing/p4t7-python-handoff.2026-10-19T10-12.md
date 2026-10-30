# P4-T7 Python parser checked subset

Timestamp: 2026-10-19T10-12
Command: poetry run python SCRATCH/issue-980-p4t7-python-freeze.py
EXIT_CODE: 0
Output Summary: FROZEN_READY checked subset; full P4-T7 review and acceptance pending.

Scope: new `packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_python.py` (289 lines) and `tests/discovery_runtime/analyzer/test_dependency_python.py` (309 lines), plus this prefix's evidence. No shared-source, integration, other-parser, checkpoint, plan or Git changes were made by this worker.

Baseline: reuse parent 09:44 baseline covering ten absent paths and 62 accepted streams. New pair had no previous executable coverage; predecessors and the 152-case shared proof were not rerun. Checked shared source is commit `1dd386135f0f52c247d7b85ccd766cbc63ebaf4d`, SHA256 `3b55bb3f4c79348851d2e8838c7233ab26aee1274526f916b55e2443d6289253`. Every focused7 command records that exact shared hash before and after execution. The subsequent shared SR1-SR4 repair is outside this proof.

Plan and implementation: approved P4-T7 finite requirements/setup.cfg declaration parser uses immutable shared carriers and budgets. Strict ConfigParser disables interpolation, rejects DEFAULT declarations/inheritance and duplicate sections/options. Original physical CR/LF anchors survive normalized INI validation. Unrelated option continuations cannot introduce dependency keys. Safe names/extras/constraints and recognized marker names survive; marker values and reference targets do not. Fixed errors discard the complete population. Includes/options/editable entries, escaped continuations, dynamic attr/file lists and unsupported grammar are rejected; no execution, expansion or input traversal occurs. The parser creates no inventory rows, identifiers, provenance or evaluated graph claims.

Public seam: `parse_python_dependencies(content: bytes, *, format: Literal["requirements", "setup-cfg"], limits: DependencyLimits) -> DependencyResult`. Formats are flat, so no recursive max_depth traversal occurs. Work charges input/selected character scans, marker/extras scanning and configuration traversal; conservative text charges precede configuration allocation. Shared add owns candidate/retained text charges. The finite grammar is intentionally narrower than complete PEP508.

Diffs: complete new-file snapshots are `p4t7-python-full-file-1.2026-10-19T10-12.txt` and `p4t7-python-full-file-2.2026-10-19T10-12.txt`.

QA: focused7 completed Black check, Ruff, strict scoped Pyright and 98 in-memory Pytest cases in that order on identical source bytes. New lint findings: 0; type diagnostics: 0; failing tests: 0. Parser coverage: 154/154 statements, 86/86 branches; every one of its seven callables is 100% covered. No new classes. Tests cover finite grammar, redaction, physical anchors, malformed/ambiguous INI, unsupported constructs, exact resource boundaries and exhaustion after valid prefixes. Test cases create no temporary files or external dependencies. Whole-repository coverage and task acceptance are not claimed.

The first test run passed 91/93 tests; its two failures were assertions expecting the code spelling in the fixed human message. Assertions now verify both the actual frozen code and message. Failure streams remain retained. Intermediate formatting/lint corrections and comment/documentation changes are followed by the final clean sequence. Earlier mixed-separator scratch path presentations were normalized without changing raw stream hashes.

Evidence: `p4t7-python-freeze.2026-10-19T10-12.json` contains exact source hashes, all 98 executed node IDs, per-callable coverage, timings and evidence hashes. `p4t7-python-focused7-*.2026-10-19T10-11.json` retains independent raw stdout/stderr hashes and scratch-relative stream references. Exact executed gate/freeze harnesses and coverage JSON are retained beside the manifest. Review, repaired-shared composition, integration and final ordered task validation remain pending.
