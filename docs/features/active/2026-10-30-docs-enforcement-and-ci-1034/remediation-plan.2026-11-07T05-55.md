# 2026-10-30-docs-enforcement-and-ci - Remediation Plan (proportionate cycle 4)

- **Issue:** #1034
- **Branch:** `feature/docs-enforcement-and-ci-1034-r2`
- **Status:** Authored for remediation cycle 4, an owner-authorized exception to the three-attempt remediation guard.
- **Inputs:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-inputs.2026-11-07T05-55.md` (F6 and note N15), and `### F6 results` and the N15 row of the Findings Table of `code-review.2026-11-07T05-55.md` in the same folder.
- **Owner decision (binding):** Option 2, text only. Both limit statements are corrected to describe what the code does, and every shell form that stays allowed is named. No hook logic changes. This overrides action 1 of F6 in the inputs file, which preferred a code route for the comment groups.
- **Review standard:** a shell form the hook does not model is non-blocking when the limit text names it.
- **Scope:** F6 and N15 by text; the optional N17 path correction. N1 to N5 stay deferred by the relayed owner directive; N13 is accepted design; N16, N18 and N19 are left untouched.

## Execution Rules

- Commit and push after every phase. Each commit stages only that phase's files. No rebase and no forced push.
- `.claude/skills/execution-environment/SKILL.md` owns tool routes, launchers, command-text restrictions, the batch budget and CI shape; this plan does not restate them.
- Language: PowerShell comment-based help and Markdown. No Python, TypeScript or test file is added or edited.
- These stay unchanged against `MERGE_BASE`: in both hook trees `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-payload.ps1` and `enforce-epic-merge-gate-command.ps1`. `HELPER` and `HELPER_BUNDLE`, which this feature added after `MERGE_BASE`, stay unchanged against `CYCLE_START`. Only comment-based help changes in `HOOK`.
- `HOOK` and `HOOK_BUNDLE` stay byte-identical: the task that edits `HOOK` copies it in the same task.
- Every `FEATURE/spec.md` edit above `## Acceptance Criteria` keeps the physical line count, and the physical line number of the `## Acceptance Criteria` heading is unchanged.
- Parallel-only directive (owner, binding): the Pester gate is one `Invoke-PoshQCParallelTest` run, read through the `ExitCode` property of its returned object, and the pytest gate is one `pytest -n auto` run. Each is re-run only after a fix. No single-process, seeded-shuffle, reversed-order or ordering-comparison run is planned; P0-T5 and P2-T4 record that waiver. Failures seen only in single-process runs do not block.
- Poetry commands run with `env -u VIRTUAL_ENV`. `poetry install` runs only in P0-T3 and only under its condition.

## Definitions

- `FEATURE` is `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`.
- `SCRATCH` is `<session scratchpad>/issue-1034/`; scratch file names start with `issue-1034-`, and evidence records the token `SCRATCH`, never a host path.
- `EPIC_REF` is `origin/epic/documentation-estate-tooling-integration`, fetched in P0-T2.
- `MERGE_BASE` is the live output of `git merge-base EPIC_REF HEAD`, re-derived before each comparison.
- `CYCLE_START` is the output of `git rev-parse HEAD` captured at the start of P0-T2, before any edit of this cycle, and recorded in the P0-T2 artifact.
- `HOOK` is `.claude/hooks/enforce-docs-complete-gate.ps1`, and `HOOK_BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
- `HELPER` is `.claude/hooks/enforce-docs-complete-gate-target.ps1`, and `HELPER_BUNDLE` is `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate-target.ps1`.
- `SPEC` is `FEATURE/spec.md`, and `STORY` is `FEATURE/user-story.md`. `SPEC` has no bundle copy: no file under `extensions/drm-copilot/resources/` carries the feature folder name, which P0-T2 confirms.
- `COMPOUND_SUITE` is `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1`.
- `<NL>` is a line feed. Driver rows carry it through PowerShell double-quoted escapes, so no row depends on file line endings.
- Each step script that gates a value ends with an exit status that fails when any stated value fails, so the recorded `EXIT_CODE:` carries the acceptance.

## Design: Limit Text

The edit is made in two places that carry the same content: the `What it establishes` and `Outside what it can observe` paragraphs inside the `Residual limits` block of the `HOOK` header, and the residual-limits bullet of `### Hook \`enforce-docs-complete-gate.ps1\`` in `SPEC`, whose first physical line carries `What it establishes` and whose second carries `Outside what it can observe`. In `SPEC` each change stays inside its existing physical line, with code spans in backticks as the line already uses them. The `Ambient state` and `Accepted false denies` text is unchanged.

