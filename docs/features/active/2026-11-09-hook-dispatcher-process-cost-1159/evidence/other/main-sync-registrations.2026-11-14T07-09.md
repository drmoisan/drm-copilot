# Registrations on the merged tree — main-sync cycle 1 ([P0-T3])

Timestamp: 2026-11-14T07-09
Command: sh SCRATCH/issue-1159-c1-reg.sh -- runs SCRATCH/issue-1159-genreg.ps1 (the recreated [P3-T1] helper) with -Ref set to the previous merge base 063504dc4b2ea08a2c5bd39b57d70ce5963815ed and then to the new merge base 2c8dee6dd3a82f210561d9efe623767ae902de51, compares each output with cmp against .claude/hooks/pretooluse-dispatch.json and .codex/hooks/pretooluse-dispatch.json, and counts the PreToolUse entries outside the dispatcher in .claude/settings.json (hooks.PreToolUse) and the [[hooks.PreToolUse]] tables outside the dispatcher in .codex/config.toml
EXIT_CODE: 0
Output Summary: Previous merge base: helper output equals both committed registries byte for byte (claude 6 groups and 32 hooks; codex 4 groups and 46 hooks), so the helper matches [P3-T1]. New merge base: claude registry equal, codex registry equal (same group and hook counts; isolation and notes kept). Registrations outside the dispatcher: Claude 0 (one hooks.PreToolUse entry, the dispatcher). Codex 0 (one [[hooks.PreToolUse]] table, whose command and command_windows name invoke-pretooluse-dispatch.ps1, timeout 690). Agent-frontmatter hooks are excluded per D11.

| Check | Claude | Codex |
|---|---|---|
| Helper output at previous merge base vs committed registry | equal | equal |
| Helper output at new merge base vs committed registry | equal | equal |
| PreToolUse registrations outside the dispatcher | 0 | 0 |
