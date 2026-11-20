# P4-T9 registry subset review

Timestamp: 2026-10-19T13-08
Command: poetry run python SCRATCH/issue-980-p4t9-registry-review.py
EXIT_CODE: 0
Output Summary: REGISTRY_SUBSET_REVIEW_PASS; no findings or open behavioral probes.

Reviewed only the five frozen registry/public-export/dispatch-test/neutrality paths. The current protocol alias, fixed 12-identity metadata, complete pre-import profile/selection guard, literal dispatch, combined accounting and narrow neutrality allowance satisfy this subset contract. The emitter hash binds composition proof and is not included in this implementation review.

Retained proof: clean ordered format/lint/types and 77 cases, 63/63 statements and 28/28 branches. All five source/test bindings, the dependency binding, focused raw streams and 48 lossless archived payloads reconcile. The earlier import-trap failure remains preserved; its corrected observer retains the intended optional-import negative boundary. No suite or behavioral probe was replayed.

Commit closure: registry/public exports require no uncommitted emitter API; all fixed adapter imports match accepted baseline blobs, and the unchanged pipeline call uses only the baseline inventory_result signature. The 77-case composition proof remains bound to the frozen current emitter, whose new semantics are outside this review.

The receipt checker initially expected a failed-case summary in historical stdout. Its retained diagnostic is qualified: that run reported 31 passes on stdout and the import-trap AssertionError on stderr before exiting 1. Only the checker assumption was corrected.

This subset can be checkpointed. Shared/core subset review and complete final gates remain pending. No P4-T9 or AC checkbox changed; current accepted counts remain 40/84 tasks and 13/66 AC.
