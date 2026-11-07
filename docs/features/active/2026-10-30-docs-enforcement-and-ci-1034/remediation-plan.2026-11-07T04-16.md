# 2026-10-30-docs-enforcement-and-ci - Remediation Plan (proportionate cycle 3)

- **Issue:** #1034
- **Branch:** `feature/docs-enforcement-and-ci-1034-r2`
- **Status:** Authored for the third and last attempt the remediation guard allows.
- **Inputs:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-inputs.2026-11-07T04-16.md`, and `### F4 results` and `### F5 results` of `code-review.2026-11-07T04-16.md` in the same folder.
- **Scope:** the integration merge (N12), F4, F5, N14, and a real-bash comparison wider than the listed rows. N1 to N5 stay deferred by the relayed owner directive; N13 is accepted design and needs no change.

## Execution Rules

- Commit and push after every task, including the `[expect-fail]` tasks. Each commit stages only that task's files. The merge is a merge commit: no rebase and no forced push.
- `.claude/skills/execution-environment/SKILL.md` owns tool routes, launchers, command-text restrictions, the batch budget and CI shape; this plan does not restate them. Under its `## Hook Execution Context`, a branch hook is not exercised by an isolated subagent, so hook behavior is proven only by Pester rows and by the real-process and real-bash runs of P3-T6 and P3-T7.
- Language: PowerShell and Markdown. No Python file is added or edited on this branch; the Python files that arrive through the merge are upstream.
- These stay unchanged in both hook trees: `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-payload.ps1`, `enforce-epic-merge-gate-command.ps1`.
- `HOOK` and `HOOK_BUNDLE`, and `HELPER` and `HELPER_BUNDLE`, stay byte-identical: every task that edits one copies it in the same task.
- Every `FEATURE/spec.md` edit above `## Acceptance Criteria` keeps the physical line count, so the criterion positions cited by the review artifacts stay valid. Criterion text and checkboxes are not edited; the next review owns the checkboxes.
- Parallel-only directive: the final Pester gate is one `Invoke-PoshQCParallelTest` run, read through the `ExitCode` property of its returned object, and the final pytest gate is one `pytest -n auto` run. Each is re-run only after a fix. No fresh single-process run and no shuffled run is planned. P1-T2, P2-T2, P3-T2 and P3-T3 run only the named suites, as cycle 2 did for its fail-first and gate rows; they are not gates of the whole tree.

## Definitions

- `FEATURE` is `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`.
- `SCRATCH` is `<session scratchpad>/issue-1034/`; scratch file names start with `issue-1034-`, and evidence records the token `SCRATCH`, never a host path.
- `EPIC_REF` is `origin/epic/documentation-estate-tooling-integration`, fetched in P0-T2.
- `MERGE_BASE` is the live output of `git merge-base EPIC_REF HEAD`, re-derived before each comparison. After P1-T1 it is the merged epic tip, so upstream files are outside every branch diff.
- `MERGE_COMMIT` is the commit P1-T1 creates, the output of `git log --merges --first-parent -1 --format=%H HEAD`, recorded in `FEATURE/evidence/other/integration-merge.<timestamp>.md`.
- `HOOK` is `.claude/hooks/enforce-docs-complete-gate.ps1`, and `HOOK_BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
- `HELPER` is `.claude/hooks/enforce-docs-complete-gate-target.ps1`, and `HELPER_BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate-target.ps1`.
- `CLI` is `.claude/lib/docs/Invoke-DocsCommand.ps1`, and `CLI_BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1`.
- `HOOK_SUITE` is `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`, `COMPOUND_SUITE` is `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1`, and `HELPER_SUITE` is `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1`.
- `REVISION_SUITE` is `tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1`, and `CLI_SUITE` is `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`.
- `<NL>` is a line feed and `<CRLF>` a carriage return and line feed; `\<NL>` is a backslash followed by a line feed. Rows carry these characters through PowerShell double-quoted escapes, so no fixture depends on file line endings.
- Each step script that gates a value ends with an exit status that fails when any stated value fails, so the recorded `EXIT_CODE:` carries the acceptance.

## Integration Merge: Effect on This Item

The brief states that the upstream change altered the `InvokeProcess` member. The planner has no git and could not read the epic tip: no checkout on this host is at that commit, and the planned 1031 edit it could read names only the `inventory` row. P1-T1 therefore reads the upstream side and applies the rule below, which needs no further decision.

The two helpers depend on the member through a narrow contract. `Resolve-DocsContextRevision` and `Read-DocsContextRevisionText` take it as `[scriptblock] $InvokeProcess`, call it with four positional values (`'git'`, the argument array, empty standard input, `30`), pass the root as `-C <Root>` inside the argument array, and read `TimedOut`, `ExitCode` and `Stdout` from the result. The `ResolveRevision` and `ReadRevisionText` closures default that parameter to the local `$invokeProcess`, so it must be assigned above them. Neither helper depends on the process working directory.

| Case | Upstream member after the merge | Effect on the two helpers | Effect on `REVISION_SUITE` |
|---|---|---|---|
| A | Keeps the four leading positional parameters and the result keys, including a change that adds an optional parameter or binds a working directory | None: the positional call and `-C <Root>` still hold | None: every row unchanged |
| B | Becomes a closure or otherwise resolves differently, with the same positions and keys | None to their bodies; `$invokeProcess` stays assigned above the two closures, and the comment above them is corrected | Rows that inject a stand-in unchanged. 'routes the default wiring of <Member> through Invoke-DocsProcess once with git and a 30-second wait' stays as written: if `Invoke-DocsProcess` is no longer reached, the two closures adopt the seam upstream gave its member, and the assertion is not weakened |
| C | Renames or reorders a parameter, or changes a result key | The call and the read of the result are updated to the new contract | `Get-TestRecordingProcess` and each row reading a recorded field are updated, for the same reason; no assertion is removed |

`CLI_SUITE` row 'exposes the same member names as the in-memory context, the four InvokeProcess parameters and the Operation seam' compares the real and in-memory member lists in order and pins the parameter names. Its disposition is unchanged when upstream updated it; it passes only when the merged order of the `New-DocsCommandContext` members equals the order in `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`. The row 'forwards the four arguments unchanged to Invoke-DocsProcess and returns its result' is upstream's to keep.

## Design: Reader, View and Candidate Test

All edits are in `HELPER`. The shared normalizer stays unchanged.

`Read-DocsCompleteGatePlainCommand`, working on the raw `CommandText` before normalization for these two tests:

- F4: when the reader reaches a comment and the raw text holds a backslash-newline, it returns not plain. The test is `\\\r?\n` over the raw text.
- Word-split form, found by the planner review: the normalizer turns a backslash-newline inside a word into a space, but bash joins the two halves, so `gh pr mer\<NL>ge 12` reads as `gh pr mer ge 12` and allows while bash merges. The reader returns not plain when the raw text holds a backslash-newline with a non-blank character on both sides (`\S\\\r?\n\S`). `gh pr merge \<NL>12` and `gh pr \<NL>merge 12` have a blank before the backslash and stay plain.
- N14: the after-word check is removed in P3-T3, subject to that task's condition.
- Consequence recorded in the limits: `gh pr merge \<NL>12 # note` is not plain and denies. A word split inside a quoted value also denies.

