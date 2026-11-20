# Code Review: Pre-Implementation Gate False Positives (Issue #1160), Re-audit After Remediation Cycle 4

**Review Date:** 2026-11-14
**Branch:** `bug/preimplementation-gate-false-positives-1160` @ `9cc48a9f4f0bd2ea914572776f5a7c4d7cc038d4` (PR #1174)
**Base:** `main`; merge base `f9e817b2ace9875b24f3df8ad27b97a4065a435e` (`git merge-base origin/main HEAD` after a fetch)
**Scope:** full branch diff, 148 files (PowerShell gate and sibling hooks with bundle copies, ten new Pester files, six brief copies, two orchestrate copies, two pack manifests, feature-folder records)
**Review standard:** owner directive OD-1 and spec decision D18 (policy-level standard for stage 2).

## Executive Summary

Cycle 4 resolves F3. Decision D19 changes the subcommand selection of `Test-OrchestrationGateMentionHostRecord` from "the first later token that does not start with `-`" to "the token directly after the command word, after transparent wrappers". A subcommand-scoped host with any option, option value, or attached `=value` form before its subcommand is no longer a mention host, so the stage-1 hit is confirmed, as at the merge base. The rule does not depend on knowing which options take a value, so it closes the whole class rather than the listed examples. The reviewer confirmed this with 40 ordinary runner invocations across all five subcommand-scoped hosts, including options that the plan did not list, and found no ordinary invocation that stage 2 declassifies. FP-01 to FP-17 remain unclassified on both surfaces.

No blocking finding. Seven non-blocking items follow: N1 to N5 carried from the third review, and two new informational items (N6, N7). N3 and N4 remain dispositioned out of scope under OD-1 / D18.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (N1) | `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` and its three copies | D17 | A hand-off through a host's own output-file option across statements, or through state left by an earlier call, stays outside the model, as D17 states. | None. | Recorded in D17; unchanged. | `spec.md` D17 |
| Info (N2) | same file | coverage | Two uncovered lines per measured copy, unchanged from cycle 3: the `break` after a PowerShell `-CommandWithArgs`, `-cwa`, or `-EncodedCommand` flag whose payload is the last word, and the `continue` after an Opaque NoPayload record without a governed word. Both copies are at 99.00%. | Optional: one modelled mention written with `-cwa` and the payload last. | Above every threshold; disclosed by the executor. | `evidence/qa-gates/coverage-comparison.2026-11-14T03-10.md`; reviewer parse of `powershell-coverage.xml` |
| Info (N3, out of scope under OD-1 / D18) | same file | `Get-OrchestrationGateMentionHostTable`, `npm` subcommands | `npm help --viewer=browser --browser=prettier lint` is unclassified at head and classified at the merge base. | None in this PR. | Using `npm help` as a launcher through its browser option is a further evasion variant, not an ordinary invocation of `prettier`. Disposition: out of scope under OD-1 / D18 (carried from the third review). | Third review, probe S01 |
| Info (N4, out of scope under OD-1 / D18) | same file | `ag` host | `ag --pager pytest x` is unclassified at head and classified at the merge base; `ag` ignores the pager when output is not a terminal. | None in this PR. | Not an ordinary invocation, and inert without a terminal. Disposition: out of scope under OD-1 / D18 (carried from the third review). | Third review, probe Q14 |
| Info (N5) | feature folder | `evidence/other/evidence-stamp-disclosure.2026-11-14T01-36.md` | Thirteen cycle 3 evidence filenames differ from their write minute by one minute; disclosed, not renamed. | None. | Append-only rule kept; no selection depends on the difference. | Disclosure file |
| Info (N6) | same file | `Test-OrchestrationGateMentionHostRecord`, the D19 line, `else { '' }` arm | No test drives the arm for a subcommand-scoped host word with no following token. It is reachable only as a non-carrying pipeline mate (for example `echo pytest \| npm`), where it returns `$false` (not a host) and the hit is confirmed. The executor disclosed this and corrected an inaccurate reachability statement through an appended `## Correction` section. | Optional: one row or case such as `echo pytest \| npm` with `Expected = $true`. | The arm fails closed: reviewer probe M14 (`echo pytest \| npm`) is classified at head and at the merge base on both surfaces. The line itself is covered, and Pester gates line coverage only. | `coverage-comparison.2026-11-14T03-10.md` `## Correction`; reviewer probe M14 |
| Info (N7) | same file | header comment, rule 3 | The D19 rewrap leaves one header comment line at 128 characters (`sort --compress-program, or a GNU abbreviation ...`), while neighbouring lines wrap near 95. | Optional: rewrap on the next edit of the sibling. | Cosmetic; formatter and analyzer report nothing. Changing it now would require a four-copy edit for no behavioural gain. | Reviewer line-width check of lines 25 to 35 |

No covered file is at or above 700 logical lines (largest: Codex gate 499, commands sibling 489, Claude gate 485); no file-size Warning row applies. No finding unrelated to issue #1160 was identified.

## Detailed Review

### F3 re-verification across the class

The change is one statement (`.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`, line 138):

```powershell
$subcommand = if ($wordIndex + 1 -lt $tokens.Count) { $tokens[$wordIndex + 1] } else { '' }
```

`$wordIndex` is the index returned by `Skip-CommandLineTransparentWrapper`, so wrappers such as `timeout 60` and `env` are skipped before the position is read. No listed subcommand starts with `-`, so any option before the subcommand yields a non-listed word and the record is not a host. This is fail-closed: D19 can only turn host records into non-host records, which only adds confirmations, and the classified set lies between the cycle 3 head set and the merge-base set (AC-3).

Reviewer probes on both surfaces (`Test-ImplementationCommand` at head, and with stage 2 forced to confirm, which equals the merge-base decision because stage 1 is unchanged):

- All 120 ED rows classified, FP-01 to FP-17 unclassified, NG-01 to NG-09 as expected: 0 mismatches.
- 40 runner invocations with an option before the subcommand. The 37 that hit stage 1 are classified at head. They cover every subcommand-scoped host and options outside the plan's list: `npm --cache search run lint`, `npm --userconfig help run lint`, `npm --registry view run lint`, `npm -w search exec prettier --check .`, `npm --prefix=search run lint`, `npm -s run lint`, `npm -ws run test:unit`, `pip --proxy show install black`, `pip --python list install ruff`, `pip --log-file show install pytest`, `pip --timeout list install pytest`, `pip --exists-action show install black`, `pip3 --cert freeze install pyright`, `poetry -C show run pytest -q`, `poetry --project=search run pytest`, `poetry -q run pytest`, `poetry --no-interaction run pytest`, `git --namespace log bisect run pytest`, `git --exec-path=log bisect run pytest`, `git -c core.pager=less log bisect run pytest`. Wrapped and compound forms are also classified: `timeout 60 npm -w search run lint`, `env npm --prefix help run lint`, `nice poetry -C search run pytest`, `time npm -w view run lint`, `python -m pip --cache-dir list install black`, `bash -c 'poetry -C search run pytest'`, `npm ls prettier; npm -w search run lint`, `grep -r pytest . | npm -w search run lint`. Three forms (`poetry --directory search install`, `npx -w search prettier --check .`, `pwsh -NoProfile -Command "npm -w search run lint"`) miss stage 1 at both head and merge base, so stage 2 does not affect them.
- 14 mention controls. `git log --grep pytest`, `git grep -n pytest`, `npm ls prettier`, `pip show pytest`, `poetry show pytest`, `timeout 60 npm ls prettier`, `npm view prettier version`, and `pip3 list | grep pytest` are unclassified at head. The stated D19 cost forms (`git --no-pager log --grep pytest`, `npm --silent ls prettier`, `pip -q show black`, `poetry --no-ansi show pytest`) and `git -C . log --grep pytest` are classified, as at the merge base. `echo pytest | npm` is classified (N6).
- Claude and Codex outputs are identical line for line.

F3 is resolved for the whole class: every subcommand-scoped host of the table, with any global option form before its subcommand.

### Discrimination of the D19 cases

The reviewer loaded the commands sibling in memory with the D19 statement replaced by four incorrect implementations and ran the four D19 cases against each:

| Mutant | `confirms ... option value` | `confirms ... global option before` | `clears ... directly after the command word` | `clears ... after a transparent wrapper` |
|---|---|---|---|---|
| cycle 3 loop (first non-option token) | killed | killed | survives | survives |
| skip a listed set of value-taking options | survives | killed | survives | survives |
| reject any option anywhere in the record | survives | survives | killed | survives |
| read token 1 instead of the token after the command word | survives | survives | survives | killed |

Each mutant is killed by at least one case, and the head implementation passes all four. The fail-before run (`evidence/regression-testing/fail-before-subcommand-position.2026-11-14T02-34.md`) shows exactly the 84 expected failures (ED-97 to ED-116 in both runners and the two `confirms` cases on both surfaces) and no other failure, so the new rows also discriminate.

### Bookkeeping leg

Unchanged since the first review; the final gate passes the leg suites on both surfaces.

### Tests

Cycle 4 appends ED-97 to ED-120 to the shared corpus (header comment updated to name D19) and adds `Context 'subcommand position (decision D19)'` with four cases to the commands suite; the suite diff adds 19 lines and removes none. No existing assertion changed. New rows and cases are pure strings with no mocks.

### Mirrors and documentation

The commands sibling has one SHA256 (`588836fb03c2dda9...`) across four copies and the bookkeeping sibling one (`55e6e9200b258924...`). Each gate file equals its bundle copy (`cmp`). The six brief copies share one SHA256 (`797b8bbd795206ff...`); each carries `decision D19` once and the D18 sentence once, and the cycle 4 diff of the brief touches only the #1160 bullet. The sibling header carries the D18 sentence once and names D19 in rule 3 and in the function help. The two orchestrate copies are unchanged and share one SHA256. D17, D18, and D19 are recorded in `spec.md` under `## Decisions`; the cycle 4 `spec.md` diff adds 7 lines and removes none.

### Security and correctness

The header and D18 state that this is a policy-level control and not a security boundary. F3 was judged and re-verified under that standard. No new construct found in this review needs the OD-1 / D18 out-of-scope disposition. No absolute path appears in any changed file or evidence artifact.

## Verification Performed

- `git -C <item worktree> diff <merge base>..HEAD` over the gate files, siblings, corpus, and suites; `git diff 25cc3ffce..HEAD` for the cycle 4 delta; `git diff --numstat` for the additive-change checks.
- Classification probes: the 146 corpus rows and 54 additional commands through `Test-ImplementationCommand` on the head Claude and Codex gates, at head and with stage 2 forced to confirm; identical decisions on both surfaces.
- Mutation probes: four in-memory mutants of the D19 statement against the four D19 cases.
- Coverage: reviewer parse of `artifacts/pester/powershell-coverage.xml` (root and per-file LINE counters) matched `evidence/qa-gates/coverage-comparison.2026-11-14T03-10.md`.
- `sha256sum` of the sibling, brief, and orchestrate copies; `cmp` of each gate file with its bundle copy; `grep -c` of `decision D19` and the D18 sentence; logical line counts of all 22 changed PowerShell files.
- `validate_evidence_locations.py --root <item worktree>`: exit 0.
- `gh pr view 1174`: head `9cc48a9f4`, `MERGEABLE`, CI jobs queued.

## Verdict

**PASS.** F3 is resolved across the class. No blocking finding. N1 to N7 need no change in this PR; N3 and N4 are out of scope under OD-1 / D18.
