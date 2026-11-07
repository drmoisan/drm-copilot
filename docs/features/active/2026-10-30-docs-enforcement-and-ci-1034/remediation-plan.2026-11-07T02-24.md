# 2026-10-30-docs-enforcement-and-ci - Remediation Plan (design cycle 2)

- **Issue:** #1034
- **Branch:** `feature/docs-enforcement-and-ci-1034-r2`
- **Status:** Revised once after preflight; this is the single permitted revision of the cycle.
- **Inputs:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-inputs.2026-11-07T02-24.md`, and `### F1 remaining forms` and `### F3 results` of `code-review.2026-11-07T02-24.md` in the same folder.
- **Scope:** F1 remaining forms, F3, N8 (P2-T5 of `remediation-plan.2026-11-07T01-25.md`), N10 (one discriminating row), and N9 (stated in the residual limits). N1 to N5 stay deferred by the relayed owner directive.

## Execution Rules

- Commit and push after every task, including the `[expect-fail]` tasks. Each commit stages only that task's files.
- `.claude/skills/execution-environment/SKILL.md` owns tool routes, launchers, command-text restrictions, the batch budget and CI shape; this plan does not restate them. Under its `## Hook Execution Context` a branch hook is not exercised by an isolated subagent, so hook behavior is proven only by Pester rows and by the real-process runs of P1-T4 and P2-T6.
- Language: PowerShell and Markdown, plus the one JSON row in `pack-manifests/core.json`. No Python file is added or edited.
- `.claude/hooks/enforce-epic-merge-gate-command.ps1` and `.codex/hooks/enforce-epic-merge-gate-command.ps1` stay unchanged and byte-identical. `hook-command-scanner.ps1`, `hook-command-invocation.ps1` and `hook-command-payload.ps1` also stay unchanged in both hook trees.
- Every `spec.md` edit above `## Acceptance Criteria` preserves the physical line count, so the criterion positions cited by the review artifacts stay valid. Acceptance criterion text and checkboxes are not edited; the next review owns the checkboxes.
- Parallel-only directive (relayed owner directive, recorded in `FEATURE/evidence/other/owner-waiver.2026-11-07T01-51.md`): the final Pester gate is one `Invoke-PoshQCParallelTest` run and the final pytest gate is one `pytest -n auto` run, re-run only after a fix. No fresh single-process run and no shuffled run is planned.
- Cycle 1 tasks waived in that record and covered here: its P4-T5 by P4-T5 of this plan (mirror identity), its P4-T11 by P4-T9 (scope), its P4-T12 by P4-T10 (content), its P4-T13 by P4-T11 (criteria) and its P4-T14 by P4-T12 (self-review). Its P2-T5 is carried as P3-T1.

## Definitions

- `FEATURE` is `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`.
- `SCRATCH` is `<session scratchpad>/issue-1034/`; scratch file names start with `issue-1034-`, and evidence records the token `SCRATCH`, never a host path.
- `MERGE_BASE` is the live output of `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`, derived in P0-T2 and re-derived before each scope comparison.
- `CYCLE_BASE` is the commit named on the `Branch:` line of `FEATURE/remediation-inputs.2026-11-07T02-24.md`.
- `PLAN_HEAD` is the commit that added this plan, the output of `git log --diff-filter=A --format=%H -- FEATURE/remediation-plan.2026-11-07T02-24.md`.
- `HOOK` is `.claude/hooks/enforce-docs-complete-gate.ps1`, and `HOOK_BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
- `HELPER` is `.claude/hooks/enforce-docs-complete-gate-target.ps1`, and `HELPER_BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate-target.ps1`.
- `CORE_MANIFEST` is `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- `HOOK_SUITE` is `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`, `COMPOUND_SUITE` is `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1`, and `HELPER_SUITE` is `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1`.
- `TOUCHED_SUITES` are `HOOK_SUITE`, `COMPOUND_SUITE`, `HELPER_SUITE` and `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`.
- The Pester count source and the baseline-relative rule are those of `FEATURE/plan.2026-10-30T18-40.md` `## Definitions`, with the checkpoint rule that a failure outside `TOUCHED_SUITES` is pre-existing only when the same test fails at `MERGE_BASE` on this host.
- Each step script that gates a value ends with an exit status that fails when any stated value fails, so the recorded `EXIT_CODE:` carries the acceptance.

## Design: Fail-Closed Allowlist

Two review rounds each found forms outside the previous list. This cycle therefore stops extending a list of forms for the enabled-gate path. A command is first classified as a merge candidate by a broad test, and a candidate reaches the selector lookup only when the whole command is proven to be one plain `gh pr merge`.

Decision on placement: the detection is local to `HELPER`. The shared predicate `Test-EpicMergeGateCommandInScope` still runs and still supplies wrapper payloads, substitution bodies, xargs injection and unbalanced text, but no shared file changes. The epic merge gate keeps its own behavior.

`HELPER` is dot-sourced by `HOOK` after `hook-docs-only-diff.ps1`, holds only function definitions, dot-sources nothing, and has no statement at file level. It holds these five functions:

- `Read-DocsCompleteGatePlainCommand -CommandText` (new) returns `@{ IsPlain; Words }`. It reads the text from `ConvertTo-CommandLineNormalizedText` with surrounding whitespace trimmed, under this closed grammar, and any other character makes `IsPlain` false:
  - A word is a run of unquoted characters from `A-Za-z0-9_./:=@%+,#-`, single-quoted spans, and double-quoted spans holding no `$`, backtick or backslash. Spans concatenate, as in bash. `Words` holds each word with its quotes removed.
  - At the start of a word, an unquoted `#` ends the operands: the remainder is a comment and must hold no newline. A `#` inside a word or inside quotes is literal, so `"#12"` stays a selector.
  - A redirection is `[n]>`, `[n]>>`, `[n]<`, `&>` or `&>>` followed by one literal word, or `[n]>&` followed by digits or `-`. Digits directly before the operator are the file descriptor, as bash reads them, so `12>x` has no selector word. Redirections are removed from `Words`. A word after a redirection makes `IsPlain` false, so only trailing redirections are plain.
- `Get-DocsCompleteGateUnquotedView -CommandText` (new) returns the `MaskedText` of every `Read-CommandLineSegment` record over `ConvertTo-CommandLineNormalizedText`, joined with a space. Quoted spans and heredoc bodies are blank in this view; operators and leading words do not affect it.
- `Test-DocsCompleteGateMergeCandidate -CommandText` (new) decides in this order:
  1. When the command is plain and its first word is `gh`: `Get-CommandLineStructuralWalk` over `Words` for `pr merge`. On `Match`, the command is a candidate unless `Read-DocsCompleteGateMergeOperand` reads it and reports `DisableAutoOnly`. On any other outcome, the result of `Test-EpicMergeGateCommandInScope` stands.
  2. Otherwise `Test-EpicMergeGateCommandInScope` true means candidate.
  3. Otherwise the view decides. Candidate when it holds the whole words `gh`, `pr`, `merge` in that order (case-insensitive, with the word boundaries of `Test-CommandLineWordPresent`), or the whole words `gh`, `api` in that order while `Test-EpicMergeGateApiMutationText` is true for the normalized text with its quotes intact. The second test reads quoted text because a merge endpoint or mutation name is usually quoted.
