# 2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding (Remediation Plan, Cycle 2)

- **Issue:** #543
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-07
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** full-bug
- **Branch:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`
- **Requirements source:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-inputs.2026-10-02T07-08.md`, finding R1 (PA-5, CR-10; Blocking, autonomous) and optional item N1 (PA-3), both applied in this cycle. Acceptance criterion source: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`, `## Acceptance Criteria`; all 20 criteria are PASS and checked, and this plan does not touch them.
- **Supporting inputs:** `policy-audit.2026-10-02T07-08.md`, `code-review.2026-10-02T07-08.md`, `feature-audit.2026-10-02T07-08.md`, and the cycle-1 plan `remediation-plan.2026-10-02T05-58.md`, all in the same feature folder.

**Scope statement:** Evidence-only remediation of one Markdown file, `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`. R1 replaces the composed value on the row under `### Reset 1 (P2-T4)` and adds one correction line. N1 replaces the reused value on the line-3 header row and adds one correction line. The file is not renamed, the recorded command is not re-run, and no other pre-existing file changes. No production file, test file, guidance file, `spec.md` checkbox, or audit artifact is edited. Final QC is evidence-only because no code changes: the evidence-location validator, the scope check, the `spec.md` checkbox counts, and the plan validator. The plan stops and reports on any failed stop condition.

**Fail-closed evidence rule:** Every evidence-producing task names its artifact. A task stays unchecked while its artifact is absent, incomplete, or carries a placeholder in place of an observed value. A failed stop condition makes the cycle outcome BLOCKED, never PASS.