`Get-DocsCompleteGateUnquotedView` removes every backslash from the joined `MaskedText`, so `g\h` reads as `gh`.

`Test-DocsCompleteGateMergeText -Text -MutationText` (new, sixth helper function) returns true when `Text` holds the whole words `gh`, `pr`, `merge` in order, or the whole words `gh`, `api` in order while `Test-EpicMergeGateApiMutationText` is true for `MutationText`.

`Test-DocsCompleteGateMergeCandidate` keeps steps 1 and 2. Step 3 runs for two forms of the command: the raw text, and the raw text with each backslash-newline deleted, because a comment ending in a backslash needs the first form and a split word needs the second. For each form:

1. `view` is `Get-DocsCompleteGateUnquotedView` of the form, and `spelled` is `ConvertTo-CommandLineNormalizedText` of the form with every single quote, double quote and backslash removed.
2. The command is a candidate when `Test-DocsCompleteGateMergeText -Text view -MutationText spelled` is true.
3. The command is a candidate when `view` holds an evaluator word and `Test-DocsCompleteGateMergeText -Text spelled -MutationText spelled` is true. `spelled` includes heredoc bodies, so a heredoc to `bash` is read.

Evaluator words, whole-word and case-insensitive: `sh`, `bash`, `zsh`, `dash`, `ksh`, `pwsh`, `powershell`, `eval`, `source`. The first, second, third, fourth, eighth and ninth are the list of the inputs; `ksh`, `pwsh` and `powershell` are added because the shared wrapper tables hold them, so the same payload already denies at top level. `HELPER` keeps no file-level statement, so the list lives in the function, and no function invokes a variable with `&`.

The non-plain path needs no change: `Get-DocsCompleteGateMergeTarget` denies `PR_UNRESOLVED` for every candidate that is not plain, which covers the `gh pr view` and `--disable-auto` rows of F4.

## Design: Limit Statement

The `Residual limits` paragraph of the `HOOK` header and the residual-limits bullet of `### Hook` in `FEATURE/spec.md` carry the same content, in this order:

1. Nature. This hook reads command text and is not a shell parser. It is a policy-level control, not a security boundary and not a cryptographic one.
2. What it establishes, and nothing beyond this. It looks up the selector of a command it reads as one plain `gh pr merge`, and with the gate enabled it denies `PR_UNRESOLVED` for these groups whichever pull request they name: the words `gh pr merge` or a `gh api` merge endpoint or mutation in the unquoted text, including a compound command, a wrapper payload the shared predicate reads, a word split by a backslash or a backslash-newline, and a comment joined to a later command by a backslash-newline; and quoted or heredoc text holding those words beside an unquoted evaluator word (the nine words named).
3. Outside what it can observe. Any other way of causing a merge is not visible to it, and such a command allows. Known forms: other interpreters such as `python -c` and `node -e`; `curl` to the API; scripts on disk; computed command words (`$a$b pr merge 12`, `$(echo 'gh pr merge 12')`); a quoted command word outside the leading position; evaluators outside the named words (`trap`, `fish`, `.`); a `gh` alias; a mutation supplied from a file; a merge endpoint whose number is a variable; a direct `git push` to `main`; and forms not modelled. This list is not complete: the class is every form the text tests do not recognize, and a form missing from this list is not thereby denied.
4. Ambient state. The profile and receipt are read from the local working tree. An ambient `GH_REPO` or `GH_HOST`, and any directory or environment change made by an earlier Bash call, are not visible (`cd`, `builtin cd`, `env --chdir`, `GIT_DIR=`, `read GH_REPO`, bare `export GH_REPO`); the same forms inside the merge command are not plain and deny. A push after the lookup is not observed unless `--match-head-commit` is passed.
5. Accepted false denies, which do not occur with the gate disabled or the profile absent: an unquoted mention (`echo gh pr merge 12`, `gh pr view 12 && git merge main`); a quoted mention beside an evaluator word, including a path ending in `.sh`; a compound or `gh api` merge of a non-integration pull request; a comment or a split word together with a backslash-newline in an otherwise plain merge; a `GET` on the merge endpoint; any `=value` spelling of `--disable-auto`.

Sentences to correct, found by searching `HOOK`, `HELPER` and `FEATURE/spec.md` for `any form`, `every`, `never`, `only`, `proven`, `cannot` and `always` in text about merge detection:

