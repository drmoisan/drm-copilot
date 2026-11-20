# p3t2-patch-zero-context

Timestamp: 2026-10-18T14-19
Command: poetry run python SCRATCH/issue-980-p3t2-patch-zero-context.py
EXIT_CODE: 1
Output Summary: error: patch failed: docs/discovery/templates/v2/domain-profile.yaml:1; error: docs/discovery/templates/v2/domain-profile.yaml: patch does not apply; error: patch failed: docs/discovery/templates/v2/coverage-ledger.json:1; error: docs/discovery/templates/v2/coverage-ledger.json: patch does not apply

Working directory: .
Started: 2026-10-18T14:19:42.728825+00:00
Duration seconds: 1.678
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
{"original_staged_whitespace_exit": 2, "original_staged_whitespace_output": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:1685: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:1703: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2836: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2838: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2842: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2854: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2891: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2897: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2902: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2903: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2981: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2984: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2986: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:2993: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3012: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3016: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3020: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3057: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3059: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3063: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3067: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3080: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3081: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3085: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3090: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3094: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3098: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3112: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3116: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3122: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3126: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3127: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3208: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3211: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3218: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3219: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3239: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3240: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3427: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3432: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3437: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3442: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3446: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3451: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3457: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3460: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3461: trailing whitespace.\n+ \ndocs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md:3471: trailing whitespace.\n+ \n"}
Traceback (most recent call last):
  File "SCRATCH\issue-980-p3t2-patch-zero-context.py", line 23, in <module>
    assert validation.returncode == 0, validation.stdout + validation.stderr
           ^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: <stdin>:1660: trailing whitespace.
"""Pure orchestration for discovery-workspace initialization.
<stdin>:2810: trailing whitespace.
"""Domain-neutrality regression tests for discovery templates and rendered output."""
<stdin>:2950: trailing whitespace.
from typing import Any
<stdin>:2952: trailing whitespace.
    calls: list[dict[str, Any]] = []
<stdin>:2992: trailing whitespace.
"""Tests for `scripts.dev_tools.discovery.init_flow`."""
error: patch failed: tests/scripts/dev_tools/discovery/test_init_models.py:23
error: tests/scripts/dev_tools/discovery/test_init_models.py: patch does not apply
error: patch failed: tests/scripts/dev_tools/discovery/test_init_flow.py:1
error: tests/scripts/dev_tools/discovery/test_init_flow.py: patch does not apply
error: patch failed: tests/scripts/dev_tools/discovery/test_init_cli.py:38
error: tests/scripts/dev_tools/discovery/test_init_cli.py: patch does not apply
error: patch failed: tests/scripts/dev_tools/discovery/test_domain_neutrality.py:1
error: tests/scripts/dev_tools/discovery/test_domain_neutrality.py: patch does not apply
error: patch failed: tests/discovery_runtime/test_initialization_conflicts.py:1
error: tests/discovery_runtime/test_initialization_conflicts.py: patch does not apply
error: patch failed: tests/discovery_runtime/test_initialization.py:1
error: tests/discovery_runtime/test_initialization.py: patch does not apply
error: patch failed: tests/discovery_runtime/initialization_test_support.py:1
error: tests/discovery_runtime/initialization_test_support.py: patch does not apply
error: patch failed: scripts/dev_tools/discovery/init_flow.py:1
error: scripts/dev_tools/discovery/init_flow.py: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py:1
error: packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/init_io.py:1
error: packages/discovery-runtime/src/drm_copilot_discovery/init_io.py: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py:1
error: packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json:4
error: packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/unspecified-behaviors.yaml:1
error: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/unspecified-behaviors.yaml: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/scope.yaml:1
error: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/scope.yaml: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/product-decisions.yaml:1
error: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/product-decisions.yaml: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/parity-matrix.json:1
error: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/parity-matrix.json: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/domain-profile.yaml:1
error: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/domain-profile.yaml: patch does not apply
error: patch failed: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/coverage-ledger.json:1
error: packages/discovery-runtime/src/drm_copilot_discovery/_resources/docs/discovery/templates/v2/coverage-ledger.json: patch does not apply
error: patch failed: packages/discovery-runtime/resource-manifest.json:4
error: packages/discovery-runtime/resource-manifest.json: patch does not apply
error: patch failed: docs/discovery/templates/v2/unspecified-behaviors.yaml:1
error: docs/discovery/templates/v2/unspecified-behaviors.yaml: patch does not apply
error: patch failed: docs/discovery/templates/v2/scope.yaml:1
error: docs/discovery/templates/v2/scope.yaml: patch does not apply
error: patch failed: docs/discovery/templates/v2/product-decisions.yaml:1
error: docs/discovery/templates/v2/product-decisions.yaml: patch does not apply
error: patch failed: docs/discovery/templates/v2/parity-matrix.json:1
error: docs/discovery/templates/v2/parity-matrix.json: patch does not apply
error: patch failed: docs/discovery/templates/v2/domain-profile.yaml:1
error: docs/discovery/templates/v2/domain-profile.yaml: patch does not apply
error: patch failed: docs/discovery/templates/v2/coverage-ledger.json:1
error: docs/discovery/templates/v2/coverage-ledger.json: patch does not apply
```
