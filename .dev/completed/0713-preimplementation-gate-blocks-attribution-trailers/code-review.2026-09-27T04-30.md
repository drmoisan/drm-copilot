# Code Review: Preimplementation Gate Attribution Trailers (#713)

**Review Date:** 2026-09-27
**Timestamp:** 2026-09-27T04-30
**Branch:** `bug/preimplementation-gate-blocks-attribution-trailers-713` @ `586e9037255b17d75c01d9c5f3e7b87b42aa4333`
**Base:** merge-base `2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d` (`origin/main`, the #718 merge of #710)
**Scope:** full branch diff (55 files). Production code: the four helper copies (one canonical edit, three byte copies). Test code: one new Pester suite. Documentation: two skill documents and their mirrors, plus the feature folder.
**Review emphasis (caller-directed):** security of the relaxation, and mirror byte-identity.

---

## Executive Summary

The change is small, well-anchored, and consistent with the spec's Security Argument. It has three parts:

- It admits `$` and backtick inside single-quoted spans only.
- It models `--trailer` on `git commit` through the existing `-m` value-consumption path.
- It adds `#` to the outside-quote deny set.

The helper line count is unchanged at 497.

**Security conclusion for the caller's question.** Under POSIX shell semantics, which is how the Claude `Bash` tool (Git Bash on this host) interprets commands, the relaxation opens no bypass of the preimplementation gate. This was verified by static analysis of the scanner state machines against POSIX 2.2.1 to 2.3 and by the 22 deny rows that pass on both runtimes:

- The single-quote exception applies only where POSIX guarantees literal text.
- `--trailer` values are never collected as pathspec operands.
- The `#` change strictly narrows the admitted set.

One conditional exposure remains (CR-1, Major, non-blocking). If the Codex runtime's `Bash` command text is interpreted by PowerShell, the Unicode single-quote characters U+2018 to U+201B desynchronize the scanner. The new single-quote `$` relaxation would then admit a hidden `$(...)` subexpression that the base denied. The repository does not establish which interpreter the Codex `Bash` tool uses on Windows, so this finding is recorded as conditional.

Separately, the review found a pre-existing, verified-by-analysis gate bypass through unquoted brace expansion in a pathspec operand (CR-2, Major, non-blocking). This branch did not introduce it.

**Mirror byte-identity.** Confirmed by reviewer recomputation:

- All four helper copies: SHA256 `9e84af141f7166f1be27a2e62b53437cb1537e1ac4230ccc054c11295af1bae7`, committed blob `c3510b7f`.
- `epic-plan/SKILL.md` pair: `69655fde...a13a65`, blob `d8878a9d`.
- `parallel-plan/SKILL.md` pair: `92577726...0ea762`, blob `5c560ad5`.

**Verdict:** APPROVE with non-blocking follow-ups. Blocking findings: 0.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (non-blocking, conditional) | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and three copies | `Test-OrchestrationCommandTextUnresolvable`, line 140 (`$openQuote -ne "'"` guard) | CR-1. The quote tracker recognises only ASCII `'` and `"`. PowerShell's tokenizer also treats U+2018, U+2019, U+201A, and U+201B as single-quote characters, and U+201C to U+201E as double-quote characters. For `git commit -m 'a’ $(Remove-Item src -Recurse) ‘b' -- docs/features/active/x/plan.md`, the scanner reads one single-quoted span from the first `'` to the last `'`, so the `$` is skipped and the line is exempt. PowerShell instead closes the first string at `’`, evaluates `$(...)` as an argument subexpression, and opens a new string at `‘`. On base, every `$` denied, so this exposure is introduced by the #713 relaxation. It applies only where command text reaches the helper and is then executed by PowerShell. The Claude surface is not affected (matcher `Bash`, executed by Git Bash). The Codex surface registers the gate on `^Bash$`. | Before or alongside merge, choose one: (a) treat U+2018 to U+201E as unresolvable in every quote state, for example by extending the existing escaped-quote early return with `IndexOfAny` over a new constant (about +1 line; 498 is within the cap), and add deny rows for both runtimes; or (b) verify and record in the spec that Codex `Bash` command text is always executed by a POSIX shell. Fold into the #710 shell-dialect follow-up, which also appears unfiled. | Spec S1 depends on the tracker agreeing with the executing shell about quote state. S4 enumerates POSIX constructs only, and S2 states that "the gate evaluates Bash commands only", a premise the repository does not verify for Codex. | Static trace of lines 131-160 against the example. PowerShell quote classes per the PowerShell language tokenizer (single-quote class U+0027, U+2018-U+201B). Not executed: the worktree-isolation guard denies `pwsh`, and the probe script stayed in the scratchpad. Codex matcher: `.codex/config.toml` lines 120-137. #710 precedent: `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/policy-audit.2026-09-27T02-55.md` line 341. |
| Major (pre-existing, non-blocking) | same four copies | `Test-ExemptOrchestrationOperand`, lines 257-275 | CR-2. Brace expansion is not modelled. The operand `docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts` contains no segment equal to `..` and no `*?[` wildcard, and it starts with `docs/features/active/`, so it is exempt. Bash expands it to eight copies of `docs/features/active/../../../src/prod.ts`, which git normalizes to `src/prod.ts`. `git add <that operand>` is therefore admitted with no ready checkpoint and stages a production file. The same code exists on base, so #713 neither introduces nor widens this. | File a separate issue. A line-neutral fix is to add `{` to `$script:OutsideQuoteCommandCharacters` (a quoted `{` is literal in bash, and git pathspecs do not interpret braces), with a regression row on both runtimes. | It violates the gate invariant stated in spec Security Argument ("an admitted command line stages or commits only paths inside the exempt trees"). | Reviewer ran `echo docs/features/active/{..,..}/{..,..}/{..,..}/src/prod.ts` in the Bash tool, which printed eight `docs/features/active/../../../src/prod.ts` words. The static trace through `Test-ExemptOrchestrationStagingCommand` finds no rejecting branch. The full gate path was not executed (the guard denies `pwsh`). |
| Minor | same four copies | `Test-ExemptOrchestrationStagingCommand`, lines 467-468 | CR-3. The inline comment "Row 12: interpolation anywhere, redirection outside quotes, and unmodelled backslash escapes" no longer matches the rule. Interpolation is now admitted inside single quotes, and `#` is now an outside-quote character. | Update the comment in the next change to this file; AC7 already permits it, and it is line-neutral. | Stale security comments mislead future reviewers of a fail-closed gate. | `git diff 2d9bb87c...HEAD` shows no hunk at those lines; `cat -n` lines 467-468. |
| Nit | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1` | deny and admit tables | CR-4. No row pins `--trailer` consuming a following `--` token. For example, `git commit -m x --trailer -- src/x.ts` is denied and `... --trailer -- docs/features/active/x/a.md` is admitted. The behaviour matches git's parse-options, which takes the next argv as a required option value, but it is untested. | Optionally add one deny row and one admit row when the suite is next edited. | It pins the helper's reading against git's argument parser for the new option. | Static trace of lines 402-408. |
| Info | helper copies | `--trailer` value | CR-5. Residual trailer command execution through `trailer.<key>.cmd` or `.command` configuration is outside the gate's control. The admitted line cannot set configuration: `-c` fails the case-sensitive `-C` selector check, and an env-prefix makes `Token[0]` not `git`. | None beyond the spec Risks entry. | Recorded for completeness; the spec already acknowledges it. | `evidence/baseline/p0-git-trailer-support.md` (`TRAILER_CONFIG: none`, git 2.53.0); helper lines 302, 364. |
| Info | branch history | commits `b93417c2` to `6747ee77` | CR-6. The six planning commits carry `Claude-Session` without `Co-Authored-By`, the defect this issue fixes. Commits from `8f621b60` onward carry both trailers. | None. Rewriting history is not warranted. | Demonstrates the defect and the fix on the branch itself. | `git log --format='%(trailers:only,unfold)' 2d9bb87c..HEAD`. |

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- **Constants block (line 36).** Renaming `RedirectionCommandCharacters` to `OutsideQuoteCommandCharacters` and adding `#` states the rule's actual scope. The accompanying comment explains why a quoted `#` is literal.
- **Line 140.** `$openQuote -ne "'" -and ...` is evaluated before the quote-state branch. For the opening `'` itself, `$openQuote` is still `0`, and for the closing `'` it is still `'`, but neither character is an interpolation character, so ordering does not matter. A `$` immediately after a closing `'` is evaluated with `$openQuote` already reset only on the next iteration. Trace: at the closing `'`, the interpolation check sees `'` (not interpolation), then the branch resets `$openQuote` to `0`. The following `$` is checked with `$openQuote = 0` and denies. Correct.
- **Line 402 and line 410.** `--trailer` joins the exact-match (`-ceq`) and `StartsWith('--trailer=')` branches, reusing the `$index += 2` guard. The dangling form reaches `return $false` at line 406. Abbreviations (`--trail`) and case variants (`--Trailer`) fall through to `return $false` at line 415. `git add --trailer` is rejected earlier by the subcommand guard at line 399.
- **Net-zero line delta.** The numstat is 16/16 per copy, so the 500-line cap holds whether or not sibling changes merge first (spec Merge-Order Independence).

#### API and safety notes

- **Scanner agreement (POSIX).** `Split-OrchestrationCommandLine` models backslash escapes outside single quotes (#710). `Test-OrchestrationCommandTextUnresolvable` does not, but it denies `\'` and `\"` anywhere and any backslash inside double quotes. The remaining backslash form outside quotes (`\x`, where `x` is not a quote) cannot change quote state. The two scanners and bash therefore agree on quote state for every line that reaches tokenization.
- **POSIX constructs that could desynchronize quote state.** Each is either modelled or denied:
  - `'` and `"`: modelled.
  - `$'` and `$"`: denied, because `$` is denied outside quotes.
  - Backtick: denied outside quotes and inside double quotes.
  - `<<`, `<<<`, `<(`: denied, because `<` is denied outside quotes.
  - `#`: now denied outside quotes.
  - `!` history expansion: disabled in non-interactive bash.
- **Carriage return.** `Split-OrchestrationCommandLine` splits on an unquoted CR, while bash treats CR as a word character. This makes the helper's per-segment reading stricter than bash, not looser. A merged bash invocation carries the second segment's words (`git`, `add`, `commit`) as extra pathspecs, which git rejects as non-matching. Pre-existing; no admitted escape found.
- **Non-POSIX interpreters.** See CR-1.

#### Error handling and logging

- Every new rejection path returns `$false` (allow-side-only exemption). The predicate's `try/catch` fail-closed wrapper is unchanged. No logging was added; none is required for a pure predicate.

---

## Test Quality Audit

- **Structure.** One `Describe -ForEach` over two runtime descriptors dot-sources each gate from `$PSScriptRoot`, so the changed lines execute in both canonical helper copies. The JaCoCo artifact shows `ci >= 1` on lines 36, 140, 156, 402, 406, 410, and 412 in both helper `<sourcefile>` entries.
- **Admit rows.** These assert the predicate first and then the decision seam with an explicitly not-ready checkpoint. An admit row the exemption rejects therefore never reaches the epic-scope read.
- **Deny rows.** These assert at predicate level (`Test-ExemptOrchestrationStagingCommand` false and `Test-ImplementationCommand` true) and never call the decision seam. This gives merge-order independence from #707 and #709 (spec D9).
- **Fail-before discipline.** Exactly ten names per runtime failed on the unmodified helpers, as predicted. The S4 desynchronization row failed before, which proves the pre-existing bypass by execution. Pass-before pins are documented with a D13 exception dossier.

### Reviewed test and QA artifacts

- `evidence/regression-testing/fail-before-attribution-trailer.md`: 48 passed, 20 failed, exit 1 as expected.
- `evidence/regression-testing/pass-after-attribution-trailer.md`: 68 passed, 0 failed.
- `evidence/regression-testing/fail-before-exception.2026-09-27T03-34.md`: D13 pins.
- `evidence/qa-gates/final-scoped-coverage.md`, `final-coverage-delta.md`, `final-pester-full.md`, `final-poshqc-format.md`, `final-poshqc-analyze.md`, `final-pytest-push-down.md`, `final-seven-stage-loop.md`.
- `evidence/qa-gates/mirror-parity-sha256.md`, `parity-and-legacy-contracts.md`, `test-portability-inspection.md`, `scope-boundary.md`.
- `artifacts/pester/powershell-coverage.xml` (re-read by the reviewer).

### Quality assessment prompts

| Question | Answer |
|---|---|
| Do the tests prove the defect and the fix? | Yes. The trailer, single-quote, and `#` rows fail on base and pass after the fix. |
| Do the deny rows cover every bypass class named in AC4? | Yes. There are 22 rows, including both heredoc recipes and `$'...'`. |
| Are there untested security-relevant branches? | The `--trailer` swallowing `--` case (CR-4, Nit). Unicode quote look-alikes (CR-1) and brace expansion (CR-2) are untested because the helper does not model them. |
| Are the tests hermetic? | Yes. No temp files, no git process, no `origin/` or gitignored state (portability inspection, matches=0). |

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| `$` and backtick literal only inside single quotes (POSIX 2.2.2) | PASS | Line 140 guard; deny rows 4 to 8 (double-quoted `$`, `$(...)`, backtick, heredoc recipe, `$'...'`). |
| No new path into operand collection | PASS | `--trailer` values are consumed at lines 402-414 and never reach `$operands`; after `--`, a `--trailer` token is an operand and fails the prefix test. |
| `--trailer` confined to `git commit` | PASS | Subcommand guard at line 399 runs before the option checks; deny row "a trailer option on the add subcommand". |
| `#` comment desynchronization closed | PASS | Line 36 and line 156; fail-before proves base admitted the S4 line on both runtimes. |
| Configuration-driven trailer execution cannot be enabled by an admitted line | PASS | `-c` fails the `-C` selector check (line 302); an env prefix fails the `Token[0] -cne 'git'` check (line 364). |
| Quote-state agreement with a PowerShell interpreter | PARTIAL (non-blocking, conditional) | CR-1. |
| Operand confinement under bash word expansion | PARTIAL (pre-existing, non-blocking) | CR-2 (brace expansion). |
| Four helper copies byte-identical | PASS | SHA256 `9e84af14...f1bae7` x4; blob `c3510b7f` x4. |
| Two skill-document pairs byte-identical | PASS | epic-plan `69655fde...` x2 (blob `d8878a9d`); parallel-plan `92577726...` x2 (blob `5c560ad5`). |
| Documentation matches behaviour | PASS | The skill subsection states the `--trailer` and multi-`-m` forms, the single-quote rule, the unquoted-`#` denial, and the non-admitted heredoc and `-F` forms. These match helper lines 36, 140, 156, and 402-414. |

---

## Research Log

- Read `spec.md` Security Argument S1 to S4, Decisions D1 to D13, Test Strategy, and Acceptance Criteria.
- Read the full post-change helper (497 lines) and the base helper (`git show 2d9bb87c:...`), and diffed the two.
- Read the gate command leg (`Test-ImplementationCommand`, lines 126-160) and the hook registrations. Claude: `.claude/settings.json` matcher `Bash`. Codex: `.codex/config.toml` matcher `^Bash$` for the command leg and `^(apply_patch|Edit|Write)$` for the path leg.
- Checked repository docs for the interpreter behind Codex `Bash` commands on Windows and found no record. Other Codex hooks accept both `Bash` and `shell_command` tool names.
- Confirmed bash brace expansion with a Bash-tool `echo`. PowerShell tokenization was not executed, because the worktree-isolation guard refused `pwsh`, and the refusal was not circumvented.

---

## Verdict

**APPROVE with non-blocking follow-ups.** Blocking findings: 0.

- CR-1: decide before or alongside merge, and record the disposition in the PR description.
- CR-2: file as a separate issue. It is a pre-existing bypass in the same predicate.
- CR-3 and CR-4: address in the next edit to the helper or suite.
