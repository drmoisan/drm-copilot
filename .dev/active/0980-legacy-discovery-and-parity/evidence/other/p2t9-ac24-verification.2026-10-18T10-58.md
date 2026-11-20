# AC-24 completion-policy verification

Timestamp: 2026-10-18 10:58:28 UTC

Criterion: Completion checks coverage, evidence, unresolved behavior, acceptance scenarios, and configured platform dimensions.

Status: PASS for the pure completion-policy criterion. The distinct CLI, report-rendering and native-hook criteria remain pending.

| Required behavior | Implemented composition and measured proof |
| --- | --- |
| Coverage | `validation._Validation.complete` invokes accepted coverage rules with `complete=True` over the configured source records. P2-T6's 48 independent cases prove exact inventory/ledger accounting; the current mode probes prove configured inventory/disposition omissions block discovery while honest drafts remain structurally valid. |
| Evidence | Mandatory evidence/claim findings remain in every mode. Current additional probes reject corrupted runtime evidence even with all completion switches disabled and planning set to none; enabled required-feature evidence rejects absent qualifying source proof. P2-T3/P2-T4 independently verify payload integrity and observed/runtime claims. |
| Unresolved behavior | Current required-open-legacy cases fail completion despite an approved target decision; optional uncertainty remains represented without an unrelated completion failure. The source observation bytes stay unchanged. The configured gate and scoped intentional-unspecified approval behavior are measured independently. |
| Acceptance scenarios | Completion invokes `validate_acceptance(..., complete=True)` with the current dimension obligations. Current probes show missing required scenarios block when configured; accepted P2-T7 evidence proves pending/superseded scenarios, wrong criterion/approval origin and incomplete client/platform/mode tuples cannot satisfy requirements. |
| Configured platform dimensions | Completion invokes `validate_dimensions(..., complete=True)` before acceptance and target parity. Accepted P2-T7's 49 cases prove monotonic global/client/feature requirements, optional dimensions, explicit applicability and approved waivers. Accepted P2-T8's 53 cases prove target coordinates and consistent online/offline/mobile classifications. The current complete configured graph passes discovery/parity/planning, and the composed production path is fully covered. |

Current evidence: [final executor verification](../regression-testing/p2t9-executor-verification.2026-10-18T10-58.md), [63-check numerical proof](../regression-testing/p2t9-executor-checks.2026-10-18T10-58.json), [107-test final run](../regression-testing/p2t9-pass7-tests.2026-10-18T10-54.md), and [107-test reversed run](../regression-testing/p2t9-pass7-isolation.2026-10-18T10-57.md). Prior accepted composition inputs are [P2-T6 coverage](../regression-testing/p2t6-executor-verification.2026-10-18T09-32.md), [P2-T7 dimensions/acceptance](../regression-testing/p2t7-executor-verification.2026-10-18T10-00.md), and [P2-T8 parity](../regression-testing/p2t8-executor-verification.2026-10-18T10-20.md). Their file hashes remain unchanged in the current 203-path comparison.

This checkoff does not claim a complete validation command, report rendering, protected native authority or planning-hook integration. The approved-target/open-legacy distinction remains a required P5 generation and P10 documentation handoff.