- `HOOK` `.SYNOPSIS`: the gate applies to a `gh` merge it reads, not to every merge.
- `HOOK` `.DESCRIPTION` opening: every command in a readable envelope is allowed with the gate off, because an envelope anomaly and a failed import still deny.
- `HOOK` `Residual limits`: replaced whole, which removes "a merge in any form other than one plain gh pr merge denies".
- `HELPER` header: "a form the grammar does not model can never lose its selector" is removed. The replacement says a candidate reaches the lookup only when the reader accepts the whole command as one plain `gh pr merge`, every other candidate denies, and a command the candidate test does not recognize is not gated, as the hook header states.
- `HELPER` `Test-DocsCompleteGateMergeCandidate` `.SYNOPSIS`: "may merge a pull request" becomes a statement about command text.
- `FEATURE/spec.md` `### Solution summary` item 3, `## Behavior` second gate bullet (the sentences starting "the hook allows every Bash call" and "it allows only when"), and the residual-limits bullet of `### Hook`.
- Reviewed and kept: `HOOK` header steps 2 and 4 ("every other candidate" is limited to candidates), "The head revision is always the pull request headRefOid", and the `FEATURE/spec.md` `## Upstream Contract Notes` phrase "the hook allows the gated merge only when", which names merges the hook gates. Test text with the same claim: the `COMPOUND_SUITE` header sentence "every merge that is not one plain gh pr merge denies" is corrected, and the `HELPER_SUITE` header's count of five functions becomes six.

## Row Groups

Enabled rows assert deny `PR_UNRESOLVED` with zero `gh` calls; disabled and absent rows assert allow with zero `gh` calls. Rows join the existing `$script:CompoundCommands` table in Context `compound merge scope (F3)` of `COMPOUND_SUITE`, so each command runs in all three states. Enabled rows of Groups F4, W and F5 must fail at the merged head, under the rule P2-T2 states for rows the review did not observe. Their disabled and absent rows pass at head and after, because the gate allows those commands in both states; they cannot fail first. In F4 forms the head looks up a selector, and the mocked lookup exits 1, so the zero-call assertion is what fails.

Group F4:

- `gh pr merge 34 # x\<NL>gh pr merge 12`
- `gh pr merge 34 # first line \<NL>gh pr merge 12 # second`
- `gh pr merge 34 \<NL># x\<NL>gh pr merge 12`
- `gh pr view 34 # x\<NL>gh pr merge 12`
- `gh pr merge --disable-auto # x\<NL>gh pr merge 12`
- `gh pr view 34 --json title # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge`
- `gh pr merge 34 # x\<CRLF>gh pr merge 12`
- `gh pr merge \<NL>12 # note`

Group W, the word-split form:

- `gh pr mer\<NL>ge 12`
- `g\<NL>h pr merge 12`
- `gh p\<NL>r merge 12`
- `gh pr mer\<CRLF>ge 12`
- `true; gh pr mer\<NL>ge 12`

Group F5:

- `if true; then sh -c 'gh pr merge 12'; fi`
- `if true; then bash -c "gh pr merge 12"; fi`
- `! sh -c 'gh pr merge 12'`
- `exec sh -c 'gh pr merge 12'`
- `for n in 12; do sh -c "gh pr merge $n"; done`
- `if true; then eval 'gh pr merge 12'; fi`
- `! eval 'gh pr merge 12'`
- `nice sh -c 'gh pr merge 12'`
- `find . -maxdepth 0 -exec sh -c 'gh pr merge 12' \;`
- `sudo sh -c 'gh pr merge 12'`
- `if true; then bash <<EOF<NL>gh pr merge 12<NL>EOF<NL>fi`
- `echo 'gh pr merge 12' | sh`
- `printf 'gh pr merge 12' | bash`
- `g\h pr merge 12`
- `gh pr mer\ge 12`
- `gh p\r merge 12`
- `true; g\h pr merge 12`
- `g\h api -X PUT repos/o/r/pulls/12/merge`
- `if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi`
- `echo 'gh api -X PUT repos/o/r/pulls/12/merge' | bash`
- `if true; then ksh -c 'gh pr merge 12'; fi`
- `if true; then pwsh -Command 'gh pr merge 12'; fi`
- `source <(echo 'gh pr merge 12')`
- `echo bash 'gh pr merge 12'`
- `./run.sh 'gh pr merge 12'`

Group D, one new row of the same table, which pins a limit-statement claim and passes at head: `gh api -X GET repos/o/r/pulls/12/merge`.

Group C, controls, pass at head and after, new rows of 'allows the quoted mention <Command> with no gh call when the gate is <State>': `git log --grep='gh pr merge'` and `git commit -m 'gh api -X PUT repos/o/r/pulls/12/merge'`. The controls `git commit -m 'gh pr merge 12'` and `echo "gh pr merge 12"` are already rows and stay unchanged.

Group R, the claims of `Outside what it can observe`, new Context `residual limits` of `COMPOUND_SUITE`, with the It 'allows <Command> with no gh call with the gate enabled because it is outside what the hook observes'. These pass at head and after; they pin the limit statement, and a later deny that makes one fail is a stated change of the limit:

- `python -c "import os; os.system('gh pr merge 12')"`
- `node -e "require('child_process').execSync('gh pr merge 12')"`
- `curl -X PUT https://api.github.com/repos/o/r/pulls/12/merge`
- `./merge.sh`
- `sh merge.sh`
- `a=g; b=h; $a$b pr merge 12`
- `$(echo 'gh pr merge 12')`
- `if true; then "gh" pr merge 12; fi`
- `! gh pr 'merge' 12`
- `exec gh 'pr' merge 12`
- `gh pr me${x}rge 12`
- `trap 'gh pr merge 12' EXIT`
- `gh alias set m 'pr merge 12'; gh m`
- `gh api graphql -F query=@f.graphql`
- `gh api graphql --input f`
- `gh api -X PUT repos/o/r/pulls/$n/merge`
- `git push origin HEAD:main`

Group H, new rows of `HELPER_SUITE`:

