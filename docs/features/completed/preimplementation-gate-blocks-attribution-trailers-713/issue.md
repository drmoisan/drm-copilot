# Bug: preimplementation-gate-blocks-attribution-trailers

- Issue: #713
- Type: bug
- Labels: bug
- Work Mode: full-bug
- Source: GitHub issue #713 body (the lifecycle record `docs/features/potential/2026-09-26-preimplementation-gate-blocks-attribution-trailers.md` is not present on this branch; this file was populated from the issue body on 2026-09-27)

## Summary

When no per-feature checkpoint exists, `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` admits a commit only as a single `-m` command free of `<`, `>`, `$` and backticks. A required `Co-Authored-By: Name <email>` trailer therefore cannot be written, and planning-branch commits land without attribution.

## Environment

- OS/version: Windows 11, Claude Code
- Python version: n/a (PowerShell hook)
- Command/flags used: a planner committing a manifest to `parallel/<slug>-plan` with a message carrying a `Co-Authored-By` trailer
- Data source or fixture: the parallel run `backlog-2026-09-26` (2026-09-25)

## Steps to Reproduce

1. With no `artifacts/orchestration/orchestrator-state.json` feature checkpoint, commit on a planning branch using a message that includes `Co-Authored-By: ... <noreply@anthropic.com>`.
2. Observe the `PREIMPLEMENTATION_GATE_BLOCKED` denial.
3. Retry without the trailer; it passes.

## Expected Behavior

Attribution trailers, which session policy requires, are writable on planning and housekeeping commits.

## Actual Behavior

The `backlog-2026-09-26` planner committed its manifest and kickoff without `Co-Authored-By` lines; only `Claude-Session` survived. Separately, in the same session, a heredoc-fed commit message was denied outright, because the gate matches whole command text, including heredoc bodies.

## Logs / Screenshots

- Snippet: the `parallel/backlog-2026-09-26-plan` commit history; the planner's final report, deviation 3.

## Impact / Severity

- Medium

## Acceptance Criteria

- [ ] With no ready feature checkpoint, a pathspec-scoped planning or housekeeping commit whose message carries a `Co-Authored-By: Name <email>` trailer is admitted by `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (no `PREIMPLEMENTATION_GATE_BLOCKED` denial).
- [ ] The admitted commit form(s) are documented, and the `<`, `>`, `$`, and backtick characters inside a quoted commit-message argument no longer cause a denial on their own.
- [ ] The relaxation opens no bypass: shell redirection, command substitution, variable expansion, chaining, and non-exempt pathspecs outside the quoted message remain denied, each covered by a regression test.
- [ ] The Codex mirror under `.codex/hooks/` and the extension-bundled mirrors under `extensions/drm-copilot/resources/` remain byte-identical to the `.claude/hooks/` source after the change.
- [ ] Regression tests reproduce the original denial before the fix and pass after it; the PowerShell toolchain (format, analyze, Pester with coverage) passes.