**Evidence location:** All new evidence resolves under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/<kind>/`, with `<kind>` drawn from `remediation-baseline`, `other`, and `qa-gates`. No artifact of this plan is written under `evidence/regression-testing/` or any `artifacts/` evidence path. Cycle-1 artifacts, including `evidence/remediation-baseline/phase0-instructions-read.md`, are not overwritten; this cycle writes new, timestamped files.

---

## Decisions fixed by this plan

1. **R1 applied by content match.** The R1 edit locates the row by the literal `Timestamp: 2026-10-02T05-30` (unique in the file at planning time: line 31, under `### Reset 1 (P2-T4)`). The R1 table in the inputs names line 31 for the pre-N1 file; after N1 is applied the row sits on line 32. Both edits are performed with the Edit tool on literal text, never by line number. Corrected value: `2026-10-02T05-18` (the reviewer-observed write time 05:18:16, floored to the minute; fixed by the inputs, not recomputed).
2. **N1 applied.** Both audits recommend applying N1 together with R1, and this cycle's delegation requires it. The line-3 literal is `Timestamp: 2026-10-02T05-01` (unique in the file; the filename suffix `05-01` is not a `Timestamp: ` row). The other 17 `evidence/baseline/` artifacts that share the `05-01` reading remain out of scope (inputs, Non-blocking Items, N1).
3. **Correction-line text is fixed by the inputs.** R1 line: `Timestamp-Correction: original value 2026-10-02T05-30 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the command run time.` N1 line: `Timestamp-Correction: original value 2026-10-02T05-01 was a reused reading rather than a clock reading for this artifact; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the write time.` Each is inserted directly below its `Timestamp:` row, and no third `Timestamp:` row is added.
4. **Expected counts, re-derived against the current tree (2026-10-07).** The current tree contains 78 Markdown files under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/`. Each carries exactly one line beginning `Timestamp:`, except `evidence/other/python-batch-budget.2026-10-02T05-01.md`, which carries two (lines 3 and 31); that is 79 rows in 78 files. Exactly 35 files carry one line beginning `Timestamp-Correction:` (the 35 cycle-1 R2 artifacts under `evidence/regression-testing/` and `evidence/qa-gates/`), and `evidence/other/` carries none. No evidence line ends with a carriage return (a search for a trailing `\r` in the target file returned no match). Consequences:
   - Before the edits, the command `grep -rc "^Timestamp:" <evidence>/ | grep -v ":1$"` prints exactly one line, the python-batch-budget file with count 2. After the edits it still prints exactly that one line (the edits replace values; they add no `Timestamp:` row).
   - Before the edits, `grep -rc "^Timestamp-Correction:" <evidence>/ | grep -c ":1$"` prints `35`. After R1 and N1, the python-batch-budget file carries two correction lines, so the file count with exactly one stays `35`, not the inputs' pre-N1 figure of 36, and `grep -rc "^Timestamp-Correction:" <evidence>/ | grep ":2$"` prints exactly one line, the python-batch-budget file. The inputs' alternative figure (36 without N1) does not apply because N1 is applied.
   - New artifacts written by this plan each carry exactly one line beginning `Timestamp:` (the header row) and no line beginning `Timestamp-Correction:`, so they do not change any count above (see Execution notes, content restriction).
5. **Whole-file row scan (inputs R1 step 5).** The inputs ask for a scan of every `Timestamp:` row, not only the first row per file. The mechanical derivation of "later than the file's write time" used here is a comparison of each row's value with the minute of the author time of the last commit that touched the file at the pinned start SHA (`git log -1 --date=format-local:%Y-%m-%dT%H-%M <start SHA> -- <path>`). A file is written before it is committed, so a row value later than that commit minute is later than the write time. The reviewer's own observation for the R1 row (write 05:18:16, last commit `af88dd58` at 05:19:12) shows the same ordering. The scan script `rows_543.py` (below) applies the rule to every row of every evidence file that exists at the start SHA and lists files created during this cycle separately (their values are host-clock readings). The commit time is an upper bound only, so a passing scan establishes that no row is composed later than its commit; it cannot detect a composed value that is earlier than the commit. This limit matches the reviewer's own observation method for write times. Pre-edit expectation: exactly one LATE row, the R1 row.
6. **D4 anchors.** The branch now contains the merge commit `592c91ea` of `origin/main` at `f6ef5b2f`. Anchored diffs in this plan use the literal start SHA recorded by P0-T2 (a descendant of `f6ef5b2f`, equal to `592c91ea` unless the orchestrator has since committed plan files) and the merge parents `592c91ea^1` and `592c91ea^2`; none uses `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd` as the comparison base for a production-file check. P0-T3 verifies the D4 claim that the merge-changed files and the branch-changed files since `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd` do not intersect.
7. **No Prettier task.** The repository formats with Prettier only for TypeScript, JavaScript, and JSON globs (`package.json` at the worktree root, line 32, `format:check`: `"src/**/*.{ts,tsx,js,mjs,cjs,json}"` and the listed config files; `extensions/drm-copilot/package.json` line 207, `format`, the same kind of globs). Markdown is not in any Prettier glob, so a Prettier check of the edited Markdown file would test nothing and is not included.
8. **No full Python or Jest suites.** No production or test file changes, so no unit, lint, type, architecture, or coverage gate applies. The final QC set is the evidence-location validator, the scope check, the `spec.md` counts, and the plan validator.
9. **Commit boundaries are orchestrator-owned.** The delegation forbids committing. The executor runs no `git add`, `git commit`, or `git push`; each phase ends with a boundary note naming the commit message the orchestrator uses.

## Fixed edit text (Phase 1)

R1 edit (Edit tool, `replace_all` false): in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`, replace the line

```text
Timestamp: 2026-10-02T05-30
```

with these two lines:

```text
Timestamp: 2026-10-02T05-18
Timestamp-Correction: original value 2026-10-02T05-30 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the command run time.
```

N1 edit (Edit tool, `replace_all` false): in the same file, replace the line

```text
Timestamp: 2026-10-02T05-01
```

with these two lines:

```text
Timestamp: 2026-10-02T05-18
Timestamp-Correction: original value 2026-10-02T05-01 was a reused reading rather than a clock reading for this artifact; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the write time.
```

Expected post-edit rows in that file: line 3 `Timestamp: 2026-10-02T05-18`; line 4 the N1 correction line; line 32 `Timestamp: 2026-10-02T05-18`; line 33 the R1 correction line (the N1 insertion moves the R1 row from line 31 to line 32).