1. `What it establishes`: the words "in the unquoted text" become "in the text the shared scanner reads as unquoted". This names what `Get-DocsCompleteGateUnquotedView` returns: the `MaskedText` of `Read-CommandLineSegment`.
2. `What it establishes`, a closing sentence with this content: the shared scanner keeps no comment state, reads `<<` as a heredoc opener wherever it appears, and does not nest double quotes inside a command substitution inside double quotes, so a merge line bash runs can read as quoted or heredoc text and allow. The forms named are: a quote character in a # comment before and after the merge line (`# it's`); a heredoc opener << in a # comment (`# a<<b`); a shift in arithmetic (`x=$((1<<4))`); and double quotes nested in a command substitution inside double quotes (`echo "$(git log -1 --format="%h"; gh pr merge 12)"`).
3. `Outside what it can observe`, `Known forms`: five forms are added before "and forms not modelled": an ANSI-C quoted command word (`$'g\x68' pr merge 12`); arguments piped to `gh` through `xargs gh` (`printf 'pr\nmerge\n12\n' | xargs gh`); a shell alias holding the merge (`alias m='gh pr merge 12'`, then `m`); an encoded payload decoded with `base64 -d` and piped to `sh`; and a branch merge through `gh api repos/o/r/merges`, which merges branches with no pull request.

In `HOOK` the added text sits inside the `<# ... #>` help block, so it never contains the two-character closing sequence of that block, and the wrapped lines keep the existing four-space indent and the existing width.

### Asserted Tokens

P1-T3 checks, in the `HOOK` header and in `SPEC`, each after removing backticks and collapsing every whitespace run to one space, that each token below is present and that `in the unquoted text` is absent. The tokens are backslash-free by design.

| ID | Token | Form |
|---|---|---|
| K1 | `the shared scanner reads as unquoted` | corrected wording |
| K2 | `keeps no comment state` | scanner limit |
| K3 | `quote character in a # comment` | F6 group A |
| K4 | `heredoc opener << in a # comment` | F6 group B |
| K5 | `$((1<<4))` | F6 group C |
| K6 | `double quotes nested in a command substitution` | F6 group D |
| K7 | `x68` | N15 ANSI-C command word |
| K8 | `xargs gh` | N15 `xargs` |
| K9 | `shell alias` | N15 alias |
| K10 | `base64 -d` | N15 encoded payload |
| K11 | `repos/o/r/merges` | N15 branch merge |

### Named-Form Rows

P1-T4 drives `Invoke-DocsCompleteGateDecision` from a `SCRATCH` driver, as cycle 3 did for its comparison, with an enabled profile, no receipt, and `Invoke-DocsOnlyGhExe` replaced by a recorder. Nothing under `tests/` uses the driver. Each row must allow with zero lookups, which confirms that the text names a form that allows:

- R1 `# Merge once it's green<NL>gh pr merge 12 --merge<NL># Delete the branch now that it's merged<NL>git status`
- R2 `# a<<b<NL>gh pr merge 12<NL>b`
- R3 `x=$((1<<4))<NL>gh pr merge 12<NL>4`, recording the N19 error text on the error stream if it appears
- R4 `echo "$(git log -1 --format="%h"; gh pr merge 12)"`
- R5 `$'g\x68' pr merge 12`
- R6 `printf 'pr\nmerge\n12\n' | xargs gh`
- R7 `alias m='gh pr merge 12'<NL>m`
- R8 `echo Z2ggcHIgbWVyZ2UgMTI= | base64 -d | sh`
- R9 `gh api repos/o/r/merges -f base=main -f head=x`

Controls in the same run, unchanged by this cycle: `git commit -m 'gh pr merge 12'`, `echo "gh pr merge 12"` and `git log --grep='gh pr merge'` allow; `gh pr merge 12 # note` and `gh pr merge 34 # it's` reach one lookup each.

## Existing Asserting Tests and Dispositions

