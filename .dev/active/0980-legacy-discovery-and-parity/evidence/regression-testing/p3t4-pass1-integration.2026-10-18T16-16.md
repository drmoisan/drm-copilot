# p3t4-pass1-integration

Timestamp: 2026-10-18T16-16
Command: poetry run python SCRATCH/issue-980-p3t4-composed-integration.py
EXIT_CODE: 1
Output Summary:     );   File ".\packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py", line 296, in __init__;     raise ValueError("Workspace and external lock paths must be absolute"); ValueError: Workspace and external lock paths must be absolute

Working directory: .
Started: 2026-10-18T16:16:20.575195+00:00
Duration seconds: 1.890
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
Traceback (most recent call last):
  File "SCRATCH\issue-980-p3t4-composed-integration.py", line 35, in <module>
    writer = GuardedMutationWriter(capture=lambda: capture(store, catalog), invalidate_authority=lambda: revoked.append("invalidated"), primitives=disk.provider(limit=baseline.snapshot.profile.limits.document_bytes))
                                                                                                                                                   ~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File ".\tests\discovery_runtime\mutation_test_support.py", line 201, in provider
    return LocalMutationPrimitives(
        workspace_root=self.root,
    ...<5 lines>...
        document_bytes=limit,
    )
  File ".\packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py", line 296, in __init__
    raise ValueError("Workspace and external lock paths must be absolute")
ValueError: Workspace and external lock paths must be absolute
```