- `Read-DocsCompleteGateMergeOperand` (moved from `HOOK`) keeps its closed flag table, drops its redirection branch (redirections never reach it now, and a quoted `'>x'` is an operand), and adds `DisableAutoOnly`. `gh` parses the value of a boolean flag and the last spelling wins, so a `--flag=value` spelling is never read as the bare flag:
  - `DisableAutoOnly` is true only when the bare word `--disable-auto` was read as a flag, no `--disable-auto=<value>` spelling was read, and no flag of `$script:EpicMergeGateActionFlags` was read in either spelling (`--auto` or `--auto=false`), counting cluster letters and skipping flag values. `gh pr merge 12 --disable-auto=false` and `gh pr merge 12 --disable-auto --disable-auto=false` are therefore merges.
  - `--merge=<value>` supplies a selector only when the value is not `1` or `0`. `gh` reads those two as booleans, so `gh pr merge --merge=1` merges the current branch and not pull request 1. `--merge=12` stays a selector: `gh` rejects that value and merges nothing, so the lookup cannot misbind a merge.
  - The other spellings keep their current reading. `--<value flag>=<value>` and `-R=<value>` supply the value. `-s=false` and every other `=` after a standalone short letter are unreadable, so they deny `PR_UNRESOLVED`. `--delete-branch=<value>` and `--help=<value>` do not affect the target. `gh --help=false pr merge 12` is `Unmodeled`, because `Skip-CommandLineOption` treats only the bare `--help` as `Terminal`, so it denies.
  - The shared predicate reads raw tokens, so it treats `gh pr merge 12 # --disable-auto`, `gh pr merge 12 --subject --disable-auto` and `gh pr merge 12 --disable-auto=false` as `--disable-auto`-only; step 1 above closes all three.
- `Get-DocsCompleteGateMergeTarget` (moved, rewritten) returns the existing target shape. `Reason` is `$null` only when the command is plain, its first word is exactly `gh`, the walk returns `Match`, the operands are readable, and the merged repository values pass the existing shape and conflict checks. Every other case is `PR_UNRESOLVED` with no `gh` call. The message keeps the clause `does not name one pull request` and tells the caller to run one plain `gh pr merge`.

Removed as unreachable: `Read-DocsCompleteGateApiTarget` and `Test-DocsCompleteGateContextChange`. A `gh api` merge is never a plain `gh pr merge`, and a directory or `GH_REPO` change is never part of a plain command, so with the gate enabled both deny `PR_UNRESOLVED`.

`Invoke-DocsCompleteGateDecision` replaces only its scope test: `Test-DocsCompleteGateMergeCandidate` runs where `Test-EpicMergeGateCommandInScope` ran, before any file read. With the gate disabled or the profile absent the result is unchanged: allow with no `gh` call.

Residual limits, stated in the `HOOK` header `Residual limits` paragraph and in `spec.md`:

- The profile and receipt are read from the local working tree.
- An ambient `GH_REPO` or `GH_HOST`, and any directory or environment change made by an earlier Bash call, are not visible (N9: `cd`, `builtin cd`, `env --chdir`, `GIT_DIR=`, `read GH_REPO`, bare `export GH_REPO`). The same forms inside the merge command are not plain and deny.
- A `gh` alias is not visible.
- A mutation supplied from a file and a merge endpoint whose number is a variable are not admitted. The unquoted `{owner}` endpoint limit of the previous header is closed by the view and is removed.
- A form obfuscated with a quoted command word outside the leading position, a variable holding a command word, `eval` over assembled text, or a script file is not a candidate.
- An unquoted mention denies while the gate is enabled: `echo gh pr merge 12` and `gh pr view 12 && git merge main` deny `PR_UNRESOLVED`. This false deny is accepted, and it does not occur with the gate disabled or the profile absent.
- With the gate enabled, a merge in any form other than one plain `gh pr merge` denies `PR_UNRESOLVED` whichever pull request it names, including a `gh api` merge and a compound command on a non-integration pull request.
- A `GET` on the merge endpoint is treated as a merge.
- Any `=value` spelling of `--disable-auto`, including `--disable-auto=true`, is treated as a merge.
- A push after the lookup is not observed unless `--match-head-commit` is passed.
- A direct `git push` to `main` is outside `gh` scope.

## Row Groups

`Stand-in` is `Set-TestTargetSeam` unless a row states otherwise. `Group A`, `Group B`, the enabled rows of `Group D`, the enabled rows of the unquoted forms of `Group E`, and `Group U` must fail at head. Every other row of `HOOK_SUITE` and `COMPOUND_SUITE` must pass at head.

`HOOK_SUITE` takes Group A, B, C and U, and `COMPOUND_SUITE` takes Group D and E. To keep `HOOK_SUITE` below the 700-line advisory tier, a row whose assertion matches an existing `-ForEach` table joins that table instead of adding an `It`.

Group A, new rows of the existing table 'denies PR_UNRESOLVED with no gh call for <Command>' in Context `merge target binding (F1)`, deny `PR_UNRESOLVED` with zero `gh` calls:

- `gh pr merge 2>&1 12`
- `gh pr merge --merge 2>&1 epic/x-integration`
- `gh pr merge >log 2>&1 12`
- `gh pr merge &>log 12`
- `gh pr merge >&2 12`
- `gh pr merge {12..12}`
- `gh pr merge 1{2..2}`
- `gh pr merge 2>/dev/null 12`
- `gh pr merge > 99 12`
- `gh pr merge 12 &`
- `gh pr merge 12;`
- `env --chdir=../other gh pr merge 12`
- `builtin cd ../other; gh pr merge 12`
- `GIT_DIR=../other gh pr merge 12`
- `read GH_REPO; gh pr merge 12`
- `export GH_REPO; gh pr merge 12`

Group B, new rows of the existing table 'looks up <Lookup> and denies RECEIPT_ABSENT for <Command>' in the same Context, except the two rows under `Set-TestIntegrationCheckoutSeam`, which go in the new Context `integration checkout (F1)`. Each denies `RECEIPT_ABSENT` with exactly one lookup, the one named:

