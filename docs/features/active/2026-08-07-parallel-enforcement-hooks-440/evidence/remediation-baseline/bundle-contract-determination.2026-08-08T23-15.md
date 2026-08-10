# Bundle-Contract Determination — Issue #440 F7 Remediation Cycle 1

- **Task:** [P0-T10]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`

Timestamp: 2026-08-09T00-25

## Command 1 — `.claude` scope

Command: `git status --porcelain -- .claude` (run from the repository root)

EXIT_CODE: 0

Output, verbatim:

```
 M .claude/hooks/enforce-epic-invocation-origin.ps1
 M .claude/settings.json
 M .claude/skills/parallel-orchestrate/SKILL.md
?? .claude/hooks/enforce-parallel-cohort-barrier.ps1
?? .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
```

All five entries are pre-existing uncommitted work from the **original** plan `plan.2026-08-07T11-10.md` (53/53 tasks complete), not from this remediation cycle. This branch has zero commits, so the original plan's output is still uncommitted working-tree state. Each of the five already has its byte mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/` and its `pack-manifests/core.json` entry, all present in the same pre-existing working-tree set (see the P0-T12 baseline). **This remediation cycle creates and modifies no file under `.claude/`**, so these five entries are the P0-T12 baseline, not a delta this cycle produces. P3-T3 re-runs this command and confirms no change is attributable to this cycle.

## Command 2 — build-output ignore status

Command: `git check-ignore -v extensions/drm-copilot/out extensions/drm-copilot/dist` (run from the repository root)

EXIT_CODE: 0

Output, verbatim:

```
.gitignore:1:out	extensions/drm-copilot/out
.gitignore:2:dist	extensions/drm-copilot/dist
```

Both paths are ignored. Exit code 0 from `git check-ignore` means every supplied path matched an ignore rule; `.gitignore` line 1 is `out` and line 2 is `dist`.

## The Four Determinations

### 1. No `.claude` file is in scope, so no byte mirror and no `pack-manifests/core.json` entry are required

This remediation creates or modifies no file under `.claude/`. Its entire change set is: one new TypeScript module under `extensions/drm-copilot/src/lib/validate/`, a two-line addition to an existing sibling in that directory, a test-fixture recolour and a `coverageThreshold` entry in the extension test scope, two new TypeScript test files, one new Python test file, a new JSON corpus under `tests/fixtures/`, and this feature's own plan and evidence artifacts. **The `.claude` byte-mirror contract is NOT TRIGGERED.** No byte mirror into `extensions/drm-copilot/resources/claude-customizations/.claude/` is required, and no new entry in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` is required.

### 2. `extensions/drm-copilot/src/**` is compiled extension source under a different contract from the `.claude` mirror

The `.claude` bundle-mirror contract governs `.claude/**` runtime customization files, which are byte-mirrored into the extension's `resources/claude-customizations/` tree and enumerated in the pack manifests. `extensions/drm-copilot/src/**` is compiled extension SOURCE: it is consumed by `tsc` and by the esbuild bundlers, not byte-copied into a resource pack. **No mirror obligation applies to `extensions/drm-copilot/src/**`.** The new module and the seam edit both land under that path.

### 3. `out` and `dist` are gitignored, so NO build, compile, or packaging step is required for this remediation to land

The extension's build outputs — `out/extension.js` and `out/mcp-server.js`, produced by `esbuild-extension.cjs` and `esbuild-mcp-server.cjs` — are gitignored, as the `git check-ignore -v` output above proves for both `out` and `dist`. No compiled artifact is committed, so nothing in the repository goes stale when a `src/**` file changes. **No build, compile, or packaging step is required.** The only compilation this change requires is `npm run typecheck` (`tsc -p ./ --noEmit`, verified clean at P0-T5) plus the in-memory `ts-jest` transform used by the Jest run, both already in the TypeScript toolchain. The esbuild bundles are produced by the extension scope's own `npm run compile` / `npm run build`, which the release process invokes and which no task in this plan runs.

### 4. The bundled `out/mcp-server.js` picks up the ported invariant only at rebuild/republish time — a release-time step, recorded here, not a task in this plan

An installed extension serves `mcp__drm-copilot__validate_orchestration_artifacts` from the bundled `out/mcp-server.js`. Because that bundle is gitignored and is produced by the release process rather than by this remediation, the ported `PARALLEL_COHORT_BARRIER_VIOLATION` invariant reaches a user's live MCP surface only after the extension is rebuilt and republished. That is a release-time step owned by the release process, identical in kind to advisory finding A-2's mechanism. **It is recorded here and is not a landing-time obligation of this remediation.** No task in this plan performs it.

## Determination Summary

All four determinations are confirmed by the two recorded commands. P3-T3 provides the confirming check by running `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` together with `git status --porcelain -- .claude`.
