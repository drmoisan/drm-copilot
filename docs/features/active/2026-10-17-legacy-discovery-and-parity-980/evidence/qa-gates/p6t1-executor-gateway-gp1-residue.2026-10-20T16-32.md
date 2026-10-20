# P6-T1 gateway GP1 residue (2026-10-20T16-32)

Timestamp: 2026-10-20T16-32
Command: `poetry run python SCRATCH/issue-980-p6t1-gateway-gp1-residue.py`
EXIT_CODE: 0

Output Summary: GW1–GW3 functional repairs are confirmed. Five existing GP1 contract targets require text-only corrections; no new behavioral finding or open probe remains.

- GP1-R1: `packages/discovery-runtime/src/drm_copilot_discovery/gateway.py:94` — `_failure`. The code parameter describes a simulated process status; value: JsonObject | None describes a context-exit exception. Describe code as the fixed gateway failure code and value as optional parsed JSON context. Neither parameter carries a process status or exception.
- GP1-R2: `packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py:148` — `LocalServiceIO.writer`. The required CapturedWorkspace baseline is described as possibly None. Describe the required accepted capture used for the same-root guarded writer; remove the absent-baseline alternative.
- GP1-R3: `packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py:175` — `LocalServiceIO._recapture`. The required CapturedWorkspace baseline is described as possibly None. Describe the required prior capture whose profile and repository are reloaded; remove the absent-baseline alternative.
- GP1-R4: `tests/discovery_runtime/gateway_test_support.py:231` — `MemoryProcess.__exit__`. The BaseException | None value is described as optional decoded context. Describe value solely as the context-exit exception instance, or None when no exception occurred.
- GP1-R5: `tests/discovery_runtime/test_gateway.py:434` — `test_unexpected_executor_failure_cannot_claim_empty_effects.refuse`. The test double claims to return DiscoveryResult and raise AssertionError, but unconditionally raises ValueError. State that the test double does not return and deliberately raises ValueError after invocation; preserve its declared signature and executable body.

Preserve executable AST, signatures, decorators, assertions and all 98 passing case identities. The original review, probes and repair freeze remain immutable.

Gateway is dependent WIP: its fixed lazy executor requires the uncommitted core service modules. Preserve the authorized six core modules and three tests with explicit unaccepted status; retain the 40/109 passing prefix, one operational interruption, 68 unexecuted cases and absence of saved coverage.

The combined final reverse run and P6-T1 acceptance remain pending. Plan/AC counts remain 46/84 and 23/66. Next: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.