## Constants

- Start state: the worktree HEAD at the start of this cycle is `592c91ea` (merge of `origin/main` at `f6ef5b2f`). P0-T2 records the full 40-character SHA, referred to below as the start SHA.
- Pre-merge comparison base from cycle 1 (D2 of the original plan): `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`. It is used only by the P0-T3 intersection check.
- Target file: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`.
- Evidence tree: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/`.

## Execution notes

- **Shell.** No PowerShell is in scope: no `pwsh`, no `sh` wrapper, no `.sh` script. Heredocs and `cmd; echo` chains are refused, so every command runs alone from the worktree root. Pipelines of two `grep` commands (as written in the inputs) are permitted. Multi-line `poetry run python -c` is a no-op; each Python helper is a scratchpad `.py` file run with `poetry run python <scratchpad>/<name>.py` from the worktree root. `<scratchpad>` is the executor session's scratchpad directory, outside the repository.
- **Clock.** Every new artifact's `Timestamp:` value is read with `date +%Y-%m-%dT%H-%M` immediately before the recorded command runs (for an artifact that records no command, immediately before writing it). The same value is the artifact's filename `<ts>`. A reading is never reused across tasks and never composed or estimated.
- **Artifact fields.** Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is non-zero also carries `ExpectedExitCode: <int>`. One artifact carries one expectation, so each command has its own artifact.
- **Content restriction on new artifacts.** In every artifact written by this plan, the only line that begins with `Timestamp:` is the header row, and no line begins with `Timestamp-Correction:`; quote correction text inside backticks or after other text on the line, and quote grep output with its `path:line:` prefix. The count checks in P0-T5, P0-T6, P1-T6, P1-T7, and P1-T8 depend on this.
- **Edits.** The two edits to the target file use the Edit tool only. No other pre-existing file is edited, except the checkboxes of this plan.
- **Stops.** A stop condition means: do not run later tasks, leave the failed task unchecked, and report the task ID, the command, and its output to the orchestrator. Do not retry an Edit task after it succeeded.
- **Hooks.** If a hook denies a command, stop and report; do not route around it.
- **Commit boundaries (orchestrator).** The orchestrator commits and pushes after each phase using `git add -A -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543` and a commit message file. Suggested messages: after Phase 0 `docs(543): record remediation cycle 2 baselines`; after Phase 1 `docs(543): correct residual composed timestamps in python-batch-budget evidence`; after Phase 2 `docs(543): record remediation cycle 2 final verification`. Each message ends with the attribution trailer required by the session.

## Scratchpad scripts (write verbatim)

`<scratchpad>/d4_check_543.py` (P0-T3):

```python
"""Verify the D4 merge-adaptation claim for issue 543: no overlap of merge-changed and branch-changed files."""

import subprocess
import sys

MERGE = "592c91ea"
MAIN = "f6ef5b2f"
OLD_BASE = "ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd"


def git_lines(*args):
    result = subprocess.run(
        ["git", *args],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return [line for line in result.stdout.splitlines() if line]


def main():
    parents = git_lines("rev-parse", MERGE + "^1", MERGE + "^2")
    main_sha = git_lines("rev-parse", MAIN)[0]
    second_is_main = len(parents) == 2 and parents[1] == main_sha
    print(f"PARENTS first={parents[0]} second={parents[1]} main={main_sha} second_is_main={second_is_main}")
    branch_changed = set(git_lines("diff", "--name-only", OLD_BASE, MERGE + "^1"))
    merge_changed = set(git_lines("diff", "--name-only", MERGE + "^1", MERGE))
    overlap = sorted(branch_changed & merge_changed)
    for path in overlap:
        print(f"OVERLAP {path}")
    print(
        f"SUMMARY branch_changed={len(branch_changed)} "
        f"merge_changed={len(merge_changed)} intersection={len(overlap)}"
    )
    return 0 if second_is_main and not overlap else 1


if __name__ == "__main__":
    sys.exit(main())
```

