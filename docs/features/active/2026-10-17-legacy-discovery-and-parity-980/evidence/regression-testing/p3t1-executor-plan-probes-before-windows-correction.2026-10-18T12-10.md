# P3-T1 retained mutation proof before Windows correction

Timestamp: 2026-10-18T12-10
Command: poetry run python SCRATCH/issue-980-p3t1-probes.py
EXIT_CODE: 0
Output Summary: The pre-pause run completed 42/42 bounded in-memory mutation checks with stable source hashes. It is preserved after explicit user resume; it does not establish corrected native-provider behavior.

Captured completion: 2026-10-18T11:42:20.845963+00:00. During the requested WIP freeze and pause, this result remained in SCRATCH and no task receipt or checkoff was written. The source hashes and all cases are preserved in [the JSON result](p3t1-executor-plan-probes-before-windows-correction.2026-10-18T12-10.json).

The probe imports mutation_plan and mutation_io and supplies memory primitives to GuardedMutationWriter. It records the provider hash as part of its surrounding source set but does not import or execute LocalMutationPrimitives. The actual Windows smoke separately found that attribute-only directory access did not enforce the intended rename restriction. Native acceptance therefore remains open until the corrected access flags pass their direct tests and the real Windows smoke in the final ordered gate.

```text
{"name": "create-posix", "passed": true, "details": {"ok": true, "root": "/workspace", "writes": ["docs/migration/discovery/product-decisions.yaml"]}}
{"name": "create-windows", "passed": true, "details": {"ok": true, "root": "C:/workspace", "writes": ["docs/migration/discovery/product-decisions.yaml"]}}
{"name": "create-unc", "passed": true, "details": {"ok": true, "root": "//server/share/workspace", "writes": ["docs/migration/discovery/product-decisions.yaml"]}}
{"name": "unchanged-skip", "passed": true, "details": {"ok": true, "status": "skipped"}}
{"name": "digest-replacement", "passed": true, "details": {"status": "updated"}}
{"name": "repeatable-dry-run", "passed": true, "details": {"repeatable": true, "writes": 0, "revocations": 0}}
{"name": "plan-invalid-prospective", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_IDENTITY", "message": "MUTATION_IDENTITY: Proposed artifact kind/ID differs"}}
{"name": "plan-wrong-id", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_IDENTITY", "message": "MUTATION_IDENTITY: Proposed artifact kind/ID differs"}}
{"name": "plan-wrong-kind", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_INVALID", "message": "MUTATION_INVALID: Prospective graph is invalid"}}
{"name": "plan-missing-grant", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_GRANT", "message": "MUTATION_GRANT: No exact kind/ID/path write grant"}}
{"name": "plan-grant-id", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_GRANT", "message": "MUTATION_GRANT: No exact kind/ID/path write grant"}}
{"name": "plan-grant-kind", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_GRANT", "message": "MUTATION_GRANT: No exact kind/ID/path write grant"}}
{"name": "plan-grant-path", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_GRANT", "message": "MUTATION_GRANT: No exact kind/ID/path write grant"}}
{"name": "plan-stale-digest", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_PRECONDITION", "message": "MUTATION_PRECONDITION: Original content digest differs"}}
{"name": "plan-missing-original-digest", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_PRECONDITION", "message": "MUTATION_PRECONDITION: Original content digest differs"}}
{"name": "plan-empty-changes", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_LIMIT", "message": "MUTATION_LIMIT: Provide a bounded nonempty change set"}}
{"name": "plan-duplicate-path", "passed": true, "details": {"rejected": "PathPolicyError", "code": "PATH_COLLISION", "message": "PATH_COLLISION: 'docs/migration/discovery/product-decisions.yaml': Remove duplicate or aliased paths."}}
{"name": "plan-oversize", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_LIMIT", "message": "MUTATION_LIMIT: Proposed content exceeds document limit"}}
{"name": "plan-production", "passed": true, "details": {"rejected": "PathPolicyError", "code": "PATH_WRITE_DENIED", "message": "PATH_WRITE_DENIED: 'src/changed.py': Use the artifact kind's exact configured file or child location."}}
{"name": "plan-profile", "passed": true, "details": {"rejected": "PathPolicyError", "code": "PATH_WRITE_DENIED", "message": "PATH_WRITE_DENIED: 'docs/migration/discovery/domain-profile.yaml': Use the artifact kind's exact configured file or child location."}}
{"name": "plan-outside", "passed": true, "details": {"rejected": "PathPolicyError", "code": "PATH_WRITE_DENIED", "message": "PATH_WRITE_DENIED: 'other/decisions.yaml': Use the artifact kind's exact configured file or child location."}}
{"name": "stale-bytes", "passed": true, "details": {"result": false, "revocations": 1, "findings": ["MUTATION_STALE: Complete input state changed; reload"]}}
{"name": "stale-addition", "passed": true, "details": {"result": false, "revocations": 1, "findings": ["MUTATION_STALE: Complete input state changed; reload"]}}
{"name": "stale-deletion", "passed": true, "details": {"result": false, "revocations": 1, "findings": ["MUTATION_STALE: Complete input state changed; reload"]}}
{"name": "stale-identity", "passed": true, "details": {"result": false, "revocations": 1, "findings": ["MUTATION_STALE: Complete input state changed; reload"]}}
{"name": "stale-parent-link", "passed": true, "details": {"result": false, "revocations": 1, "findings": ["PATH_LINK: 'docs/migration/discovery': Use ordinary local paths."]}}
{"name": "stale-collision", "passed": true, "details": {"result": false, "revocations": 1, "findings": ["MUTATION_STALE: Complete input state changed; reload"]}}
{"name": "stale-dry-run", "passed": true, "details": {"result": false, "revocations": 0, "findings": ["MUTATION_STALE: Complete input state changed; reload"]}}
{"name": "guarded-race-collision", "passed": true, "details": {"uncertain": ["docs/migration/discovery/product-decisions.yaml"], "writes": []}}
{"name": "guarded-race-input-edit", "passed": true, "details": {"uncertain": ["docs/migration/discovery/product-decisions.yaml"], "writes": []}}
{"name": "guarded-race-parent-replacement", "passed": true, "details": {"uncertain": ["docs/migration/discovery/product-decisions.yaml"], "writes": []}}
{"name": "post-write-raise-after-write", "passed": true, "details": {"uncertain": ["docs/migration/discovery/product-decisions.yaml"], "findings": ["Uncertain native result"]}}
{"name": "post-write-extra-file", "passed": true, "details": {"uncertain": ["docs/migration/discovery/product-decisions.yaml"], "findings": ["MUTATION_POSTCONDITION: Committed input bytes differ from the plan"]}}
{"name": "post-write-parent-identity", "passed": true, "details": {"uncertain": ["docs/migration/discovery/product-decisions.yaml"], "findings": ["MUTATION_POSTCONDITION: An unrelated input identity changed"]}}
{"name": "authority-invalidation-failure", "passed": true, "details": {"writes": 0, "authority_invalidated": false}}
{"name": "partial-write-stop", "passed": true, "details": {"statuses": ["created", "conflict"], "writes": ["docs/migration/discovery/product-decisions.yaml"], "uncertain": ["docs/migration/discovery/unspecified-behaviors.yaml"]}}
{"name": "tampered-plan", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_PLAN", "message": "MUTATION_PLAN: Plan fields differ from their validated reconstruction"}}
{"name": "allowed-role", "passed": true, "details": {"ok": true, "role": "requirements-reconciler", "writes": ["docs/migration/discovery/product-decisions.yaml", "docs/migration/discovery/reports/required-output-manifest.json"]}}
{"name": "wrong-role", "passed": true, "details": {"rejected": "MutationError", "code": "MUTATION_INVALID", "message": "MUTATION_INVALID: Prospective graph is invalid"}}
{"name": "concrete-writer-create", "passed": true, "details": {"ok": true, "events": ["enter", "create", "exit"]}}
{"name": "concrete-writer-replace", "passed": true, "details": {"ok": true, "events": ["enter", "replace", "exit"]}}
{"name": "concrete-writer-guard-race", "passed": true, "details": {"ok": false, "events": ["enter", "exit"]}}
```
