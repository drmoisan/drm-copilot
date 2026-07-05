# Push-Down Delivery Membership — Issue #312

Timestamp: 2026-07-05T13-15
Command: JSON membership check of core.json.paths; physical-presence check in both .claude/ and the byte-mirror tree; gitignore trackability check.
EXIT_CODE: 0

Output Summary:
- --packs core delivery: `.claude/lib/model-routing/ModelRouting.psm1` is present in extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json paths[] (membership = True). Asserted by the manifest-membership Pester test (P3-T4) and the Python pack-selection contract test (P7-T4).
- No-selection full-tree publish: the module is physically present in BOTH `.claude/lib/model-routing/ModelRouting.psm1` and the byte-mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/model-routing/ModelRouting.psm1`.
- Trackability: `.gitignore` originally ignored `.claude/lib/` via the Python-build `lib/` rule; a negation exception (mirroring the existing `src/lib`/`test/lib` exceptions) was added so the module and its byte-mirror are tracked and therefore delivered to fresh clones. `git status` now lists both as untracked-to-be-added (not ignored).
- Result: both delivery paths (--packs core and full-tree publish) are satisfied.
