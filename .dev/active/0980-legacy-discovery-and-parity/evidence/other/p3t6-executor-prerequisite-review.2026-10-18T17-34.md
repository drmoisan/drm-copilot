# P3-T6 bounded prerequisite review

Timestamp: 2026-10-18 17:34:56 UTC
Status: Supported bounded correction proposal; coordinator must record exact ownership before accepted-file edits. P3-T6 remains unchecked.

The worker's [two-case reproduction](../regression-testing/p3t6-prerequisite-probe.2026-10-18T17-31.json) and [command receipt](../regression-testing/p3t6-prerequisite-probe.2026-10-18T17-31.md) record PATH_WRITE_DENIED for a transported feature contract and DUPLICATE_ID/REFERENCE_AMBIGUOUS for an exact source export replica. Source hashes were unchanged. Independent read-only inspection confirmed both implementation paths; this review did not repeat the worker's run.

PathPolicy routes ordinary kinds to ordinary output roots. plan_mutation checks loader-derived kind/ID, and commit_mutation plus GuardedMutationWriter reconstruct/revalidate the policy. Relabeling members, substituting a profile or supplying a fabricated resolved target would bypass the intended contract. Separately, the loader assigns imported members their source ownership, while reference duplicate grouping does not distinguish an original from a manifest-bound identical export copy. The specification's transport section and source export layout require that configured local export, including combined repositories.

The supported subset is four existing modules: R/path_policy.py, R/mutation_plan.py, R/mutation_io.py and R/references.py. One new pure same-component helper R/transport_manifest.py contains shared manifest validation/value logic; PathPolicy is already 472 lines. The prescribed P3-T6 export/import suites retain the new behavior tests. No schema, provider, dependency or requirement change is proposed. The existing export/import outcome requires this integration, so no new independent outcome or replan is established.

Required correction boundaries:

- Reconstruct the schema-valid manifest from its actual bytes, recompute the canonical digest, verify unique paths/counts and exact member kind/ID/path/hash/size. Authored transport verification is never authority.
- Permit only manifest-bound members under the configured source-snapshot root with exact trusted grants. Reject specialist invocation. The default ordinary route remains unchanged.
- Accept only absent creation or identical existing-byte skip. Validate the complete prospective graph and member set, publish the manifest last, and carry the context through plan reconstruction, fresh path resolution, guarded publication and postchecks. Retain full input/parent freshness, invalidation and truthful partial results.
- Normalize replicas only after validated manifest physical-path/entry membership and matching repository/full revision/origin/kind/ID/member pointer/raw bytes. Two ordinary duplicates, unbound imported copies and conflicting bytes retain their errors. Keep all physical inputs in the snapshot and input manifest; no first-match or status-based exemption.
- Preserve exact prior hashes except coordinator-authorized paths. A separately checked prerequisite checkpoint may precede full API integration. New component splits require their exact paths recorded before editing.

Verification starts from accepted commit 27753e5f8b9a6cd1d85b9d1d28d2999800af209a, 255 accepted predecessor paths and 24 frozen paths. Progress remains 29/84 tasks and 11/66 criteria. Next tasks are P3-T6, P3-T7, P3-T8, P4-T1 and P4-T2.
