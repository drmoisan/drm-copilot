# p3t2-first-batch-lint

Timestamp: 2026-10-18T13-06
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py packages/discovery-runtime/src/drm_copilot_discovery/init_io.py scripts/dev_tools/discovery/init_flow.py tests/discovery_runtime/test_initialization.py tests/discovery_runtime/initialization_test_support.py tests/scripts/dev_tools/discovery/test_init_flow.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_domain_neutrality.py
EXIT_CODE: 1
Output Summary: [1m[94m70 |[0m     before = dict(case.disk.store.metadata.entries);    [1m[94m|[0m; ; Found 24 errors.

Working directory: .
Started: 2026-10-18T13:06:33.903600+00:00
Duration seconds: 0.832
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:61:89
   [1m[94m|[0m
[1m[94m59 |[0m @dataclass(frozen=True, kw_only=True)
[1m[94m60 |[0m class InitializationResult:
[1m[94m61 |[0m     """Report structural validity and exact partial effects, never a completion receipt."""
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m62 |[0m
[1m[94m63 |[0m     ok: bool
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:78:89
   [1m[94m|[0m
[1m[94m76 |[0m     templates: InitializationTemplates | None = None,
[1m[94m77 |[0m ) -> InitializationPlan:
[1m[94m78 |[0m     """Validate the complete creation graph before writes, preserving valid existing bytes."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m79 |[0m     selected = templates or InitializationTemplates.load()
[1m[94m80 |[0m     repository = io.available_repository()
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:175:89
    [1m[94m|[0m
[1m[94m174 |[0m def _outputs(plan: InitializationPlan) -> tuple[InitializationOutput, ...]:
[1m[94m175 |[0m     """Project deterministic intended dispositions from physical absence, not virtual flags."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m176 |[0m     physical = dict(plan.capture.physical_metadata)
[1m[94m177 |[0m     profile = plan.capture.proposal_base.snapshot.profile
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:213:89
    [1m[94m|[0m
[1m[94m211 |[0m     force: bool = False,
[1m[94m212 |[0m ) -> InitializationResult:
[1m[94m213 |[0m     """Recheck physical inputs, bootstrap root paths, then use accepted artifact mutations.
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m214 |[0m
[1m[94m215 |[0m     Dry-run performs no directory, file, activation, receipt or revocation writes.
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:342:89
    [1m[94m|[0m
[1m[94m340 |[0m     force: bool = False,
[1m[94m341 |[0m ) -> InitializationResult:
[1m[94m342 |[0m     """Provide the typed root entrypoint; invalid existing content fails before writes."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m343 |[0m     plan = plan_initialization(request, io=io, templates=templates)
[1m[94m344 |[0m     return commit_initialization(plan, io=io, dry_run=dry_run, force=force)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:348:89
    [1m[94m|[0m
[1m[94m347 |[0m def validate_template_set(template_root: Path, fs: FileSystem) -> None:
[1m[94m348 |[0m     """Preserve the legacy helper's complete missing-template diagnostics without writes."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m349 |[0m     missing = (
[1m[94m350 |[0m         [str(template_root)]
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:378:89
    [1m[94m|[0m
[1m[94m377 |[0m def substitute_placeholders(text: str, tokens: Mapping[str, str] | None = None) -> str:
[1m[94m378 |[0m     """Retain the legacy literal substitution helper, separate from typed v2 rendering."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m379 |[0m     for token, value in (tokens or {}).items():
[1m[94m380 |[0m         text = text.replace(token, value)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:399:89
    [1m[94m|[0m
[1m[94m397 |[0m     validate_target_path(target_dir, fs, force=force)
[1m[94m398 |[0m     raise ValueError(
[1m[94m399 |[0m         "Legacy initialization lacks explicit v2 identity/configuration and trusted writes. "
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m400 |[0m         "Use initialize_workspace(InitializationRequest(...), io=InitializationIO.local(...)) "
[1m[94m401 |[0m         "with system ID/name, repository ID, role and source roots or explicit draft_configuration. "
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:400:89
    [1m[94m|[0m
[1m[94m398 |[0m     raise ValueError(
[1m[94m399 |[0m         "Legacy initialization lacks explicit v2 identity/configuration and trusted writes. "
[1m[94m400 |[0m         "Use initialize_workspace(InitializationRequest(...), io=InitializationIO.local(...)) "
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m401 |[0m         "with system ID/name, repository ID, role and source roots or explicit draft_configuration. "
[1m[94m402 |[0m         "force never permits overwriting existing content."
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (101 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:401:89
    [1m[94m|[0m
[1m[94m399 |[0m         "Legacy initialization lacks explicit v2 identity/configuration and trusted writes. "
[1m[94m400 |[0m         "Use initialize_workspace(InitializationRequest(...), io=InitializationIO.local(...)) "
[1m[94m401 |[0m         "with system ID/name, repository ID, role and source roots or explicit draft_configuration. "
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^[0m
[1m[94m402 |[0m         "force never permits overwriting existing content."
[1m[94m403 |[0m     )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:47:89
   [1m[94m|[0m
[1m[94m46 |[0m     def require_same(self, other: InitializationCapture) -> None:
[1m[94m47 |[0m         """Reject any changed byte, checkout, namespace, absence or physical identity."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m48 |[0m         if (
[1m[94m49 |[0m             self.physical_metadata != other.physical_metadata
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:138:89
    [1m[94m|[0m
[1m[94m136 |[0m @dataclass(frozen=True, kw_only=True)
[1m[94m137 |[0m class BootstrapResult:
[1m[94m138 |[0m     """Report exact completed paths and bounded uncertainty without claiming authority."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m139 |[0m
[1m[94m140 |[0m     ok: bool
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:148:89
    [1m[94m|[0m
[1m[94m147 |[0m class InitializationIO:
[1m[94m148 |[0m     """Bind trusted native readers, guard and directory handles before processing inputs.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m149 |[0m
[1m[94m150 |[0m     A host must authenticate root and bind these capabilities independently of
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:205:89
    [1m[94m|[0m
[1m[94m203 |[0m         directories: tuple[str, ...] = (),
[1m[94m204 |[0m     ) -> InitializationCapture:
[1m[94m205 |[0m         """Load a complete proposal and separately freeze actual bytes and identities."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m206 |[0m         inputs = _ProposalInputs(self, profile_path, profile_bytes, directories)
[1m[94m207 |[0m         proposal = capture_workspace(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:229:89
    [1m[94m|[0m
[1m[94m228 |[0m     def physical_capture(self, profile_path: str) -> CapturedWorkspace:
[1m[94m229 |[0m         """Read only actual inputs after bootstrap; no proposal can reach mutation commit."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m230 |[0m         return capture_workspace(
[1m[94m231 |[0m             workspace_root=self.workspace_root,
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (98 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:251:89
    [1m[94m|[0m
[1m[94m249 |[0m         self, target: ResolvedPath, anchors: ExitStack, created: list[str]
[1m[94m250 |[0m     ) -> None:
[1m[94m251 |[0m         """Exclusively create missing directories and pin checked identities through postcheck."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^[0m
[1m[94m252 |[0m         directory = anchors.enter_context(self.open_directory())
[1m[94m253 |[0m         if directory.identity() != target.observations[0].identity:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:280:89
    [1m[94m|[0m
[1m[94m278 |[0m         directories: tuple[str, ...],
[1m[94m279 |[0m     ) -> BootstrapResult:
[1m[94m280 |[0m         """Publish only the root profile and configured empty directories under one guard.
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m281 |[0m
[1m[94m282 |[0m         Every ordinary artifact is published later by the accepted mutation engine.
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:297:89
    [1m[94m|[0m
[1m[94m295 |[0m         if tuple(sorted(directories)) != allowed:
[1m[94m296 |[0m             raise ValueError(
[1m[94m297 |[0m                 "Bootstrap directories must exactly match configured artifact directories"
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m298 |[0m             )
[1m[94m299 |[0m         created: list[str] = []
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:337:89
    [1m[94m|[0m
[1m[94m335 |[0m                         if stamp.kind == "missing"
[1m[94m336 |[0m                     )
[1m[94m337 |[0m                     # Root-only profile publication is separate from analyst output grants.
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m338 |[0m                     target = replace(
[1m[94m339 |[0m                         target,
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:394:89
    [1m[94m|[0m
[1m[94m392 |[0m         profile_bytes: bytes,
[1m[94m393 |[0m     ) -> None:
[1m[94m394 |[0m         """Allow exactly new configured directories/profile while preserving prior inputs."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m395 |[0m         files = dict(before.physical_files)
[1m[94m396 |[0m         profile_path = before.proposal_base.snapshot.profile.artifacts["profile"]
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_io.py:428:89
    [1m[94m|[0m
[1m[94m426 |[0m             ):
[1m[94m427 |[0m                 raise OSError(
[1m[94m428 |[0m                     "Initialization changed an unrelated filesystem identity or namespace"
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m429 |[0m                 )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\initialization_test_support.py:34:89
   [1m[94m|[0m
[1m[94m32 |[0m @pytest.fixture(scope="module")
[1m[94m33 |[0m def initialization_templates() -> InitializationTemplates:
[1m[94m34 |[0m     """Load immutable committed fixtures; output operations remain entirely in memory."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m35 |[0m     return InitializationTemplates.load(read=lambda path: (ROOT / path).read_bytes())
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_initialization.py:38:89
   [1m[94m|[0m
[1m[94m36 |[0m     role: SystemRole,
[1m[94m37 |[0m ) -> None:
[1m[94m38 |[0m     """Create every configured artifact directory with no fabricated completion facts."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m39 |[0m     case = InitializationCase(initialization_catalog)
[1m[94m40 |[0m     request = request_for(role)
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_initialization.py:68:89
   [1m[94m|[0m
[1m[94m66 |[0m     initialization_templates: InitializationTemplates,
[1m[94m67 |[0m ) -> None:
[1m[94m68 |[0m     """A virtual profile validates a proposal but cannot become a physical observation."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m69 |[0m     case = InitializationCase(initialization_catalog)
[1m[94m70 |[0m     before = dict(case.disk.store.metadata.entries)
   [1m[94m|[0m

Found 24 errors.
```
