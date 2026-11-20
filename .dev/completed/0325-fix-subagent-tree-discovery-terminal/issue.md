# fix-subagent-tree-discovery-terminal (Issue #325)

- Date captured: 2026-07-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/fix-subagent-tree-discovery-terminal/ (Issue #325)

- Issue: #325
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/325
- Last Updated: 2026-07-07
- Work Mode: minor-audit

## Problem / Why

The `drmCopilotExtension.showSubagentTree` command (merged in PR #323, closes #320)
returns "No root session transcripts found under .claude/projects/**/*.jsonl." in every
repository. Two defects/gaps are in scope:

1. Transcript discovery (bug). The command globs for transcripts relative to the open
   workspace root (`getWorkspaceRoot()` + `.claude/projects/**/*.jsonl`, i.e.
   `<repo>/.claude/projects/`). Claude Code does not write transcripts inside the repo;
   it writes them to a per-user global directory keyed by an encoded cwd:
   `~/.claude/projects/<encoded-cwd>/*.jsonl`. Verified on disk: `~/.claude/projects/`
   holds thousands of transcripts, and per-workspace folders use an encoded name where
   the absolute cwd has path separators and `:` replaced by `-` (e.g.
   `C:\Users\DanMoisan\repos\drm-copilot` -> `C--Users-DanMoisan-repos-drm-copilot`).
   Per-worktree sibling folders also exist (e.g. `...-wt-2026-06-13-11-51`). The
   in-memory unit tests used the same relative glob, so they never exercised the real
   discovery path.

2. Output destination (enhancement). The command writes the rendered tree to a VS Code
   `OutputChannel`. It should instead print the tree to an integrated terminal and
   reveal it, keeping genuine error reporting on the existing error path.

## Proposed Behavior

- Resolve the user-global Claude projects directory (`~/.claude/projects/`, honoring a
  home-dir / CLAUDE config dir override if one exists) instead of globbing inside the repo.
- Narrow candidate discovery to the encoded folder(s) matching the current workspace path,
  including per-worktree sibling folders. Confirm the exact encoding rule against on-disk
  examples before implementing.
- Preserve existing behavior otherwise: exclude flattened `/subagents/` transcripts,
  auto-select a single candidate, quick-pick for multiple, clear error when none found
  (error message names the real search location).
- Render the tree to a stably-named integrated terminal (e.g. "drm-copilot: Subagent Tree"),
  reuse/replace a single named terminal across runs, preserve the existing header line and
  full `formatTree` output (multi-line rendered correctly), and reveal the terminal.
- Route only the rendered tree to the terminal; keep failures / zero-candidates / user-cancel
  on the existing error path (`showErrorMessage` / diagnostic sink).

## Acceptance Criteria

- [x] Transcript discovery resolves the user-global Claude projects directory
  (`~/.claude/projects/`, honoring a home-dir / CLAUDE config dir override) rather than
  globbing `<repo>/.claude/projects/`.
- [x] Candidate discovery is narrowed to the encoded directory name for the current
  workspace path (separators and `:` replaced by `-`), verified against on-disk examples,
  and includes per-worktree sibling folders.
- [x] Existing selection behavior is preserved: flattened `/subagents/` transcripts are
  excluded, a single candidate auto-selects, multiple candidates prompt via quick-pick.
- [x] The zero-candidates error message names the real user-global search location.
- [x] The rendered tree (existing header line plus full `formatTree` output) is written to
  an integrated VS Code terminal, and the terminal is revealed.
- [x] The terminal uses a stable, recognizable name and repeated runs reuse/replace a single
  named terminal rather than accumulating terminals.
- [x] Genuine errors (failures, zero-candidates, user-cancel) still route to the error path
  (`showErrorMessage` / diagnostic sink), not solely to the terminal.
- [x] The pure module boundary is preserved: `extensions/drm-copilot/src/lib/subagent-tree/`
  contains no `vscode` imports and `formatTree` remains a pure string renderer; filesystem-root
  resolution and terminal wiring live in the host-bound command file or behind injectable seams.
- [x] The command remains testable without a live VS Code host: the terminal factory is injected
  the same way the FileSystem seam is, and unit tests assert on captured terminal output.
- [x] The extension toolchain passes: `npm run format`, `lint`, `typecheck`, `test:coverage`,
  `build`. Per-file coverage meets lines >= 85% and branches >= 75%; no production file is
  excluded from coverage.

## Constraints & Risks

- Preserve the host-neutral module boundary: `src/lib/subagent-tree/` must stay free of
  `vscode` imports. All filesystem-root resolution and terminal wiring go in the host-bound
  command file or behind an injectable seam.
- The encoded-directory drive-letter case varies on disk (`c--Users-...` and `C--Users-...`
  both observed); matching must tolerate this.
- Live-host validation (real transcript location + real terminal) is a follow-up per PR #323;
  in-memory tests bypass both paths. This is a known out-of-scope follow-up, not part of this
  deliverable.

## Test Conditions to Consider

- [ ] Transcripts resolved from the user-global dir
- [ ] Workspace -> encoded-dir matching (including drive-letter case tolerance)
- [ ] Per-worktree sibling folders included
- [ ] Zero-candidates message names the real search location
- [ ] Rendered tree (header + formatTree) written to the terminal seam; terminal revealed
- [ ] Terminal name is stable and reused across runs
- [ ] Errors route to the error path, not only the terminal

## Next Step

- [ ] Promote to GitHub issue (bug template)
- [ ] Create `docs/features/active/fix-subagent-tree-discovery-terminal/` folder from the template