- `gh pr merge 12 #99`, lookup `pr view 12`.
- `gh pr merge 12 # note; echo done`, lookup `pr view 12`.
- `gh pr merge 12 # --disable-auto`, lookup `pr view 12`.
- `gh pr merge 12 --subject --disable-auto`, lookup `pr view 12`.
- `gh pr merge 12 --disable-auto=false`, lookup `pr view 12`.
- `gh pr merge 12 --disable-auto=true`, lookup `pr view 12`.
- `gh pr merge 12 --disable-auto --disable-auto=false`, lookup `pr view 12`.
- `gh pr merge --merge=1 12`, lookup `pr view 12`.
- `gh pr merge #99`, bare lookup `pr view`, under the new stand-in `Set-TestIntegrationCheckoutSeam`, where no selector returns the integration pull request and `#99` and `1` each return an unrelated one. This is the cycle 1 regression row.
- `gh pr merge --merge=1`, bare lookup `pr view`, under `Set-TestIntegrationCheckoutSeam`. At head it looks up `pr view 1` and allows.

Group C, new control rows, pass at head and after the change:

- `gh pr merge 12 >/dev/null 2>&1`, `gh pr merge "12"`, `gh pr merge --subject 'a; b' 12` and `gh pr merge 12 --disable-auto --auto=false`: lookup `pr view 12`, deny `RECEIPT_ABSENT`, in the table of Group B.
- `gh pr merge "#12"`: lookup `pr view #12`, deny `RECEIPT_ABSENT`, in the table of Group B. `$script:LookupAnswers` gains that key.
- `gh pr merge --squash 2>&1` and `gh pr merge 12>x`: bare lookup, allow, in the existing table 'looks up the current branch and allows <Command>' of Context `merge target controls`.
- `gh pr merge --merge` under `Set-TestIntegrationCheckoutSeam`: bare lookup, deny `RECEIPT_ABSENT`, in Context `integration checkout (F1)`.
- `gh pr merge 12 --disable-auto # note`, `gh pr view feature/merge` and `gh --help pr merge`: allow with zero `gh` calls, in the existing table 'allows <Command> with no gh call' of Context `merge target controls`.
- `gh pr merge 12 --unknown x` (N10): deny `PR_UNRESOLVED` with zero `gh` calls, in the existing `denies PR_UNRESOLVED with no gh call for <Command>` row table. Behavior at head is correct, so this row passes at head; P2-T7 proves it discriminates.

Group D, new Context `compound merge scope (F3)` of `COMPOUND_SUITE`. Each command has an enabled row (deny `PR_UNRESOLVED`, zero `gh` calls) and a disabled row (allow, zero `gh` calls, profile disabled and profile absent). In `COMPOUND_SUITE` the enabled stand-in is `Set-TestFileSeam` with an enabled profile and a default `Invoke-DocsOnlyGhExe` mock that exits 1, because every row asserts zero `gh` calls and needs no lookup answers:

- `if gh pr checks 12; then gh pr merge 12 --merge; fi`
- `for n in 12; do gh pr merge "$n" --merge; done`
- `! gh pr merge 12`
- `exec gh pr merge 12`
- `while true; do gh pr merge 12 --merge; break; done`
- `if false; then echo x; else gh pr merge 12; fi`
- `until gh pr merge 12; do sleep 1; done`
- `sudo gh pr merge 12`
- `nice gh pr merge 12`
- `coproc gh pr merge 12`
- `find . -maxdepth 0 -exec gh pr merge 12 \;`
- `gh pr checks 12 && gh pr merge 12 --merge`
- `case x in x) gh pr merge 12;; esac`
- `f() { gh pr merge 12; }; f`
- `time gh pr merge 12`
- `nohup gh pr merge 12`
- `(gh pr merge 12)`
- `{ gh pr merge 12; }`
- `if true; then gh api -X PUT repos/o/r/pulls/12/merge; fi`
- `! gh api graphql -f query='mutation{mergePullRequest(x)}'`
- `gh api -X PUT repos/{owner}/{repo}/pulls/12/merge`

Group E, new Context `merge mentions` of `COMPOUND_SUITE`:

- Quoted, allow with zero `gh` calls with the gate enabled and disabled (pass at head): `git commit -m 'gh pr merge 12'`, `echo "gh pr merge 12"`.
- Unquoted, deny `PR_UNRESOLVED` with zero `gh` calls enabled (fail at head), allow with zero `gh` calls disabled (pass at head): `echo gh pr merge 12`, `gh pr view 12 && git merge main`.

Group U is the nine updated rows of `## Existing Asserting Tests and Dispositions`.

## Existing Asserting Tests and Dispositions

Found by searching `tests/` for `enforce-docs-complete-gate`, `DOCS_COMPLETE_GATE`, `Read-DocsCompleteGate`, `Get-DocsCompleteGateMergeTarget`, `Test-DocsCompleteGateContextChange`, `Test-EpicMergeGateCommandInScope` and for suites that enumerate `.claude/hooks`.

`HOOK_SUITE` holds 111 rows at head. Every row follows, grouped by `It` with its row count. No row is weakened: an updated row keeps its deny and adds the assertion of zero `gh` calls.

Context `gate disabled`, unchanged:

- 'allows <Command> with no gh call when the profile is <State>': 14 rows, the seven commands `gh pr merge`, `gh pr merge 7 --squash`, `gh pr merge 7 --auto`, `gh pr merge 7 --admin`, `gh api -X PUT repos/o/r/pulls/7/merge`, `git status`, `gh pr view 7`, in the two states. The candidate test precedes the profile read, and a disabled or absent profile still allows.

Context `gate enabled`, unchanged, because each drives `gh pr merge 7 --merge`, a plain form, or a non-merge command:

- 'allows a non-merge command with no file read and no gh call': 1 row. `git log --oneline` is not a candidate.
- 'allows an envelope whose tool_input has no command': 1 row.
- 'allows a passing receipt whose revision equals headRefOid and looks up the named pull request': 1 row.
- 'looks up the current-branch pull request for a bare merge': 1 row.
- 'allows a merge whose pull request is not the integration target (<Case>)': 2 rows.
- 'denies <Code> for an integration pull request': 4 rows.
- 'denies RECEIPT_REVISION_MISMATCH and names both revisions': 1 row.
- 'denies PROFILE_UNREADABLE for a malformed profile with no gh call': 1 row.
- 'denies PR_UNRESOLVED when <Case>': 4 rows.
- 'denies MATCH_HEAD_MISMATCH when --match-head-commit differs from headRefOid': 1 row.
- 'allows when --match-head-commit equals headRefOid': 1 row.
- 'denies RECEIPT_PATH_INVALID when the receipt path is <Case>': 2 rows.

Context `merge target binding (F1)`, 'looks up <Lookup> and denies RECEIPT_ABSENT for <Command>', 22 rows:

