# AC-03 local profile verification

Timestamp: 2026-10-18 15:27:15 UTC
Criterion: `Configuration is loaded from a local domain profile.`
Status: VERIFIED

The accepted [profile boundary](../regression-testing/p1t10-executor-verification.2026-10-18T07-14.md) validates immutable repository-local configuration, roles, roots and inherited requirements. The accepted [initialization proof](../regression-testing/p3t2-executor-verification.2026-10-18T14-19.md) demonstrates configured source/target/combined projections. Their current source hashes remain preserved by P3-T3's final prior-path audit; the authorized binary-provider correction is separately measured.

P3-T3 completes the actual local selection/activation boundary. Current tests exercise the default path and custom profile paths, return the selected profile bytes/path, reject missing/malformed profiles, reject locator/argument disagreement and ambiguous candidates, and prevent a deleted active configuration from becoming inactive. The [native activation proof](../regression-testing/p3t3-windows-activation.2026-10-18T15-18.json) uses real local storage, observes protected activation through a new service instance and verifies local profile replacement. The [corrected initialization physical-byte proof](../regression-testing/p3t3-windows-initialization-byte-reproof.2026-10-18T15-23.json) independently verifies all six projected files.

The [independent executor audit](../regression-testing/p3t3-executor-verification.2026-10-18T15-27.md) confirms the complete clean ordered task gate, exact current/index bytes, all prior preservation requirements and adequate raw per-unit coverage. The criterion is therefore checked individually in all three source documents by changing only its checkbox. Its wording remains unchanged.

AC-04 remains unchecked because ordinary native-hook behavior is not yet integrated. CLI, generated assets, publication, installed-host validation and full-feature completion remain their existing independent criteria. The expected updated count is 11/66 checked in each source, with 55 remaining; the specification's separate seven Definition of Done and twelve seeded-test checkboxes remain unchanged.
