Timestamp: 2026-07-09T15-50

Command: `git grep -n "claude-customizations" -- scripts/dev_tools`

Output Summary: The grep returned four matches, all in
`scripts/dev_tools/push_down_claude_customizations.py` (the
`BUNDLE_ROOT_RELATIVE_DIR` constant pointing at
`extensions/drm-copilot/resources/claude-customizations` and the
`ARTIFACT_DIRECTORY`/docstring references) and one match in
`scripts/dev_tools/push_down_claude_pack_selection.py` (a docstring mention
of the `pack-manifests` subdirectory path). Inspection of
`push_down_customizations()` in `push_down_claude_customizations.py` shows:

- `effective_bundle` resolves to `source_root / BUNDLE_ROOT_RELATIVE_DIR`
  (or the caller-supplied `bundle_root`), i.e. the bundle at
  `extensions/drm-copilot/resources/claude-customizations` is read only as
  the source of `pack-manifests/**` JSON and the legacy C# variant subtree,
  via `_resolve_published_paths()` and `ExcludingFileSystem(..., variant_root=effective_bundle)`.
- The actual `.claude` tree that gets copied is read from
  `ROOT_FOLDERS = (Path(".claude"),)` under `source_root` (the repo root, or
  the bundled template's own root when invoked from the template), and
  written to the caller-supplied `destination_root` via
  `push_down_scoped_customizations(...)`.
- `destination_root` is always an external workspace path passed by the
  CLI's `--destination` argument (see `parse_args`/`main`); there is no code
  path in this module, or in
  `scripts/dev_tools/push_down_claude_pack_selection.py`, that writes back
  into `extensions/drm-copilot/resources/claude-customizations/.claude/`.

Conclusion: no repo script auto-generates or synchronizes the bundle at
`extensions/drm-copilot/resources/claude-customizations/.claude/` from the
repo-root `.claude/` tree. The bundle is a manually maintained mirror. A
direct, byte-identical file copy (as performed in Phase 1, tasks P1-T2
through P1-T5) is the correct remediation mechanism.
