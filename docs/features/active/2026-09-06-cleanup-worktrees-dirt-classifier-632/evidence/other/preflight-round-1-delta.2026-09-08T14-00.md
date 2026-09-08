# Remediation cycle 2 — preflight round 1 delta

- Plan under review: `docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/remediation-plan.2026-09-08T06-51.md`
- Reviewer: `atomic-executor` (preflight mode), full-pass validation against the tree at `02150524`
- Signal: **PREFLIGHT: REVISIONS REQUIRED**
- Convergence: FURTHER ROUNDS LIKELY (D-1 and D-2 are design changes that propagate through D2, D3, P0-T7, P2-T1, P2-T3..P2-T9, P4-T3, P4-T4)

## Verified clean (no action)

Library at 463 lines and `cleanup_worktrees_lib.sh` at 496; the arithmetic-guard regex matches exactly 30 lines today; stub keys `rev-parse --verify --quiet` at `stub-bin/git:270-271`; membership test at `test_cleanup_worktrees_dirt_classify.bats:214-252` asserting `seen -eq 30` over 25 scenarios; `issue.md:12` is `- Work Mode: full-bug`; spec has 45 checkboxes, 0 unchecked; `main:$rel` count 1; `2>&1` count 1; `_shell-coverage.yml` carries `workflow_dispatch`; 11 push-down contract tests; `shell-qc.sh test` discovers `tests/shell` by directory; the integration branch exists; the six `dirt_unique` non-classifier files exist.

All five tabulated guard mutations were hand-traced through the ladder and the stub and produce HAS_UNIQUE to ALL_DISPOSABLE exactly as the plan states. P1-T5's expect-fail prediction including its positive control is correct. P2-T10's prediction is correct.

## Both planner departures SUSTAINED

1. **`rev-parse --verify --quiet main:$rel` over `ls-files --error-unmatch`.** `AD` means present in the index, absent from the worktree, so `ls-files --error-unmatch` exits 0 on exactly the entry the guard must catch. `diff --quiet main -- <path>` can only return 0 with the path absent from the worktree when the pathspec matches nothing in either tree, which is precisely the case `main:<path>` fails to resolve. The narrowing cannot suppress a legitimate `CONTENT_ON_MAIN`. Stub arm present; `sanitize` maps `main:staged_only.md` to `main_staged_only.md`.
2. **Three of four N2 fixtures need two files; one guard cannot be separated in the reviewer's named scenario.** For `dirt_classifier_read_error` with only `hash-object.notes.md.out` added, the mutated run reaches rung 4's untracked half with no `rev-parse.main_notes.md` fixture, so `mainblob` is empty and rung 5 has no fixture either — the entry lands on `UNIQUE` by a second route, not `CONTENT_ON_MAIN`. For `dirt_tracked_read_errors` the csproj entry is already `UNIQUE` via the rung-3 hard-read guard so the aggregate cannot move, and the per-file verdict does not change either because the mutated path hits `[[ -z $blob ]]`. Corrected counts 28 scenarios / 34 records verified (25+3, and 30+2+1+1); AC-8's `twenty-eight` is correct for the end state.

## Systemic gate — can fail, but does not enforce the claimed property

P2-T6's "the sed program actually changed the source" assertion plus P3-T7's clean-gate requirement mean a harness that never executed the mutated library could not reach a passing P3-T7. That half is sound. D-1 and D-2 negate the rest.

---

## Blocking defects

### D-1 BLOCKING — the enumeration excludes every guard shape that produced R1, R2, and R5

`remediation-inputs.2026-09-08T06-51.md` states the criterion as "every fail-closed guard and every non-empty guard" and asserts it "would have caught R1, R2, R5, N1, and all four sites in N2". The plan's arithmetic regex catches none of the three:

| Finding | Site (current tree) | Line |
|---|---|---|
| R1 Y-column gate | `if [[ $x != " " && $x != "?" && $x != "!" && $y == " " ]]; then` | 260 |
| R2 ` -> ` split gate | `if [[ ${xy:0:1} == R \|\| ${xy:0:1} == C ]]; then` | 403 |
| R5 diff-header skip | `"--- a/"* \| "+++ b/"* \| "--- /dev/null" \| "+++ /dev/null") continue ;;` | 172 |

