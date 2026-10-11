# Feature Audit: Exempt-operand bypass, per-segment epic-scope targets, trailer documentation, and Codex shell finding (#732, bundles #738, #745, #735)

**Audit Date:** 2026-10-09
**Branch:** `bug/exempt-operand-bypass-brace-and-dot-segments-exec-732` (local `c1b-732-resume`), head `d7b0d524ffe51819243946e632cb34eec0a36521`
**Feature folder:** `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732`

---

## Scope and Baseline

- **Base:** `origin/epic/enforcement-hook-precision-integration` (tip `5d9d88469f62327688aec48c182e40aebb71eb6d`); merge base `497cb504ad9a4e5435dc8946333ebc28baea50c4`. Epic mode: the PR targets the integration branch, not `main`.
- **Diff scope:** `git diff origin/epic/enforcement-hook-precision-integration...HEAD`, 117 files (14 production `.ps1` paths including mirrors, 15 Pester suites, 6 skill documents, 2 pack manifests, 80 feature documents and evidence files).
- **Work mode:** `full-bug` (`issue.md` line 12: `- Work Mode: full-bug`). AC source: `spec.md` only, section `## Acceptance Criteria`. No `user-story.md` exists, consistent with the mode.
- **PR context:** regenerated at review time (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, head `d7b0d524`). No PR exists yet for the branch.
- **Plan:** `plan.2026-10-08T13-53.md`, 129 of 129 tasks checked, 0 unchecked.
- **Baseline behavior:** at the merge base, both #732 operand shapes were exempt (fail-before evidence `evidence/regression-testing/fail-before-732.md`: 58 planned failures, including both shapes on both surfaces at helper and gate level). Epic-scope resolution read only the first `-C` of the first segment (`evidence/regression-testing/fail-before-738.md`: 20 planned failures). The targets file did not exist (`fail-before-exception.2026-10-09T04-01.md`, `git cat-file -e` exit 128).
- **Reviewer verification at HEAD:** Pester over 30 suites, 1042 passed, 0 failed; pytest contract suites, 32 passed; SHA-256 parity of every mirrored file; `validate_evidence_locations` exit 0; behavioral probes of the targets resolver and operand check (scratchpad only).

---

## Acceptance Criteria Inventory

Source: `spec.md`, `## Acceptance Criteria` (30 checkbox items; all 30 were already checked `[x]` at review start).

