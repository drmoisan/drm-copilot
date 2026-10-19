Timestamp: 2026-10-19T02:55:04.585902+00:00
Command: poetry run python SCRATCH\issue-980-p4t1-native.py docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p4t1-final-native-result.2026-10-19T02-54.json
EXIT_CODE: 0
Output Summary:

```text
PASS native capture includes configured source, test, project and documentation bytes
PASS native capture prunes dependency and output frontiers before metadata or bytes
PASS excluded dependency and artifact frontiers retain explicit accounting
PASS native source hash preserves CRLF and Unicode bytes
PASS native precapture binds documentation to actual immutable Git bytes
PASS native default and dry-run analysis preserve tree and semantic identity
PASS native ledger seed proposals remain uninspected and unassigned
PASS native mutation preview validates without publication or invalidation
PASS native guarded first publication succeeds and invalidates prior authority
PASS native publication creates exactly one inventory and preserves all existing bytes
PASS native repeat publication skips the exact existing artifact
PASS native changed source rejects stale request before publication
PASS native bounded read failure retains unavailable input without fabricated bytes
{
  "checks": [
    "native capture includes configured source, test, project and documentation bytes",
    "native capture prunes dependency and output frontiers before metadata or bytes",
    "excluded dependency and artifact frontiers retain explicit accounting",
    "native source hash preserves CRLF and Unicode bytes",
    "native precapture binds documentation to actual immutable Git bytes",
    "native default and dry-run analysis preserve tree and semantic identity",
    "native ledger seed proposals remain uninspected and unassigned",
    "native mutation preview validates without publication or invalidation",
    "native guarded first publication succeeds and invalidates prior authority",
    "native publication creates exactly one inventory and preserves all existing bytes",
    "native repeat publication skips the exact existing artifact",
    "native changed source rejects stale request before publication",
    "native bounded read failure retains unavailable input without fabricated bytes"
  ],
  "count": 13,
  "elapsed_seconds": 42.4663326000009,
  "scope": "Windows native operational fixture under SCRATCH; core analyzer remains pure and host Git execution is injected",
  "working_tree_mutations": "synthetic fixture only",
  "pinned_revision": "4d5454c2b886fc3a6f096ce08f6211648dcaaa4b"
}

```

Exact source/test bytes unchanged: True
Raw command output and hashes: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t1-final-native-run-025504.2026-10-19T02-55.json