- Unchanged, 16 rows, each a plain form: `gh pr merge https://github.com/o/r/pull/12 --merge`; `gh pr merge epic/x-integration --merge`; `gh pr merge --merge -- epic/x-integration`; `gh pr merge --subject title epic/x-integration`; `gh pr merge -sd epic/x-integration`; `gh pr merge -sb 99 epic/x-integration`; `gh pr merge 12 -R other/repo`; `gh pr merge 12 --repo other/repo`; `gh pr merge 12 --repo=other/repo`; `gh pr merge 12 -Rother/repo`; `gh pr merge 12 -R=other/repo`; `gh --repo other/repo pr merge 12`; `gh pr -R other/repo merge 12`; `gh --repo other/repo pr merge 12 -R other/repo`; `gh pr merge epic/x-integration > log`; `gh pr merge epic/x-integration >log`.
- Updated, 6 rows of Group U, moved to 'denies PR_UNRESOLVED with no gh call for <Command>'. Reason: each is not one plain `gh pr merge`, so the design denies before any lookup: `gh api -X PUT repos/other/repo/pulls/12/merge`; `gh api -X PUT /repos/other/repo/pulls/12/merge`; `timeout 30 gh pr merge epic/x-integration`; `sh -c 'gh pr merge epic/x-integration'`; `gh pr merge 99 --disable-auto; gh pr merge epic/x-integration --merge`; `cd ../other && gh pr merge https://github.com/o/r/pull/12 --merge`.

Context `merge target binding (F1)`, 'denies PR_UNRESOLVED with no gh call for <Command>', 31 rows, all unchanged, because each is not plain or has unreadable operands: the three GraphQL mutation rows; `gh api graphql -f query='mutation{mergePullRequest(x)}' repos/o/r/pulls/12/merge`; `gh pr merge 99 --merge; gh pr merge 12 --merge`; `gh pr merge 99 --merge; gh api -X PUT repos/o/r/pulls/12/merge`; `gh --unknown pr merge 12`; `gh pr merge 12 'unbalanced`; `echo 12 | xargs gh pr merge --merge`; `gh pr merge $PR`; `gh pr merge 12 -R $REPO`; `gh pr merge 12 --unknown`; `gh pr merge 12 -z`; `gh pr merge 12 13`; `gh pr merge -- -x`; `gh pr merge 12 --repo bad`; `gh pr merge 12 --repo`; `gh --repo a/b pr merge 12 -R c/d`; `gh api -X PUT https://api.github.com/repos/o/r/pulls/12/merge`; `gh api --hostname ghe.example.com -X PUT repos/o/r/pulls/12/merge`; `gh api -X PUT repos/o/r/pulls/12/merge repos/o/r/pulls/13/merge`; `gh api -X PUT repos/$OWNER/r/pulls/12/merge`; `cd ../other && gh pr merge 12 --merge`; `pushd ../other; gh pr merge 12`; `chdir ../other; gh pr merge 12`; `Set-Location ../other; gh pr merge 12`; `Push-Location ../other; gh pr merge 12`; `sl ../other; gh pr merge 12`; `GH_REPO=other/repo gh pr merge 12`; `GH_HOST=ghe.example.com gh pr merge 12`; `export GH_REPO=other/repo; gh pr merge 12`.

Context `merge target controls`, 11 rows:

- 'looks up number 12 and denies RECEIPT_ABSENT for <Command>', unchanged, 3 rows: `gh pr merge 12 --merge`; `gh pr merge --merge=12` (`12` is not `1` or `0`, so it stays a selector); `gh pr merge 12 --merge 2>&1`.
- Same `It`, updated, 3 rows of Group U, moved to 'denies PR_UNRESOLVED with no gh call for <Command>': `gh pr merge 12 --merge; echo done`; `gh pr view 12; gh pr merge 12 --merge`; `gh api -X PUT 'repos/{owner}/{repo}/pulls/12/merge'`. Reason: each is not one plain `gh pr merge`.
- 'looks up the current branch and allows <Command>', unchanged, 2 rows: `gh pr merge --squash`; `gh pr merge --help`.
- 'allows <Command> with no gh call', unchanged, 2 rows: `gh pr merge 12 --disable-auto` (step 1 of the candidate test); `gh api graphql -f query='query{viewer{login}}'` (plain, not `pr merge`, out of the shared scope).
- 'denies PR_UNRESOLVED for a full-length uppercase headRefOid', unchanged, 1 row.

The remaining rows are unchanged, because each drives `gh pr merge 7 --merge`, a seam directly, or the entry point:

- Context `read failures (F2)`, 4 rows: 'denies PROFILE_UNREADABLE with no gh call when the profile read throws'; 'denies RECEIPT_UNREADABLE without claiming an absent file when the receipt read throws'; 'denies PR_UNRESOLVED when Invoke-DocsOnlyGhExe throws'; 'returns 0 and emits a PAYLOAD_ANOMALY deny when ReadPayload throws'.
- Context `payload anomaly`, 2 rows: 'denies an envelope it cannot read (<Case>)'.
- Context `entry point`, 2 rows: 'writes the compact decision JSON and returns 0 for a supplied payload'; 'acquires the payload through the ReadPayload seam when none is supplied'.
- `Describe 'enforce-docs-complete-gate seams (issue #1034)'`, 5 rows: 'returns the repository root two levels above the hook directory'; 'returns $null for a path that does not exist'; 'returns $null when a parent directory does not exist'; 'throws for an existing path that cannot be read as a file'; 'returns the text of an existing file (the hook itself, read only)'.

The counts sum to 14 + 20 + 22 + 31 + 11 + 4 + 2 + 2 + 5 = 111.

Other suites:

- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`: text unchanged. Its rows are discovered from the AST, so it gains the row 'B1: PreToolUse .claude/hooks/enforce-docs-complete-gate.ps1 blocks naming enforce-docs-complete-gate-target.ps1 when that direct edge fails', which proves the hook denies when `HELPER` fails to load. The `$script:ReasonPrefix` row is unchanged.
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`: text unchanged. S2 and S4 read the new edge, which is a single-statement guard over a file with no further edge, on both the repository and the mirror root.
- Unchanged, because the hook keeps its entry point, imports and prefix: `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (its `$script:ExemptHook` list is keyed on registered hooks, and `HELPER` is not registered), and `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1` and `enforcement-hooks-checkpoint-path-explicit.Tests.ps1`.
- Unchanged in text, and each passes only with the `CORE_MANIFEST` row and the bundle copy of P2-T1: `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` (enumerates the bundled hooks directory), `test_push_down_claude_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py` (reads the new `$PSScriptRoot` dependency of `HOOK`) and `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`.
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1` and the epic merge gate suites are unchanged, because no shared file changes.
- Codex: `HELPER` is Claude-only under OQ-4, with no `.codex/hooks` twin, and `scripts/dev_tools/generate_codex_agent_variants.py` reads no `.claude/hooks` path, so the Codex `core.json`, the generator check and `test_push_down_codex_and_agents_pack_manifest_completeness.py` are unaffected. P4-T7 and P4-T6 confirm this.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md` and `.claude/rules/tonality.md`, and write `FEATURE/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:` and the six paths in order.
- [x] [P0-T2] Fetch `origin/epic/documentation-estate-tooling-integration`, derive `MERGE_BASE`, confirm `artifacts/orchestration/orchestrator-state.json` selects the `large` or `remediation` route and is not terminal, and write `FEATURE/evidence/remediation-baseline/preconditions.<timestamp>.md`.
  - Acceptance: the artifact records `MERGE_BASE`, the route value, the logical line count of `HOOK`, and equal SHA-256 values for the `.claude/hooks` and `.codex/hooks` pair of `enforce-epic-merge-gate-command.ps1`. Any failure stops the run as BLOCKED.
- [x] [P0-T3] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `HOOK` and `HOOK_SUITE`, and write `FEATURE/evidence/remediation-baseline/pssa.<timestamp>.md`.
  - Acceptance: the artifact records the finding count per file.
- [x] [P0-T4] Record the Pester coverage baseline of `HOOK` in `FEATURE/evidence/remediation-baseline/pester-coverage.<timestamp>.md`.
  - The baseline is the line coverage recorded in `FEATURE/evidence/regression-testing/pester-parallel.2026-11-07T02-05.md`. The task confirms that `HOOK` shows no diff between the commit that added that artifact and `HEAD`. Only when that diff is not empty, this task runs one `Invoke-PoshQCParallelTest` and reads the figure from its merged coverage XML instead.
  - Acceptance: `Output Summary:` records the numeric line coverage of `HOOK`, its covered and missed counts, and the diff result. Python coverage is not captured because no Python file is in scope.

### Phase 1 — Failing Rows

- [x] [P1-T1] [expect-fail] In `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`, add the rows of Group A, Group B and Group C, move the nine Group U rows as `## Existing Asserting Tests and Dispositions` states, add `Set-TestIntegrationCheckoutSeam`, and add the `$script:LookupAnswers` keys `pr view #12`, the unrelated `pr view #99` and the unrelated `pr view 1`; and create `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1` with the rows of Group D and Group E.
  - `Set-TestIntegrationCheckoutSeam` follows `Set-TestTargetSeam`, and the disabled rows of Group D and Group E use `Set-TestFileSeam` with a disabled and an absent profile. No row starts a process or writes a file.
  - `COMPOUND_SUITE` dot-sources `HOOK`, and its `BeforeAll` and `AfterAll` follow the first `Describe` of `HOOK_SUITE`, with only `ConvertTo-TestEnvelope`, `Get-TestProfileText`, `Set-TestFileSeam` and the mocks of `Get-DocsCompleteGateRepositoryRoot` and `Invoke-DocsOnlyGhExe`.
  - Acceptance: both files parse; the row count of `HOOK_SUITE` equals 111 plus the rows of Group A, Group B and Group C; `COMPOUND_SUITE` holds only the rows of Group D and Group E. P1-T2 records the failing rows.
- [ ] [P1-T2] [expect-fail] Run branch-current Pester over `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` and `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1` and write `FEATURE/evidence/regression-testing/fail-before.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Acceptance: the step script exits 1 only when every row that `## Row Groups` says must fail at head fails and every other row passes, and exits 255 otherwise. The artifact lists each failing row name. A row that passes against head when it is listed to fail is a task failure, because it proves nothing.
- [ ] [P1-T3] [expect-fail] Run the bash-exact comparison at head under `SCRATCH/bash-exact/` and write `FEATURE/evidence/regression-testing/bash-exact-before.<timestamp>.md` with `ExpectedExitCode: 1`.
  - A stand-in `gh` on `PATH` under `SCRATCH/bash-exact/bin/` prints its arguments, one per line, into a log file under `SCRATCH/bash-exact/`, because a command under test can redirect its standard output. Real bash runs each command in a scratch working directory with standard input from `/dev/null`. A `SCRATCH` driver dot-sources the `HOOK` of a consumer copy of `.claude/hooks` and `.claude/lib` under `SCRATCH/bash-exact/consumer/` that holds an enabled profile and no receipt, because the worktree has no `docs/documentation-estate/docs-profile.json` and a gate with no profile makes no lookup. The driver replaces only `Invoke-DocsOnlyGhExe` with a recorder using the answers of `Set-TestTargetSeam`, and reports the lookup and decision. This is evidence, not a test: nothing under `tests/` uses the stand-in.
  - Command set: the rows of `### F1 remaining forms`, `gh pr merge #99`, and the controls `gh pr merge 12 --merge 2>&1`, `gh pr merge 12 >/dev/null 2>&1`, `gh pr merge --squash 2>&1`, `gh pr merge 12>x`, `gh pr merge "#12"`, `gh pr merge 12 #99`, `gh pr merge --subject 'a b' 12`, `gh --repo o/r pr merge 12`.
  - A row agrees when the hook looks up the selector and repository that bash passed to `gh`, or denies `PR_UNRESOLVED` with no lookup. The three no-merge controls of Group C, `gh pr merge 12 --disable-auto # note`, `gh pr view feature/merge` and `gh --help pr merge`, also agree when the hook allows with no lookup: none of them merges a pull request, so no selector exists for a lookup to match. This clause covers those three commands only, none of which is in the set of this task, and any other row that allows with no lookup disagrees.
  - Acceptance: the step script exits 1 only when `gh pr merge 2>&1 12`, `gh pr merge --merge 2>&1 epic/x-integration`, `gh pr merge >log 2>&1 12`, `gh pr merge &>log 12`, `gh pr merge >&2 12`, `gh pr merge {12..12}`, `gh pr merge 1{2..2}` and `gh pr merge #99` disagree, and exits 255 otherwise. The artifact records, for each command, the arguments bash passed, the lookup, and the decision.
- [ ] [P1-T4] [expect-fail] Run the F3 table in real hook processes against a consumer copy of `.claude/hooks` and `.claude/lib` under `SCRATCH/consumer/` with an enabled profile and no receipt, and write `FEATURE/evidence/regression-testing/f3-hook-process-before.<timestamp>.md` with `ExpectedExitCode: 1`.
  - Each process receives the envelope on standard input. The command set is the eleven commands of the `### F3 results` table.
  - Acceptance: the step script exits 1 only when each command prints `allow` with exit 0, and exits 255 otherwise. The artifact records each decision text, with host paths replaced by the token `SCRATCH`.

### Phase 2 — Helper and Hook Correction

