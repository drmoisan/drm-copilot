# bundle-sync-agents (Issue #113)

- Date captured: 2026-03-21
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bundle-sync-agents/ (Issue #113)

- Issue: #113
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/113
- Last Updated: 2026-03-22
- Work Mode: full-feature

## Problem / Why

The repository already has `scripts/dev-tools/sync-agents-from-instructions.ps1`, but it is not exposed through the VS Code extension command surface that currently drives other destination-workspace workflows. Users who push bundled tooling into another workspace can sync customization files there, but they cannot trigger `AGENTS.md` regeneration from the extension in the same way.

The current script also hard-codes a fixed section list and rewrites section titles instead of discovering the canonical instruction sources that actually exist under `.github/`. That makes the sync brittle when new instruction files are added, renamed, or reorganized, and creates drift between the generated `AGENTS.md` content and the instruction set the repo actually ships.

## Proposed Behavior

Add a new extension command that runs a bundled `sync-agents-from-instructions` workflow against the current destination workspace root, following the same execution model used by `drmCopilotExtension.pushDownCopilotCustomizations` and the other live bundled commands.

Update the sync implementation so generation is discovery-based instead of section-list-based. The script should treat `.github/copilot-instructions.md` as the canonical repository-wide preamble, scan the destination workspace’s `.github/` tree for applicable `*.instructions.md` files, strip frontmatter, and combine their bodies into a deterministic `AGENTS.md` output without requiring a manually maintained array of section definitions. The generated file should still remain clearly marked as derived output and should preserve a stable ordering so repeated runs are idempotent.

## Acceptance Criteria (early draft)

- [ ] The extension contributes a new command for syncing `AGENTS.md`, and invoking it runs the bundled sync workflow against the open workspace root rather than the extension installation directory.
- [ ] The bundled sync workflow reads `.github/copilot-instructions.md` and discovers instruction sources under `.github/` from the destination workspace instead of depending on a hard-coded section-definition array.
- [ ] The generated `AGENTS.md` includes the canonical repository instructions plus the discovered instruction bodies in a deterministic order, strips YAML frontmatter from source files, and produces identical output on repeated runs when inputs have not changed.
- [ ] If the destination workspace is missing required source files such as `.github/copilot-instructions.md` or has no discoverable instruction files, the command fails with an actionable error message instead of generating partial or misleading output.
- [ ] Adding a new instruction file under the supported `.github/` discovery scope causes the next sync run to include it automatically without requiring a code change to the sync script.

## Constraints & Risks

- Scope should stay limited to generating `AGENTS.md` for the destination workspace; this idea does not require changing the semantics of the underlying instruction files themselves.
- Discovery must be deterministic. If file ordering depends on platform-specific enumeration order, two developers could generate different `AGENTS.md` output from the same repo state.
- The script must avoid recursively ingesting generated or mirrored outputs such as `AGENTS.md` itself, otherwise the generated file can become self-referential or duplicate content.
- Title generation is a compatibility risk. Some instruction files have frontmatter metadata and markdown headings today, but future files may not. The implementation should define a stable fallback for section labels.
- Bundling the command into the extension adds one more workspace-execution path that must remain aligned between the repo-root script and the bundled extension copy.

## Test Conditions to Consider

- [ ] Unit coverage areas
	- Discovery of `.github/copilot-instructions.md` plus `*.instructions.md` files from the destination workspace
	- Frontmatter stripping, empty-file handling, deterministic ordering, and section-label derivation
	- Exclusion of generated outputs or unsupported files from the aggregation set
- [ ] Integration scenarios
	- Extension command execution updates `AGENTS.md` successfully in a workspace that contains the expected `.github/` instruction sources
	- Workspace with an added instruction file is resynced without any code changes and includes the new content
	- Workspace missing required inputs fails fast with a clear error surfaced through the extension output/logging path
- [ ] CLI/API examples
	- Manual invocation of `scripts/dev-tools/sync-agents-from-instructions.ps1` against an explicit repo root still works for repository-local use
	- Extension command invocation produces the same `AGENTS.md` result as the direct script run for the same workspace contents

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/bundle-sync-agents/` folder from the template