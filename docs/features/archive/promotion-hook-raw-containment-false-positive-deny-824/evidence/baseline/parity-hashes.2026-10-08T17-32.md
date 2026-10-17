# Baseline: Parity Hashes

Timestamp: 2026-10-08T17-32
Command: sh <SCRATCHPAD>/s-hash.sh baseline
EXIT_CODE: 0
Output Summary:
GROUP shared-hook-command-scanner.ps1 DISTINCT=1
GROUP shared-hook-command-heredoc.ps1 ABSENT_AT_BASELINE
GROUP shared-hook-command-payload.ps1 ABSENT_AT_BASELINE
GROUP shared-hook-command-payload-powershell.ps1 ABSENT_AT_BASELINE
GROUP shared-hook-command-invocation.ps1 DISTINCT=1
GROUP shared-hook-command-invocation-operands.ps1 ABSENT_AT_BASELINE
GROUP claude-enforce-promotion-mcp-only.ps1 DISTINCT=1
GROUP claude-enforce-epic-worktree-removal-gate.ps1 DISTINCT=1
GROUP claude-enforce-parallel-worktree-removal-gate.ps1 DISTINCT=1
GROUP claude-enforce-pr-author-skill-helpers.ps1 DISTINCT=1
GROUP claude-enforce-pr-author-command-allowlist.ps1 ABSENT_AT_BASELINE
GROUP claude-pr-author.md DISTINCT=1
GROUP claude-SKILL.md DISTINCT=1
GROUP codex-enforce-promotion-mcp-only.ps1 DISTINCT=1
GROUP codex-enforce-epic-worktree-removal-gate.ps1 DISTINCT=1

## Hash detail

- hook-command-scanner.ps1 (4 copies): d8543cb9c460a3fff80377b63dbcffe97fc89b9da582addc48132960962add0b
- hook-command-invocation.ps1 (4 copies): b82246c61bb9fcb44ad6471dfa15278069c599ac3a52da26e62ede0cf1e92609
- .claude enforce-promotion-mcp-only.ps1 (2 copies): 924ad2efa174972acd7749066eb4fc07885e9ccdac4286a537419d8ec997406d
- .claude enforce-epic-worktree-removal-gate.ps1 (2 copies): 3042e2804480999462d308c25188064f673e519b81091f140e1ea18e99d4d060
- .claude enforce-parallel-worktree-removal-gate.ps1 (2 copies): 67cb665edf02839e58ef5a6fbc3f311e0c872b2b4efa56b0683047d8c8ea1f25
- .claude enforce-pr-author-skill-helpers.ps1 (2 copies): fae566112a3c4b394a9f11e4ef6f7db76ff1569b1ca1ce9eb90c2c5c64ab4e32
- .claude/agents/pr-author.md (2 copies): b5d05de8f95082fdbbd9da572ee349cfe87afc03a4e51f7280c0cf5a0976b5fd
- .claude/skills/pr-author/SKILL.md (2 copies): 74a06998669bca71d2e776ec93d1a8cfc5c02dc4526f69fd21c387237807da2b
- .codex enforce-promotion-mcp-only.ps1 (2 copies): b768e096d612f894363e09cb7c7d3be1578210dc5d0460135bfe12897e4ba6b8
- .codex enforce-epic-worktree-removal-gate.ps1 (2 copies): 91b1e722d76b120209dea80af7a9dac272f8b202f99389a7b20dc5cbe1a6c440
