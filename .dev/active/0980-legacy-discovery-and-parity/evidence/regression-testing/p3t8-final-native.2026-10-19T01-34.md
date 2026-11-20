# p3t8-final-native

Timestamp: 2026-10-19T01-34
Command: poetry run python SCRATCH/issue-980-p3t8-native.py . SCRATCH SCRATCH/issue-980-p3t8-native-result.json
EXIT_CODE: 0
Output Summary: PASS scoped P3-T8 stage 7; duration 3.258 seconds. Exact source hashes are in the paired JSON receipt.

```text
PASS native pagination returns sorted selected files
PASS native original hashes and Unicode CRLF spans are retained
PASS configured revision is not asserted for working bytes
PASS native literal search returns exact ordered match spans
PASS native exact project entry read is supported
PASS denied selection reads no target bytes
PASS successful and denied operations preserve native tree
PASS native adapter enforces the requested byte limit
PASS native continuation rejects changed source bytes
PASS native imported evidence retains immutable source identity
PASS native imported reads preserve every artifact byte
PASS unrequested corrupted payload blocks requested member release
PASS all native opens receive positive bounded byte limits
PASS no activation or mutation lock is created
{"count": 14, "elapsed_seconds": 1.906}
```
