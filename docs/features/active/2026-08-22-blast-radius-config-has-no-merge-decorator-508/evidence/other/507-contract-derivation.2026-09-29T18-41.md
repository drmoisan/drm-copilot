# #507 Contract Derivation (P0-T8, P0-T9)

Timestamp: 2026-09-29T18-41
Command: see per-section commands below (run in Bash from the repository root; grep/sed/wc executed directly).
EXIT_CODE: 0
Output Summary:
- REGISTRY_MODULE: scripts/dev_tools/push_down_claude_destination_writes.py (314 lines)
- REGISTRY_MAPPING: MERGED_RELATIVE_PATHS; REGISTRY_ENTRY_TYPE: NONE; REGISTRY_TUPLE: NONE
- MERGE_DECORATOR: DestinationMergeFileSystem; MERGE_CALL_ORDER: (destination_text, source_text, path)
- ROUTING_MERGE_FUNCTION: merge_routing_documents(destination_text, source_text, path)
- PY_DERIVE_CORE_MODULE: scripts/dev_tools/push_down_claude_blast_radius_derive_core.py
- PARITY_TEST_FILE: tests/scripts/dev_tools/test_push_down_claude_parity.py (438 lines)
- PARITY_TARGET: tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py (new file; R4, 438 > 380)
- CONFIG_SEED_TEST: tests/scripts/dev_tools/test_push_down_claude_config_carriage.py::test_config_carriage_publishes_exactly_two_bundle_config_files
- CONFIG_PUBLISH_ROOT: BUNDLE = /repo/extensions/drm-copilot/resources/claude-customizations (inside the test)
- SOURCE_ROOT_EQUALS_REPO_ROOT: yes
- No STATUS: BLOCKED condition was reached.

## P0-T8 raw outputs

### Rule R1 inputs
First P0-T7 search production files that are also in the P0-T6 change set, excluding `scripts/dev_tools/push_down_claude_customizations.py`:
- scripts/dev_tools/push_down_claude_destination_writes.py
- scripts/dev_tools/push_down_claude_routing_merge.py

Two candidates, so the `^MERGED_[A-Z_]*[[:space:]]*[:=]` filter was applied.
Command (D-TOOLS: Grep tool, content mode, glob `push_down_claude_{destination_writes,routing_merge}.py` under scripts/dev_tools): grep -n -E "^MERGED_[A-Z_]*[[:space:]]*[:=]" <each candidate>
EXIT_CODE: 0
```
scripts/dev_tools/push_down_claude_destination_writes.py:86:MERGED_RELATIVE_PATHS: Mapping[str, MergeFunction] = {
```
(push_down_claude_routing_merge.py: no match.) Exactly one candidate remains.

REGISTRY_MODULE: scripts/dev_tools/push_down_claude_destination_writes.py
REGISTRY_MODULE_DOTTED: scripts.dev_tools.push_down_claude_destination_writes

### Symbol listing
Command: grep -n -E "^class |^def |^[A-Z][A-Z_]+ *[:=]" scripts/dev_tools/push_down_claude_destination_writes.py
EXIT_CODE: 0
```
86:MERGED_RELATIVE_PATHS: Mapping[str, MergeFunction] = {
94:def _normalize_posix(value: Path) -> str:
100:def _relative_posix(path: Path, root: Path) -> str | None:
113:class _DelegatingFileSystem:
158:class DestinationMergeFileSystem(_DelegatingFileSystem):
198:class BlastRadiusDeriveFileSystem(_DelegatingFileSystem):
237:class BundleConfigFileSystem(_DelegatingFileSystem):
288:def build_destination_write_stack(
```

