# Agents repeatedly hit the cd-chained read-command deny (Issue #1165)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Agents_repeatedly_hit_the_cd-chained_read-command_deny/ (Issue #1165)

- Issue: #1165
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1165
- Last Updated: 2026-11-09
## Problem / Why

Over several days the owner has seen the same fleet notice: "3 agents hit the same failure: PreToolUse:Bash hook error: Forbidden Bash pattern: 'cd ... && <read command>' (or ';'-chained) ... One cause across agents usually belongs in the playbook, not in each agent." Observed command shapes include `cd <dir> && git status --short && git log --oneline -3 && cat ...` and `cd <dir> && env -u VIRTUAL_ENV poetry install --no-interaction ...`. The coordinator session hit the same deny on 2026-11-09.

Root cause (verified by reading the sources on 2026-11-09):

- `.claude/hooks/validate-bash.ps1` (`$script:CdChainedReadCommandPattern`, `Get-BashBlockReason`) correctly denies a `cd` followed in the same command by `grep|cat|head|tail|less|more|awk|sed -n`, because Claude Code's permission engine cannot resolve the read against Read() rules after a `cd`.
- The playbook (`.claude/skills/execution-environment/SKILL.md`, `## Command-Text Restrictions`) lists the restriction but gives no replacement forms. Agents that are not briefed with that skill (plugin agents, general-purpose agents, ad hoc workers) never see it at all.
- The deny message suggests only "use an absolute path for the read". The common real intent is "run a tool in another directory" (a sibling worktree outside the session's working directories, where the Bash cwd resets every call), for which the correct forms are `git -C <abs>`, `poetry -C <abs>` / `poetry --directory <abs>`, `npm --prefix <abs>`, absolute-path reads, or a `sh <SCRATCH>/<file>.sh` script. None of these is named.
- The agent-isolated worktree guard forbids `git -C <other worktree>` and `cd <path> && git`; the correct form differs by context (isolated worktree: cwd already correct, no cd; non-isolated agent working in a sibling worktree: `-C`/absolute paths). The playbook does not state that split as an instruction.

## Proposed Behavior

- One always-loaded, pushed-down rule (a `.claude/rules/*.md` file without a `paths:` scope, or the equivalent always-loaded surface) states the Bash command-shape rule and the replacement forms by context, so every agent in a consuming repository sees it before its first Bash call, regardless of which skill briefed it.
- The `execution-environment` playbook's `## Command-Text Restrictions` gains a "preferred forms" table (intent -> form, split by isolated worktree vs sibling worktree), and the briefs that restate command text point to it.
- The `validate-bash.ps1` deny message (Claude and Codex copies) names the replacement forms for the detected intent: a read op -> absolute path or Read tool; with `git`/`poetry`/`npm`/`npx` present in the chain -> the corresponding `-C` / `--directory` / `--prefix` form; multi-step -> a `sh` script under SCRATCH. The decision, the pattern and the leading `Forbidden Bash pattern:` token are unchanged.
- Measure recurrence: if the hooks already log denials, report the count before and after; otherwise record that no count is available.

## Acceptance Criteria (early draft)

- [ ] An always-loaded rule carrying the command-shape rule and replacement forms exists on the Claude surface (and the Copilot/Codex equivalents where a parallel surface exists) and is in the push-down payload.
- [ ] execution-environment `## Command-Text Restrictions` carries the intent -> form table split by isolated worktree vs sibling worktree, consistent with the isolation-guard facts already listed there.
- [ ] The validate-bash deny message names the replacement form for the detected intent; Pester tests cover read-only, git, poetry and multi-step chains; the allow/deny decision set is unchanged (regression tests over the existing corpus).
- [ ] Claude and Codex hook copies and the extension resource mirrors stay byte-consistent where parity tests require it.

## Constraints & Risks

- Pushed-down code is PowerShell or bash; no new Python. Test runs are parallel-only; evidence is append-only.
- Do not weaken the deny: the permission-engine limitation is real; only the guidance changes.
- `.claude/skills/execution-environment/SKILL.md` is also edited by #1158 (test-execution policy), a separable docs-section overlap.

## Source

Owner request of 2026-11-09 ("I keep seeing this same message over several days. Please address it.").
