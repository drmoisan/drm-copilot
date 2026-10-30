# Preflight fixes for remediation cycle 2 (Phases 17 and 18)

Timestamp: 2026-10-30T11-29
Plan: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md
EXIT_CODE: 0
Output Summary: Single-pass preflight of Phases 17 and 18 against the tree at the head of `feature/legacy-discovery-and-parity-980`. Every cited file, symbol, heading, suite and search literal was re-derived; two trivial anchor defects were fixed in task text only, no task was added, removed or reordered, and no substantive defect was found. The branch-current validator passed before and after the fixes.

## Fixes

1. `[P17-T2]` | stale anchor | The Python test condition read "`consumed_at` matches the schema timestamp pattern". The `timestamp` definition in schemas/discovery/v2/common.schema.json carries `format` `date-time` and no `pattern`, so the condition now names the schema format and the helper that checks it: `is_rfc3339_timestamp` in tests/schemas/discovery/v2_schema_test_support.py (verified to accept the millisecond spelling `consumeSentinelGrant` writes through `toISOString()`). The asserted value is unchanged.
2. `[P17-T2]` | ambiguous anchor | The acceptance read "the fixture record keys equal the keys of examples/discovery/v2/host-observation.example.yaml". The example is a sentinel tool observation carrying the grant quartet (`tool`, `input_sha256`, `expires_at`, `state`), which `ConvertTo-DiscoveryHostObservationRecord` writes only when a sentinel input digest is supplied, so the shell record cannot carry them. The acceptance now names `records.tool`. The asserted key set is unchanged.

## Checks that found no defect

- Design facts: `consumeSentinelGrant` writes the `.consumed` latch through `createExclusive` with `canonicalJson` and never rewrites the record; `Get-DiscoverySessionObservation` reads `.json` names only; `Get-DiscoveryObservationEvidence` requires `state` `consumed`; `ConvertTo-DiscoveryHostObservationRecord` derives the reference from the tool-call identifier digest and writes `state` `issued`; `Add-GateSentinelObservation` hand-writes both records with `state` `consumed`; `recordObservation` hand-writes `state` `issued`.
- Acceptance literals: `git grep -c -F "'state'] = 'consumed'" -- tests/scripts` prints one line (the test support) before P17-T4; `git grep -c -F "never rewritten" -- docs/engineering/legacy-discovery-and-parity/enforcement.md` prints nothing before P17-T7.
- Set S references `observation-tool-alpha` and `observation-shell-alpha` appear in exactly the four suites and the test support the plan names; the cases the plan names by title exist.
- The two bundled mirrors of CL/DiscoveryCapability.psm1 are byte-identical to the source before P17-T4.
- DTTEST/test_discovery_documentation_contracts.py pins no sentence of `## Capability probe`; the P17-T7 wording "updated only where it pins the replaced sentence" is conditional and needs no change.
- SCRATCH is defined as `<session scratchpad>/issue-980/`; no line-number or commit-SHA citation appears in Phases 17 and 18.