### write_text range
Command: sed -n '/^    def write_text/,/^    [^ )]\|^[^ ]/p' scripts/dev_tools/push_down_claude_destination_writes.py
EXIT_CODE: 0
```
    def write_text(self, path: Path, content: str) -> None:
        """Delegate to the wrapped adapter."""

        self._inner.write_text(path, content)

    def ensure_dir(self, path: Path) -> None:
    def write_text(self, path: Path, content: str) -> None:
        """Write ``content``, merging it when the path is registered and exists.

        Raises:
            ValueError: Propagated from the merge function (for example
                ``RoutingMergeError``) before the inner write occurs.
        """

        relative = _relative_posix(path, self._destination_root)
        merge = self._merges.get(relative) if relative is not None else None
        # An absent destination file has nothing to preserve, so the source
        # text is written unchanged and the next push merges against it.
        if merge is not None and self._inner.is_file(path):
            content = merge(self._inner.read_text(path), content, path)
        self._inner.write_text(path, content)


class BlastRadiusDeriveFileSystem(_DelegatingFileSystem):
    def write_text(self, path: Path, content: str) -> None:
        """Write ``content``, deriving it for the blast-radius target path.

        Raises:
            BlastRadiusDeriveError: When the bundled document is not parseable.
            BlastRadiusGuardError: When a forbidden glob would be emitted. Both
                are raised before the inner write.
        """

        if _relative_posix(path, self._destination_root) == BLAST_RADIUS_RELATIVE_PATH:
            observations = collect_destination_observations(
                self._destination_root, self._lister
            )
            content = derive_destination_module_map(observations, content)
        self._inner.write_text(path, content)


class BundleConfigFileSystem(_DelegatingFileSystem):
```

### Line count
Command: wc -l scripts/dev_tools/push_down_claude_destination_writes.py
EXIT_CODE: 0
```
314 scripts/dev_tools/push_down_claude_destination_writes.py
```

### Derive-core search
Command: grep -rln --include=*.py -E "^class BlastRadiusGuardError" scripts/dev_tools
EXIT_CODE: 0
```
scripts/dev_tools/push_down_claude_blast_radius_derive_core.py
```

Command: sed -n '/^class BlastRadiusGuardError/,/^[^ ]/p' scripts/dev_tools/push_down_claude_blast_radius_derive_core.py
EXIT_CODE: 0
```
class BlastRadiusGuardError(ValueError):
    """Raised when the derivation would emit a forbidden glob.

    Attributes:
        glob (str): The forbidden glob that tripped the guard.
        module_name (str): Module that would have carried the glob.
    """

    def __init__(self, module_name: str, glob: str) -> None:
        """Build the TypeScript-identical message for the offending module."""

        super().__init__(
            f"Derived blast-radius module {module_name} would emit the forbidden "
            f"glob {glob}; the derivation was aborted before writing."
        )
        self.glob = glob
        self.module_name = module_name


def _prune_ancestors(paths: Sequence[str]) -> list[str]:
```

Command: grep -n -E "^(BLAST_RADIUS_RELATIVE_PATH|FORBIDDEN_GLOBS)" scripts/dev_tools/push_down_claude_blast_radius_derive_core.py
EXIT_CODE: 0
```
63:BLAST_RADIUS_RELATIVE_PATH = "config/blast-radius.json"
73:FORBIDDEN_GLOBS: tuple[str, ...] = ("**", "docs/**", "tests/**")
```

