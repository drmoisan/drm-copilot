# p3t7-pass3-native

Timestamp: 2026-10-19T00-43
Command: poetry run python SCRATCH/issue-980-p3t7-native.py . SCRATCH SCRATCH/issue-980-p3t7-final-native.json
EXIT_CODE: 0
Output Summary: PASS scoped P3-T7 stage 7; duration 600.041 seconds. Exact source hashes are in the paired JSON receipt.

```text
PASS all seven kinds form a structurally valid draft
PASS dry run preserves exact original tree and authority
PASS native guarded publication reports every created artifact
PASS original bytes survive native publication
PASS persisted report remains an immutable projection
PASS mapped output hashes match exact native bytes
PASS exact repeat skips publication without changing bytes
PASS repeat preserves identical immutable mapping
PASS different existing output fails without overwrite
PASS controlled native partial publication returns failure
PASS partial failure retains uncertainty and originals
PASS persisted report never claims partial completion
PASS migration never activates the draft root
```