`<scratchpad>/rows_543.py` (P0-T7, P1-T9). Argument: the start SHA from P0-T2.

```python
"""Compare every evidence Timestamp row with commit times for issue 543 (remediation R1 step 5)."""

import os
import re
import subprocess
import sys

FEATURE = "docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543"
DATE_FORMAT = "--date=format-local:%Y-%m-%dT%H-%M"
VALUE = re.compile(r"\d{4}-\d{2}-\d{2}T\d{2}-\d{2}")


def last_commit_minute(ref, path):
    result = subprocess.run(
        ["git", "log", "-1", "--format=%ad", DATE_FORMAT, ref, "--", path],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return result.stdout.strip()


def evidence_files():
    found = []
    for folder, _, names in os.walk(FEATURE + "/evidence"):
        for name in names:
            if name.endswith(".md"):
                found.append(os.path.join(folder, name).replace("\\", "/"))
    return sorted(found)


def timestamp_rows(path):
    with open(path, encoding="utf-8", newline="") as handle:
        lines = handle.read().split("\n")
    rows = []
    for number, line in enumerate(lines, start=1):
        if line.startswith("Timestamp:"):
            rows.append((number, line[len("Timestamp:"):].strip()))
    return rows


def main():
    if len(sys.argv) != 2:
        print("usage: rows_543.py <start-sha>")
        return 2
    ref = sys.argv[1]
    old_files = old_rows = new_files = new_rows = late = bad = 0
    for path in evidence_files():
        last = last_commit_minute(ref, path)
        rows = timestamp_rows(path)
        if not last:
            new_files += 1
            new_rows += len(rows)
            for number, value in rows:
                print(f"NEWROW {path}:{number} value={value}")
            continue
        old_files += 1
        old_rows += len(rows)
        for number, value in rows:
            if not VALUE.fullmatch(value):
                status = "BAD-FORMAT"
                bad += 1
            elif value > last:
                status = "LATE"
                late += 1
            else:
                status = "OK"
            print(f"ROW {path}:{number} value={value} last_commit={last} {status}")
    print(
        f"SUMMARY old_files={old_files} old_rows={old_rows} late={late} bad={bad} "
        f"new_files={new_files} new_rows={new_rows}"
    )
    return 0 if late == 0 and bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
```

## Plan Deviations

D4 merge-adaptation: origin/main f6ef5b2f merged into the item branch as 592c91ea on 2026-10-07; the intersection of merge-changed files and branch-changed files since ef80c57d is empty; anchored git diffs use base f6ef5b2f (or HEAD~ refs) instead of ef80c57d.

Basis and handling: the claim of an empty intersection is supplied by the coordinator and is re-verified by task P0-T3 before any edit, using `592c91ea^1` and `592c91ea^2` as the merge parents. Where this plan needs a diff anchor it uses the literal start SHA from P0-T2, which descends from `f6ef5b2f` (P0-T2 checks the ancestry). D1 to D3 and D-TIMESTAMPS of the original plan are unaffected and are not re-recorded here.

---

### Phase 0 — Policy reads and remediation baseline capture

No language toolchain baseline applies: this plan changes one Markdown evidence file and runs one Python evidence validator, and no Python, TypeScript, or PowerShell source is touched. The baselines below capture the states that the Phase 1 edits change.

- [ ] [P0-T1] Read the policy files in `policy-compliance-order` order and write `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/phase0-instructions-read.<ts>.md`.
  - Files, in order: `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/tonality.md`; `.claude/rules/plan-acceptance-gates.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`; then the requirements input `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-inputs.2026-10-02T07-08.md`.
  - Acceptance: the artifact exists with `Timestamp:` (host clock), `Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> quality tiers -> tonality -> plan acceptance gates -> evidence conventions`, and `Files Read:` listing the eight files above in that order. It states that no language-specific rule applies because no source file changes. The cycle-1 file `evidence/remediation-baseline/phase0-instructions-read.md` is not modified. No Phase 1 task begins before this artifact exists.

