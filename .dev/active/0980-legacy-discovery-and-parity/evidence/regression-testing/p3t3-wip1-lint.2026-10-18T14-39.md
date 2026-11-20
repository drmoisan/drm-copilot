# p3t3-wip1-lint

Timestamp: 2026-10-18T14-39
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/configuration.py packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py tests/discovery_runtime/test_configuration.py tests/discovery_runtime/test_activation_store.py tests/discovery_runtime/test_activation_filesystem.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 44 errors.; No fixes available (2 hidden fixes can be enabled with the `--unsafe-fixes` option).

Working directory: .
Started: 2026-10-18T14:39:59.032441+00:00
Duration seconds: 0.748
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
 [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_filesystem.py:1:89
  [1m[94m|[0m
[1m[94m1 |[0m """Protect external activation bytes through the accepted native directory primitives."""
  [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m2 |[0m
[1m[94m3 |[0m from __future__ import annotations
  [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_filesystem.py:104:89
    [1m[94m|[0m
[1m[94m102 |[0m         self, *, create: bool, capture: dict[str, str] | None = None
[1m[94m103 |[0m     ) -> Generator[Directory, None, None]:
[1m[94m104 |[0m         """Pin every ordinary ancestor, exclusively creating absent state directories."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m105 |[0m         path = Path(self.location.directory)
[1m[94m106 |[0m         with ExitStack() as anchors:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_filesystem.py:126:89
    [1m[94m|[0m
[1m[94m124 |[0m         self, path: Path, directory: Directory, capture: dict[str, str] | None
[1m[94m125 |[0m     ) -> None:
[1m[94m126 |[0m         """Bind opened state ancestors to the retained guard, rejecting namespace replacement."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m127 |[0m         name, identity = path.as_posix(), directory.identity()
[1m[94m128 |[0m         if name in self._identities and self._identities[name] != identity:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:50:89
   [1m[94m|[0m
[1m[94m49 |[0m class RegistryIO(Protocol):
[1m[94m50 |[0m     """Read and conditionally replace a fixed protected record under the shared guard."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m51 |[0m
[1m[94m52 |[0m     def read(self) -> bytes | None:
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:53:89
   [1m[94m|[0m
[1m[94m52 |[0m     def read(self) -> bytes | None:
[1m[94m53 |[0m         """Return exact protected bytes or genuine absence; other I/O errors propagate."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m54 |[0m         ...
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:84:89
   [1m[94m|[0m
[1m[94m82 |[0m         candidate_paths: tuple[str, ...] = (DEFAULT_PROFILE,),
[1m[94m83 |[0m     ) -> None:
[1m[94m84 |[0m         """Bind trusted collaborators; candidate paths are observations, not permissions."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m85 |[0m         self.location, self.registry, self.primitives = location, registry, primitives
[1m[94m86 |[0m         self.metadata, self.read_bytes, self.catalog = metadata, read_bytes, catalog
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (96 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:105:89
    [1m[94m|[0m
[1m[94m103 |[0m         candidate_paths: tuple[str, ...] = (DEFAULT_PROFILE,),
[1m[94m104 |[0m     ) -> ActivationStore:
[1m[94m105 |[0m         """Wire the real provider from host-resolved paths; no request can call this factory."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^[0m
[1m[94m106 |[0m         workspace = Path(location.workspace)
[1m[94m107 |[0m         state = Path(location.directory)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:141:89
    [1m[94m|[0m
[1m[94m140 |[0m     def _record(self, raw: bytes | None) -> ActivationRecord | None:
[1m[94m141 |[0m         """Reject malformed/wrong-workspace protected records rather than disable gates."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m142 |[0m         return (
[1m[94m143 |[0m             None
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (101 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:153:89
    [1m[94m|[0m
[1m[94m151 |[0m         self, *, profile_path: str | None = None, controlled: bool = False
[1m[94m152 |[0m     ) -> ConfigurationSelection:
[1m[94m153 |[0m         """Read exact configuration and protected state; never create registry or workspace files."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^[0m
[1m[94m154 |[0m         raw = self.registry.read()
[1m[94m155 |[0m         record = self._record(raw)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:192:89
    [1m[94m|[0m
[1m[94m190 |[0m         if selected.profile is not None:
[1m[94m191 |[0m             self._policy(selected.profile).validate_configuration()
[1m[94m192 |[0m         # Concurrent edits cannot turn a read of mixed generations into a valid selection.
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m193 |[0m         if (
[1m[94m194 |[0m             self.registry.read() != raw
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:205:89
    [1m[94m|[0m
[1m[94m204 |[0m     def _policy(self, profile: ProfileV2) -> PathPolicy:
[1m[94m205 |[0m         """Reuse accepted path validation with exact host metadata and workspace binding."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m206 |[0m         return PathPolicy(
[1m[94m207 |[0m             profile, workspace_root=self.location.workspace, metadata=self.metadata
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:217:89
    [1m[94m|[0m
[1m[94m215 |[0m         changed: list[str],
[1m[94m216 |[0m     ) -> None:
[1m[94m217 |[0m         """Retain exact pre-observed or exclusively created ancestors through postcheck."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m218 |[0m         directory = anchors.enter_context(self.open_directory())
[1m[94m219 |[0m         if directory.identity() != target.observations[0].identity:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:248:89
    [1m[94m|[0m
[1m[94m246 |[0m         candidates: tuple[tuple[str, bytes | None], ...],
[1m[94m247 |[0m     ) -> None:
[1m[94m248 |[0m         """Reject changed original bytes and parent/leaf identities before any publication."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m249 |[0m         if self.registry.read() != raw or any(
[1m[94m250 |[0m             self._optional(path) != old for path, _, old in writes
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:265:89
    [1m[94m|[0m
[1m[94m264 |[0m     def configure(self, request: ConfigurationRequest) -> ConfigurationResult:
[1m[94m265 |[0m         """Validate root intent, revoke old authority and report exact/uncertain effects.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m266 |[0m
[1m[94m267 |[0m         Authorization is injected from native/user context, never a request role.
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:312:89
    [1m[94m|[0m
[1m[94m310 |[0m                 policy.resolve_read(path, allow_missing=True) for path, _, _ in writes
[1m[94m311 |[0m             )
[1m[94m312 |[0m             # A second known candidate cannot be silently hidden by changing the locator.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m313 |[0m             candidates = tuple(
[1m[94m314 |[0m                 (path, self._optional(path)) for path in self.candidate_paths
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:322:89
    [1m[94m|[0m
[1m[94m320 |[0m                 raise ConfigurationError(
[1m[94m321 |[0m                     "CONFIGURATION_AMBIGUOUS",
[1m[94m322 |[0m                     "Remove competing profile candidates through an explicit root operation.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m323 |[0m                 )
[1m[94m324 |[0m             profile_hash, locator_hash = (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:350:89
    [1m[94m|[0m
[1m[94m348 |[0m                 self._require_inputs(raw, writes, policy, observations, candidates)
[1m[94m349 |[0m                 uncertain = ("protected-activation",)
[1m[94m350 |[0m                 # Record active intent first: partial workspace writes must keep gates active.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m351 |[0m                 self.registry.write(next_record, expected=raw)
[1m[94m352 |[0m                 changed.append("protected-activation")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (102 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:356:89
    [1m[94m|[0m
[1m[94m354 |[0m                 opened: dict[str, str] = {}
[1m[94m355 |[0m                 if policy is not None:
[1m[94m356 |[0m                     # Shared primitives publish exact root-only paths without widening analyst grants.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^[0m
[1m[94m357 |[0m                     for (path, content, original), observed in zip(
[1m[94m358 |[0m                         writes, observations
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1m`zip()` without an explicit `strict=` parameter[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:357:64
    [1m[94m|[0m
[1m[94m355 |[0m                   if policy is not None:
[1m[94m356 |[0m                       # Shared primitives publish exact root-only paths without widening analyst grants.
[1m[94m357 |[0m                       for (path, content, original), observed in zip(
    [1m[94m|[0m  [1m[91m________________________________________________________________^[0m
[1m[94m358 |[0m [1m[91m|[0m                         writes, observations
[1m[94m359 |[0m [1m[91m|[0m                     ):
    [1m[94m|[0m [1m[91m|_____________________^[0m
[1m[94m360 |[0m                           uncertain = tuple(
[1m[94m361 |[0m                               stamp.path
    [1m[94m|[0m
[1m[96mhelp[0m: [1mAdd explicit value for parameter `strict=`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (102 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py:408:89
    [1m[94m|[0m
[1m[94m406 |[0m                         changed.append(path)
[1m[94m407 |[0m                         uncertain = ()
[1m[94m408 |[0m                 # Newly created and pre-existing retained identities must still name the same parents.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^[0m
[1m[94m409 |[0m                 if any(
[1m[94m410 |[0m                     self.metadata(path).identity != identity
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (100 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\configuration.py:42:89
   [1m[94m|[0m
[1m[94m40 |[0m                 message=message,
[1m[94m41 |[0m                 artifact_path=path,
[1m[94m42 |[0m                 next_action="Use the root configuration operation to repair or activate discovery.",
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^[0m
[1m[94m43 |[0m             ),
[1m[94m44 |[0m         )
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
 [1m[94m-->[0m tests\discovery_runtime\test_activation_filesystem.py:1:89
  [1m[94m|[0m
[1m[94m1 |[0m """Check platform authority locations without environment reads or real filesystem I/O."""
  [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m2 |[0m
[1m[94m3 |[0m from __future__ import annotations
  [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mMove standard library import `collections.abc.Callable` into a type-checking block[0m
 [1m[94m-->[0m tests\discovery_runtime\test_activation_filesystem.py:5:29
  [1m[94m|[0m
[1m[94m3 |[0m from __future__ import annotations
[1m[94m4 |[0m
[1m[94m5 |[0m from collections.abc import Callable
  [1m[94m|[0m                             [1m[91m^^^^^^^^[0m
[1m[94m6 |[0m from typing import Literal, cast
  [1m[94m|[0m
[1m[96mhelp[0m: [1mMove into type-checking block[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_activation_filesystem.py:48:89
   [1m[94m|[0m
[1m[94m46 |[0m     platform: str, home: str, local: str | None, state: str | None, expected: str
[1m[94m47 |[0m ) -> None:
[1m[94m48 |[0m     """Trusted host values select the mandated registry location without session dependence."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m49 |[0m     workspace = "EXTERNAL_PATH" if platform == "windows" else "/workspace"
[1m[94m50 |[0m     location = RegistryLocation.for_host(
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_activation_filesystem.py:97:89
   [1m[94m|[0m
[1m[94m95 |[0m     changes: dict[str, object],
[1m[94m96 |[0m ) -> None:
[1m[94m97 |[0m     """Unsupported platforms and workspace-contained authority roots cannot provision state."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m98 |[0m     arguments = {
[1m[94m99 |[0m         "workspace_root": "/workspace",
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:33:89
   [1m[94m|[0m
[1m[94m32 |[0m class MemoryRegistry:
[1m[94m33 |[0m     """Retain protected bytes separately from a test's workspace and record all writes."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m34 |[0m
[1m[94m35 |[0m     def __init__(self, disk: MemoryDisk) -> None:
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:43:89
   [1m[94m|[0m
[1m[94m42 |[0m     def read(self) -> bytes | None:
[1m[94m43 |[0m         """Return the current protected observation without consulting workspace input."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m44 |[0m         return self.raw
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:55:89
   [1m[94m|[0m
[1m[94m54 |[0m class ConfigurationCase:
[1m[94m55 |[0m     """Own root context, registry, namespace and revocation state for exactly one test."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m56 |[0m
[1m[94m57 |[0m     def __init__(
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:87:89
   [1m[94m|[0m
[1m[94m86 |[0m     def authorize(self) -> None:
[1m[94m87 |[0m         """Model an independently verified native/user principal, never a request role."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m88 |[0m         self.authorization_calls += 1
[1m[94m89 |[0m         if not self.authorized:
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (104 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:109:89
    [1m[94m|[0m
[1m[94m107 |[0m     config_catalog: SchemaCatalog, path: str
[1m[94m108 |[0m ) -> None:
[1m[94m109 |[0m     """Root configuration writes exact bytes, revokes old grants and records deliberate deactivation."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^[0m
[1m[94m110 |[0m     case = ConfigurationCase(config_catalog, profile=path)
[1m[94m111 |[0m     content = profile_bytes(path)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:143:89
    [1m[94m|[0m
[1m[94m141 |[0m     config_catalog: SchemaCatalog, action: str
[1m[94m142 |[0m ) -> None:
[1m[94m143 |[0m     """No request action, profile field or dry-run flag can fabricate root authorization."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m144 |[0m     case = ConfigurationCase(config_catalog)
[1m[94m145 |[0m     case.authorized = False
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:161:89
    [1m[94m|[0m
[1m[94m159 |[0m     config_catalog: SchemaCatalog,
[1m[94m160 |[0m ) -> None:
[1m[94m161 |[0m     """Projected valid root intent performs only reads, including on a fresh workspace."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m162 |[0m     case = ConfigurationCase(config_catalog)
[1m[94m163 |[0m     before = dict(case.disk.store.metadata.entries)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:195:89
    [1m[94m|[0m
[1m[94m193 |[0m     config_catalog: SchemaCatalog, change: str
[1m[94m194 |[0m ) -> None:
[1m[94m195 |[0m     """Missing, malformed or disabled workspace declarations keep active discovery blocked."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m196 |[0m     case = ConfigurationCase(config_catalog)
[1m[94m197 |[0m     assert case.service.configure(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (98 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:218:89
    [1m[94m|[0m
[1m[94m216 |[0m     config_catalog: SchemaCatalog,
[1m[94m217 |[0m ) -> None:
[1m[94m218 |[0m     """A publication failure reports bounded effects and requires repair, never silent opt-out."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^[0m
[1m[94m219 |[0m     case = ConfigurationCase(config_catalog)
[1m[94m220 |[0m     case.disk.fail_publish = True
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:241:89
    [1m[94m|[0m
[1m[94m239 |[0m     config_catalog: SchemaCatalog,
[1m[94m240 |[0m ) -> None:
[1m[94m241 |[0m     """Accepted profile validation runs before lock acquisition, activation or invalidation."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m242 |[0m     case = ConfigurationCase(config_catalog)
[1m[94m243 |[0m     with pytest.raises(ProfileError):
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:259:89
    [1m[94m|[0m
[1m[94m257 |[0m     config_catalog: SchemaCatalog,
[1m[94m258 |[0m ) -> None:
[1m[94m259 |[0m     """Unrelated work remains unaffected without creating even an authority directory."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m260 |[0m     case = ConfigurationCase(config_catalog)
[1m[94m261 |[0m     assert case.service.select(controlled=True).state == "inactive"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (98 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_activation_store.py:303:89
    [1m[94m|[0m
[1m[94m302 |[0m     def racing_authorization() -> None:
[1m[94m303 |[0m         """Inject a competing known profile only after the original read and guard acquisition."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^[0m
[1m[94m304 |[0m         case.authorize()
[1m[94m305 |[0m         if case.authorization_calls == 2:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_configuration.py:61:89
   [1m[94m|[0m
[1m[94m59 |[0m     config_catalog: SchemaCatalog, path: str
[1m[94m60 |[0m ) -> None:
[1m[94m61 |[0m     """A valid locator or explicit selector locates configuration without granting activation."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m62 |[0m     content = profile_bytes(path)
[1m[94m63 |[0m     kwargs = {"profile_path": path} if path != DEFAULT_PROFILE else {}
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_configuration.py:86:89
   [1m[94m|[0m
[1m[94m84 |[0m     config_catalog: SchemaCatalog,
[1m[94m85 |[0m ) -> None:
[1m[94m86 |[0m     """Only matching protected observations yield active readiness, with exact raw bytes."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m87 |[0m     content = profile_bytes()
[1m[94m88 |[0m     selection = select_configuration(
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (100 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_configuration.py:103:89
    [1m[94m|[0m
[1m[94m101 |[0m     config_catalog: SchemaCatalog,
[1m[94m102 |[0m ) -> None:
[1m[94m103 |[0m     """Absent activation/default leaves unrelated work alone; root tombstones override leftovers."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^[0m
[1m[94m104 |[0m     assert (
[1m[94m105 |[0m         select_configuration(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_configuration.py:153:89
    [1m[94m|[0m
[1m[94m151 |[0m     config_catalog: SchemaCatalog, case: str
[1m[94m152 |[0m ) -> None:
[1m[94m153 |[0m     """Each independent selector/freshness violation remains a blocking typed finding."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m154 |[0m     content = profile_bytes()
[1m[94m155 |[0m     candidates = {DEFAULT_PROFILE: content}
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (96 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_configuration.py:242:89
    [1m[94m|[0m
[1m[94m241 |[0m def test_record_round_trip_preserves_audit_chain_and_workspace_identity() -> None:
[1m[94m242 |[0m     """Protected transitions are deterministic, bounded and bound to one canonical workspace."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^[0m
[1m[94m243 |[0m     record = active_record(profile_bytes())
[1m[94m244 |[0m     assert (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_configuration.py:279:89
    [1m[94m|[0m
[1m[94m277 |[0m )
[1m[94m278 |[0m def test_invalid_protected_fields_fail_closed(key: str, value: object) -> None:
[1m[94m279 |[0m     """Corrupt versions, identities or added authority claims never become inactive state."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m280 |[0m     document = cast(
[1m[94m281 |[0m         "dict[str, object]", json.loads(active_record(profile_bytes()).encode())
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_configuration.py:313:89
    [1m[94m|[0m
[1m[94m311 |[0m     changes: dict[str, object],
[1m[94m312 |[0m ) -> None:
[1m[94m313 |[0m     """Only closed configuration intent is accepted, with no root or registry path field."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m314 |[0m     with pytest.raises(ValueError):
[1m[94m315 |[0m         replace(ConfigurationRequest(action="activate"), **changes)
    [1m[94m|[0m

Found 44 errors.
No fixes available (2 hidden fixes can be enabled with the `--unsafe-fixes` option).
```
