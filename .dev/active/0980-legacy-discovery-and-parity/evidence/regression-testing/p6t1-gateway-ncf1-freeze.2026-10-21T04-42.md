# NCF1 checked repair freeze

Timestamp: 2026-10-21T04-42

Command: `SCRATCH/issue-980-p6t1-gateway-ncf1-freeze.py`

EXIT_CODE: 0

Output Summary: Three owned paths frozen after clean Black/Ruff/Pyright and 26 passing focused controls. Independent source confirmation reported clear; final task/native/isolation acceptance remains pending.

The repair preserves RegistryLocation validation before canonicalization, resolves the trusted host base, and verifies the complete resolved state still matches its fixed layout and workspace digest. ActivationStore.local remains unchanged and rechecks canonical/external state. Missing leaves require no construction writes; resolution and authority failures remain errors.

Fresh BODY coverage is 6/6 lines and 2/2 branches for _canonical_state_location, and 9/9 lines and 4/4 branches for installed_local_io. Qualified file coverage is 137/138 lines (99.275%) and 39/40 branches (97.5%), combining the fresh observations with exact AST-identical retained ranges. The raw focused file measurement is retained separately and is not presented as a whole-module run.

The 22 new IDs and four existing IDs are retained in the proof. Only the approved nested resolver stub changes in the legacy test; all other legacy callable ASTs are identical. Source/test sizes are 423/494/345 lines.

The initial Black formatting and single Ruff type-only-import finding remain in the evidence. All four loop3 gates passed without input drift. The proof-builder tuple/list metadata diagnostic is preserved in its archive; it did not change coverage observations.

The JSON enumerates this repair's three code paths and nineteen evidence files, including its own path through an external hash. The already-frozen seven diagnosis files are referenced separately and are not added to this repair-only staging enumeration. Original configure/native/init receipts, package assets and fixture bytes were not changed. Package rebuilding is coordinator-owned and serialized separately; no native or final-run execution occurred here.

Readable views are explicit UTF-8/LF without trailing whitespace. Use normalized_scoped_unified_diffs in the JSON for text review: it normalizes both sides to LF. The earlier proof's scoped_unified_diffs normalized only its after side and may therefore display unchanged CRLF lines as changed. Exact original/current bytes and hashes remain authoritative in the archived streams; this presentation qualification changes no earlier artifact.
