# Receipt-Procedure Surfaces Disposition (DC-22) ([P9-T1])

Timestamp: 2026-10-08T22-46

Command: git ls-files ".codex/agents/pr-author*.toml"
EXIT_CODE: 0

Command: git grep -n -e "Documentation-Only" -- .github/agents/pr-author.agent.md
EXIT_CODE: 0

Output Summary:
`git ls-files` listed six tracked files:
- .codex/agents/pr-author-c1.toml
- .codex/agents/pr-author-c2.toml
- .codex/agents/pr-author-c3-elevated.toml
- .codex/agents/pr-author-c3.toml
- .codex/agents/pr-author-c4.toml
- .codex/agents/pr-author.toml

`git grep` printed one line:
- `.github/agents/pr-author.agent.md:140:## PR Body and Receipt Protocol (Documentation-Only in This Ecosystem)`

Execution note: both commands were issued as `git -C <WORKSPACE_ROOT> ...` because the Bash tool's working directory is reset between calls; the arguments are otherwise identical.

## DC-22 disposition

- `.github/agents/pr-author.agent.md:140-162` names the PR body and receipt protocol generically under the heading at line 140, which marks it as documentation-only in the Copilot ecosystem. The Copilot ecosystem has no PreToolUse hook surface, so no per-segment allowlist hook can be registered there. The file is not changed.
- `.codex/agents/pr-author*.toml` (six files above) contain no receipt-procedure text: the companion artifact `receipt-procedure-codex-grep.2026-10-08T22-46.md` records exit 1 for a case-insensitive search for `sha256` and `receipt`. The files are not changed.
- Codex has no pr-author hook. The per-segment allowlist hook `.claude/hooks/enforce-pr-author-command-allowlist.ps1` and the single-command receipt procedure apply only to the Claude surface (`.claude/agents/pr-author.md`, `.claude/skills/pr-author/SKILL.md`) and its bundled mirror.
