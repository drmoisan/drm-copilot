# Follow-ups — Issue #708

Timestamp: 2026-09-27T09-02

These items are out of scope for #708 (spec "Out of Scope and Follow-ups" and decision D11). None was changed by this work.

1. FOLLOW-UP: Codex Edit-branch instance of the same defect.
   `.codex/hooks/enforce-completion-consistency.ps1`, function `Resolve-EditedCheckpointContent`, still passes the relative checkpoint literal to its reader, and its bundled copy under `extensions/drm-copilot/resources/codex-and-agents-customizations` carries the same code. The pinned reader assertion in `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` must change together with that fix. Sequence this after #707 merges.

2. FOLLOW-UP: `String.Replace` replaces every occurrence of `old_string`.
   `Resolve-EditedCheckpointContent` applies the patch with `String.Replace`, which replaces all occurrences; the Edit tool replaces a single unique occurrence unless `replace_all` is set. The in-memory result can therefore differ from the file the Edit produces when `old_string` occurs more than once.

3. FOLLOW-UP: Default-reader test depends on the working directory.
   The test in `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` (context "Edit tool calls (no full content)") uses the default reader, so its result depends on whether a checkpoint file exists relative to the test process working directory. It should inject a reader.

4. FOLLOW-UP: Fail semantics for a missing or unreadable targeted checkpoint.
   The Claude hook allows an Edit when the targeted checkpoint is missing, empty, or cannot be patched; the Codex hook denies in the equivalent case. Whether the Claude hook should deny is a policy decision that #708 does not make (spec D6).

5. FOLLOW-UP: Optional post-merge live confirmation.
   After merge, confirm the behavior live with an isolated-worktree subagent that edits its own absolute checkpoint path. This is optional and is not an acceptance criterion.
