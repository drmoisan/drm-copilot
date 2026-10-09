# Issue #742 disposition comment (posted on PR #855)

Timestamp: 2026-10-08T22-50
PostedAs: comment
PostedAt: 2026-10-09T01-45
CommentURL: https://github.com/drmoisan/drm-copilot/pull/855#issuecomment-6072402795
PostedBy: `gh pr comment 855 --repo drmoisan/drm-copilot --body-file <comment text below>` (exit 0)
PostingCheck: `gh pr list --repo drmoisan/drm-copilot --head bug/promotion-hook-raw-containment-false-positive-deny-exec-824 --state open --json number` exited 0 and printed `[]` at 2026-10-08T22-51 ([P9-T4]).
Target: pull request for branch bug/promotion-hook-raw-containment-false-positive-deny-exec-824 (bundles #742)

## Comment text

Disposition of the remaining #742 items, delivered with #824 (branch `bug/promotion-hook-raw-containment-false-positive-deny-exec-824`).

Item 1 (`git --version` denied by the worktree-removal gates and classified as an implementation command) is fixed in code by this change: git terminal options (`--version`, `-v`, `--help`, `-h`, `--html-path`, `--man-path`, `--info-path`, `--exec-path`) now end matching with no match, and the named regression rows REG-03, REG-05, REG-07, and REG-08 pass.

Item 2 (worktree isolation guard refuses Bash command text containing `bash`, `pwsh`, `wsl`, or a heredoc): this is a Claude Code runtime control, not a repository hook. No repository code change is made. Workarounds that operate within the guard: run a script file with `sh file.sh`; use `npx --yes ...` for Node tooling; use the MCP PoshQC tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) for the PowerShell toolchain.

Item 3 (evidence-filename Write guard refusing names containing "report"): this guard is runtime-owned. No repository code change is made. The repository hook `.claude/hooks/enforce-evidence-locations.ps1` matches forbidden directory prefixes only (`.claude/hooks/enforce-evidence-locations.ps1:65-80`: `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, and related prefixes, matched at the start of the path or after a directory separator); it does not inspect file names.

Item 4 (`cd ... && <read>` refusal): `.claude/hooks/validate-bash.ps1` defines `CdChainedReadCommandPattern` at `:222`, `Get-CdChainedReadCommandMatch` at `:230-323`, and the deny text at `:340-343`. The rule is intentional: the Claude Code permission engine cannot resolve a read command against `Read()` rules once a preceding `cd` has changed the working directory in the same command line. The rule is unchanged by this work, and its suites (`tests/scripts/claude-hooks/validate-bash.Tests.ps1`, `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`, `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`, `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1`) are unmodified.
