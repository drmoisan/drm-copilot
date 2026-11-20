# p3t3-native1-lint

Timestamp: 2026-10-18T14-58
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/configuration.py packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py tests/discovery_runtime/test_configuration.py tests/discovery_runtime/test_activation_store.py tests/discovery_runtime/test_activation_filesystem.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mOrganize imports[0m; ; Found 1 error.; [[36m*[0m] 1 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T14:58:53.512008+00:00
Duration seconds: 0.835
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_activation_filesystem.py:4:1
   [1m[94m|[0m
[1m[94m 2 |[0m   I/O."""
[1m[94m 3 |[0m
[1m[94m 4 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 5 |[0m [1m[91m|[0m
[1m[94m 6 |[0m [1m[91m|[0m import os
[1m[94m 7 |[0m [1m[91m|[0m from contextlib import contextmanager
[1m[94m 8 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 9 |[0m [1m[91m|[0m from pathlib import Path
[1m[94m10 |[0m [1m[91m|[0m from typing import TYPE_CHECKING, Literal, cast
[1m[94m11 |[0m [1m[91m|[0m
[1m[94m12 |[0m [1m[91m|[0m import pytest
[1m[94m13 |[0m [1m[91m|[0m from drm_copilot_discovery.activation_filesystem import NativeRegistry, RegistryLocation
[1m[94m14 |[0m [1m[91m|[0m from drm_copilot_discovery import activation_store
[1m[94m15 |[0m [1m[91m|[0m
[1m[94m16 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import MemoryDirectory, MemoryDisk
[1m[94m17 |[0m [1m[91m|[0m from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
   [1m[94m|[0m [1m[91m|_______________________________________________________________________________________^[0m
[1m[94m18 |[0m
[1m[94m19 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

Found 1 error.
[[36m*[0m] 1 fixable with the `--fix` option.
```
