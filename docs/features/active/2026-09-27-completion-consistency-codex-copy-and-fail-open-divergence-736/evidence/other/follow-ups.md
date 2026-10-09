# Out-of-scope follow-ups (issue #736)

Timestamp: 2026-10-08T18-03

1. FOLLOW-UP: the cwd-relative patch-source read in `Resolve-CodexUpdatedFileContent` in `.codex/hooks/codex-pretooluse-file-mapping.ps1` still resolves its source file against the working directory; it is outside this change.
2. FOLLOW-UP: the invalid-JSON reconstructed-content divergence between the two completion-consistency hooks (the Claude hook allows, the Codex hook denies) remains; it is recorded as accepted per-surface behaviour in this change.
3. FOLLOW-UP: the Claude-allow versus Codex-deny split in `enforce-checkpoint-monotonic.ps1` for unresolved Edit calls remains; it is outside this change.
