Timestamp: 2026-10-19T02:44:15.739859+00:00
Command: poetry run python SCRATCH\issue-980-p4t1-native.py docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p4t1-final-native-result.2026-10-19T02-44.json
EXIT_CODE: 1
Output Summary:

```text
PASS native capture includes configured source, test, project and documentation bytes
PASS native capture prunes dependency and output frontiers before metadata or bytes
PASS excluded dependency and artifact frontiers retain explicit accounting
PASS native source hash preserves CRLF and Unicode bytes
PASS native precapture binds documentation to actual immutable Git bytes
PASS native default and dry-run analysis preserve tree and semantic identity
PASS native ledger seed proposals remain uninspected and unassigned
Traceback (most recent call last):
  File "SCRATCH\issue-980-p4t1-native.py", line 118, in <module>
    plan = plan_inventory(baseline, result, grants=(grant,))
  File "WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py", line 270, in plan_inventory
    return plan_mutation(baseline, (change,), grants=grants, invocation=invocation)
  File "WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py", line 413, in plan_mutation
    raise MutationError(
    ...<3 lines>...
    )
drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

```

Exact source/test bytes unchanged: True
Raw command output and hashes: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t1-final-native-run-024415.2026-10-19T02-44.json
