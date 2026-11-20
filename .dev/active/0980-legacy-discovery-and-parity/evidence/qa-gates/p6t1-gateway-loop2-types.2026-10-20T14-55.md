Timestamp: 2026-10-20T14-55
Command: `.venv/Scripts/python.exe -m pyright packages/discovery-runtime/src/drm_copilot_discovery/gateway.py packages/discovery-runtime/src/drm_copilot_discovery/gateway_local.py packages/discovery-runtime/src/drm_copilot_discovery/doctor.py tests/discovery_runtime/test_gateway.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_doctor.py`
EXIT_CODE: 1
Output Summary: loop2-types; exit 1; elapsed 1.308 seconds.

```text
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\gateway.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\gateway.py:243:13 - error: Expression with type "tuple[str, ...] | tuple[()]" cannot be assigned to target tuple
    Type "tuple[()]" is incompatible with target tuple
      Tuple size mismatch; expected 2 but received 0 (reportAssignmentType)
WORKSPACE\tests\discovery_runtime\test_gateway.py
  WORKSPACE\tests\discovery_runtime\test_gateway.py:244:13 - error: Method "read" overrides class "_BufferedIOBase" in an incompatible manner
    Parameter 2 type mismatch: base parameter is type "int | None", override parameter is type "int"
      Type "int | None" is not assignable to type "int"
        "None" is not assignable to "int" (reportIncompatibleMethodOverride)
  WORKSPACE\tests\discovery_runtime\test_gateway.py:250:20 - error: "_read_request" is private and used outside of the module in which it is declared (reportPrivateUsage)
  WORKSPACE\tests\discovery_runtime\test_gateway.py:259:13 - error: Method "read" overrides class "_BufferedIOBase" in an incompatible manner
    Parameter 2 type mismatch: base parameter is type "int | None", override parameter is type "int"
      Type "int | None" is not assignable to type "int"
        "None" is not assignable to "int" (reportIncompatibleMethodOverride)
  WORKSPACE\tests\discovery_runtime\test_gateway.py:264:17 - error: "_read_request" is private and used outside of the module in which it is declared (reportPrivateUsage)
  WORKSPACE\tests\discovery_runtime\test_gateway.py:274:22 - error: "_failure" is private and used outside of the module in which it is declared (reportPrivateUsage)
  WORKSPACE\tests\discovery_runtime\test_gateway.py:293:20 - error: "_emit" is private and used outside of the module in which it is declared (reportPrivateUsage)
  WORKSPACE\tests\discovery_runtime\test_gateway.py:324:20 - error: "_emit" is private and used outside of the module in which it is declared (reportPrivateUsage)
  WORKSPACE\tests\discovery_runtime\test_gateway.py:349:20 - error: "_emit" is private and used outside of the module in which it is declared (reportPrivateUsage)
WORKSPACE\tests\discovery_runtime\test_gateway_local.py
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:315:39 - error: "shutil" is not exported from module "drm_copilot_discovery.gateway_local" (reportPrivateImportUsage)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:315:56 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(name: Unknown) -> Literal['/trusted/git']" (reportUnknownArgumentType)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:315:63 - error: Type of parameter "name" is unknown (reportUnknownLambdaType)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:323:39 - error: "subprocess" is not exported from module "drm_copilot_discovery.gateway_local" (reportPrivateImportUsage)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:356:23 - error: "shutil" is not exported from module "drm_copilot_discovery.gateway_local" (reportPrivateImportUsage)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:358:9 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(name: Unknown) -> (Literal['/trusted/git'] | None)" (reportUnknownArgumentType)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:358:16 - error: Type of parameter "name" is unknown (reportUnknownLambdaType)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:371:42 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(self: Unknown, strict: bool = False) -> Unknown" (reportUnknownArgumentType)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:371:49 - error: Type of parameter "self" is unknown (reportUnknownLambdaType)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:371:69 - error: Return type of lambda is unknown (reportUnknownLambdaType)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:373:23 - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "classmethod[Unknown, (), Path]" (reportUnknownArgumentType)
  WORKSPACE\tests\discovery_runtime\test_gateway_local.py:390:39 - error: "ActivationStore" is not exported from module "drm_copilot_discovery.gateway_local" (reportPrivateImportUsage)
21 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
