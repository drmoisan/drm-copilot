# P3-T6 no-equivalence reference compatibility finding

Timestamp: 2026-10-18 18:27:24 UTC

Status: bounded prerequisite correction required; no task acceptance.

The full affected suite [retains one failure after 301 passes](../regression-testing/p3t6-pass1-tests.2026-10-18T18-25.md), with 430 collected and 128 unrun, in 30.39 seconds. The unchanged accepted test is `test_references.py::test_transport_entries_resolve_their_declared_repository[source-snapshot-manifest-artifacts-source_repository-feature-contract]`. Its sole imported target has no validated replica-equivalence group. The test receives REFERENCE_KIND instead of its established unique declared-repository resolution.

Independent source inspection confirms the cause in `ReferenceIndex._replica_targets`: the implementation appends the imported target before checking whether matching `self.replicas` entries exist, creating an apparent group and then applying manifest physical-path filtering. The failing reference source hash was `6222b7135dce93869b02e9e00276d31b4f648dc3c9b42e4b5c8fdb8f8d904ed2`; the command records stable source/test bytes. This evidence supersedes the initial process-status estimate that the suite had stopped without a failure.

The supported correction is confined to the already authorized references.py: return the original target immediately when no proven replicas match, then include the imported representative and select physical imported members only within an actual validated group. Keep ordinary duplicate, conflicting-byte and unbound-copy rejection unchanged. This restores the prior single-target resolver contract; it does not waive complete loader, manifest member/hash, revision, graph or writer validation.

Required narrow checks are the existing source/extension manifest regression cases and retained exact physical manifest/source-contract selection, common outgoing-link/source-proof exclusion, conflicting/unbound copies and ordinary duplicates. Rebind the existing 13-case R1 and seven-case R2 matrices after the final reference correction. Retain the 44-case API result for its original hashes; documentation-only API edits can be bound by executable AST and the reference dependency by those updated narrow proofs. Do not claim all six production bytes remained identical after this correction.

Complete documentation/size preparation before restarting the established seven-stage task gate. The failed full run, prior passing proofs and all exact source identities remain historical evidence. Original task baseline and nine-path scope remain unchanged; plan progress is 29/84 and AC progress is 11/66.