| ID | Group | Criterion (abridged) |
|---|---|---|
| AC-01 | #732 | OperandNormalization suite: both #732 shapes return `$false` on both copies; fail-before recorded |
| AC-02 | #732 | Same suite: every Test Strategy item 1 deny row returns `$false` on both surfaces; suite passes |
| AC-03 | #732 | Same suite: `$true` for each of five exempt trees, a `.` segment, and single-quoted `{ , ( @` messages |
| AC-04 | #732 | OperandBypass suites (Claude, Codex) pass and deny both shapes with `PREIMPLEMENTATION_GATE_BLOCKED:` |
| AC-05 | #732 | D4 row 18 and LACS allow 3 assert deny in both CommandExemption suites; suites pass |
| AC-06 | #732 | ChainEscape escaped-semicolon row asserts not exempt on both surfaces; suite passes |
| AC-07 | #732 | `Test-ExemptOrchestrationOperand` has no `\`-to-`/` rewrite or wildcard prefix branch; outside-quote set is exactly `> < # { } , ( ) @` |
| AC-08 | #732 | Helpers Parity suite passes (SHA-256 identity, at most 500 lines) |
| AC-09 | #738 | C1a API verification record precedes edits; targets file calls only those functions and not `Split-OrchestrationCommandLine` |
| AC-10 | #738 | Targets file in four roots; parity test; listed in both manifests and `SharedModuleNames` |
| AC-11 | #738 | Targets unit suite passes and covers every FR-3 rule on both copies |
| AC-12 | #738 | Claude EpicScopeTargets gate-level rows pass |
| AC-13 | #738 | Codex epic-scope-targets rows pass, including `apply_patch` and no-`-C` session root |
| AC-14 | #738 | Every new epic-scope deny begins with the prefix and carries one of four reason codes |
| AC-15 | #738 | Existing epic-scope, operand-resolution, worktree-resolution, and `claude-lib/worktree-resolution` suites pass; changed assertions recorded as D3 intended changes |
| AC-16 | #745 | `.agents` epic-plan skill and mirror document the Integration Commit Form; files identical; resource-contract suite passes |
| AC-17 | #745 | Quoting-rule text in all six skill files states the backslash rule, `{ } , ( ) @`, and the operand character set |
| AC-18 | #745 | AttributionTrailer suite has the `--trailer --` admit and deny rows; passes |
| AC-19 | #745 | Same suite has U+201A, U+201B, U+201E deny rows; passes |
| AC-20 | #745 | Helpers backslash test and every added or changed helpers line at most 120 characters; scan recorded |
| AC-21 | #745 | Spec records D5 heredoc decision with rationale |
| AC-22 | #735 | Research Q1 records the Codex Windows shell finding and evidence table |
| AC-23 | #735 | Research commit precedes the first commit modifying Codex hooks |
| AC-24 | #735 | Header comments of the four helpers copies and the Codex gate (and mirror) cite #735 and state the rules; Codex gate states `workdir` absence and session-root default |
| AC-25 | Cross-cutting | Diff lists no modes, invocation, or scanner file |
| AC-26 | Cross-cutting | Legacy Codex contracts and five pytest push-down/manifest suites pass |
| AC-27 | Cross-cutting | No added or changed hook file is Python or invokes `python`, `python3`, `py`, `poetry`; content search recorded |
| AC-28 | Cross-cutting | Every added or changed production and test file at most 500 lines; counts recorded |
| AC-29 | Cross-cutting | Direct PoshQC run records line coverage >= 85% for every added or changed file under `.claude/hooks`, `.claude/lib`, `.codex/hooks`; artifact and baseline recorded |
| AC-30 | Cross-cutting | PowerShell toolchain single clean pass recorded |

---

## Acceptance Criteria Evaluation