- 'reads <Case> as not plain': a comment ending in a backslash-newline; a backslash-newline before a comment; a comment with a `<CRLF>` continuation; a word split by a backslash-newline; a word split by a `<CRLF>` continuation. These must fail at head.
- 'reads <Case> as plain': `gh pr \<NL>merge 12`, and `gh pr merge\<NL> 12`. These pass at head. The row 'a backslash-newline continuation' already holds `gh pr merge \<NL> 12`.
- `Get-DocsCompleteGateUnquotedView`: a new It 'removes a backslash from an unquoted word' for `g\h pr merge 12`, which must fail at head.
- Context `Test-DocsCompleteGateMergeText`, new, one row each for the `gh pr merge` words, `gh api` with a mutation, `gh api` with no mutation, and no words. All four must fail at head, because the function does not exist there.
- `Test-DocsCompleteGateMergeCandidate` table 'returns <Expected> for <Case>': true for `g\h pr merge 12`, `gh pr mer\<NL>ge 12`, `if true; then sh -c 'gh pr merge 12'; fi` and `if true; then sh -c 'gh api -X PUT repos/o/r/pulls/12/merge'; fi`, which must fail at head; false for `git commit -m 'gh pr merge 12'`, `if true; then sh -c 'echo hi'; fi` and `if true; then sh -c 'merge pr gh'; fi`, which pass at head.
- `Get-DocsCompleteGateMergeTarget`: a new It 'keeps the selector of <Case>' asserting selector `12` and no reason for the four controls of F4 action 3 (`gh pr merge 12 # note; echo done`, `gh pr merge 12 #99`, `gh pr merge \<NL>12`, `gh pr \<NL>merge 12`). These pass at head.

## Existing Asserting Tests and Dispositions

Found by searching `tests/` for `Read-DocsCompleteGatePlainCommand`, `Get-DocsCompleteGateUnquotedView`, `Test-DocsCompleteGateMergeCandidate`, `Residual limits`, `InvokeProcess`, `ResolveRevision` and `ReadRevisionText`. The three helper symbols and the header text are named only in `HELPER_SUITE`; `HOOK_SUITE` and `COMPOUND_SUITE` reach them through `Invoke-DocsCompleteGateDecision`.

- `HELPER_SUITE` 'reads <Case> as plain' and 'reads <Case> as not plain': every existing row unchanged. No existing row holds a backslash-newline together with a comment or inside a word; 'a backslash-newline continuation' has a blank before the backslash, and the comment rows hold no backslash-newline. N14 changes no row, as the 335 of 335 result for H6 in `code-review.2026-11-07T04-16.md` shows; P3-T3 confirms it.
- `HELPER_SUITE` Context `Get-DocsCompleteGateUnquotedView`, 3 rows, unchanged: none holds a backslash.
- `HELPER_SUITE` 'returns <Expected> for <Case>', 19 rows, unchanged. 'step 3, a quoted mention' has no evaluator word, 'step 3, an unquoted api word with a quoted endpoint' stays true because `spelled` keeps the endpoint, and 'step 3, words out of order' stays false.
- `HELPER_SUITE` Contexts `Read-DocsCompleteGateMergeOperand` and `Get-DocsCompleteGateMergeTarget`: unchanged; the operand reader is not edited, and the target rows hold no backslash-newline.
- `COMPOUND_SUITE` existing rows, Contexts `compound merge scope (F3)` and `merge mentions`: unchanged. Their commands are candidates at head or quoted mentions with no evaluator word. Its header text is corrected, with no assertion change.
- `HOOK_SUITE`, every row: unchanged, and the file is not edited. It holds no backslash-newline, and its rows with a comment hold none, so `gh pr merge 12 #99`, `gh pr merge 12 # note; echo done` and `gh pr merge 12 # --disable-auto` keep their lookups. No row pins header text.
- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`: unchanged, because this cycle adds no dot-source edge and no file.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`: changed upstream and arrives through the merge. The upstream plan adds a seam detection class for interpreter names; `& $InvokeProcess 'git'` names no interpreter, and `HELPER` has no variable invocation. P1-T2 runs it.
- `REVISION_SUITE`, `CLI_SUITE`, `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1`: as `## Integration Merge: Effect on This Item` states.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`: unchanged, passing only with the byte-identical bundle copies; P4-T6 and P4-T8 run them.

## Comparison Set

P3-T6 runs the command set below under real bash. The set is derived mechanically, so a third party obtains the same rows.

- Listed: every command of Groups F4, W, F5, C, D and R, and the `Top-level controls` of `### F5 results`, where the elided `'...'` is `'gh pr merge 12'` and `bash <<EOF` is a heredoc whose body is `gh pr merge 12`.
- Multi-line: each first line in `gh pr view 34`, `gh pr merge 34`, `gh pr merge --disable-auto`, `ls`, `true`; joined by each of `<NL>`, ` # x<NL>`, ` # x\<NL>`, ` # x \<NL>`, ` \<NL>`, `\<NL>`, `\<CRLF>`, `;<NL>`, ` &&<NL>`, ` && \<NL>`, ` |<NL>`; to each second line in `gh pr merge 12`, `gh api -X PUT repos/o/r/pulls/12/merge`.
- Positional: for each index after the first character of `gh pr merge 12`, the text with one of `\<NL>`, `\`, `''`, `""` inserted at that index.
- Payload: each payload in `gh pr merge 12`, `gh pr merge 12 --merge`, `gh api -X PUT repos/o/r/pulls/12/merge`, placed at `%` in each template: `sh -c '%'`; `bash -c "%"`; `eval '%'`; `eval "%"`; `if true; then sh -c '%'; fi`; `! sh -c '%'`; `exec sh -c '%'`; `nice sh -c '%'`; `for i in 1; do bash -c '%'; done`; `while true; do sh -c '%'; break; done`; `case x in x) sh -c '%';; esac`; `f() { sh -c '%'; }; f`; `( sh -c '%' )`; `{ sh -c '%'; }`; `echo '%' | sh`; `printf '%' | bash`; `sh <<< '%'`; `bash <(echo '%')`; `source <(echo '%')`; `eval "$(echo '%')"`; `$(echo '%')`; `trap '%' EXIT`; `cat <<EOF | sh<NL>%<NL>EOF`; `if true; then bash <<EOF<NL>%<NL>EOF<NL>fi`; `sh -c 'echo first<NL>%'`; `python -c "import os; os.system('%')"`; `node -e "require('child_process').execSync('%')"`.
- Files: a scratch `merge.sh` holding `gh pr merge 12`, run as `sh merge.sh`, `. ./merge.sh`, `source merge.sh`, `./merge.sh`.

Stand-ins under `SCRATCH/compare/bin/`, first on `PATH`: `gh`, `git` and `curl` record their arguments, one per line, in a log under `SCRATCH/compare/`, and touch no network or repository. `sudo` runs its arguments. On a Windows host, `python`, `node` and `pwsh` start children through the Windows search path, which does not run an extensionless script, so each stand-in also has a `.cmd` form and the directories holding the real `gh`, `git` and `curl` are removed from `PATH`. Each command runs in a scratch working directory with standard input from `/dev/null`. A row whose interpreter is missing on the host is recorded `not observed` with the reason.

A `SCRATCH` driver dot-sources the `HOOK` of a consumer copy with an enabled profile and no receipt, replaces only `Invoke-DocsOnlyGhExe` with a recorder, and reports lookup and decision. Nothing under `tests/` uses it. A row merged when the log holds `pr merge` without `--help` and not `--disable-auto` alone, `api` or `curl` with a merge endpoint, or `git push` naming `main`. Results:

- `agree`: merged and denied with no lookup; merged and every merged selector looked up; or not merged. A deny of a command that did not merge is also recorded as `false deny`, which does not fail the task.
- `escape`: merged and allowed with no lookup, or a lookup of a different selector. Each escape is resolved in the same task as `## Implementation Plan` states.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md` and `.claude/rules/tonality.md`, and write `FEATURE/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:` and the six paths in order.
- [x] [P0-T2] Fetch `EPIC_REF`, derive `MERGE_BASE`, confirm `artifacts/orchestration/orchestrator-state.json` selects the `large` or `remediation` route and is not terminal, and write `FEATURE/evidence/remediation-baseline/preconditions.<timestamp>.md`.
  - Acceptance: the artifact records the `EPIC_REF` tip, `MERGE_BASE`, the route value, the logical line counts of `HOOK`, `HELPER`, `COMPOUND_SUITE` and `HELPER_SUITE`, and equal SHA-256 values for the `.claude/hooks` and `.codex/hooks` pair of each of the four shared files that has a twin. Any failure stops the run as BLOCKED.