- [ ] [P2-T1] Create `.claude/hooks/enforce-docs-complete-gate-target.ps1` with the five functions of `## Design: Fail-Closed Allowlist`, copy it byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate-target.ps1`, and add its row to `CORE_MANIFEST` directly after the row of `.claude/hooks/enforce-docs-complete-gate.ps1`.
  - `HOOK` is not edited here. The helper has a header stating its purpose and that it runs only under `HOOK`, which loads the shared functions it calls. Each function has comment-based help and `CmdletBinding()`. No function invokes a variable with `&`, because `enforcement-hooks-no-python-invocation.Tests.ps1`, which P2-T4 runs, reports that form as a dynamic invocation.
  - Acceptance: the file parses with no parser error; `@(Get-Content -LiteralPath .claude/hooks/enforce-docs-complete-gate-target.ps1).Count` is at most 500; the SHA-256 of the two copies is equal; the new path appears exactly once in `CORE_MANIFEST`, and that file still parses as JSON.
- [ ] [P2-T2] In `.claude/hooks/enforce-docs-complete-gate.ps1`, add the guarded dot-source of `enforce-docs-complete-gate-target.ps1`, remove the four target functions, make `Invoke-DocsCompleteGateDecision` call `Test-DocsCompleteGateMergeCandidate`, and copy the file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
  - The dot-source follows the `hook-docs-only-diff.ps1` line, in the same single-statement `try` and `catch` form with `Add-HookDependencyFailure -Name 'enforce-docs-complete-gate-target.ps1'`, so a helper that fails to load denies through `Get-HookDependencyFailureDecision`.
  - Removed: `Read-DocsCompleteGateMergeOperand`, `Read-DocsCompleteGateApiTarget`, `Test-DocsCompleteGateContextChange` and `Get-DocsCompleteGateMergeTarget`. The header decision order (steps 2 and 4) and the `Residual limits` paragraph state the design and the list of `## Design: Fail-Closed Allowlist`, and the comment above the `enforce-epic-merge-gate-command.ps1` import names what the hook and helper still use.
  - Acceptance: every Context of `HOOK_SUITE` and `COMPOUND_SUITE` reports zero failures in a branch-current Pester run, so every Group A, B, D, E and U row passes; `@(Get-Content -LiteralPath .claude/hooks/enforce-docs-complete-gate.ps1).Count` is at most 500; the SHA-256 of the two copies is equal.
- [ ] [P2-T3] Create `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1`, which dot-sources `HOOK` and tests the helper functions directly with in-memory strings.
  - The new suite is written here and not in Phase 1 because the functions it calls do not exist at head; the decision rows of Phase 1 are the fail-first proof of the behavior.
  - `Read-DocsCompleteGatePlainCommand` rows: plain results for concatenated quoting, a single-quoted body holding `;`, `$` and `&`, a backslash-newline continuation, each redirection form, a redirection followed by a comment, and `#` inside a word; not-plain results for each of `;`, `|`, `&`, `(`, `)`, `{`, `}`, `*`, `?`, `~`, `$`, a backtick, a backslash, an unquoted newline, a double-quoted `$`, a word after a redirection, `>&log`, `<<`, a comment followed by a newline, and an unbalanced quote; the empty result for blank text.
  - `Get-DocsCompleteGateUnquotedView` rows: a quoted span and a heredoc body are blank, and an unquoted merge is present across `2>&1`.
  - `Test-DocsCompleteGateMergeCandidate` rows: each branch of its three steps. `Read-DocsCompleteGateMergeOperand` rows: `DisableAutoOnly` for `--disable-auto`, `--disable-auto --merge`, `-s --disable-auto`, a flag value equal to `--disable-auto`, `--disable-auto=false`, `--disable-auto=true`, `--disable-auto --disable-auto=false` and `--disable-auto --auto=false`; `Selector` for `--merge=1`, `--merge=0` and `--merge=12`. `Get-DocsCompleteGateMergeTarget` rows: selector, repository and pin of a plain form, and `PR_UNRESOLVED` for a first word that is not exactly `gh`.
  - `AfterAll` removes the modules that `HOOK_SUITE` removes. No row starts a process or writes a file.
  - Acceptance: the file reports zero failures in a branch-current Pester run, and it stays below 700 lines.
- [ ] [P2-T4] Run branch-current Pester over `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1`, `enforce-docs-complete-gate-compound.Tests.ps1`, `enforce-docs-complete-gate-target.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `PreToolUsePayload.Contract.Tests.ps1`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1` and `enforcement-hooks-no-python-invocation.Tests.ps1`, and write `FEATURE/evidence/regression-testing/gate-rows.<timestamp>.md`.
  - Acceptance: zero failed and zero errored in the JUnit file; the row 'B1: PreToolUse .claude/hooks/enforce-docs-complete-gate.ps1 blocks naming enforce-docs-complete-gate-target.ps1 when that direct edge fails' is present and passes; the artifact records the passed count of each new Context.
- [ ] [P2-T5] Re-run the P1-T3 comparison against the corrected hook under `SCRATCH/bash-exact/` and write `FEATURE/evidence/regression-testing/bash-exact-after.<timestamp>.md`.
  - The consumer copy of P1-T3 is refreshed, so it holds the corrected `HOOK` and `HELPER`.
  - The P1-T3 command set is extended with every row of Group A, Group B and Group C except the rows under `Set-TestIntegrationCheckoutSeam`.
  - Acceptance: the step script exits 0 only when every row agrees under the P1-T3 definition. The artifact records, for each command, the arguments bash passed, the lookup, and the decision.
- [ ] [P2-T6] Re-run the real hook process table against a fresh consumer copy under `SCRATCH/consumer/` and write `FEATURE/evidence/regression-testing/f3-hook-process-after.<timestamp>.md`.
  - The consumer copy includes `HELPER`. The set is every command of Group D, with the profile enabled, disabled and absent, and the two quoted commands of Group E with the profile enabled.
  - Acceptance: the step script exits 0 only when every Group D command with an enabled profile prints `deny` with `PR_UNRESOLVED` and the clause `does not name one pull request`, which proves no lookup ran, at exit 0; every Group D command with a disabled or absent profile prints `allow` at exit 0; and both quoted commands print `allow` at exit 0. A second case removes `HELPER` from the consumer copy and requires `deny` for `gh pr merge 12 --merge` with text naming `enforce-docs-complete-gate-target.ps1`. Host paths are replaced by the token `SCRATCH`.
- [ ] [P2-T7] (N10) Apply mutant A17 to a scratch copy of `.claude/hooks`, `.claude/lib` and `HOOK_SUITE` under `SCRATCH/mutant/`, and write `FEATURE/evidence/regression-testing/mutant-a17.<timestamp>.md`.
  - The copy keeps the repository layout, so the suite resolves the copied `HOOK`. A17 removes the check in `Read-DocsCompleteGateMergeOperand` that returns unreadable for a flag outside both tables. An unmutated control run of the same copy runs first. The worktree is not modified.
  - Acceptance: the step script exits 0 only when the control run reports zero failures and the mutant run fails the row for `gh pr merge 12 --unknown x`.

