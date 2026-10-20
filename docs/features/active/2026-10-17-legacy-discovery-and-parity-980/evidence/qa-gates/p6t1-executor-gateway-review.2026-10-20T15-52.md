# P6-T1 gateway and doctor review

**SCOPED_FINDINGS_COMPLETE — changes required.** Six-file handoff: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-gateway-handoff.2026-10-20T15-39.json` (`2b4131888a8e9e580b3cdf58d63e5f7d6180016487f63d592728b22ba02b592b`).

- **GW1:** An unexpected serializer error after executor return escapes with no fixed diagnostic or exit code. Preserve refusal of replacement JSON and return fixed stderr/exit 3.
- **GW2:** Git enters its blocking pipe read before a timed wait. Bound the complete read/process lifetime while retaining bounded output and cleanup.
- **GW3:** Doctor scans a 4,095-character candidate under a 2,048-unit work policy, then returns success with 2,046 units remaining. Reserve path measurement and comparison work prospectively.
- **GP1:** Complete the exact typed docstring and eight comment locations enumerated in the JSON receipt. Preserve existing assertions and file limits.

The original ordered **86/86** and reverse **86/86** proof is retained. One bounded probe process exited 0; no suite or Git child ran. The Git observation proves call ordering only, not a wall-clock failure.

Raw probe and six original source/test streams: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-gateway-probe.2026-10-20T15-52.json`. Exact locations, counters, documentation list and repair bounds: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-gateway-review.2026-10-20T15-52.json`.

No open probe remains. Native host authority/revocation and integrated task acceptance remain pending. Current phase P6; next five: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.