- [ ] [P0-T2] Capture the repository state baseline in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/state-anchor.<ts>.md` by running, each alone from the worktree root: `git rev-parse HEAD`; `git status --porcelain`; `git merge-base --is-ancestor f6ef5b2f HEAD`; `git merge-base --is-ancestor 592c91ea HEAD`; `git diff --name-only 592c91ea HEAD -- extensions scripts tests .claude .github .agents .codex`.
  - Acceptance: the artifact carries the four fields, records the 40-character HEAD SHA (the start SHA), the porcelain output, exit 0 for both `--is-ancestor` checks, and empty output for the `git diff --name-only` command. The `HEAD` SHA either begins with `592c91ea` or is a descendant of it (the second `--is-ancestor` exit 0). Every porcelain path is under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`. Stop condition: a porcelain path outside that folder, a non-zero `--is-ancestor` exit, or any path printed by the `git diff --name-only` command, because this plan assumes the audited code and the merged tree are unchanged.

- [ ] [P0-T3] Verify the D4 claim: write `<scratchpad>/d4_check_543.py` verbatim from "Scratchpad scripts", run `poetry run python <scratchpad>/d4_check_543.py` from the worktree root, and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/d4-merge-intersection.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the `PARENTS` line (with `second_is_main=True`) and the line `SUMMARY branch_changed=<n> merge_changed=<m> intersection=0` with the observed numbers, and no `OVERLAP` line. Stop condition: a non-zero exit, `second_is_main=False`, or any `OVERLAP` line; report the overlapping paths to the orchestrator, because the D4 deviation text would then be incorrect.

- [ ] [P0-T4] Capture the target-file row baseline by running `grep -n "^Timestamp" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/target-rows-before.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting exactly two output lines: `3:Timestamp: 2026-10-02T05-01` and `31:Timestamp: 2026-10-02T05-30`. Because the pattern `^Timestamp` also matches the correction-line label, two lines establish that no correction line exists yet. Stop condition: any other line count, line number, or value.

- [ ] [P0-T5] Capture the row-count baseline by running `grep -rc "^Timestamp:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep -v ":1$"` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/timestamp-row-counts-before.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting exactly one output line, the target file path ending `python-batch-budget.2026-10-02T05-01.md:2`. Stop condition: any other output (a second line means another file has a second or a zero count, which is a new finding to report).

- [ ] [P0-T6] Capture the correction-line baseline by running `grep -rc "^Timestamp-Correction:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep -c ":1$"` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/correction-line-counts-before.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the printed count `35`. Stop condition: any other count.