### Phase 3 — Documentation

- [ ] [P3-T1] (N8, N9) Update the non-criterion hook design text of `FEATURE/spec.md`, with each edit keeping its physical line count.
  - `### Hook` section of `enforce-docs-complete-gate.ps1`: the reuse list (`Test-EpicMergeGateCommandInScope` through `Test-DocsCompleteGateMergeCandidate`; `Get-EpicMergeGateSelectorPrNumber` is no longer used), decision step 2, decision step 4 (`gh pr view [<selector>] [--repo <value>]`, reached only by one plain `gh pr merge`), and the residual limits, which carry the full list of `## Design: Fail-Closed Allowlist`.
  - Reason-code table: the `RECEIPT_UNREADABLE` row adds a read failure on an existing file, and the `RECEIPT_ABSENT` row is unchanged in meaning.
  - `### Registration and push-down` core-pack bullet, the `## Constraints & Risks` batch-budget and file-size bullets, and the `## Artifact Classification` hook and bundle rows name `HELPER`. The file-size bullet states that target reading moved to a helper at the 500-line limit, which supersedes the wording that cycle 1 P2-T5 proposed.
  - Acceptance: `## Acceptance Criteria` keeps its line position, and `git diff PLAN_HEAD -- FEATURE/spec.md` together with `git status --porcelain -- FEATURE/spec.md` shows no change to any line of that section.
- [ ] [P3-T2] In `## Artifact Classification` of `FEATURE/plan.2026-10-30T18-40.md`, add rows for `.claude/hooks/enforce-docs-complete-gate-target.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate-target.ps1`, `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1` and `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1`.
  - The two production rows are inserted after the `Bundle copies of the seven rows above` row, so that count stays correct; class hook and hook mirror, language PowerShell, rule R1, D. The two test rows follow the `HOOK_SUITE` row; class test, language PowerShell (Pester), rule D.
  - Acceptance: each of the four paths appears in that section, and no other row changes, shown by `git diff PLAN_HEAD -- FEATURE/plan.2026-10-30T18-40.md` together with `git status --porcelain -- FEATURE/plan.2026-10-30T18-40.md`.

### Phase 4 — Final QA Loop and Self-Review

Any failing step, or any step that changes a file, restarts the loop from P4-T1. The parallel Pester and `pytest -n auto` runs are re-run only after a fix.

- [ ] [P4-T1] Run the PoshQC formatter over `.claude/hooks/enforce-docs-complete-gate.ps1`, `.claude/hooks/enforce-docs-complete-gate-target.ps1`, `HOOK_SUITE`, `COMPOUND_SUITE` and `HELPER_SUITE`, and write `FEATURE/evidence/qa-gates/format.<timestamp>.md`.
  - Acceptance: the SHA-256 of each target and the `git status --porcelain` output captured before and after the run are identical, and both comparisons are recorded.
- [ ] [P4-T2] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the P4-T1 files and write `FEATURE/evidence/qa-gates/pssa.<timestamp>.md`.
  - Acceptance: zero findings for each file, compared against P0-T3.
- [ ] [P4-T3] Run one `Invoke-PoshQCParallelTest` from `scripts/powershell/PoshQC/PoshQC.psd1` with `-Root` at the worktree root and the default `-WorkerCount`, and write `FEATURE/evidence/regression-testing/pester-parallel.<timestamp>.md`.
  - Acceptance: the artifact records `ExitCode`, `WorkerCount`, per-shard exit codes and the test counts of `HOOK_SUITE`, `COMPOUND_SUITE` and `HELPER_SUITE`; every file in `TOUCHED_SUITES` reports 0 failed and 0 errored; the baseline-relative rule holds for any other failure. A merged `artifacts/pester/pester-junit.xml` reporting zero failures is the expected result. When a shard fails and no merged file exists, counts follow the Pester count source definition.
- [ ] [P4-T4] Read per-file line coverage from the merged `artifacts/pester/powershell-coverage.xml` of P4-T3, without a further run, and write `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md`.
  - Acceptance: `.claude/hooks/enforce-docs-complete-gate.ps1` and `.claude/hooks/enforce-docs-complete-gate-target.ps1` each have line coverage of at least 85%, recorded numerically with covered and missed counts; the artifact records the baseline of P0-T4 and the post-change figure of `HOOK`; no line of a function in `HELPER`, and no line changed in `Invoke-DocsCompleteGateDecision`, is uncovered. The script tail of `HOOK` after the dot-source return is outside that last condition, because no in-process suite reaches it. `config/poshqc-coverage.json` shows no change against `MERGE_BASE`. No branch gate applies to Pester.
- [ ] [P4-T5] Compute SHA-256 for the pairs `HOOK` and `HOOK_BUNDLE`, `HELPER` and `HELPER_BUNDLE`, and `.claude/hooks/enforce-epic-merge-gate-command.ps1` and `.codex/hooks/enforce-epic-merge-gate-command.ps1`, and write `FEATURE/evidence/other/mirror-hashes.<timestamp>.md`.
  - Acceptance: every pair is equal, and `git diff MERGE_BASE HEAD -- .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1` is empty.
- [ ] [P4-T6] Run one Pytest with `--strict-markers --strict-config -n auto` over the module set of P0-T6 of `FEATURE/plan.2026-10-30T18-40.md` under `tests/scripts/dev_tools/`, and write `FEATURE/evidence/qa-gates/python-contracts.<timestamp>.md`.
  - Acceptance: zero failures, with the passed count recorded. This run covers the resource, completeness and dependency-closure contracts for `HELPER`.
- [ ] [P4-T7] Run `scripts/dev_tools/generate_codex_agent_variants.py` in module form with `--check` and write `FEATURE/evidence/qa-gates/codex-generator-check.<timestamp>.md`.
  - Acceptance: exit code 0.
- [ ] [P4-T8] Run the Jest test of P0-T8 of `FEATURE/plan.2026-10-30T18-40.md` in `extensions/drm-copilot/` and write `FEATURE/evidence/qa-gates/jest-manifest.<timestamp>.md`.
  - Acceptance: zero failures, with the passed count recorded.
- [ ] [P4-T9] Write `FEATURE/evidence/qa-gates/scope-check.<timestamp>.md` from `git diff --name-only MERGE_BASE HEAD` and `git diff --name-only CYCLE_BASE HEAD`, together with `git status --porcelain`.
  - Acceptance: the paths this cycle changed outside `FEATURE/` are exactly `HOOK`, `HOOK_BUNDLE`, `HELPER`, `HELPER_BUNDLE`, `CORE_MANIFEST`, `HOOK_SUITE`, `COMPOUND_SUITE` and `HELPER_SUITE`; over the whole branch no path ends in `.py`, `.ts`, `.tsx`, `.js`, `.mjs` or `.cjs`, no path is under `.github/workflows/` or `.codex/hooks/`, and every path outside `FEATURE/` appears in `## Artifact Classification` of `FEATURE/plan.2026-10-30T18-40.md`.
