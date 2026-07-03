## README Stale Reference Verification — Remediation Cycle 1 (Issue #272)

**Timestamp:** 2026-07-02T20-55
**Command:** `grep -n "validate-orchestrator-state" README.md`
**EXIT_CODE:** 1 (grep convention: exit code 1 means no matches found)
**Output Summary:**
Zero matches remain for `validate-orchestrator-state` in `README.md`. The stale bullet `` `validate-orchestrator-state.yml` — validation of the orchestrator-state checkpoint artifact. `` was removed from the `## CI and release workflows` list (previously line 390), which described a workflow file that this feature's own PR deletes.

**Before:**
```
- `publish-extension.yml` — tag-driven publication of the VS Code extension to the Marketplace, gated on the extension test matrix; pull requests that touch the extension build and package without publishing.
- `validate-orchestrator-state.yml` — validation of the orchestrator-state checkpoint artifact.
- `npm-audit-gate.yml` — npm dependency audit gate.
```

**After:**
```
- `publish-extension.yml` — tag-driven publication of the VS Code extension to the Marketplace, gated on the extension test matrix; pull requests that touch the extension build and package without publishing.
- `npm-audit-gate.yml` — npm dependency audit gate.
```