- [ ] [P0-T7] Capture the all-rows scan baseline: write `<scratchpad>/rows_543.py` verbatim from "Scratchpad scripts", run `poetry run python <scratchpad>/rows_543.py <start SHA from P0-T2>` from the worktree root, and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/timestamp-rows-scan-before.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 1`, and `ExpectedExitCode: 1`. Its `Output Summary:` quotes the summary line, which carries `old_files=78 old_rows=79 late=1 bad=0` followed by the `new_files` and `new_rows` counts for artifacts created earlier in this cycle, and quotes the single `LATE` line, which is `ROW docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md:31 value=2026-10-02T05-30 last_commit=<minute> LATE`, with `<minute>` read from the output and at or after `2026-10-02T05-18` (otherwise the corrected value would also be later than the commit). Stop condition: a `LATE` row for any other path or line, `bad` other than 0, `old_files` or `old_rows` different from the figures above, or a `last_commit` earlier than `2026-10-02T05-18`.

Phase 0 boundary: orchestrator commit and push (message in Execution notes). The executor does not commit.

### Phase 1 — R1 and N1: correct the python-batch-budget evidence rows

- [ ] [P1-T1] Apply the R1 edit to `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` with the Edit tool, using the "R1 edit" text in "Fixed edit text": the old string is `Timestamp: 2026-10-02T05-30` and the new string is the two lines given there. Do not rename the file and do not re-run its recorded command.
  - Acceptance: the file contains one line `Timestamp: 2026-10-02T05-18` directly followed by the R1 `Timestamp-Correction:` line quoted in "Fixed edit text"; the result is verified by P1-T3 and P1-T4. Stop condition: the Edit tool reports that the old string is absent or not unique.

- [ ] [P1-T2] Apply the N1 edit to the same file with the Edit tool, using the "N1 edit" text in "Fixed edit text": the old string is `Timestamp: 2026-10-02T05-01` and the new string is the two lines given there. Change nothing else.
  - Acceptance: the file contains one line `Timestamp: 2026-10-02T05-18` directly followed by the N1 `Timestamp-Correction:` line quoted in "Fixed edit text"; the result is verified by P1-T3 and P1-T4. Stop condition: the Edit tool reports that the old string is absent or not unique.

- [ ] [P1-T3] Record the edit as a diff against the start SHA by running `git diff -U0 <start SHA from P0-T2> -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` and `git status --porcelain -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`, and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget-correction.<ts>.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0`. The quoted diff output has exactly two hunks; the removed lines (those beginning with a single `-`, excluding the file header) are exactly two, `-Timestamp: 2026-10-02T05-01` and `-Timestamp: 2026-10-02T05-30`; the added lines (those beginning with a single `+`, excluding the file header) are exactly four: two `+Timestamp: 2026-10-02T05-18` lines and the two correction lines of "Fixed edit text". The porcelain output is empty or one line for that path (` M` when uncommitted; empty only if the orchestrator has already committed the edit). To keep the content restriction, the artifact quotes each diff line with its leading `+` or `-` character, which prevents any line from beginning with `Timestamp:` or `Timestamp-Correction:`. Stop condition: any other hunk, removed line, or added line.

- [ ] [P1-T4] Verify the target-file rows by running `grep -n "^Timestamp" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/target-rows-after.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting exactly four output lines in this order: line 3 `Timestamp: 2026-10-02T05-18`; line 4 beginning `Timestamp-Correction: original value 2026-10-02T05-01`; line 32 `Timestamp: 2026-10-02T05-18`; line 33 beginning `Timestamp-Correction: original value 2026-10-02T05-30`. Each quoted line keeps its `<n>:` prefix. Stop condition: any other count, order, line number, or value.

- [ ] [P1-T5] Run the inputs' absence check by running `grep -rn "^Timestamp: 2026-10-02T05-30$" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/composed-row-absence.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an `Output Summary:` stating that the command printed no line. The search literal is the `Timestamp: 2026-10-02T05-30` row quoted in decision 1. The `$` anchor is safe because P0 established that the target file has no carriage returns (decision 4); the P1-T4 artifact shows the removed row at line 31 no longer exists. Stop condition: any printed line.

- [ ] [P1-T6] Run the inputs' second-row count check by running `grep -rc "^Timestamp:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep -v ":1$"` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/timestamp-row-counts-after.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting exactly one output line, the target file path ending `python-batch-budget.2026-10-02T05-01.md:2`. The count is unchanged from P0-T5 because the edits replaced two values and added no `Timestamp:` row; a value of 2 in that file and 1 in every other file (including every new artifact of this cycle) is the expected state. Stop condition: any other output.

- [ ] [P1-T7] Run the correction-line file count by running `grep -rc "^Timestamp-Correction:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep -c ":1$"` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/correction-line-counts-after.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the printed count `35` (the 35 cycle-1 artifacts; the target file now has two correction lines and so is excluded from the files with exactly one). The inputs' figure of 36 applies only when N1 is not applied. Stop condition: any other count.

- [ ] [P1-T8] Run the correction-line two-count check by running `grep -rc "^Timestamp-Correction:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep ":2$"` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/correction-line-two-counts.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting exactly one output line, the target file path ending `python-batch-budget.2026-10-02T05-01.md:2`. Stop condition: any other output.