- [ ] [P4-T10] Scan the files changed in this cycle and write `FEATURE/evidence/qa-gates/content-checks.<timestamp>.md`.
  - Checks: `HOOK_SUITE`, `COMPOUND_SUITE` and `HELPER_SUITE` contain none of `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName` or `$env:TEMP`; `@(Get-Content -LiteralPath <path>).Count` is at most 500 for `.claude/hooks/enforce-docs-complete-gate.ps1` and `.claude/hooks/enforce-docs-complete-gate-target.ps1`, and below 700 for all three suites; after collapsing whitespace, the `HOOK` header and `FEATURE/spec.md` each contain `earlier Bash call`, `quoted command word` and `unquoted mention`; neither `HOOK` nor `HELPER` defines `Read-DocsCompleteGateApiTarget` or `Test-DocsCompleteGateContextChange`; the bracket-class forbidden-token scan of P7-T10 of `FEATURE/plan.2026-10-30T18-40.md` reports no match over the cycle's files.
  - Acceptance: the step script exits 0 only when every check passes.
- [ ] [P4-T11] Re-evaluate the criteria at spec:516, story:65 and story:73 of `FEATURE/spec.md` and `FEATURE/user-story.md` against the evidence of this cycle, and write `FEATURE/evidence/other/criteria-reevaluation.<timestamp>.md`.
  - Acceptance: one PASS or FAIL row per criterion names its evidence file, among `fail-before`, `gate-rows`, `bash-exact-after` and `f3-hook-process-after`. Checkboxes are not edited; the next review owns them. A FAIL row returns to the owning Phase 2 task.
- [ ] [P4-T12] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against the whole branch diff from `MERGE_BASE` and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md`.
  - The artifact replaces `FEATURE/evidence/qa-gates/self-review.2026-11-07T01-03.md` under the newest-file selection rule, and its `Output Summary:` says so. It covers the whole branch, not only this cycle, and records that N1 to N5 stay deferred.
  - Acceptance: one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P4-T1, and the self-review rewritten.

## Acceptance Criteria Traceability

E1 is the first epic criterion, at spec:516 and story:65. U2 is the second story criterion, at story:73.

| ID | Requirement | Implementation | Tests | Evidence |
|---|---|---|---|---|
| F1 | Every selector form looks up what bash passes, or denies | P2-T1, P2-T2 | P1-T1, P2-T3, P2-T4 | `fail-before`, `bash-exact-before`, `bash-exact-after` |
| F3 | A merge in a compound command is a candidate and denies; disabled allows | P2-T1, P2-T2 | P1-T1, P2-T3, P2-T4 | `f3-hook-process-before`, `f3-hook-process-after` |
| FS | Target reading moved to a helper with manifest, bundle and fail-closed load | P2-T1, P2-T2, P3-T2 | P2-T4, P4-T6, P4-T8 | `gate-rows`, `mirror-hashes`, `python-contracts`, `jest-manifest` |
| N8 | `spec.md` design text matches the hook | P3-T1 | P4-T10 | `content-checks` |
| N9 | Context changes are stated in the residual limits | P2-T2, P3-T1 | P1-T1, P4-T10 | `content-checks`, `gate-rows` |
| N10 | The unknown-flag check has a discriminating row | P1-T1 | P2-T7 | `mutant-a17` |
| E1, U2 | Integration merge denied with a receipt reason; disabled allows | P2-T1, P2-T2 | P2-T4, P2-T5, P2-T6 | `criteria-reevaluation` |

## Pre-Mortem

- Review checklists: P4-T12 walks all three templates against the whole branch diff, and P4-T11 re-evaluates the three criteria the audit held at PARTIAL. The self-review states that a compound or `gh api` merge of a non-integration pull request now denies with the gate enabled, so the reviewer reads story:74 and the criterion at spec:525 against plain forms.
- Coverage: `HELPER` is new, so every line is changed. `HOOK_SUITE`, `COMPOUND_SUITE` and `HELPER_SUITE` drive each branch, P4-T4 requires at least 85% for `HOOK` and `HELPER` from the merged coverage XML, and it requires no uncovered line in a `HELPER` function. `HOOK` loses covered lines to the move, so its percentage can fall while staying above the threshold; P4-T4 records the figures. `config/poshqc-coverage.json` already names `.claude/hooks`, so `HELPER` is measured with no configuration change.
- Mirror parity: P2-T1 and P2-T2 copy each bundle file in the editing task, and P2-T1 adds the `CORE_MANIFEST` row in the same task, so no mid-plan suite sees a bundle gap. P4-T5 proves SHA-256 identity and that the shared command file is unchanged in both runtimes. P4-T6, P4-T7 and P4-T8 run the contract, Codex generator and Jest manifest checks. The plan changes no fact in the execution-environment brief (no CI job, required context, tool route or batch-budget rule), so no brief-update task is needed.
- File size: `HOOK` is at the 500-line limit of spec:541. The move removes four functions, leaving an estimated 330 lines, and `HELPER` is estimated at 300. P2-T1 and P2-T2 measure each, and P4-T10 measures both and all three suites. `HOOK_SUITE` is 589 lines at head. With Group D and Group E in `COMPOUND_SUITE` and the Group A, B and C rows joining existing tables, it is estimated at 660 and `COMPOUND_SUITE` at 130; new `It` blocks for those rows would have reached about 720. Helper rows go to `HELPER_SUITE`. P4-T10 keeps every suite below the 700-line advisory tier.
- Test isolation: the seeded shuffled Pester run and the fresh single-process run are not performed, because the relayed owner parallel-only directive bars them; P4-T3 runs concurrent shards and P4-T6 runs `pytest -n auto`. The seeded Jest run and the reversed-order Python run are not applicable because no Jest or Python test is new or changed. Rows use Pester mocks scoped to each `It`, and `COMPOUND_SUITE` and `HELPER_SUITE` remove imported modules in `AfterAll` as `HOOK_SUITE` does.
- CI-only behavior: all three suites run on case-sensitive `ubuntu-latest` in `poshqc / PowerShell hook suites (Linux)`, so rows use exact file-name case, no drive letter and no process. Coverage comes from `poshqc / PowerShell QC` on `windows-latest`. A new file under `tests/scripts` is assigned to a shard automatically. The real-bash and real-process runs are local evidence, not suite rows. spec:544 stays owned by the S9 CI gate.
- Evidence: every artifact is under `FEATURE/evidence/<kind>/` with a write-time stamp and the four required fields. Fail-before evidence is P1-T2, P1-T3 and P1-T4, each with `ExpectedExitCode: 1`. Runs under `SCRATCH` record that token rather than a host path.
