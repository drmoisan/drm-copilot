# P3-T3 consolidated independent review

Timestamp: 2026-10-18 14:38:38 UTC
Task: P3-T3 only
Disposition: two blocking implementation findings; no plan change

The [bounded diagnostic](../regression-testing/p3t3-executor-boundaries-initial.2026-10-18T14-38.json) passes six cases and fails the two below. All source hashes remain stable across the four-second invocation. The exact scope is the approved configuration/activation component and its mechanical filesystem split.

## R1: implicit deactivation skips protected-state freshness

ActivationStore.select returns immediately for a protected deactivation record and no explicit profile selector. It never executes the ordinary selection's second registry read. The probe changes the protected record to an active generation during the first read and receives state=inactive with reads=1. A configured gate can therefore consume stale deactivation even though the registry has been reactivated.

Require the inactive fast path to verify unchanged protected bytes before returning. Preserve the valid deliberate-deactivation behavior, including ignoring leftover malformed workspace files during an implicit inactive gate check. Add a direct concurrent-reactivation regression. This applies the existing active/inactive fail-closed contract and the already implemented selection freshness rule.

## R2: candidate ambiguity is not revalidated under the commit guard

configure checks configured candidate paths before entering the mutation guard. Its guarded input check only binds the two output paths and protected record. In the probe, the second trusted authorization callback creates a known alternate candidate before guarded publication. The operation still returns success and writes the protected activation, config directory and locator, although its known candidate set has become ambiguous.

Bind the candidate observations used for the ambiguity decision and recheck them under the shared guard before revocation or publication. Retain fail-closed handling if they change during the operation. Add a direct competing-candidate regression without weakening successful root activation or explicit profile selection.

## Passing reviewed boundaries and limits

The mandatory trusted authorization/revocation callbacks are outside ConfigurationRequest. Requests contain no role, native identity or authority path. RegistryLocation fixes platform-specific external state locations; NativeRegistry supplies bounded fixed-name reads, cooperative exclusion, anchored per-file publication and explicit error propagation. Root activation records protected active intent before workspace publication, while deactivation retains a session-independent generation/predecessor tombstone.

The worker's parent-identity correction is measured as passing: changing the discovery parent at protected-registry publication no longer permits the proposed profile write. Partial workspace publication retains protected active state and blocks controlled selection. These checks do not replace final unit coverage, native provider integration or the future P8 authority-request schema correction.

No production, test, policy, checkpoint, staging or task checkoff was performed by the verifier. Final acceptance remains pending correction, clean ordered gates and current-byte proof.
