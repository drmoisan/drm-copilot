# Pack-Manifest-Completeness Baseline (P0-T6)

Timestamp: 2026-08-28T11-36

Task: [P0-T6]
Issue: #573
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `poetry run pytest tests/scripts/dev_tools/ -k test_bundled_claude_files_are_listed_in_some_pack_manifest -q`

EXIT_CODE: 0

## Result

```
.                                                                        [100%]
1 passed, 4111 deselected in 0.72s
```

The `-k` selector resolved to exactly one test, the named test in `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, and it passed.

This baseline is green. Unlike the bundle-parity contract test captured in [P0-T5], this test enumerates the **bundled** payload rather than the repository `.claude` tree, so gitignored local state under `.claude/state/` does not affect it.

The relevance to this change is that the plan creates no new file. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is already listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, so the manifest requires no edit and this test must remain green with the manifest byte-unchanged. That is re-checked at [P3-T3] and the manifest's absence from the diff is re-checked at [P5-T11] (AC-15).

Output Summary: GREEN baseline. `1 passed, 4111 deselected in 0.72s`; exactly one test selected, zero failures. No pre-existing failure to attribute. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` is complete as committed and must remain unedited, since this change adds no new bundled file.