- [ ] [P1-T9] Run the all-rows scan after the edits: `poetry run python <scratchpad>/rows_543.py <start SHA from P0-T2>` from the worktree root, recorded in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/timestamp-rows-scan-after.<ts>.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0`. Its `Output Summary:` quotes the summary line, which carries `old_files=78 old_rows=79 late=0 bad=0` followed by the `new_files` and `new_rows` counts for the artifacts created in this cycle, and quotes the two target-file `ROW` lines at lines 3 and 32 (each `value=2026-10-02T05-18` and ending `OK`). Stop condition: a non-zero exit, any `LATE` or `BAD-FORMAT` row, or `old_files` or `old_rows` different from the figures above.

- [ ] [P1-T10] Run the inputs' whole-file row listing by running `grep -rn "^Timestamp:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/timestamp-rows-listing.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the two target-file lines, `3:Timestamp: 2026-10-02T05-18` and `32:Timestamp: 2026-10-02T05-18`, each with its path prefix, and recording the total number of output lines. The per-row comparison with commit times is carried by P1-T9; this listing is the inputs' own whole-file command and records the rows for the re-audit. Stop condition: a missing target line or a target-file value other than `2026-10-02T05-18`.

Phase 1 boundary: orchestrator commit and push (message in Execution notes). The executor does not commit.

### Phase 2 — Final QC (evidence-only; no code changed)

No production or test file is written by this plan, so no format, lint, type-check, test, or coverage gate applies; P2-T2 proves that condition. If P2-T2 fails, the plan stops and a revision adds the full QA loop for the language that changed.

- [ ] [P2-T1] Run the evidence-location validator `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` from the worktree root and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/evidence-locations.<ts>.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0`, and records that the output contains no `VIOLATION:` line (the validator prints nothing on success). It is a read-only check, so the exit code is the full observation. Stop condition: a non-zero exit or any `VIOLATION:` line.

- [ ] [P2-T2] Verify the change scope by running `git diff --name-status <start SHA from P0-T2> -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`, `git diff --name-only <start SHA from P0-T2> -- extensions scripts tests .claude .github .agents .codex`, and `git status --porcelain`, and record them in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/remediation-scope-check.<ts>.md`. The `git status --porcelain` span lists new, untracked artifacts, which the name-status diff cannot show.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0`. In the first command's output, no `D` or `R` status appears; the `M` set is a subset of the target file `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` and `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-plan.2026-10-02T07-08.md`, and contains the target file; every `A` path is under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/` or is `remediation-plan.2026-10-02T07-08.md` or `remediation-inputs.2026-10-02T07-08.md` in the same folder; `spec.md` and the three `07-08` audit artifacts are not listed. The second command prints nothing. Every path in the porcelain output is under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`. The `Output Summary:` states that zero production, test, and guidance files changed, so no language QA loop is required. Stop condition: any other status or path.

- [ ] [P2-T3] Re-check the checked acceptance-criteria count of `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` by running `grep -c '^- \[x\] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` and recording it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/spec-checked-count.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the printed count `21` (the 20 acceptance criteria plus the `Medium` severity box; observed 21 in the current tree). Stop condition: any other count.

- [ ] [P2-T4] Re-check the unchecked count of `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` by running `grep -c '^- \[ \] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` and recording it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/spec-unchecked-count.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the printed count `3` (the `Blocker`, `High`, and `Low` severity boxes; observed 3 in the current tree). Stop condition: any other count.

- [ ] [P2-T5] Validate this plan by running `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-plan.2026-10-02T07-08.md` and recording it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/remediation-plan-validation.<ts>.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0` for the CLI, whose stdout contains `plan validation passed:` followed by the path; the artifact states that the MCP validator is run by the orchestrator, because it is not in atomic-executor's tool surface. Any `PLAN GATE WARNING: ` lines are quoted verbatim. Stop condition: a non-zero CLI exit.

Phase 2 boundary: orchestrator commit and push (message in Execution notes), then the orchestrator runs the MCP plan validator and routes the cycle to re-audit. The executor does not commit.