### Rule R2 values
- REGISTRY_ENTRY_TYPE: NONE (no dataclass entry type in REGISTRY_MODULE)
- REGISTRY_TUPLE: NONE
- REGISTRY_MAPPING: MERGED_RELATIVE_PATHS (module-level `Mapping[str, MergeFunction]` dict literal, line 86; keys are string literals)
- Entry type field names: n/a (REGISTRY_ENTRY_TYPE is NONE)
- MERGE_DECORATOR: DestinationMergeFileSystem (constructor `(inner, *, destination_root, merges=MERGED_RELATIVE_PATHS)`)
- MERGE_CALL_ORDER: (destination_text, source_text, path) - read from `content = merge(self._inner.read_text(path), content, path)` in `DestinationMergeFileSystem.write_text`; also stated by the `MergeFunction` alias comment at line 83.
- ROUTING_MERGE_FUNCTION: merge_routing_documents(destination_text: str, source_text: str, path: Path) -> str, in scripts/dev_tools/push_down_claude_routing_merge.py line 121
- REGISTRY_MODULE_DOTTED: scripts.dev_tools.push_down_claude_destination_writes
- PY_DERIVE_CORE_MODULE: scripts/dev_tools/push_down_claude_blast_radius_derive_core.py
- PY_DERIVE_CORE_MODULE_DOTTED: scripts.dev_tools.push_down_claude_blast_radius_derive_core
- BlastRadiusGuardError constructor signature: `__init__(self, module_name: str, glob: str)`; attributes `glob`, `module_name`.
- BLAST_RADIUS_RELATIVE_PATH defined at module level: yes (line 63)
- FORBIDDEN_GLOBS defined at module level: yes (line 73)
- Other #507 symbols in REGISTRY_MODULE (for P9-T6): MergeFunction, MERGED_RELATIVE_PATHS, _normalize_posix, _relative_posix, _DelegatingFileSystem, DestinationMergeFileSystem, BlastRadiusDeriveFileSystem, BundleConfigFileSystem, build_destination_write_stack.
- Composition note: `build_destination_write_stack` places BlastRadiusDeriveFileSystem outside DestinationMergeFileSystem, so a merge registered for `config/blast-radius.json` receives the derived document as its source text.

## P0-T9 raw outputs

### Rule R3
Third P0-T7 output: tests/scripts/dev_tools/test_push_down_claude_parity.py, tests/scripts/dev_tools/test_skill_bundle_contract_repo.py. Only test_push_down_claude_parity.py is in the P0-T6 change set. Exactly one candidate.
PARITY_TEST_FILE: tests/scripts/dev_tools/test_push_down_claude_parity.py

Command: grep -n -E "^[[:space:]]*def test_" tests/scripts/dev_tools/test_push_down_claude_parity.py
EXIT_CODE: 0
```
257:def test_root_folders_match_typescript_in_order() -> None:
266:def test_merged_relative_paths_match_typescript() -> None:
283:def test_derived_relative_paths_match_typescript() -> None:
298:def test_typescript_root_folder_extraction_detects_divergence() -> None:
312:def test_python_root_folder_extraction_detects_divergence() -> None:
326:def test_set_comparison_fails_on_divergent_merged_paths() -> None:
348:def test_typescript_extraction_rejects_zero_declarations() -> None:
363:def test_python_extraction_rejects_zero_declarations() -> None:
378:def test_typescript_comment_stripping_ignores_commented_declarations() -> None:
397:def test_routing_merge_fixture_parity() -> None:
```

Command: wc -l tests/scripts/dev_tools/test_push_down_claude_parity.py
EXIT_CODE: 0
```
438 tests/scripts/dev_tools/test_push_down_claude_parity.py
```

PARITY_TEST_NAMES (10): test_root_folders_match_typescript_in_order, test_merged_relative_paths_match_typescript, test_derived_relative_paths_match_typescript, test_typescript_root_folder_extraction_detects_divergence, test_python_root_folder_extraction_detects_divergence, test_set_comparison_fails_on_divergent_merged_paths, test_typescript_extraction_rejects_zero_declarations, test_python_extraction_rejects_zero_declarations, test_typescript_comment_stripping_ignores_commented_declarations, test_routing_merge_fixture_parity
PARITY_TEST_NAMES_COUNT: 10

### Rule R4
PARITY_TEST_FILE line count 438 > 380.
PARITY_TARGET: tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py (new file; imports shared helpers from PARITY_TEST_FILE). Final for the rest of the plan.

### Rule R5
Command: grep -rln --include=*.ts "push_down_claude_customizations" extensions/drm-copilot/test
EXIT_CODE: 0
```
extensions/drm-copilot/test/lib/push-down/push-down-service-call.test.ts
extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts
extensions/drm-copilot/test/mcp-server.test.ts
extensions/drm-copilot/test/mcp-tools.push-down-claude.test.ts
extensions/drm-copilot/test/push-down-claude-handler.test.ts
extensions/drm-copilot/test/repo-automation-service.push-down-claude.test.ts
```