- [x] [P0-T3] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `HOOK`, `HELPER`, `CLI`, `COMPOUND_SUITE` and `HELPER_SUITE`, and write `FEATURE/evidence/remediation-baseline/pssa.<timestamp>.md`.
  - Acceptance: the artifact records the finding count per file.
- [x] [P0-T4] Record the coverage baseline of `HOOK`, `HELPER` and `CLI` in `FEATURE/evidence/remediation-baseline/pester-coverage.<timestamp>.md`.
  - The figures of `HOOK` and `HELPER` are those of `FEATURE/evidence/qa-gates/coverage-delta.2026-11-07T03-57.md`, and the figure of `CLI` is the post-change value of `FEATURE/evidence/qa-gates/coverage-delta.2026-11-06T12-22.md`. The task confirms each file shows no diff between the commit that added its artifact and `HEAD`. Only when a diff is not empty, it runs one `Invoke-PoshQCParallelTest` and reads the figure from the merged coverage XML instead.
  - Acceptance: `Output Summary:` records the numeric line coverage, covered and missed counts of each file, and each diff result.

### Phase 1 — Integration Merge

- [x] [P1-T1] Merge `EPIC_REF` into the branch with a merge commit, resolve `.claude/lib/docs/Invoke-DocsCommand.ps1` by keeping both sides, copy it byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1`, and apply the matching case of `## Integration Merge: Effect on This Item`.
  - Kept from upstream: every line of its `InvokeProcess` and context changes, verbatim. Kept from this item: the `surface-delta` row under `# --- 1034: surface-delta ---`, `Resolve-DocsContextRevision`, `Read-DocsContextRevisionText`, and the two members with their closures and description lines. `$invokeProcess` stays assigned above the two closures. Case C edits to `REVISION_SUITE` go in this commit.
  - A conflict in any other path stops the run as BLOCKED, because the inputs list only these two.
  - Acceptance: `git merge-base --is-ancestor EPIC_REF HEAD` exits 0; `HEAD` has two parents and the push is not forced; `CLI` holds no conflict marker and parses with no parser error; the SHA-256 of `CLI` and `CLI_BUNDLE` is equal.
- [ ] [P1-T2] Run branch-current Pester over `tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1`, `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1`, `tests/scripts/claude-lib/docs/DocsSurfaceDeltaCommands.Tests.ps1`, `HOOK_SUITE`, `COMPOUND_SUITE`, `HELPER_SUITE` and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, re-check the T11 condition, and write `FEATURE/evidence/other/integration-merge.<timestamp>.md`.
  - T11 is the criterion at spec:533 as `## Acceptance Criteria Traceability` of `FEATURE/plan.2026-10-30T18-40.md` reads it: the row under the 1034 anchor, and a diff limited to added lines plus the OQ-1 members. The stale `900008` anchor text of that criterion is N5, which stays deferred.
  - Acceptance: zero failed and zero errored; `git diff -w --numstat MERGE_BASE HEAD -- .claude/lib/docs/Invoke-DocsCommand.ps1 .claude/lib/docs/DocsProfileCommands.psm1` reports 0 deleted for each file, because the 8 whitespace-only lines of `New-DocsCommandContext` are the T11 deviation the audits recorded; the `surface-delta` row sits directly under its anchor and `Test-DocsCommandTable` returns no finding for `Get-DocsCommandTable`; the artifact records `MERGE_COMMIT`, the merged tip, the upstream form of the `InvokeProcess` member, the case applied, and the disposition of each `REVISION_SUITE` and `CLI_SUITE` row named in that section. A failure returns to P1-T1.

