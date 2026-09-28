# [P12-T12] D3 fail-closed table — row-to-test mapping

Timestamp: 2026-09-07T16-08

Command:

```
mcp__drm-copilot__run_poshqc_test
  workspace_root = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31
  scan_folders   = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]
```

EXIT_CODE: 2 (folder-wide; decomposed in `evidence/qa-gates/manual-replay.2026-09-07T16-05.md`, and
attributable entirely to two pre-existing failures outside this change's scope)

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context, so the suites could not be run through `Invoke-Pester -Path <suite>`. They were run through
`mcp__drm-copilot__run_poshqc_test` scoped by `scan_folders` to the two hook test folders, and every
per-case status below was read from `artifacts/pester/pester-junit.xml`.

Source: the D3 table at `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
lines 414 to 428, section `### D3 — The fail-closed argument (form by form)`.

## Output Summary

The D3 table has **15 rows**. Every row maps to at least one named Pester case on every side to which
it applies, and every mapped case reports **Passed**. The seven wrapper deny pins are listed
separately in section 2 with the case name and the observed decision for each; all fourteen (seven
per side) report Passed.

| Measure | Value |
| --- | --- |
| D3 rows | 15 |
| Rows with at least one named case per applicable side | **15 of 15** |
| Rows with no mapped case | **0** |
| Wrapper deny pins listed with an observed decision | **7 per side, 14 total** |
| Mapped cases reporting anything other than Passed | **0** |

Side applicability. The preimplementation gate, the promotion hook, `validate-bash.ps1`, the epic
merge gate, and the epic worktree-removal gate exist on both the Claude and the Codex side, so their
rows are mapped on both. The pr-author family, the parallel worktree-removal gate, and the parallel
abandon gate are Claude-only, so their rows are mapped on the Claude side only and the Codex column
records `n/a — Claude-only hook` rather than a gap.

## 1. Row-by-row mapping

### Row 1 — `echo x | xargs git add` (deny today, deny under this specification, neutral)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `wrapper deny pin 1: denies a staging command relocated through xargs` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `wrapper deny pin 1: denies a staging command relocated through xargs` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `wrapper deny pin 1: classifies a gh pr create relocated through xargs` | Passed |

### Row 2 — `bash -c 'git add .'` / `sh -c "git add ."` (deny, deny, neutral)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `wrapper deny pin 2: denies a staging command nested inside a bash -c argument` | Passed |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `wrapper deny pin 3: denies a staging command nested inside an sh -c argument` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `wrapper deny pin 2: denies a staging command nested inside a bash -c argument` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `wrapper deny pin 3: denies a staging command nested inside an sh -c argument` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `wrapper deny pin 2: classifies a gh pr create nested inside a bash -c argument` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `wrapper deny pin 3: classifies a gh pr create nested inside an sh -c argument` | Passed |

### Row 3 — `env git add .` / `command git add .` / `nohup git add .` (deny, deny, neutral)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `wrapper deny pin 4: denies a staging command behind the env transparent wrapper` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `wrapper deny pin 4: denies a staging command behind the env transparent wrapper` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `wrapper deny pin 4: classifies a gh pr create behind the env transparent wrapper` | Passed |
| Claude (parser) | `hook-command-invocation.Tests.ps1` | `structural git classification.skips VAR=value prefixes and transparent wrappers before the command word` | Passed |
| Codex (parser) | `hook-command-invocation.Tests.ps1`, Codex copy | `structural git classification.skips VAR=value prefixes and transparent wrappers before the command word` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `wrapper carve-out set.exposes exactly the fourteen members named by D2 Piece 2` | Passed |
| Codex (parser) | `hook-command-scanner.Tests.ps1`, Codex copy | `wrapper carve-out set.exposes exactly the fourteen members named by D2 Piece 2` | Passed |

`command` and `nohup` are pinned as members of the wrapper carve-out set by the membership case,
which asserts the set's exact fourteen members against the named script-scope constant, and by
`constant tables.exposes exactly the five transparent wrappers of D2 Piece 3 step 2` in the
invocation suite on both sides.

### Row 4 — `pwsh -NoProfile -Command "Invoke-Pester …"` (deny, deny, neutral)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper` | Passed |
| Both (acceptance) | `hook-command-parser.AcceptanceCases.Tests.ps1` | `AT-6 still classifies a pwsh -Command wrapper carrying a test invocation` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `wrapper deny pin 5: classifies a gh pr create behind the pwsh -Command wrapper` | Passed |

### Row 5 — `bash <<EOF … git add … EOF` (deny, deny, neutral; deliberate direction reversal against masking)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `wrapper deny pin 6: denies a heredoc body piped into bash` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `wrapper deny pin 6: denies a heredoc body piped into bash` | Passed |
| Claude (exemption) | `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | `denies the same heredoc body when it feeds a shell wrapper instead of a file` | Passed |
| Codex (exemption) | `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | `denies the same heredoc body when it feeds a shell wrapper instead of a file` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `wrapper deny pin 6: classifies a heredoc body piped into bash` | Passed |

The last two rows are the sibling `It` blocks added by [P1-T8] and [P1-T10] alongside the single
intended assertion reversal, and they are the cases that keep the reversal from being a fail-open
change: the same heredoc body allows when it feeds a file and denies when it feeds a wrapper.

### Row 6 — `echo "$(git add .)"`, live substitution inside quotes (deny, deny, neutral)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `wrapper deny pin 7: denies a live substitution inside a double-quoted span` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `wrapper deny pin 7: denies a live substitution inside a double-quoted span` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `segment flags.sets HasLiveSubstitution for a dollar-paren inside a double-quoted span` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `ScanText clause order.clause 1 selects RawText for an unbalanced or live-substitution segment` | Passed |
| Codex (parser) | `hook-command-scanner.Tests.ps1`, Codex copy | `segment flags.sets HasLiveSubstitution for a dollar-paren inside a double-quoted span` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `wrapper deny pin 7: classifies a live substitution inside a double-quoted span` | Passed |

### Row 7 — `git -C ../x add .`, the bare relocating spelling (allow-by-non-match today, **deny**, fail-closed)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `denies a relocating git add carrying a directory global option` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `denies a relocating git add carrying a directory global option` | Passed |
| Claude (parser) | `hook-command-invocation.Tests.ps1` | `structural git classification.classifies a relocating git add carrying a directory global option` | Passed |
| Codex (parser) | `hook-command-invocation.Tests.ps1`, Codex copy | `structural git classification.classifies a relocating git add carrying a directory global option` | Passed |
| Claude (validate-bash) | `validate-bash.TriggerScoping.Tests.ps1` | `AT-9 denies a relocating git push --force carrying a directory global option` | Passed |
| Codex (validate-bash) | `validate-bash-trigger-scoping.Tests.ps1` | `AT-9 denies a relocating git push --force carrying a directory global option` | Passed |
| Claude (worktree removal) | `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | `denies git -C /repo/main worktree remove against a checkpoint with no authorizing record` | Passed |
| Codex (worktree removal) | `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` | `denies git -C /repo/main worktree remove against a checkpoint with no authorizing record` | Passed |
| Claude (parallel removal) | `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | `brings git -C /repo/main worktree remove into scope` | Passed |

### Row 8 — `git --git-dir=<x> commit` / `git --work-tree=<x> add` (allow-by-non-match, deny, fail-closed)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `denies a relocating git commit carrying a git-dir global option` | Passed |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `denies a relocating git add carrying a work-tree global option` | Passed |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `denies an unmodeled dash-leading token between git and its subcommand` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `denies a relocating git commit carrying a git-dir global option` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `denies a relocating git add carrying a work-tree global option` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `denies an unmodeled dash-leading token between git and its subcommand` | Passed |
| Claude (parser) | `hook-command-invocation.Tests.ps1` | `structural git classification.classifies a relocating git commit carrying a git-dir global option` | Passed |
| Claude (parser) | `hook-command-invocation.Tests.ps1` | `structural git classification.classifies a relocating git add carrying a work-tree global option` | Passed |
| Codex (parser) | `hook-command-invocation.Tests.ps1`, Codex copy | the two identically named cases above | Passed |

### Row 9 — `(git add .)`, `$(git add .)`, backtick spelling (allow-by-non-match, deny, fail-closed)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `denies the subshell spelling of a staging command` | Passed |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `denies the command-substitution spelling of a staging command` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `denies the subshell spelling of a staging command` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `denies the command-substitution spelling of a staging command` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `segment delimiters.treats the subshell opener and closer as delimiters` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `segment delimiters.treats the group opener and closer as delimiters` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `segment delimiters.treats the substitution opener as a delimiter` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `segment delimiters.treats the backtick as a delimiter` | Passed |
| Codex (parser) | `hook-command-scanner.Tests.ps1`, Codex copy | the four identically named delimiter cases above | Passed |

### Row 10 — `npx --yes prettier`, `npx -p <pkg> eslint` (allow-by-non-match, deny by modeled option absorption, fail-closed)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude (parser) | `hook-command-invocation.Tests.ps1` | `constant tables.exposes exactly the modeled npx global options` | Passed |
| Codex (parser) | `hook-command-invocation.Tests.ps1`, Codex copy | `constant tables.exposes exactly the modeled npx global options` | Passed |

This row is mapped to the constant-table case rather than to a decision case. The membership of the
`npx` global-option table is what makes the absorption happen, and the case asserts that membership
exactly against the named constant, so it fails if a modeled option is added or removed. The general
absorption mechanism the table feeds is itself pinned by the `git` and `gh` relocating cases in rows
7, 8, 11, and 12, which exercise the same `Get-CommandLineGlobalOption` path with a different command
word.

### Row 11 — `gh --repo <o/r> pr create` / `gh -R <o/r> pr edit` (allow-by-non-match, deny by structural gh classifier D6, fail-closed)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `classifies gh --repo drmoisan/drm-copilot pr create --body-file artifacts/pr_body_545.md` | Passed |
| Claude | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `classifies gh -R drmoisan/drm-copilot pr edit --body-file artifacts/pr_body_545.md` | Passed |
| Claude | `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | `classifies gh --repo drmoisan/drm-copilot pr create --base epic/x where it is skipped today` | Passed |
| Claude (parser) | `hook-command-invocation.Tests.ps1` | `structural gh classification.classifies gh pr create carrying a repo global option in the equals form` | Passed |
| Codex (parser) | `hook-command-invocation.Tests.ps1`, Codex copy | `structural gh classification.classifies gh pr create carrying a repo global option in the equals form` | Passed |
| Codex (hook) | n/a — the pr-author family is Claude-only | — | — |

### Row 12 — `gh --repo <o/r> issue create` / `gh -R <o/r> issue new` (allow-by-non-match, deny by structural gh classifier D10, fail-closed)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | `denies a relocating gh issue create carrying a repo global option` | Passed |
| Claude | `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | `denies a relocating gh issue new carrying the short repo global option` | Passed |
| Codex | `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` | `denies a relocating gh issue create carrying a repo global option` | Passed |
| Codex | `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` | `denies a relocating gh issue new carrying the short repo global option` | Passed |
| Both (acceptance) | `hook-command-parser.AcceptanceCases.Tests.ps1` | `AT-5 blocks a relocating gh issue create spelling that carries a repo global option` | Passed |
| Both (paired negative) | `hook-command-parser.AcceptanceCases.Tests.ps1` | `paired negative for AT-5: a relocating gh issue list spelling still returns $null` | Passed |
| Claude (parser) | `hook-command-invocation.Tests.ps1` | `structural gh classification.classifies gh issue create carrying a short repo global option` | Passed |
| Codex (parser) | `hook-command-invocation.Tests.ps1`, Codex copy | `structural gh classification.classifies gh issue create carrying a short repo global option` | Passed |

### Row 13 — quoted mentions, heredoc prose, JSON receipt values, the word `black` in prose, all in non-wrapper segments (deny today, **allow**, deliberate allowance)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `allows a quoted mention of the staging invocation inside an echo argument` | Passed |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `allows a heredoc body that quotes the staging invocation in prose` | Passed |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `allows a heredoc whose JSON body names a governed tool as a receipt value` | Passed |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `allows prose containing the English word black` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | the four identically named cases above | Passed |
| Claude (exemption) | `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | `denies a message-body payload that merely contains the staging literal` — the single intended assertion reversal, whose expected decision changed to allow | Passed |
| Codex (exemption) | `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | the identically named case, the Codex half of the same reversal | Passed |
| Claude (promotion) | `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | `allows a heredoc whose JSON body names promotion tools as receipt values` | Passed |
| Codex (promotion) | `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` | `allows a heredoc whose JSON body names promotion tools as receipt values` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `allows a quoted --body-file mention inside a JSON receipt value` | Passed |
| Claude (pr-author) | `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | `no longer reports EPIC_BASE_BRANCH_MISMATCH for a quoted mention of the gh pr create phrase` | Passed |
| Claude (validate-bash) | `validate-bash.TriggerScoping.Tests.ps1` | `AT-10 allows a commit message that quotes a dangerous pattern in prose` | Passed |
| Codex (validate-bash) | `validate-bash-trigger-scoping.Tests.ps1` | `AT-10 allows a commit message that quotes a dangerous pattern in prose` | Passed |
| Claude (merge gate) | `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `allows a printf whose double-quoted text mentions the gated merge phrase` | Passed |
| Codex (merge gate) | `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | `allows a quoted mention of the gated merge phrase` | Passed |
| Claude (worktree removal) | `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | `allows a command whose quoted text merely mentions the removal phrase` | Passed |
| Codex (worktree removal) | `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` | `allows a command whose quoted text merely mentions the removal phrase` | Passed |
| Claude (parallel removal) | `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | `takes a quoted mention of the removal phrase out of scope` | Passed |
| Claude (abandon gate) | `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `AT-11 takes a grep whose quoted search term is the disposition token out of scope` | Passed |

### Row 14 — `npm --version && echo lint` (deny today by `.*` bridging, **allow**, deliberate allowance)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | `allows a cross-segment line whose npm segment and lint mention are in different segments` | Passed |
| Codex | `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | `allows a cross-segment line whose npm segment and lint mention are in different segments` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `segment delimiters.splits on an ampersand` | Passed |
| Codex (parser) | `hook-command-scanner.Tests.ps1`, Codex copy | `segment delimiters.splits on an ampersand` | Passed |

### Row 15 — `git${IFS}add`, `\git add`, other obfuscated respellings (allow today, unchanged, neutral)

| Side | Suite | Named case | Status |
| --- | --- | --- | --- |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `CommandWord determination.returns the first token when there is no env-assignment prefix` | Passed |
| Claude (parser) | `hook-command-scanner.Tests.ps1` | `CommandWord determination.skips VAR=value env-assignment prefixes` | Passed |
| Codex (parser) | `hook-command-scanner.Tests.ps1`, Codex copy | the two identically named cases above | Passed |

Mapping note, stated so the reader is not left to infer it. No case in the delivered suite set
supplies the literal text `git${IFS}add` or `\git add`. This row's post-change direction is
`unchanged — already ungated; this model widens nothing here`, so a decision case asserting an allow
would assert behaviour the change does not touch. The two cases mapped above pin the mechanism that
produces the row's stated outcome: `CommandWord` is the segment's first token verbatim, after
env-assignment prefixes are skipped and nothing else. `\git` and `git${IFS}add` are not the token
`git`, so the structural classifier does not classify them, and the regex triggers do not match them
for the same reason they did not before this change. This is a derivation from a named passing case
rather than a purpose-built case, and it is recorded as such.

## 2. The seven wrapper deny pins, with observed decisions

Listed separately as the task requires. Each pin appears once per side in the preimplementation-gate
trigger-scoping suites, and once more in the pr-author trigger-scoping suite on the Claude side.

### Preimplementation gate — Claude (`enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`)

| Pin | Wrapper form | Named case | Observed decision | Status |
| --- | --- | --- | --- | --- |
| 1 | `xargs` | `wrapper deny pin 1: denies a staging command relocated through xargs` | **deny** | Passed |
| 2 | `bash -c` | `wrapper deny pin 2: denies a staging command nested inside a bash -c argument` | **deny** | Passed |
| 3 | `sh -c` | `wrapper deny pin 3: denies a staging command nested inside an sh -c argument` | **deny** | Passed |
| 4 | `env` | `wrapper deny pin 4: denies a staging command behind the env transparent wrapper` | **deny** | Passed |
| 5 | `pwsh -Command` | `wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper` | **deny** | Passed |
| 6 | heredoc into `bash` | `wrapper deny pin 6: denies a heredoc body piped into bash` | **deny** | Passed |
| 7 | live substitution inside double quotes | `wrapper deny pin 7: denies a live substitution inside a double-quoted span` | **deny** | Passed |

### Preimplementation gate — Codex (`enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`)

| Pin | Wrapper form | Named case | Observed decision | Status |
| --- | --- | --- | --- | --- |
| 1 | `xargs` | `wrapper deny pin 1: denies a staging command relocated through xargs` | **deny** | Passed |
| 2 | `bash -c` | `wrapper deny pin 2: denies a staging command nested inside a bash -c argument` | **deny** | Passed |
| 3 | `sh -c` | `wrapper deny pin 3: denies a staging command nested inside an sh -c argument` | **deny** | Passed |
| 4 | `env` | `wrapper deny pin 4: denies a staging command behind the env transparent wrapper` | **deny** | Passed |
| 5 | `pwsh -Command` | `wrapper deny pin 5: denies a test invocation behind the pwsh -Command wrapper` | **deny** | Passed |
| 6 | heredoc into `bash` | `wrapper deny pin 6: denies a heredoc body piped into bash` | **deny** | Passed |
| 7 | live substitution inside double quotes | `wrapper deny pin 7: denies a live substitution inside a double-quoted span` | **deny** | Passed |

### pr-author hook — Claude (`enforce-pr-author-skill.TriggerScoping.Tests.ps1`)

The pr-author hook's pins assert that the wrapped invocation **classifies** — that is, reaches the
hook's decision logic rather than passing by non-match — which is the deny-side outcome for that hook.

| Pin | Wrapper form | Named case | Observed decision | Status |
| --- | --- | --- | --- | --- |
| 1 | `xargs` | `wrapper deny pin 1: classifies a gh pr create relocated through xargs` | **classifies** | Passed |
| 2 | `bash -c` | `wrapper deny pin 2: classifies a gh pr create nested inside a bash -c argument` | **classifies** | Passed |
| 3 | `sh -c` | `wrapper deny pin 3: classifies a gh pr create nested inside an sh -c argument` | **classifies** | Passed |
| 4 | `env` | `wrapper deny pin 4: classifies a gh pr create behind the env transparent wrapper` | **classifies** | Passed |
| 5 | `pwsh -Command` | `wrapper deny pin 5: classifies a gh pr create behind the pwsh -Command wrapper` | **classifies** | Passed |
| 6 | heredoc into `bash` | `wrapper deny pin 6: classifies a heredoc body piped into bash` | **classifies** | Passed |
| 7 | live substitution inside double quotes | `wrapper deny pin 7: classifies a live substitution inside a double-quoted span` | **classifies** | Passed |

## 3. Suite totals for every suite this mapping draws on

| Suite | Tests | Failures | Errors |
| --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | 19 | 0 | 0 |
| `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` (Codex) | 23 | 0 | 0 |
| `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 59 | 0 | 0 |
| `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (Codex) | 59 | 0 | 0 |
| `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` | 8 | 0 | 0 |
| `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` (Codex) | 8 | 0 | 0 |
| `enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 18 | 0 | 0 |
| `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | 2 | 0 | 0 |
| `validate-bash.TriggerScoping.Tests.ps1` | 7 | 0 | 0 |
| `validate-bash-trigger-scoping.Tests.ps1` (Codex) | 3 | 0 | 0 |
| `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 9 | 0 | 0 |
| `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` (Codex) | 5 | 0 | 0 |
| `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` | 5 | 0 | 0 |
| `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` (Codex) | 5 | 0 | 0 |
| `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` | 3 | 0 | 0 |
| `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 3 | 0 | 0 |
| `hook-command-parser.AcceptanceCases.Tests.ps1` | 11 | 0 | 0 |
| `hook-command-scanner.Tests.ps1` (Claude) | 42 | 0 | 0 |
| `hook-command-scanner.Tests.ps1` (Codex) | 41 | 0 | 0 |
| `hook-command-invocation.Tests.ps1` (Claude) | 44 | 0 | 0 |
| `hook-command-invocation.Tests.ps1` (Codex) | 39 | 0 | 0 |

Every suite this mapping draws on reports zero failures and zero errors.
