# Drift Corpus Expected-Payload Generation (P3-T3)

Timestamp: 2026-09-29T18-00
Command: poetry run python SCRATCH/drift-expected.py
EXIT_CODE: 0
Output Summary:
ERROR-FIXTURE name=error-item-key-missing shape_ok=True
ERROR-FIXTURE name=error-items-not-a-list shape_ok=True
ERROR-FIXTURE name=error-non-object-root shape_ok=True
GENERATED name=escape-without-conflict result=no_new_conflict
GENERATED name=halt-both-starts-absent result=halt_required
GENERATED name=halt-drifter-started-later result=halt_required
GENERATED name=halt-equal-start-timestamps result=halt_required
GENERATED name=halt-one-pair result=halt_required
GENERATED name=halt-one-start-absent result=halt_required
GENERATED name=halt-several-pairs result=halt_required
GENERATED name=malformed-peer-radius-fails-closed result=halt_required
GENERATED name=no-escape-empty-changed-paths result=no_escape
GENERATED name=no-escape-inside-radius result=no_escape
GENERATED name=non-object-edge-ignored result=halt_required
GENERATED name=peer-not-in-flight-ignored result=no_new_conflict
GENERATED name=peer-radius-iso-timestamp-evaluated result=no_new_conflict
GENERATED name=reversed-existing-edge-not-new result=no_new_conflict
GENERATED name=tolerated-overlap-under-conflict-tolerance result=no_new_conflict
GENERATOR-SUMMARY generated=15 errors=3 mismatches=0

No `MISMATCH` and no `MISSING-FIXTURE` line. A18 wrote a fixture only after the generated payload
matched the hand-stated C1 table (result, escaped paths, pairs, halted keys) and the spec invariants.

Authoring note (P3-T2): the 18 input fixtures were written by a scratch helper
(SCRATCH/write-drift-inputs.py, not committed) that encodes the C1 table; each was confirmed by A11
(`JSON-OK`) before this generation step.