Found by searching `tests/` for `unquoted text`, `What it establishes`, `Residual limits`, `Outside what it can observe`, `not modelled`, `Known forms`, `policy-level`, `not a shell parser` and `enforce-docs-complete-gate`. No test asserts the text of the `HOOK` header or of `SPEC`.

- `COMPOUND_SUITE` Context `residual limits`: its comment says the rows pin the limit statement. The rows assert decisions, which this cycle does not change, so every row is unchanged and the file is not edited.
- `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` and `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1`: decisions and helper results only; unchanged.
- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`: read the hook's guarded import lines and deny prefix, which are outside the help block; unchanged.
- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`: names the hook file in a reason table; unchanged.
- `tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1` 'treats a backslash in unquoted text as an ordinary character', and the comments holding `not modelled` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1`: unrelated files; unchanged.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`: passes only while `HOOK_BUNDLE` equals `HOOK`; unchanged, run by P2-T4.
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`: `HOOK` stays below 500 logical lines; unchanged, run by P2-T3.

P0-T2 repeats the search and records the result. A hit that asserts header or `SPEC` text stops the run as BLOCKED, because this plan adds no test edit.

## Out of Scope by Owner Decision

The `.DESCRIPTION` of `Get-DocsCompleteGateUnquotedView` in `HELPER` reads "Returns the unquoted text of a command". `HELPER` stays unchanged under the owner decision; the `HOOK` header is the limit statement, and P2-T8 records this sentence as a known wording difference, not a FAIL.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline

No tracked file outside `FEATURE/evidence/` changes in this phase.

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md` and `.claude/rules/tonality.md`, and write `FEATURE/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:` and the six paths in order.
- [x] [P0-T2] Capture `CYCLE_START`, fetch `EPIC_REF`, derive `MERGE_BASE`, confirm `artifacts/orchestration/orchestrator-state.json` selects the `large` or `remediation` route and is not terminal, and write `FEATURE/evidence/remediation-baseline/preconditions.<timestamp>.md`.
  - The artifact records `CYCLE_START`, the `EPIC_REF` tip, `MERGE_BASE`, the route value, the logical line count of `HOOK`, the physical line count of `SPEC`, the physical line number of the `## Acceptance Criteria` heading of `SPEC`, the SHA-256 of `HOOK` and `HOOK_BUNDLE`, the result of a search of `extensions/drm-copilot/resources/` for the feature folder name, and the result of the test search of `## Existing Asserting Tests and Dispositions`.
  - Acceptance: the two SHA-256 values are equal; the resource search finds no file; the test search finds no test asserting header or `SPEC` text. Any failure stops the run as BLOCKED.
- [x] [P0-T3] Run `env -u VIRTUAL_ENV poetry env info -p`, and only when the printed path lies inside this worktree's root, run `env -u VIRTUAL_ENV poetry install`; write `FEATURE/evidence/remediation-baseline/poetry-env.<timestamp>.md`.
  - The recorded path is reduced to its worktree-relative form; no host path is recorded.
  - Acceptance: the artifact records the relative environment path and the install exit code 0. A path outside the worktree stops the run as BLOCKED with no install.
- [x] [P0-T4] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `HOOK` and write `FEATURE/evidence/remediation-baseline/pssa.<timestamp>.md`.
  - Acceptance: the artifact records the finding count and each finding's rule name.
- [x] [P0-T5] Before any edit, run one `Invoke-PoshQCParallelTest` from `scripts/powershell/PoshQC/PoshQC.psd1` with `-Root` at the worktree root and the default `-WorkerCount`, and write `FEATURE/evidence/baseline/pester-parallel.<timestamp>.md`.
  - When `ExitCode` is not 0, the failing tests are read from the shard JUnit files under `artifacts/pester/parallel/shard-<i>/`, because merged files exist only after a fully green run.
  - Acceptance: `EXIT_CODE:` records the `ExitCode` property; the artifact records `WorkerCount`, each shard's exit code, total, passed and failed counts, the file and test name of every failed test as the baseline failure set, and the line coverage of `HOOK` with covered and missed counts from the merged `artifacts/pester/powershell-coverage.xml` when `ExitCode` is 0, or from the shard coverage file under `artifacts/pester/parallel/shard-<i>/` that reports the most covered lines of `HOOK` otherwise, naming that shard; it records the parallel-only waiver of `## Execution Rules`.