Command: grep -rln --include=*.py "push_down_claude_customizations" tests/scripts/dev_tools
EXIT_CODE: 0
```
tests/scripts/dev_tools/test_push_down_claude_config_carriage.py
tests/scripts/dev_tools/test_push_down_claude_customizations.py
tests/scripts/dev_tools/test_push_down_claude_destination_writes.py
tests/scripts/dev_tools/test_push_down_claude_memory_scope.py
tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py
tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py
tests/scripts/dev_tools/test_push_down_claude_pack_selection.py
tests/scripts/dev_tools/test_push_down_claude_parity.py
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
```

Walk in P0-T6 file order: the four `test_push_down_claude_blast_radius_derive*.py` files contain no `push_down_customizations(` call (checked with `grep -n -E "push_down_customizations\(|orchestration-routing"`; only a derive-core string at line 23, no push call). The next file, `tests/scripts/dev_tools/test_push_down_claude_config_carriage.py`, has as its first test (line 120) `test_config_carriage_publishes_exactly_two_bundle_config_files`, which calls `push_down_customizations` through the same-file helper `_push` and asserts the destination `config/` names equal `["blast-radius.json", "orchestration-routing.json"]`.

CONFIG_SEED_TEST: tests/scripts/dev_tools/test_push_down_claude_config_carriage.py::test_config_carriage_publishes_exactly_two_bundle_config_files
CONFIG_SEED_HELPER: _push (fs, *, packs=None)
CONFIG_SEED_ARGUMENTS: repo_root=SOURCE (Path("/repo")), destination_root=DEST (Path("/dest")), fs=<RecordingFileSystem from push_down_customizations_test_support>, source_root=SOURCE, artifact_root=DEST, packs=None (helper default), list_entries=_lister (layout lister)
CONFIG_PUBLISH_ROOT: BUNDLE = SOURCE / "extensions/drm-copilot/resources/claude-customizations" (the bundle root; the test seeds `BUNDLE/config/blast-radius.json` and `BUNDLE/config/orchestration-routing.json`, and those are the files asserted at the destination). Differs from repo_root; recorded, not a stop.
effective_source assignment observed at scripts/dev_tools/push_down_claude_customizations.py line 271: `effective_source = source_root if source_root is not None else repo_root`
SOURCE_ROOT_EQUALS_REPO_ROOT: yes (source_root=SOURCE equals repo_root=SOURCE)

### Rule R6
PARITY_TEST_FILE reads TypeScript through `_read_repo_text(TS_CUSTOMIZATIONS)` (helper at line 54; `TS_CUSTOMIZATIONS` constant at line 36; reads at lines 260 and 270, plus `TS_DERIVE_CORE` at lines 271 and 288). Parsing helpers: `_strip_ts_comments` (60), `_ts_declarations` (110), `_registry_keys` (132, accepts `{`, `new Map`, `[` initializers), `_ts_merged_paths` (146, unions `MERGED_RELATIVE_PATHS` keys and any `*MERGE*_RELATIVE_PATH(S)` literal), `_py_assignment` (181), `_py_merged_paths` (222).
TypeScript-side parity test found by the `*.ts` grep: none. The six matches are MCP, handler, and service-call tests that reference the Python script by name; none compares the Python registry. (The #507 TS parity test `extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts` exists in the change set but does not name `push_down_claude_customizations`.)

## Acceptance check
- All P0-T8 labels have a value or NONE; MERGE_DECORATOR, MERGE_CALL_ORDER, ROUTING_MERGE_FUNCTION are not NONE.
- PY_DERIVE_CORE_MODULE defines BLAST_RADIUS_RELATIVE_PATH and FORBIDDEN_GLOBS at module level.
- PARITY_TEST_FILE, PARITY_TARGET, PARITY_TEST_NAMES (10), CONFIG_SEED_TEST, CONFIG_PUBLISH_ROOT, SOURCE_ROOT_EQUALS_REPO_ROOT=yes are recorded; none is BLOCKED.
