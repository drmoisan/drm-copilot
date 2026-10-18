# p3t1-types-pass5

Timestamp: 2026-10-18T11-25
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:   EXTERNAL_PATH - error: Type of parameter "path" is unknown (reportUnknownLambdaType); 68 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T11:25:22.676228+00:00
Duration seconds: 8.490
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: Argument type is unknown
    Argument corresponds to parameter "flags" in function "open" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of "O_DIRECTORY" is unknown (reportUnknownMemberType)
  EXTERNAL_PATH - error: "O_DIRECTORY" is not a known attribute of module "os" (reportAttributeAccessIssue)
  EXTERNAL_PATH - error: Type of "O_NOFOLLOW" is unknown (reportUnknownMemberType)
  EXTERNAL_PATH - error: "O_NOFOLLOW" is not a known attribute of module "os" (reportAttributeAccessIssue)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
EXTERNAL_PATH
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
EXTERNAL_PATH
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
EXTERNAL_PATH
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(name: Unknown, **kwargs: Unknown) -> None" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "name" is unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: Type of parameter "kwargs" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: Argument type is unknown
    Argument corresponds to parameter "object" in function "__new__" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(*args: Unknown, **kwargs: Unknown) -> Literal[23]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "args" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: Type of parameter "kwargs" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(descriptor: Unknown) -> stat_result" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "descriptor" is unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "ctypes" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(*args: Unknown, **kwargs: Unknown) -> SimpleNamespace" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "args" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: Type of parameter "kwargs" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> stat_result" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(descriptor: Unknown) -> stat_result" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "descriptor" is unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(*args: Unknown, **kwargs: Unknown) -> Literal[43]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "args" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: Type of parameter "kwargs" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(descriptor: Unknown) -> stat_result" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "descriptor" is unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(descriptor: Unknown, count: Unknown) -> bytes" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "descriptor" is unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: Type of parameter "count" is unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: The function "contextmanager" is deprecated
    Annotating the return type as `-> Iterator[Foo]` with `@contextmanager` is deprecated. Use `-> Generator[Foo]` instead. (reportDeprecated)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(*args: Unknown, **kwargs: Unknown) -> Literal[53]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "args" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: Type of parameter "kwargs" is partially unknown (reportUnknownLambdaType)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: "os" is not exported from module "drm_copilot_discovery.mutation_filesystem" (reportPrivateImportUsage)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "value" in function "setattr"
    Argument type is "(path: Unknown) -> list[str]" (reportUnknownArgumentType)
  EXTERNAL_PATH - error: Type of parameter "path" is unknown (reportUnknownLambdaType)
68 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
