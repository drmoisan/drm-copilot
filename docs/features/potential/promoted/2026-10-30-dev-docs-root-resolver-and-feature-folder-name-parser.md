# dev-docs-root-resolver-and-feature-folder-name-parser (Issue #1035)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/dev-docs-root-resolver-and-feature-folder-name-parser/ (Issue #1035)
- Last Updated: 2026-10-30

- Issue: #1035
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1035
## Problem / Why

Epic #1018 (shared agent-harness layer) child 2. This issue delivers Phase 1 of #1016 (move development docs to a `.dev` root). Owner decision E1 (2026-10-30): #1016 itself is adopted by epic child 7 (Phases 2 and 3) and closes only when the move to `.dev` completes, so Phase 1 is tracked here. This issue references #1016 and does not close it; no pull request for this issue carries a Closes, Fixes or Resolves line for #1016.

No consumer reads a configured development-docs root today: TypeScript, Python and PowerShell each hard-code `docs/features`, and feature-folder names are parsed only in the date-first format.

## Proposed Behavior

#1016 Phase 1, behavior unchanged by default, as settled in decisions D-1 to D-22 of the #1016 record (`docs/features/potential/promoted/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production.md`):

- One configured key, `development_docs_root`, default `docs/features`, read by every hook, validator, MCP tool and script.
- A resolver in Python (existing modules extended in place), PowerShell and TypeScript, with the `.dev` fallback.
- `.dev/**` in the CI docs-only scope (D-12) and `.dev/**/*.json` in the JSON governance globs (D-14).
- Explicit dot-folder handling plus a test for every Node-glob and ripgrep consumer (D-13).
- Agent and hook write scopes as generated or checked literals with a coverage test (D-16).
- The feature-folder name parser accepting the old date-first format and the new `<4-digit zero-padded issue number>-<feature>` format (D-18, D-19), and the folder-creation tool naming new folders from the issue number.
- Mirrored, bundled, pack-manifest and Codex counterparts.

The prepared spec, user story, research and approved atomic plan are in the epic integration branch `epic/shared-agent-harness-layer-integration`.

## Acceptance Criteria (early draft)

- [ ] One configured key, `development_docs_root`, drives every consumer in Python, PowerShell and TypeScript; with the default `docs/features` the repository behaves exactly as before.
- [ ] With the key set to `.dev`, the resolvers return `.dev` paths, and the fallback to `docs/features` applies when `.dev` is absent.
- [ ] `.dev/**` counts as docs-only in the CI change scope and `.dev/**/*.json` stays under JSON governance.
- [ ] A test proves every Node-glob and ripgrep consumer finds a record under `.dev`.
- [ ] A test proves every agent and hook write scope covers the configured root.
- [ ] Parsers accept both the date-first and the `<NNNN>-<feature>` folder formats; new folders are named from the issue number.
- [ ] Mirrored and bundled files, pack manifests, Codex counterparts and contract tests pass.
- [ ] Enforcement hooks do not invoke Python, and no new Python file or entry point is added.

## Constraints & Risks

- Runs after the parallel run `bugs-1001-1002-1003-1006` merges; the plan's Phase 0 gate re-checks every named file.
- Does not close #1016.

## Next Step

- [ ] Promote to GitHub issue (feature)