- [x] [P0-T6] Before any edit, run one `env -u VIRTUAL_ENV poetry run pytest -n auto --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1034-coverage-baseline.json --junitxml=SCRATCH/issue-1034-pytest-baseline.xml --cov` at the worktree root (the bare `--cov` takes its source from the project coverage configuration, as the CI step `Run tests with Pytest and coverage` does), and write `FEATURE/evidence/baseline/pytest-parallel.<timestamp>.md`.
  - Acceptance: the artifact records the exit code, the passed, failed and errored counts, the node ID of every failed or errored test from the JUnit file as the baseline failure set, the `TOTAL` line coverage from the terminal report, and the branch totals from the JSON report. Paths are recorded with the token `SCRATCH`.

### Phase 1 — Limit Text

- [x] [P1-T1] Apply `## Design: Limit Text` to the comment-based help of `.claude/hooks/enforce-docs-complete-gate.ps1`, and copy the file byte for byte to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-docs-complete-gate.ps1`.
  - Only lines inside the `What it establishes` and `Outside what it can observe` paragraphs of the help block change.
  - Acceptance: `[System.Management.Automation.Language.Parser]::ParseFile` reports zero errors for the file; every line that `git diff -U0 CYCLE_START -- .claude/hooks/enforce-docs-complete-gate.ps1` adds or removes lies after the `What it establishes` line and before the `Ambient state` line of the help block; the logical line count is below 500; the SHA-256 of `HOOK` and `HOOK_BUNDLE` is equal.
- [x] [P1-T2] Apply `## Design: Limit Text` to the residual-limits bullet of `### Hook \`enforce-docs-complete-gate.ps1\`` in `FEATURE/spec.md`.
  - Acceptance: the physical line count of `SPEC` and the physical line number of `## Acceptance Criteria` equal the values recorded by P0-T2; `git diff -U0 CYCLE_START -- FEATURE/spec.md` changes exactly the two physical lines that carry `What it establishes` and `Outside what it can observe`, and no line of `## Acceptance Criteria`.
- [x] [P1-T3] Run the token check of `### Asserted Tokens` over the `HOOK` help block and `SPEC`, and write `FEATURE/evidence/regression-testing/limit-text-check.<timestamp>.md`.
  - The check runs from a step script under `SCRATCH` that reads both files, removes backticks, collapses whitespace and tests each token with an ordinal substring match.
  - Acceptance: the step script exits 0 only when K1 to K11 are each present in both texts and `in the unquoted text` is absent from both; the artifact records one row per token and file with `present` or `absent`. Before the edits of P1-T1 and P1-T2 the same script would fail on K1, so the check can fail.
- [x] [P1-T4] Run the rows and controls of `### Named-Form Rows` through the `SCRATCH` driver against the branch `HOOK`, and write `FEATURE/evidence/regression-testing/named-form-decisions.<timestamp>.md`.
  - A row that denies or looks up a selector shows that the text names a form that does not allow: the form is removed from both limit texts and from `### Asserted Tokens`, P1-T1 to P1-T3 are repeated, and the artifact records the removal.
  - Acceptance: the step script exits 0 only when R1 to R9 each allow with zero recorded lookups, the three quoted-mention controls allow, and the two plain controls each record one lookup; the artifact records each row's decision, lookup count and any error-stream text, with host paths replaced by `SCRATCH`.

### Phase 2 — Final QA Loop, Criteria and Self-Review

Any failing step, or any step that changes a file, restarts the loop from P2-T2. The parallel Pester and `pytest -n auto` runs are re-run only after a fix.

- [x] [P2-T1] (N17, optional and text-only) In the criterion of `## Acceptance Criteria` of `FEATURE/spec.md` that names `<FEATURE>/evidence/coverage/`, replace that path with `<FEATURE>/evidence/qa-gates/`, where the coverage figures are recorded as `coverage-delta.*`.
  - The checkbox and every other word of the criterion are unchanged. If the edit cannot be made within that one physical line, the task records `not applied` and changes nothing.
  - Acceptance: the physical line count of `SPEC` and the line number of `## Acceptance Criteria` equal the P0-T2 values; `git diff -U0 CYCLE_START -- FEATURE/spec.md` shows the two lines of P1-T2 plus, when applied, this one line and no other; when applied, `SPEC` contains `evidence/qa-gates/` in that criterion and no longer contains `evidence/coverage/`.
