# Remediation Inputs — Cycle 4 (CI Failure: Pack-Manifest Completeness)

- Timestamp: 2026-07-19T04:15:32Z
- Feature: legacy-discovery-dotnet-vsto-analyzers
- Canonical issue number: 369
- PR: #384 (base epic/legacy-discovery-and-parity-integration)
- Branch head at cycle entry: a26a4abbf5fd2882c1c7c72e4b73dd7e3fe0a387
- Source: S9 CI-green gate — required-workflow CI run failed
- Cycle entry: remediation.cycle_4.inputs

## Failing check

- Check name: `Extension Tests (ubuntu-latest)` — state FAILURE
  - Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/29672928175/job/88155059086
- `Extension Tests (windows-latest)` — CANCELLED (fail-fast after the ubuntu job failed)
  - Job URL: https://github.com/drmoisan/drm-copilot/actions/runs/29672928175/job/88155059105
- Workflow run: https://github.com/drmoisan/drm-copilot/actions/runs/29672928175

## Finding 1 — BLOCKING: bundled hooks not registered in any pack manifest

Severity: Blocking (synthetic finding from failed required CI check)

The extension jest suite `test/lib/push-down/claude-pack-manifest-completeness.test.ts`
("claude pack manifest completeness (real filesystem) › lists every bundled .claude agent,
skill, and hook file in some pack manifest") fails:

```
expect(missing).toEqual([]);
Expected: []
Received: [ ".claude/hooks/enforce-discovery-artifact-gate.ps1", ".claude/hooks/validate-discovery-artifact-gate.ps1" ]
```

The test requires every bundled `.claude` agent/skill/hook file under
`extensions/drm-copilot/resources/claude-customizations/.claude/` to be listed in the
`paths` array of at least one `resources/claude-customizations/pack-manifests/*.json`
manifest (minus three documented pre-existing exceptions). The two discovery-artifact-gate
hooks that cycle 2 pushed down into the bundle are not registered in any pack manifest.

### Root cause and provenance

This is the deterministic, convergent completion of the cycle-2 bundle push-down. The
integration branch was in an inconsistent intermediate state for these two hooks: the
Python contract test `test_bundled_claude_payload_contains_all_repo_runtime_contracts`
requires the repo hooks to be mirrored into the bundle, while the extension test
`claude-pack-manifest-completeness` requires every bundled file to be manifest-registered.
Both pass only when the two hooks are BOTH bundled (cycle 2) AND registered in a pack
manifest (this cycle). This mirrors the established repository pattern (issue #367,
"register seven discovery skills in core pack manifest"), which registered the sibling
discovery skills in `core.json`.

Locally reproduced: the missing set is exactly the two hooks above (the CI jest diff's
"+4" is jest rendering the two-element received array).

### Required remediation

1. Register both bundle hook paths in the core pack manifest
   `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`,
   appending to its `paths` array (hooks are core runtime; the sibling discovery skills are
   already registered in `core.json`):
   - `.claude/hooks/enforce-discovery-artifact-gate.ps1`
   - `.claude/hooks/validate-discovery-artifact-gate.ps1`
   Preserve the array's existing ordering convention; change nothing else in the manifest.
2. Re-run the extension jest suite (`npm --prefix extensions/drm-copilot run test`) until
   `claude-pack-manifest-completeness` passes.
3. Confirm the full Python toolchain remains green with no regression (Black -> Ruff ->
   Pyright -> Pytest with coverage), and that the Python bundle contract test still passes.
4. Commit and push.

### Expected outcome

The extension test passes, the CI Extension Tests checks go green, PR #384 remains
mergeable, and the S9 CI-green gate and epic-mode merge-on-green can proceed.

## Loop-cap note

This is the first CI-failure pass. Remediation cycles 1-3 were merge-conflict and
local-finding passes, each of which resolved its distinct finding (the shared cap's
halt condition, "reaches the cap without resolution," was never triggered — the chain is
converging, not stuck). The CI-failure-specific cap is the "third CI-failure pass"; this is
CI-failure pass 1. If registering the manifest surfaces yet another distinct CI failure,
the orchestrator will halt and escalate to the epic-orchestrator rather than continue.