| ID | Verdict | Evidence (reviewer-verified unless marked executor) |
|---|---|---|
| AC-01 | PASS | Reviewer run: `OperandNormalization` 76 passed (both surfaces via `-ForEach`). Fail-before: `fail-before-732.md` lines 25-26 and 49-50 (brace and escaped-dot shapes FAILED on Claude and Codex copies). |
| AC-02 | PASS | Same run, 0 failures; fail-before lists 24 deny rows per surface failing at baseline; probes confirm glob, `..`, and rooted operands deny. |
| AC-03 | PASS | Same run; allow rows for the five trees, the `.` segment, and single-quoted `{`, `,`, `(`, `@` messages pass. Probe: `docs/features/active/./x/a.md exempt=True`. |
| AC-04 | PASS | Reviewer run: Claude `OperandBypass` 2 passed, Codex `operand-bypass` 2 passed; both failed at baseline (`fail-before-732.md` lines 73-76). |
| AC-05 | PASS | Reviewer run: Claude `CommandExemption` 119 passed, Codex `command-exemption` 119 passed; the reversed rows failed at baseline (fail-before summary: 2 D4 row 18 and 2 LACS allow 3 rows). |
| AC-06 | PASS | Reviewer run: `ChainEscape` 38 passed; 2 ChainEscape rows failed at baseline. |
| AC-07 | PASS | Reviewer read of `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`: `Test-ExemptOrchestrationOperand` contains no `-replace '\\', '/'` and no `IndexOfAny($script:PathspecWildcardCharacters)`; line 40 is `$script:OutsideQuoteCommandCharacters = [char[]]@('>', '<', '#', '{', '}', ',', '(', ')', '@')`. |
| AC-08 | PASS | Reviewer run: helpers `Parity` 2 passed; reviewer `sha256sum` of four copies: one value `67a1105a...`; 470 lines each. |
| AC-09 | PASS | `evidence/other/c1a-api-verification.md` added in `95261799`, before `22c31355` (targets file) and `4dd2231d` (epic-scope edits). Reviewer `grep` of the targets file for `Split-OrchestrationCommandLine` and `ConvertTo-OrchestrationCommandToken`: 0 matches; external calls are `Read-CommandLineSegment`, `Get-CommandLineGlobalOption`, `Get-CommandLineInvocation`. |
| AC-10 | PASS | Reviewer `sha256sum`: four targets copies identical (`9b9b9137...`), 328 lines. `targets.Parity` 2 passed. Both `core.json` files list the file; `SharedModuleNames` includes it (diff). Legacy contracts 43 passed. |
| AC-11 | PASS | Reviewer run: `targets.Tests` 84 passed across both copies; rows cover path leg, unbalanced, directory change, wrapper and substitution, `GIT_*` and `--git-dir`/`--work-tree`, repeated `-C`, relative and dot-segment `-C`, and no-`-C` session root. |
| AC-12 | PASS | Reviewer run: `EpicScopeTargets` 12 passed; rows match the AC list (second-segment not-ready, repeated `-C`, relative, unresolvable, `cd`, wrapper-led, Write path, all-ready allow, single-feature unchanged). See Gaps G-A for UNC path-leg spellings, which no AC row names. |
| AC-13 | PASS | Reviewer run: Codex `epic-scope-targets` 13 passed, including the `apply_patch` absolute marker deny and no-`-C` session-root resolution. |
| AC-14 | PASS | Gate-level rows assert `StartsWith('PREIMPLEMENTATION_GATE_BLOCKED: ')` and `Contains($Code)` for `target-not-ready`, `target-unresolvable`, `target-mixed`, `target-ambiguous`; `Get-OrchestrationEpicTargetDenyReason` builds `PREIMPLEMENTATION_GATE_BLOCKED: <code>: ...`. |
| AC-15 | PASS | Reviewer run: Claude `EpicScope` 21, `OperandResolution` 10, `WorktreeResolution` 15; Codex `epic-scope` 53, `epic-resolution` 48; 10 `claude-lib/worktree-resolution` suites 254; 0 failures. The two changed assertions are listed in `evidence/other/d3-intended-changes.md` (written at P3-T1, before the edits). |
| AC-16 | PASS | `## Integration Commit Form` present in `.agents/skills/epic-plan/SKILL.md` with the three forms; reviewer `sha256sum` identical to the bundle mirror; `test_push_down_codex_and_agents_resource_contracts.py` passed in the reviewer pytest run. |
| AC-17 | PASS | Reviewer `grep -l "Quoting rules"` finds exactly the six files; diff shows each states "a backslash anywhere in the command line is denied", "`{`, `}`, `,`, `(`, `)`, and `@` are denied outside quotes", and "`A-Z a-z 0-9 . _ / -`". Mirrors identical. |
| AC-18 | PASS | Diff adds `git commit -m x --trailer -- docs/features/active/x/a.md` to the admit table and `git commit -m x --trailer -- src/x.ts` to the deny table; reviewer run `AttributionTrailer` 84 passed. |
| AC-19 | PASS | Diff adds deny rows with `[char]0x201A`, `[char]0x201B`, `[char]0x201E`; same run passed. |
| AC-20 | PASS | `evidence/qa-gates/final-line-length.md`: `BACKSLASH_TEST_LENGTH` 107 on all four copies; longest added line 31 characters per the R-LINELEN definition; OVER_120 0. Reviewer `awk` finds the only over-120 helpers line is line 83 (144 characters), which is unchanged from the base (the former line 78, optional under D7). |
| AC-21 | PASS | `spec.md` Decisions table row D5 records "Heredoc-fed commit messages are deferred" with rationale. |
| AC-22 | PASS | `research/research.2026-10-08T14-00.md` line 27: `## Q1. #735: Which shell OpenAI Codex uses to execute commands on Windows`, with an evidence table. |
| AC-23 | PASS | Research added in `c03837d0`; first Codex-hook commit on the branch is `64a9ac52`; `git merge-base --is-ancestor c03837d0 64a9ac52` exit 0. |
| AC-24 | PASS | Helpers header (all four copies, identical) lines 12-15 cite #735, the undetermined shell, and the deny rule; Codex gate (and identical mirror) `.DESCRIPTION` states the same plus "The payload carries no workdir either, so the session root is the default target". |
| AC-25 | PASS | Reviewer `git diff --name-status ...HEAD` lists no `-modes.ps1`, `hook-command-invocation.ps1`, or `hook-command-scanner.ps1` path. |
| AC-26 | PASS | Reviewer run: legacy contracts 43 passed; pytest five suites 32 passed. |
| AC-27 | PASS | `evidence/qa-gates/final-no-python.md` (executor R-NOPY); no `.py` in the changed hook paths (reviewer name list); reviewer `grep -i python|poetry` of the targets file: no match. |
| AC-28 | PASS | `evidence/qa-gates/final-line-counts.md`; reviewer `wc -l`: maximum 497 among changed files. |
| AC-29 | PASS | `evidence/qa-gates/final-pester-full.md`: seven package-join matches, 98.11%-100.00%; baseline `evidence/baseline/p0-pester-full.md` and `p0-coverage.md`. Reviewer bound the run to HEAD (policy audit binding note) and read 85.89% repo-wide from the same XML. |
| AC-30 | PASS | `evidence/qa-gates/final-toolchain-loop.md`: pass 3 clean (format 0 changed, analyze 0 issues, scoped tests 1604/0, coverage delta 0 fail rows). Reviewer analyzer and formatter checks agree. |