It also excludes every "non-empty guard" the reviewer named by that phrase: `[[ -z $blob ]]` (311, the half that actually carried the verdict in cycle 1's `dirt_classifier_read_error`), `[[ -n $mainblob && $mainblob == "$blob" ]]` (321), `[[ -n $found ]]` (341), `[[ $verdict == "UNIQUE" ]]` (410), `[[ $agg != "ALL_DISPOSABLE" ]]` (447). Scope section 3 and AC-47 present the regex as the machine-enforced form of the criterion. It is roughly half of it, and the excluded half is the half this feature has actually shipped defects in. The count of 30 is a genuine mechanical count; the definition is under-inclusive for the property it is sold as enforcing.

Delta:

- Amend D2 to define the registry's coverage obligation as a superset: every line matching the arithmetic regex must be marked and registered (unchanged), and the registry must additionally carry a row for each of the eight named non-arithmetic verdict guards at cycle-start lines 172, 260, 311 (`[[ -z $blob ]]`), 321, 341, 403, 410, 447.
- Amend P2-T5's invariant to "every regex-matched line is marked; every marked line has at least one registry row; every registry row names a marked id", so the extra rows are legal.
- Because 311 carries two independent guards on one line, amend D2 so a marker line may back more than one row, with row identity `(id, mutation)` and each row's `mutation` pattern targeting its own sub-expression. State that two rows sharing a marker must have different `mutation` patterns.
- Rewrite AC-47 to describe the enumerated set actually enforced and to name R1's, R2's and R5's gate sites as covered, rather than claiming a general property the regex does not deliver.
- Update P0-T7, P2-T1, P2-T8, P2-T9 and P4-T4 arithmetic: guard-shaped count stays 30/31; registry row count becomes 31 + 8 = 39; P2-T9's table becomes 39 rows.

### D-2 BLOCKING — `EXEMPT` is satisfiable by editing the registry, and the observation channel forces genuine guards into it

P2-T8's acceptance is met by 26 rows of kind `EXEMPT` carrying boilerplate reasons; nothing requires a scenario to have been tried. The D3 channels are `DIRTSUM|` and the stub argv only, so guards observable through the other emitted records or the return code have no path to `SEPARATED`. Two verified worked examples:

- `((clrc != 0))` at 457, under `dirt_clear_clean_failed`: mutation flips `ACTION|dirt-clear|/repo-wt/dirt|FAILED` to `...|OK`. Argv identical, no `DIRTSUM|` involved. Forced `EXEMPT` despite being a live guard on an irreversible action.
- `((srrc != 0))` at 371: observable only as `classify_worktree_dirt`'s propagated exit code, the property AC-43 already pins. Forced `EXEMPT`.

Delta:

- Amend D3 so `SEPARATED` compares the function's full emitted record stream (`DIRTFILE|`, `DIRTSUM|`, and `ACTION|` lines) and its exit status, not the `DIRTSUM|` aggregate alone. Keep `ARGV` as the second channel. This moves 457 and 371 out of `EXEMPT`.
- Amend P2-T8 to require, for every non-`SEPARATED` row, that the `reason` column name the specific scenario tried and the specific channel observed to be identical.
- Amend P2-T9's acceptance to require the artifact to reproduce that scenario name for every `EXEMPT` row, so an unattempted classification is visible on the face of the evidence.
- Extend P2-T7 (which already pins the five remediated ids to `SEPARATED`) to also pin the three R1/R2/R5 gate ids added under D-1 to `SEPARATED` or `ARGV`, since cycle 1 proved each is separable.

### D-3 BLOCKING — the marker address is unanchored, so a prefix id mutates two lines

D2 fixes the sed program as `/# guard:<id>/s/.../.../`. That address matches every line whose marker begins with `<id>`. If P2-T1 assigns ids where one is a prefix of another, one row silently mutates two guards and per-guard attribution is lost. P2-T1's `uniq -d` check does not detect prefixes.

Delta: change the address in D2 and P2-T4 to `/# guard:<id>$/`, and add to P2-T1's acceptance that no marker id is a prefix of another, verified with a command the plan states.

### D-4 BLOCKING — P4-T5 asserts a seven-word prose phrase, the exact wrap-fragile class the planner corrected in P1-T7

``grep -c 'only when `main` contains the path' .claude/skills/cleanup-merged-worktrees/SKILL.md`` is a 34-character multi-word phrase inserted into an ~80-column prose file. If the sentence wraps, the line-oriented search returns 0 and the task cannot pass however correct the edit is. P1-T7 was fixed by anchoring to a short own-line heading; the sibling was left unfixed.

Delta: replace P4-T5's acceptance with a wrap-tolerant form, either

```
sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[[:space:]]*/ /g' .claude/skills/cleanup-merged-worktrees/SKILL.md | grep -c 'only when `main` contains the path'
```

reporting `1`, or a short single-line token the executor must write verbatim on its own line. P4-T6's mirror-parity `md5sum` check is unaffected.

---

## Non-blocking defects

### D-5 — `scripts/bash/cleanup_worktrees*` matches 7 files, not 8

The tree has `cleanup_worktrees_actions_lib.sh`, `_detached_lib.sh`, `_dirt_lib.sh`, `_enumerate_lib.sh`, `cleanup_worktrees_lib.sh`, `_report_records_lib.sh`, `_scan_helper.sh`. `cleanup-worktrees.sh` uses a hyphen and does not match the stated glob. P0-T6 and P5-T9 both demand an eight-row table.

Delta: state seven and the glob, or state eight and widen the glob to `cleanup[-_]worktrees*`. Use one choice in both tasks.

### D-6 — P5-T11's "the four ran consecutively with no intervening edit" is false as ordered

The contract stage is P4-T7, which runs before P4's own edits are followed by P5-T1's write-mode formatter. The stated order format, lint, test, contract does not match the executed order, and P5-T1's restart instruction does not re-run P4-T7.

Delta: amend P5-T11 to itself run `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` as the fourth stage, record its `EXIT_CODE:` and `11 passed` in the single-consecutive-pass artifact, and cite that run rather than P4-T7's artifact. This avoids renumbering P5-T4 through P5-T12.

### D-7 — P0-T4 and P5-T2 assert counts that the command never prints

`run_check` in `scripts/bash/shell_qc_lib.sh:164` runs `shfmt -d` then `shellcheck` per file and prints nothing at all on a clean run. There is no printed shfmt-diff or shellcheck findings count to read.

Delta: amend both tasks to record the command's combined stdout and stderr verbatim and to state that it is empty, alongside `EXIT_CODE:`. If numeric counts are wanted, state the derivation the executor must run.

### D-8 — D1's reachability enumeration is under-inclusive, and P1-T10 repeats the undercount

D1 names four scenarios. Three further tracked entries also reach the rung-4 tracked half and were not analysed: `dirt_build_artifact_added_file` (`A  src/Legacy/Legacy.csproj`), `dirt_staged_tree_no_match` (`M  src/a.cs`), `dirt_staged_tree_worktree_delta` (`MM src/a.cs`). All three supply `diff-quiet..<path>.rc` of `1`, so the conclusion that only `dirt_rename_split`'s `R ` entry reaches `drc == 0` is correct; the evidence backing it is not. P1-T10's acceptance says "the three scenarios whose `diff-quiet` fixture is non-zero" when six tracked entries carry one.

Delta: extend D1's reachability paragraph and P1-T10's acceptance to the full set of seven tracked entries, naming the three above with their `diff-quiet` values, and correct "the three scenarios" to the actual count.

### D-9 — P2-T4's no-temporary-file acceptance only greps `mktemp`

`grep -c 'mktemp'` reporting 0 is satisfied by a harness that writes to `$BATS_TEST_TMPDIR`, `$BATS_TMPDIR`, `/tmp/`, or via `tempfile`.

Delta: assert `grep -cE 'mktemp|tempfile|BATS_TMPDIR|BATS_TEST_TMPDIR|/tmp/|>[[:space:]]*"?\$\{?TMPDIR'` reports `0`.

### D-10 — P0-T3's digest predicate is narrower than the formatter's file set, and states no action on a difference

`discover_shell_scripts` accepts `*.sh` or any file under `tools`, `scripts`, `.claude/lib/bash` whose shebang resolves to `bash`/`sh`. The digest command uses `-name '*.sh'` only, so a rewrite of a shebang-only file is invisible to it. `StatusBefore:`/`StatusAfter:` covers tracked files and is the stronger observation, so this is a gap in the secondary check. Separately, P0-T3 requires the artifact to state whether the digests are equal but does not say what to do if they are not.

Delta: match the digest predicate to the discovery predicate, and add to P0-T3 that if the digests differ the artifact lists the rewritten paths and states, for each, whether it is in this cycle's scope.