- [x] [P2-T2] Run the PoshQC formatter over `HOOK` and write `FEATURE/evidence/qa-gates/format.<timestamp>.md`.
  - Acceptance: the SHA-256 of `HOOK` and the `git status --porcelain` output captured before and after the run are identical, and both comparisons are recorded.
- [x] [P2-T3] Run `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `HOOK` and write `FEATURE/evidence/qa-gates/pssa.<timestamp>.md`.
  - Acceptance: zero findings, or exactly the rule-and-message set of P0-T4, recorded beside the P0-T4 count.
- [ ] [P2-T4] Run one `Invoke-PoshQCParallelTest` with the arguments of P0-T5 and write `FEATURE/evidence/regression-testing/pester-parallel.<timestamp>.md` with a comparison against the newest `FEATURE/evidence/baseline/pester-parallel.*.md`.
  - Acceptance: the artifact records `ExitCode`, each shard's exit code, the counts and the failure set read as P0-T5 reads them; every failed test of this run is in the baseline failure set, so there is no new failure; `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`, `COMPOUND_SUITE`, `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` and `tests/scripts/claude-hooks/enforce-docs-complete-gate-target.Tests.ps1` report zero failures; the artifact records the parallel-only waiver.
- [ ] [P2-T5] Read the line coverage of `HOOK` from the P2-T4 run, by the reading rule of P0-T5, without a further run, and write `FEATURE/evidence/qa-gates/coverage-delta.<timestamp>.md`.
  - Acceptance: line coverage of `HOOK` is at least 85%, recorded numerically with covered and missed counts beside the P0-T5 figure; the artifact states that the cycle changed no executable line of `HOOK`, shown by P1-T1's diff. No branch gate applies to Pester.
- [ ] [P2-T6] Run one `pytest -n auto` with the arguments of P0-T6, writing to `SCRATCH/issue-1034-coverage-final.json` and `SCRATCH/issue-1034-pytest-final.xml`, and write `FEATURE/evidence/qa-gates/pytest-parallel.<timestamp>.md` with a comparison against the newest `FEATURE/evidence/baseline/pytest-parallel.*.md`.
  - Acceptance: every failed or errored node ID of this run is in the baseline failure set, so there is no new failure; `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` reports zero failures; the artifact records the counts and the coverage totals beside the baseline as information, since no Python file changes.
- [ ] [P2-T7] Write `FEATURE/evidence/qa-gates/scope-check.<timestamp>.md` from the SHA-256 of `HOOK` and `HOOK_BUNDLE`, `git diff --name-only CYCLE_START HEAD`, `git diff MERGE_BASE HEAD` over the unchanged files of `## Execution Rules`, and `git status --porcelain`, re-deriving `MERGE_BASE` first.
  - Acceptance: the two SHA-256 values are equal; the paths changed since `CYCLE_START` outside `FEATURE/` are exactly `HOOK` and `HOOK_BUNDLE`, so `HELPER` and `HELPER_BUNDLE` are unchanged against `CYCLE_START`; `git diff MERGE_BASE HEAD -- .claude/hooks/hook-command-scanner.ps1 .claude/hooks/hook-command-invocation.ps1 .claude/hooks/hook-command-payload.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-payload.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1` is empty; `git status --porcelain` lists no path outside `FEATURE/`.
- [ ] [P2-T8] Re-evaluate criteria E1 and U2 of `## Acceptance Criteria Traceability` in `FEATURE/spec.md` and `FEATURE/user-story.md` under the review standard of this plan, and write `FEATURE/evidence/other/criteria-reevaluation.<timestamp>.md`.
  - Each criterion is checked off in its file only when its row is PASS; a FAIL row leaves the checkbox open and returns to the owning Phase 1 task. A checkbox edit changes only the bracket character of that line.
  - Acceptance: one PASS or FAIL row per criterion names its evidence among `limit-text-check`, `named-form-decisions`, `pester-parallel` and the cycle 3 artifacts `fail-before`, `gate-rows`, `bash-comparison` and `f4-f5-hook-process`, and lists each F6 group and N15 form with the limit-text phrase that names it; the physical line counts of `SPEC` and `STORY` are unchanged; each checked box has a PASS row.