### Phase 2 — Failing Rows

- [ ] [P2-T1] [expect-fail] In `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1`, add the rows of Groups F4, W, F5, D, C and R, and in `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1`, add the rows of Group H, and correct both headers as `## Design: Limit Statement` states.
  - No row starts a process or writes a file. `HOOK_SUITE` is not edited.
  - Acceptance: both files parse; each stays below 700 lines. P2-T2 records the failing rows.
- [ ] [P2-T2] [expect-fail] Run branch-current Pester over `COMPOUND_SUITE` and `HELPER_SUITE` at the merged head and write `FEATURE/evidence/regression-testing/fail-before.<timestamp>.md` with `ExpectedExitCode: 1`.
  - The rows of `### F4 results` and `### F5 results` were observed by the review. The other rows were predicted by reading the code, so two outcomes are handled here without stopping: a predicted row listed to fail that passes at head is recorded as already denied, and a Group R row that fails at head means the form already denies, so that row moves to the table of `compound merge scope (F3)` and the form leaves the limit statement.
  - Acceptance: the step script exits 1 only when every row of `### F4 results` and `### F5 results` fails with the gate enabled, every Group H row that `## Row Groups` lists to fail does so, and every disabled, absent and control row passes, and exits 255 otherwise. The artifact lists each failing row name and each row handled under the rule above.

### Phase 3 — Helper, Limits and Comparison

- [ ] [P3-T1] Apply `## Design: Reader, View and Candidate Test` to `.claude/hooks/enforce-docs-complete-gate-target.ps1`, correct its header and comment-based help as `## Design: Limit Statement` states, and copy it byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate-target.ps1`.
  - The reader's help states the two new rules. The view's help states the removal of backslashes. The candidate's help states both forms and the evaluator rule.
  - Acceptance: the file parses; `@(Get-Content -LiteralPath .claude/hooks/enforce-docs-complete-gate-target.ps1).Count` is at most 500; the SHA-256 of the two copies is equal; the shared files show no diff against `MERGE_BASE`.
- [ ] [P3-T2] Run branch-current Pester over `COMPOUND_SUITE`, `HELPER_SUITE`, `HOOK_SUITE`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, and write `FEATURE/evidence/regression-testing/gate-rows.<timestamp>.md`.
  - Acceptance: zero failed and zero errored, so every row of Groups F4, W, F5, D, C, R and H passes; the artifact records the passed count of each suite. The F4 action 3 controls and the F5 action 2 controls are named and pass.
- [ ] [P3-T3] (N14) Remove the after-word check of `Read-DocsCompleteGatePlainCommand` from `.claude/hooks/enforce-docs-complete-gate-target.ps1`, copy the file to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate-target.ps1`, re-run the suites of P3-T2, and write `FEATURE/evidence/regression-testing/n14-removal.<timestamp>.md`.
  - The check is the block after `$words.Add` that tests `$endsWord`. If any row changes result, the check is restored and the artifact names the row, because the brief conditions the removal on no row changing.
  - Acceptance: the artifact records the before and after passed and failed counts, which are equal with zero failures, and states removed or restored; the SHA-256 of the two copies is equal.
- [ ] [P3-T4] Rewrite the `Residual limits` paragraph of `.claude/hooks/enforce-docs-complete-gate.ps1`, correct its `.SYNOPSIS` and `.DESCRIPTION` opening as `## Design: Limit Statement` states, and copy the file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
  - Only comment-based help changes in this file.
  - Acceptance: the file parses; `@(Get-Content -LiteralPath .claude/hooks/enforce-docs-complete-gate.ps1).Count` is at most 500; the SHA-256 of the two copies is equal.
- [ ] [P3-T5] Update the sentences of `FEATURE/spec.md` that `## Design: Limit Statement` lists, each edit keeping its physical line count, and carry the limit statement in the residual-limits bullet of `### Hook`.
  - `SPEC_BEFORE` is the output of `git rev-parse HEAD` captured when this task starts.
  - Acceptance: the file's physical line count equals its count at `SPEC_BEFORE`, `## Acceptance Criteria` keeps its position, and `git diff SPEC_BEFORE -- FEATURE/spec.md` together with `git status --porcelain -- FEATURE/spec.md` shows no change to any line of that section.
