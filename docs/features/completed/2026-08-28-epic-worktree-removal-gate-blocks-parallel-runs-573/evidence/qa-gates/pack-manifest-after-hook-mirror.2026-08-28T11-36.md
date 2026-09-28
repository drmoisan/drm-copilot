# Pack-Manifest Completeness After the Hook Mirror (P3-T3)

Timestamp: 2026-08-28T11-36

Task: [P3-T3]
Issue: #573
Acceptance criterion supported: AC-15
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. `poetry run pytest tests/scripts/dev_tools/ -k test_bundled_claude_files_are_listed_in_some_pack_manifest -q`
2. Companion tree observation: `git status --porcelain extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

EXIT_CODE: 0

## Result

```
.                                                                        [100%]
1 passed, 4111 deselected in 0.71s
```

Exactly one test was selected and it passed. Unlike the bundle-parity contract test of [P3-T2], this test enumerates the **bundled** payload rather than the repository `.claude` tree, so the gitignored `.claude/state/` file that causes the issue #510 red does not affect it. No attribution to the [P0-T6] baseline is needed: the baseline was green and this run is green.

## The manifest itself is unchanged

`git status --porcelain` for `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` produced **no output**, meaning the file is neither modified nor staged nor untracked relative to `HEAD`. This is the expected outcome: this change creates no new file, so the gate hook was already listed in `core.json` and required no manifest entry. The manifest's continued absence from the whole-change diff is re-verified at [P5-T11].

Output Summary: PASS. `1 passed, 4111 deselected in 0.71s`, exit 0, with exactly one test selected. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` produced empty `git status --porcelain` output, confirming the manifest is byte-unchanged. AC-15's two conditions — pack-manifest test green and manifest unchanged — are both satisfied at this point in the plan.