- [ ] [P2-T9] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against the whole branch diff from `MERGE_BASE`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md`.
  - The artifact replaces the cycle 3 self-review under the newest-file selection rule and says so in `Output Summary:`. It records that N1 to N5 stay deferred, that N16 to N19 are untouched apart from the N17 outcome of P2-T1, and the `HELPER` wording difference of `## Out of Scope by Owner Decision`.
  - Acceptance: one PASS, FAIL or N/A row per checklist item and no FAIL row; a FAIL is fixed, the loop re-run from P2-T2, and the self-review rewritten.

## Acceptance Criteria Traceability

E1 is the first epic criterion under `## Acceptance Criteria` in both `SPEC` and `STORY` (gate disabled allows; enabled denies with the reason). U2 is the second story criterion under `## Acceptance Criteria` in `STORY` (enabled gate denies with a receipt reason code and allows a passing receipt).

| ID | Requirement | Implementation | Tests | Evidence |
|---|---|---|---|---|
| F6 | Both limit texts describe the scanner's view and name the comment, heredoc-opener, arithmetic and nested-quote forms | P1-T1, P1-T2 | P1-T3, P1-T4, P2-T4 | `limit-text-check`, `named-form-decisions`, `pester-parallel` |
| N15 | The five N15 forms are named in both limit texts | P1-T1, P1-T2 | P1-T3, P1-T4 | `limit-text-check`, `named-form-decisions` |
| N17 | The coverage path in the criterion names the folder that holds the figures, or the task records not applied | P2-T1 | P2-T1 | `self-review` |
| E1, U2 | Disabled allows; enabled denies with reason; each unmodelled form is named | P1-T1, P1-T2 | P2-T4, P2-T8 | `criteria-reevaluation`, `pester-parallel` |

## Pre-Mortem

- Review checklists: P2-T9 walks all three templates against the whole branch diff, and P2-T8 re-evaluates the three criteria the audit held open under the review standard the re-audit uses. P1-T4 confirms that each named form allows, so the text does not name a form that the hook in fact denies.
- Coverage: only comment-based help changes in `HOOK`, so no executable line changes; P2-T5 reads the `HOOK` figure from the single P2-T4 run and requires at least 85%. No Python file changes, so the pytest coverage totals are information only.
- Mirror parity: P1-T1 copies `HOOK_BUNDLE` in the editing task, and P0-T2 and P2-T7 compare the pair; P2-T6 runs `test_push_down_claude_resource_contracts.py` in the parallel pytest run. `SPEC` has no bundle copy, which P0-T2 confirms. No file is added, so no pack manifest changes, and no agent changes, so the Codex generator check is not needed. The plan changes no fact in the execution-environment brief, so no brief-update task is needed.
- File size: `HOOK` is 342 logical lines and gains a few help lines; P1-T1 requires fewer than 500, which keeps it in its current tier, and `FileSizePolicy.RepoGate.Tests.ps1` runs in P2-T4. `SPEC` edits stay inside existing physical lines, so its line count and the `## Acceptance Criteria` position are unchanged, which P1-T2, P2-T1 and P2-T8 assert. Markdown is exempt from the size tiers.
- Test isolation: the gates are one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run, each with a parallel baseline in Phase 0 and re-run only after a fix; no Jest test changes, so no Jest run is planned. No single-process, seeded-shuffle, reversed-order or ordering-comparison run is performed, under the owner's parallel-only directive, and P0-T5 and P2-T4 record that waiver. No test file is edited. The P1-T4 driver lives under `SCRATCH` and is not a test.
- CI-only behavior: no test or executable line changes, so no Linux-only or CI-only path is new. `COMPOUND_SUITE` keeps running in `poshqc / PowerShell hook suites (Linux)` and coverage in `poshqc / PowerShell QC`; the CI-dependent criterion of `SPEC` stays owned by the S9 CI gate after the pull request exists.
- Evidence: every artifact is under `FEATURE/evidence/<kind>/` with a write-time stamp and `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`. The Phase 0 parallel baselines are under `evidence/baseline/` as the owner directs, and the final comparisons name them by the newest-file rule. Runs under `SCRATCH` record that token rather than a host path, and the Poetry environment path is recorded relative to the worktree.
