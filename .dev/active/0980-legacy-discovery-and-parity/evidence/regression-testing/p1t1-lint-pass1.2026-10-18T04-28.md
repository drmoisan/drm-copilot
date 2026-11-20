# p1t1-lint-pass1

Timestamp: 2026-10-18T04-28
Command: poetry run ruff check packages/discovery-runtime/src tests/discovery_runtime scripts/dev_tools/discovery/__init__.py scripts/dev_tools/discovery/domain_profile.py scripts/dev_tools/discovery/domain_profile_models.py scripts/dev_tools/discovery/init_models.py scripts/dev_tools/discovery/io.py scripts/dev_tools/discovery/rendering.py scripts/dev_tools/quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/discovery/test_domain_profile.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_io.py tests/scripts/dev_tools/discovery/test_rendering.py
EXIT_CODE: 1
Output Summary: [1m[96mhelp[0m: [1mOrganize imports[0m; ; Found 4 errors.; [[36m*[0m] 3 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T04:28:14.215812+00:00
Duration seconds: 0.801
Phase: P1-T1 package extraction; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mAdd quotes to type expression in `typing.cast()`[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\rendering.py:57:50
   [1m[94m|[0m
[1m[94m55 |[0m     )
[1m[94m56 |[0m     if all_rows_have_id:
[1m[94m57 |[0m         return sorted(rows, key=lambda row: cast(str, row[id_field]))
   [1m[94m|[0m                                                  [1m[91m^^^[0m
[1m[94m58 |[0m
[1m[94m59 |[0m     def _fallback_key(row: _Row) -> str:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd quotes[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_package_contract.py:101:89
    [1m[94m|[0m
[1m[94m 99 |[0m     text = (REPOSITORY / "pyproject.toml").read_text(encoding="utf-8")
[1m[94m100 |[0m     assert (
[1m[94m101 |[0m         'drm-copilot-discovery = { path = "packages/discovery-runtime", develop = true }'
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m102 |[0m         in text
[1m[94m103 |[0m     )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\scripts\dev_tools\discovery\test_domain_profile.py:9:1
   [1m[94m|[0m
[1m[94m 7 |[0m   """
[1m[94m 8 |[0m
[1m[94m 9 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m10 |[0m [1m[91m|[0m
[1m[94m11 |[0m [1m[91m|[0m from pathlib import Path
[1m[94m12 |[0m [1m[91m|[0m
[1m[94m13 |[0m [1m[91m|[0m import pytest
[1m[94m14 |[0m [1m[91m|[0m
[1m[94m15 |[0m [1m[91m|[0m from drm_copilot_discovery import domain_profile as dp_module
[1m[94m16 |[0m [1m[91m|[0m from drm_copilot_discovery import domain_profile_models as models_module
[1m[94m17 |[0m [1m[91m|[0m from drm_copilot_discovery.domain_profile import (
[1m[94m18 |[0m [1m[91m|[0m     DEFAULT_PROFILE_FILENAME,
[1m[94m19 |[0m [1m[91m|[0m     DomainProfileError,
[1m[94m20 |[0m [1m[91m|[0m     load_domain_profile,
[1m[94m21 |[0m [1m[91m|[0m     parse_domain_profile_text,
[1m[94m22 |[0m [1m[91m|[0m )
[1m[94m23 |[0m [1m[91m|[0m from drm_copilot_discovery.domain_profile_models import (
[1m[94m24 |[0m [1m[91m|[0m     ArtifactsConfig,
[1m[94m25 |[0m [1m[91m|[0m     DomainProfile,
[1m[94m26 |[0m [1m[91m|[0m     LegacySourceConfig,
[1m[94m27 |[0m [1m[91m|[0m     TargetConfig,
[1m[94m28 |[0m [1m[91m|[0m     TechnologyStackConfig,
[1m[94m29 |[0m [1m[91m|[0m )
[1m[94m30 |[0m [1m[91m|[0m
[1m[94m31 |[0m [1m[91m|[0m from scripts.dev_tools.discovery import profile_cli as cli_module
   [1m[94m|[0m [1m[91m|_________________________________________________________________^[0m
[1m[94m32 |[0m
[1m[94m33 |[0m   # A valid minimal profile (required fields only), in YAML flow style.
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\scripts\dev_tools\discovery\test_io.py:17:1
   [1m[94m|[0m
[1m[94m15 |[0m       from _pytest.monkeypatch import MonkeyPatch
[1m[94m16 |[0m
[1m[94m17 |[0m [1m[91m/[0m import pytest
[1m[94m18 |[0m [1m[91m|[0m
[1m[94m19 |[0m [1m[91m|[0m from drm_copilot_discovery.io import (
[1m[94m20 |[0m [1m[91m|[0m     ArtifactValidationError,
[1m[94m21 |[0m [1m[91m|[0m     read_artifact_text,
[1m[94m22 |[0m [1m[91m|[0m     validate_or_raise,
[1m[94m23 |[0m [1m[91m|[0m     write_report,
[1m[94m24 |[0m [1m[91m|[0m )
   [1m[94m|[0m [1m[91m|_^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

Found 4 errors.
[[36m*[0m] 3 fixable with the `--fix` option.
```