- [ ] [P3-T6] Run `## Comparison Set` against the corrected hook under `SCRATCH/compare/` and write `FEATURE/evidence/regression-testing/bash-comparison.<timestamp>.md`.
  - Each `escape` is resolved here. A form one predicate in `HELPER` can deny without a false allow elsewhere is denied: a Group row is added to `COMPOUND_SUITE`, shown failing first, the fix is made, and `HELPER_BUNDLE` is copied. Any other form is added by name to the third item of the limit statement in `HOOK`, `HOOK_BUNDLE` and `FEATURE/spec.md`, with its Group R row. The comparison then re-runs from the start.
  - Acceptance: the step script exits 0 only when the row count equals the derivation of `## Comparison Set` plus any row this task added; every `escape` row carries a `Class:` value naming a form of the limit statement, and that form is present in the `HOOK` header and `FEATURE/spec.md` after whitespace collapse; and every row of Groups F4, W and F5 is `agree`, or `not observed` under the missing-interpreter rule of `## Comparison Set` (P3-T2 and P3-T7 still assert the hook's deny for such a row). A Group R row that the stand-ins cannot show merging, such as a `gh` alias, a mutation from a file or an unset endpoint variable, is `agree` with that reason recorded. The artifact records, for each command, the arguments bash passed, the lookup, the decision and the result, and the totals of `agree`, `false deny`, `escape` and `not observed`, with each form denied or listed in this task named.
- [ ] [P3-T7] Run every command of Groups F4, W and F5 in real hook processes against a fresh consumer copy of `.claude/hooks` and `.claude/lib` under `SCRATCH/consumer/`, and write `FEATURE/evidence/regression-testing/f4-f5-hook-process.<timestamp>.md`.
  - Each process receives the envelope on standard input.
  - Acceptance: the step script exits 0 only when each command with an enabled profile prints `deny` with `PR_UNRESOLVED` and the clause `does not name one pull request`, which shows no lookup ran, at exit 0; each command with a disabled or absent profile prints `allow` at exit 0; and `git commit -m 'gh pr merge 12'`, `echo "gh pr merge 12"` and `git log --grep='gh pr merge'` print `allow` with an enabled profile. Host paths are replaced by the token `SCRATCH`.

### Phase 4 — Final QA Loop and Self-Review

Any failing step, or any step that changes a file, restarts the loop from P4-T1. The parallel Pester and `pytest -n auto` runs are re-run only after a fix.

- [ ] [P4-T1] Run the PoshQC formatter over `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/hooks/enforce-docs-complete-gate-target.ps1`, `.claude/lib/docs/Invoke-DocsCommand.ps1`, `COMPOUND_SUITE` and `HELPER_SUITE`, and write `FEATURE/evidence/qa-gates/format.<timestamp>.md`.
  - Acceptance: the SHA-256 of each target and the `git status --porcelain` output captured before and after the run are identical, and both comparisons are recorded.
- [ ] [P4-T2] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the P4-T1 files and write `FEATURE/evidence/qa-gates/pssa.<timestamp>.md`.
  - Acceptance: zero findings for each file, compared against P0-T3.
- [ ] [P4-T3] Run one `Invoke-PoshQCParallelTest` from `scripts/powershell/PoshQC/PoshQC.psd1` with `-Root` at the worktree root and the default `-WorkerCount`, and write `FEATURE/evidence/regression-testing/pester-parallel.<timestamp>.md`.
  - The merged tree holds the upstream suites, so the total test count exceeds the cycle 2 figure.
  - Acceptance: `EXIT_CODE:` records the `ExitCode` property of the returned object and is 0; the artifact records `WorkerCount`, per-shard exit codes, and the test counts of `HOOK_SUITE`, `COMPOUND_SUITE`, `HELPER_SUITE`, `REVISION_SUITE` and `CLI_SUITE`; the merged `artifacts/pester/pester-junit.xml` reports zero failures and zero errors.
- [ ] [P4-T4] Read per-file line coverage from the merged `artifacts/pester/powershell-coverage.xml` of P4-T3, without a further run, and write `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md`.
  - Acceptance: `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/hooks/enforce-docs-complete-gate-target.ps1` and `.claude/lib/docs/Invoke-DocsCommand.ps1` each have line coverage of at least 85%, recorded numerically with covered and missed counts beside the baseline of P0-T4; no line of a function in `HELPER` is uncovered; `Resolve-DocsContextRevision` and `Read-DocsContextRevisionText` have no uncovered line. `config/poshqc-coverage.json` shows no change against `MERGE_BASE`. No branch gate applies to Pester.
- [ ] [P4-T5] Compute SHA-256 for the pairs `HOOK` and `HOOK_BUNDLE`, `HELPER` and `HELPER_BUNDLE`, `CLI` and `CLI_BUNDLE`, and `.claude/hooks/enforce-epic-merge-gate-command.ps1` and `.codex/hooks/enforce-epic-merge-gate-command.ps1`, and write `FEATURE/evidence/other/mirror-hashes.<timestamp>.md`.
  - Acceptance: every pair is equal, and `git diff MERGE_BASE HEAD -- .claude/hooks/hook-command-scanner.ps1 .claude/hooks/hook-command-invocation.ps1 .claude/hooks/hook-command-payload.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1` is empty.
- [ ] [P4-T6] Run one Pytest with `--strict-markers --strict-config -n auto` over the module set of P0-T6 of `FEATURE/plan.2026-10-30T18-40.md` under `tests/scripts/dev_tools/`, and write `FEATURE/evidence/qa-gates/python-contracts.<timestamp>.md`.
  - Acceptance: zero failures, with the passed count recorded.
- [ ] [P4-T7] Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check` and write `FEATURE/evidence/qa-gates/codex-generator-check.<timestamp>.md`.
  - Acceptance: exit code 0.
- [ ] [P4-T8] Run the Jest test of P0-T8 of `FEATURE/plan.2026-10-30T18-40.md` in `extensions/drm-copilot/` and write `FEATURE/evidence/qa-gates/jest-manifest.<timestamp>.md`.
  - Acceptance: zero failures, with the passed count recorded.
- [ ] [P4-T9] Write `FEATURE/evidence/qa-gates/scope-check.<timestamp>.md` from `git diff --name-only MERGE_BASE HEAD` and `git diff --name-only MERGE_COMMIT HEAD`, together with `git status --porcelain`, re-deriving `MERGE_BASE` first.
  - Acceptance: the paths changed since `MERGE_COMMIT` outside `FEATURE/` are a subset of `HOOK`, `HOOK_BUNDLE`, `HELPER`, `HELPER_BUNDLE`, `COMPOUND_SUITE` and `HELPER_SUITE`; over the whole branch from `MERGE_BASE`, no path ends in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`, no path is under `.github/workflows/` or `.codex/hooks/`, and every path outside `FEATURE/` appears in `## Artifact Classification` of `FEATURE/plan.2026-10-30T18-40.md`; `git status --porcelain` is empty.
- [ ] [P4-T10] Scan the files of this cycle and write `FEATURE/evidence/qa-gates/content-checks.<timestamp>.md`.
  - Checks: `COMPOUND_SUITE` and `HELPER_SUITE` contain none of `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`; `@(Get-Content -LiteralPath <path>).Count` is at most 500 for `HOOK` and `HELPER` and below 700 for `HOOK_SUITE`, `COMPOUND_SUITE` and `HELPER_SUITE`; after collapsing whitespace, the `HOOK` header and `FEATURE/spec.md` each contain `not a shell parser`, `policy-level`, `python -c`, `node -e`, `curl`, `scripts on disk`, `computed command words`, `not modelled`, `quoted command word`, `earlier Bash call` and `unquoted mention`; after collapsing whitespace, none of `HOOK`, `HELPER`, `FEATURE/spec.md` and `COMPOUND_SUITE` contains `in any form other than`, `can never lose` or `every merge that is not`; the bracket-class forbidden-token scan of P7-T10 of `FEATURE/plan.2026-10-30T18-40.md` reports no match over the cycle's files.
  - Acceptance: the step script exits 0 only when every check passes.
- [ ] [P4-T11] Re-evaluate the criteria at spec:516, story:65 and story:73 of `FEATURE/spec.md` and `FEATURE/user-story.md` against the evidence of this cycle, and write `FEATURE/evidence/other/criteria-reevaluation.<timestamp>.md`.
  - Acceptance: one PASS or FAIL row per criterion names its evidence files, among `fail-before`, `gate-rows`, `bash-comparison` and `f4-f5-hook-process`, and states each form that allows under the limit statement. Checkboxes are not edited. A FAIL row returns to the owning Phase 3 task.
- [ ] [P4-T12] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against the whole branch diff from `MERGE_BASE` and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md`.
  - The artifact replaces `FEATURE/evidence/qa-gates/self-review.2026-11-07T04-02.md` under the newest-file selection rule, and its `Output Summary:` says so. It covers the whole branch, and records that N1 to N5 stay deferred and that the integration merge moved `MERGE_BASE`.
  - Acceptance: one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P4-T1, and the self-review rewritten.

## Acceptance Criteria Traceability

E1 is the first epic criterion, at spec:516 and story:65. U2 is the second story criterion, at story:73. T11 is the criterion at spec:533.

| ID | Requirement | Implementation | Tests | Evidence |
|---|---|---|---|---|
| N12 | The epic tip is merged with both sides kept, and the bundle copy is identical | P1-T1 | P1-T2, P4-T5 | `integration-merge`, `mirror-hashes` |
| T11 | Row under its anchor, and the diff limited to added lines | P1-T1 | P1-T2 | `integration-merge` |
| F4 | A comment joined to a later command is not plain and denies; the controls keep their lookups | P3-T1 | P2-T1, P2-T2, P3-T2, P3-T7 | `fail-before`, `gate-rows`, `f4-f5-hook-process`, `bash-comparison` |
| F5 | Each group denies or is named; the class is stated; the controls stay allowed | P3-T1, P3-T4, P3-T5 | P2-T1, P2-T2, P3-T2, P3-T6, P4-T10 | `fail-before`, `gate-rows`, `bash-comparison`, `content-checks` |
| N14 | The after-word check is removed when no row changes | P3-T3 | P3-T3 | `n14-removal` |
| E1, U2 | Integration merge denied with a receipt reason; other read forms deny; disabled allows | P3-T1, P3-T4 | P4-T3, P4-T11 | `criteria-reevaluation`, `pester-parallel` |

## Pre-Mortem

- Review checklists: P4-T12 walks all three templates against the whole branch diff, and P4-T11 re-evaluates the three criteria the audit held at PARTIAL. Each of the last three reviews found forms outside its list, so P3-T6 derives a set wider than any listed row, the planner's review added Group W and the `gh api` payload rows, and the limit statement names the class rather than relying on the list being complete.
- Coverage: P4-T4 requires at least 85% for `HOOK`, `HELPER` and `CLI` from the merged XML. `HELPER` is at 100% and every new branch has a row in Group H. `CLI` was at 89.44% with `Invoke-DocsProcess` unexecuted by design; the merge can change that figure, and P4-T4 reads it.
- Mirror parity: P1-T1, P3-T1, P3-T3, P3-T4 and P3-T6 copy each bundle file in the editing task, and P4-T5 proves identity. P4-T6, P4-T7 and P4-T8 run the contract, Codex generator and Jest manifest checks. No file is added, so `pack-manifests/core.json` gains no row on this branch. The plan changes no fact in the execution-environment brief, so no brief-update task is needed.
- File size: `HOOK` is 325 logical lines and grows by the header only. `HELPER` is 290, loses the N14 block and gains about 35. `COMPOUND_SUITE` is 170 and `HELPER_SUITE` 280; each gains one table row per command. `HOOK_SUITE` is not edited. P4-T10 measures all five. `CLI` was above the 500-line guidance before the merge and its growth is upstream.
- Test isolation: the seeded shuffled Pester run and the fresh single-process run are not performed, because the relayed owner parallel-only directive bars them; P4-T3 runs concurrent shards and P4-T6 runs `pytest -n auto`. The seeded Jest run and the reversed-order Python run are not applicable because no Jest or Python test changes on this branch. New rows use the mocks already scoped to each suite, and both suites remove imported modules in `AfterAll`.
- CI-only behavior: `COMPOUND_SUITE` and `HELPER_SUITE` run on case-sensitive `ubuntu-latest` in `poshqc / PowerShell hook suites (Linux)`, and coverage comes from `poshqc / PowerShell QC` on `windows-latest`. `<CRLF>` rows build the characters through escapes, so the `eol=lf` rule cannot change them. The real-bash and real-process runs are local evidence, not suite rows. A pull request that still conflicts receives no CI, which P1-T1 removes; spec:544 stays owned by the S9 CI gate.
- Evidence: every artifact is under `FEATURE/evidence/<kind>/` with a write-time stamp and the required fields. Fail-before evidence is P2-T2, with `ExpectedExitCode: 1`. Runs under `SCRATCH` record that token rather than a host path. Coverage for the merged tree comes only from P4-T3.
