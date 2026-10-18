# p1t1-types-pass3

Timestamp: 2026-10-18T04-30
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     Argument type is "list[tuple[list[str], frozenset[str]] | tuple[list[str], frozenset[Unknown]]]" (reportUnknownArgumentType); 10 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T04:30:40.303457+00:00
Duration seconds: 7.162
Phase: P1-T1 package extraction; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: "ArtifactsConfig" is not exported from module "drm_copilot_discovery.domain_profile"
    Import from "drm_copilot_discovery.domain_profile_models" instead (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "DomainProfile" is not exported from module "drm_copilot_discovery.domain_profile"
    Import from "drm_copilot_discovery.domain_profile_models" instead (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "DomainProfileError" is not exported from module "drm_copilot_discovery.domain_profile"
    Import from "drm_copilot_discovery.domain_profile_models" instead (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "LegacySourceConfig" is not exported from module "drm_copilot_discovery.domain_profile"
    Import from "drm_copilot_discovery.domain_profile_models" instead (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "TargetConfig" is not exported from module "drm_copilot_discovery.domain_profile"
    Import from "drm_copilot_discovery.domain_profile_models" instead (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "TechnologyStackConfig" is not exported from module "drm_copilot_discovery.domain_profile"
    Import from "drm_copilot_discovery.domain_profile_models" instead (reportPrivateImportUsage)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Type of "allowed_local" is partially unknown
    Type of "allowed_local" is "set[str] | set[Unknown]" (reportUnknownVariableType)
  EXTERNAL_PATH - error: Argument of type "(value: str) -> list[str]" cannot be assigned to parameter "validator" of type "ArtifactValidator" in function "validate_or_raise"
    Type "(value: str) -> list[str]" is not assignable to type "(text: str) -> list[str]"
      Parameter name mismatch: "text" versus "value" (reportArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: "DomainProfileError" is not exported from module "drm_copilot_discovery.domain_profile"
    Import from "drm_copilot_discovery.domain_profile_models" instead (reportPrivateImportUsage)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "argvalues" in function "__call__"
    Argument type is "list[tuple[list[str], frozenset[str]] | tuple[list[str], frozenset[Unknown]]]" (reportUnknownArgumentType)
10 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
