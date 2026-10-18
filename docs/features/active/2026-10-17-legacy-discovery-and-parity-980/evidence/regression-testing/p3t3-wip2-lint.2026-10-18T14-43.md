# p3t3-wip2-lint

Timestamp: 2026-10-18T14-43
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/configuration.py packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py tests/discovery_runtime/test_configuration.py tests/discovery_runtime/test_activation_store.py tests/discovery_runtime/test_activation_filesystem.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mOrganize imports[0m; ; Found 2 errors.; [[36m*[0m] 1 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T14:42:59.388580+00:00
Duration seconds: 0.841
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\configuration.py:43:89
   [1m[94m|[0m
[1m[94m41 |[0m                 artifact_path=path,
[1m[94m42 |[0m                 next_action=(
[1m[94m43 |[0m                     "Use the root configuration operation to repair or activate discovery."
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m44 |[0m                 ),
[1m[94m45 |[0m             ),
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Exercise root configuration with fresh memory stores and real mutation primitives."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import os
[1m[94m 6 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 7 |[0m [1m[91m|[0m from hashlib import sha256
[1m[94m 8 |[0m [1m[91m|[0m from typing import TYPE_CHECKING
[1m[94m 9 |[0m [1m[91m|[0m
[1m[94m10 |[0m [1m[91m|[0m import pytest
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.activation_filesystem import RegistryLocation
[1m[94m12 |[0m [1m[91m|[0m from drm_copilot_discovery.activation_store import ActivationStore
[1m[94m13 |[0m [1m[91m|[0m from drm_copilot_discovery.configuration import (
[1m[94m14 |[0m [1m[91m|[0m     DEFAULT_PROFILE,
[1m[94m15 |[0m [1m[91m|[0m     LOCATOR_PATH,
[1m[94m16 |[0m [1m[91m|[0m     ActivationRecord,
[1m[94m17 |[0m [1m[91m|[0m     ConfigurationError,
[1m[94m18 |[0m [1m[91m|[0m     ConfigurationRequest,
[1m[94m19 |[0m [1m[91m|[0m )
[1m[94m20 |[0m [1m[91m|[0m from drm_copilot_discovery.profile_v2 import ProfileError
[1m[94m21 |[0m [1m[91m|[0m
[1m[94m22 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import MemoryDisk
[1m[94m23 |[0m [1m[91m|[0m from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
[1m[94m24 |[0m [1m[91m|[0m from tests.discovery_runtime.test_configuration import active_record, profile_bytes
   [1m[94m|[0m [1m[91m|___________________________________________________________________________________^[0m
[1m[94m25 |[0m
[1m[94m26 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

Found 2 errors.
[[36m*[0m] 1 fixable with the `--fix` option.
```