---

## Summary

All 30 acceptance criteria evaluate PASS. The two #732 bypass shapes are denied at helper and gate level on both surfaces, with recorded fail-before runs. Epic-scope decisions now resolve every segment and path target, and new denies carry stable reason codes. Documentation and the #735 header findings are in place. Toolchain, coverage, parity, and line-cap constraints are met.

### Gaps (all Non-blocking)

- **G-A (FR-3 rule 1, UNC path leg).** FR-3 rule 1 states that an absolute `file_path` contributes its own path. The implementation treats UNC (`\\server\share\...`) and extended-length (`\\?\C:\...`) spellings as relative and contributes the session root (code review CR-1; reviewer probe). No acceptance criterion names these spellings, the behavior equals the pre-change behavior, and plan rule R1 defined "absolute" to exclude them. Recommendation: deny such spellings as `target-unresolvable` in epic scope, or record a follow-up candidate FU-6 beside FU-1.
- **G-B (#745 rows not fail-before).** Test Strategy states that all new or changed rows are fail-before. The AttributionTrailer rows (AC-18, AC-19) passed at baseline (`fail-before-732.md` summary: "All 10 section-5.4 TRAILER tests are PASSED"). They pin behavior the gate already had, which is what #745 asked for; the AC wording does not require a failing run.
- **G-C (branch currency).** The integration branch advanced 35 commits after the merge base. `git merge-tree` is clean. Merge the integration tip before opening the PR so CI runs on the merged tree.
- **G-D (follow-ups unfiled).** FU-1 to FU-5 are recorded in `evidence/other/follow-ups.md` and intentionally not filed, per the spec.

### Blocking count

- FAIL: 0
- Blocking PARTIAL: 0
- Total blocking (this artifact): 0

---

## Acceptance Criteria Check-off

All 30 items in `spec.md` were already `[x]` at review start (checked by the executor at P8-T31, `evidence/other/ac-checkoff.md`). The reviewer evaluated each as PASS, so no item required a change and no item was unchecked. No new items were checked off by this review, and `spec.md` was not modified.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-27-exempt-operand-bypass-brace-and-dot-segments-732/spec.md`
- Total AC items: 30
- Checked off (delivered): 30
- Remaining (unchecked): 0
- Items remaining: none
