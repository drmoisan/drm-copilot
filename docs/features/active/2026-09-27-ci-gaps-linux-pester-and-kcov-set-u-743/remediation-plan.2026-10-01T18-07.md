# 2026-09-27-ci-gaps-linux-pester-and-kcov-set-u (Remediation Plan, cycle 1)

- **Issue:** #743
- **Parent (optional):** none
- **Owner:** drmoisan
- **Branch:** `bug/ci-gaps-linux-pester-and-kcov-set-u-743`
- **Last Updated:** 2026-10-01T18-07
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug
- Complexity band: C2 (five test files, one mechanical pattern, CI-driven verification)

## Plan Conventions

**Requirements source (sole AC source, full-bug).** `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`,
section `## Acceptance Criteria`, items AC-1 through AC-22. Primary input:
`docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-inputs.2026-10-01T18-07.md`
(findings R1 to R4, fix list F1 to F3, Do-Not-Do list). Supporting inputs: `code-review.2026-10-01T18-07.md`,
`feature-audit.2026-10-01T18-07.md`, `policy-audit.2026-10-01T18-07.md`, the executed plan
`plan.2026-09-30T03-15.md` (including its `## Execution Deviations` section, notably D11), and
`evidence/qa-gates/ci-final-linux.2026-10-01T17-57.md` with `evidence/qa-gates/linux-first-run-failures.2026-10-01T17-57.md`,
all in the same folder. `user-story.md` is not produced for full-bug work.

**Scope.** F1: make the five hook-suite test files portable to Linux (the 12 `DriveNotFoundException` failures,
AC-10 inventory rows 1 to 12). Any further Linux-only failure the re-run reports under `tests/scripts/claude-hooks/` or
`tests/scripts/codex-hooks/` is in scope (spec Files/modules table, "Other files ... Modify (conditional)") and is handled by
the contingency tasks P4-T10 and P4-T11. Re-verify on CI so both `_poshqc.yml` jobs conclude `success` on the pushed head
(closes R1 to R3, AC-6, AC-10). F3: re-run the final QC loop. F2 is an operator-run item (section below), not an executor task.

**Notation.** `<FEATURE>` denotes the literal folder
`docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743`. `<ts>` denotes the artifact creation time in
`yyyy-MM-ddTHH-mm` form. `<MERGE_BASE>` is the literal `41217012d31d35c2ee33a50be50684affd2f5f43` (merge base with `main`);
every command substitutes that literal, never `origin/main` itself. `<START_SHA>` is the 40-character SHA recorded by P0-T2
(the pushed branch head at the start of this cycle, short form `dcb2abf1`). `<CI_SHA>` is the 40-character SHA recorded by
P4-T1. `<RUN_ID>`, `<LINUX_JOB_ID>`, and `<WINDOWS_JOB_ID>` are GitHub Actions run and job IDs recorded by the task that
obtains them. `<BASELINE_RUN_ID>` is the literal `36901896617` (the executed plan's final run, head `ecba8829`).
`<session-scratchpad>` is the executor's session scratchpad, outside the repository. `<BATS_DIRECT>` is the bats-core script
path recorded by P0-T12. No absolute host path is copied into an evidence artifact: a repository-root prefix in recorded
output is replaced by `<REPO_ROOT>`, and a scratchpad prefix by `<session-scratchpad>`.

**Evidence rules.** Every evidence artifact is written under `<FEATURE>/evidence/<kind>/` with kind `remediation-baseline`
(Phase 0), `regression-testing`, `qa-gates`, or `other`; nothing is written under `artifacts/` except the tools' own
gitignored output. No delegation input supplied a non-canonical evidence path, so no
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` record applies. Every command-step artifact carries `Timestamp:`, `Command:`,
`EXIT_CODE:`, and `Output Summary:`. A task that names several commands for one artifact records one `Command:` and
`EXIT_CODE:` pair per command in that artifact. An artifact whose passing outcome is a non-zero exit carries
`ExpectedExitCode: <int>` and holds that one command only. Numeric values (counts, percentages) are recorded as numbers,
never as placeholders.

**Binding execution constraints (operator decision 2026-10-01, Option A).**
1. No `pwsh` in any form in the agent worktree, and no `sh` or `.sh` wrapper or other route around the worktree isolation
   guard. PowerShell format, analyze, and Pester run only through the MCP tools `mcp__drm-copilot__run_poshqc_format`,
   `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the item
   worktree. These return only an `ok` flag and a summary composed before the run. No task asserts a count, test name, or
   coverage value from them. Their acceptance is the `ok: true` flag plus a tree observation.
2. Pester counts, named results, and coverage come only from the CI jobs of the pushed head, read with `gh run view`,
   `gh run view --log --job`, and `gh run download`. Result files are parsed by the Python helper of reference block R5,
   written to `<session-scratchpad>` and run as `poetry run python <file>.py <mode> <argument>`. A multi-line
   `python -c` is never used.
3. The poshqc Windows job uploads its result files only when its tests pass (executed-plan deviation D11). If a Windows
   job fails, its evidence is the job log, read with `gh run view <RUN_ID> --log --job <WINDOWS_JOB_ID>`.
4. Bash, git, gh, grep, sha256sum, shfmt, shellcheck, `sh <script>`, and `npx --yes bats` run normally.
5. Commit and push at each phase boundary with pathspec commits: `git add -- <paths>` then
   `git commit -F <message file> -- <paths>`, with the message file written by the Write tool into `<session-scratchpad>`
   (reference block R6). Pushes never use force. If the preimplementation gate refuses a command, the executor records the
   refusal text and stops (BLOCKED, returned to the orchestrator).
6. Do-Not-Do list of the remediation inputs: no `-Skip`, `-Skip:$true`, `Set-ItResult -Skipped`, or OS guard that skips a test
   without a non-Windows assertion of the same behavior; no edit to `.github/workflows/_quality-checks.yml`,
   `.github/workflows/_drm-copilot-extension-tests.yml`, `.github/workflows/ci.yml`, `.github/workflows/_shell-coverage.yml`,
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, or any path under `.claude/rules/` or
   `.github/instructions/`; no `Run.Path` change in `poshqc-linux-hooks` and no change to the `poshqc` job (so
   `.github/workflows/_poshqc.yml` is not written at all); no production hook edit; no file above 500 lines
   (`tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1` is not touched by this plan); no temporary file in
   tests; no change to npm overrides.

**Command route notes.** Shell scripts run as `sh <script>` (Git Bash `sh` is GNU bash), for example
`sh scripts/bash/shell-qc.sh check`. Greps that assert a literal use `grep -c -F -e '<literal>' <file>`; the `-e` form is
required because several literals begin with a hyphen. A `grep -c` command whose expected count is `0` exits 1; that exit is
the expected result, and the assertion is the printed count. Plan checks never assert a `grep -F` literal containing a backslash
(Git for Windows grep 3.0 reads a doubled backslash as one). The full `shell-qc.sh test` run takes about 20 minutes and runs
in the background (Bash tool background mode); its completion notification carries the exit code.

**Merge-order independence.** Edits are located by content anchors; line numbers quoted below were re-derived against the
current tree during planning and are context, not locators.

**Files written by this plan (exhaustive).** Each file is written only by a task whose text names it:
`tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`;
`tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`;
`tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`;
`tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`;
`tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`;
`docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md` (AC-6 and AC-10 check-offs only);
this plan (check marks only); and evidence artifacts under `<FEATURE>/evidence/`. Further test files are written only under
P4-T11, and only when P4-T10 lists them.

**Quality tier.** `quality-tiers.yml` is absent from the repository root (`evidence/baseline/quality-tier.2026-10-01T16-01.md`);
tier T4 is assumed for the files in scope, which are tests. The uniform gates apply: format pass, zero lint findings, line coverage at or above 85% (PowerShell; no
branch gate for PowerShell), no regression on changed lines. The changed lines are test lines, which are outside the
coverage denominator, so the PowerShell coverage expectation is "not lower than the baseline".

## Operator-Run Items (not executor tasks)

F2 / R4 is an operator-run item under the 2026-10-01 operator decision. The executor does not run it, and no task below
runs it. The operator runs, from the repository root of the item worktree:

`pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml`

Expected: exit 0 and no findings. The operator records the command, exit code, and output under
`<FEATURE>/evidence/qa-gates/` with a new timestamp. A direct `actionlint .github/workflows/_poshqc.yml` run (binary on PATH)
is run by P3-T8 as supplementary evidence only. AC-5 and AC-21 stay unchecked until the operator run is recorded. Because
this plan changes no workflow file, one operator run after this plan satisfies both AC-5 and the AC-21 actionlint step.

## Reference Text

R1. `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` edits. The file uses LF line endings and 4-space
indentation. Context re-derived at planning: `BeforeAll` opens at line 22; line 28 is `$script:AlphaPrompt = ...`;
`function Get-CheckpointJson` builds the item JSON at lines 45 to 47, with `"worktree_path":"C:/worktrees/alpha"` at line 46;
line 338 is the `-ForEach` row `a blank feature folder`; lines 345, 351, 357, and 365 each pass
`-WorktreePath 'C:/worktrees/alpha'` to `Test-ParallelDriftFindingPresent`. Production reads the value through
`Join-Path -Path $WorktreePath` (`.claude/hooks/enforce-parallel-drift-gate.ps1:179`), which raises
`DriveNotFoundException` for a drive-letter path on Linux.

- R1a. Insert, immediately after the `$script:AlphaPrompt = ...` line in `BeforeAll`, these two lines:

```powershell
        # Synthetic worktree root chosen per host OS: Join-Path raises DriveNotFoundException for a drive-letter path on Linux.
        $script:SyntheticWorktree = if ($IsWindows) { 'C:/worktrees/alpha' } else { '/worktrees/alpha' }
```

- R1b. Replace the line-46 text `'"worktree_path":"C:/worktrees/alpha","blast_radius":{"paths":["scripts/declared/"],"modules":[],' +` with
  `'"worktree_path":"' + $script:SyntheticWorktree + '","blast_radius":{"paths":["scripts/declared/"],"modules":[],' +`.
- R1c. Replace the line-338 row with the following. Pester evaluates `-ForEach` data at discovery, before `BeforeAll` runs,
  so the row derives the root inline and does not read the `$script:SyntheticWorktree` variable.

```powershell
            @{ Label = 'a blank feature folder'; Worktree = $(if ($IsWindows) { 'C:/worktrees/alpha' } else { '/worktrees/alpha' }); Folder = '' }
```

- R1d. At lines 345, 351, 357, and 365 replace `-WorktreePath 'C:/worktrees/alpha'` with `-WorktreePath $script:SyntheticWorktree`.

R2. Routing-suite edits (four files). In each file, the `It 'the default reader yields direct mode when the checkpoint file is absent'`
block passes `-Root 'C:/synthetic-absent-root'` (re-derived lines: `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1:303`,
`tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1:304`,
`tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1:301`,
`tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1:298`). Each edit has two parts:

- R2a. As the first line of that `It` body, insert (indented to the body):

```powershell
            $absentRoot = if ($IsWindows) { 'C:/synthetic-absent-root' } else { '/synthetic-absent-root' }
```

- R2b. Replace `-Root 'C:/synthetic-absent-root'` with `-Root $absentRoot`. The asserted behavior is unchanged on both hosts
  (checkpoint absent, direct mode, `deny` with the `*_LARGE_PATH_REQUIRED:` reason). The sibling cases in the same
  `Context 'checkpoint seam'` already pass `-Root '/repo'` on both hosts and are not edited.

R3. Why no `-Skip`. Every edited case asserts the same outcome on Windows and Linux. The Windows literal is preserved on
Windows, and a `/`-rooted equivalent is used elsewhere, which is the pattern merged at
`tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1:47-51` and `:214`.

R4. AC-10 fix descriptions for the closed inventory (P5-T1). Rows 1 to 5: `$script:SyntheticWorktree` (OS-derived) in the
`Get-CheckpointJson` JSON of `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` (R1a, R1b). Rows 6 to 8:
`-WorktreePath $script:SyntheticWorktree` (R1d). Rows 9 to 12: `$absentRoot` derived from `$IsWindows` and passed as `-Root`
(R2a, R2b).

R5. Python helper `<session-scratchpad>/pester_xml_summary.py` (not a repository file). Modes: `junit <xml>`,
`coverage <xml>`, `inventory <xml>`, `jobs` (reads JSON on standard input). Observed shape basis: the executed plan's
evidence (`ci-final-linux.2026-10-01T17-57.md`) shows `testcase` elements under file-named `testsuite` elements.

```python
"""Session-scratchpad helper for the issue 743 remediation. Not a repository file."""
import json
import re
import sys
import xml.etree.ElementTree as ET

INVENTORY = (
    (1, "tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1", "denies when the only finding file predates the latest drift event"),
    (2, "tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1", "allows when the finding file timestamp equals the latest drift event at"),
    (3, "tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1", "allows when the finding file timestamp follows the latest drift event at"),
    (4, "tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1", "denies when the finding file name carries a non-conforming embedded substring"),
    (5, "tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1", "names the current-event requirement in the deny reason for a stale finding file"),
    (6, "tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1", "Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist"),
    (7, "tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1", "Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present"),
    (8, "tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1", "Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file"),
    (9, "tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1", "the default reader yields direct mode when the checkpoint file is absent"),
    (10, "tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1", "the default reader yields direct mode when the checkpoint file is absent"),
    (11, "tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1", "the default reader yields direct mode when the checkpoint file is absent"),
    (12, "tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1", "the default reader yields direct mode when the checkpoint file is absent"),
)


def normalize_suite(name):
    text = (name or "").replace("\\", "/")
    match = re.search(r"tests/scripts/.*", text)
    return match.group(0) if match else text


def read_cases(path):
    root = ET.parse(path).getroot()
    cases = []
    for suite in root.iter("testsuite"):
        file_name = normalize_suite(suite.get("name"))
        for case in suite.findall("testcase"):
            failed = case.find("failure") is not None or case.find("error") is not None
            cases.append((file_name, case.get("name") or "", failed))
    return root, cases


def run_junit(path):
    root = ET.parse(path).getroot()
    print("JUNIT-ROOT: tests={} failures={} errors={}".format(root.get("tests"), root.get("failures"), root.get("errors")))
    for suite in root.iter("testsuite"):
        file_name = normalize_suite(suite.get("name"))
        print("SUITE: {} | tests={} | failures={} | errors={} | skipped={}".format(
            file_name, suite.get("tests"), suite.get("failures"), suite.get("errors"), suite.get("skipped")))
        for case in suite.findall("testcase"):
            if case.find("failure") is not None or case.find("error") is not None:
                print("FAIL: {} | {}".format(file_name, case.get("name")))
    return 0


def run_coverage(path):
    root = ET.parse(path).getroot()
    counters = root.findall("counter[@type='LINE']")
    if len(counters) != 1:
        print("ROOT-LINE-COUNTER-COUNT: {}".format(len(counters)))
        return 1
    covered = int(counters[0].get("covered"))
    missed = int(counters[0].get("missed"))
    print("PS-LINE-COVERAGE: covered={} missed={} percent={:.2f}".format(covered, missed, 100.0 * covered / (covered + missed)))
    return 0


def run_inventory(path):
    _, cases = read_cases(path)
    results = {}
    others = []
    for file_name, name, failed in cases:
        matched = False
        for row, row_file, fragment in INVENTORY:
            if file_name.endswith(row_file) and fragment in name:
                results.setdefault(row, []).append(failed)
                matched = True
        if failed and not matched:
            others.append((file_name, name))
    counts = {"PASS": 0, "FAIL": 0, "MISSING": 0}
    for row, row_file, fragment in INVENTORY:
        outcomes = results.get(row, [])
        status = "MISSING" if not outcomes else ("FAIL" if any(outcomes) else "PASS")
        counts[status] += 1
        print("ROW {}: {} | {} | {}".format(row, status, row_file, fragment))
    for file_name, name in others:
        print("OTHER-FAIL: {} | {}".format(file_name, name))
    print("INVENTORY-SUMMARY: pass={} fail={} missing={} other-fail={}".format(
        counts["PASS"], counts["FAIL"], counts["MISSING"], len(others)))
    return 0


def run_jobs():
    data = json.load(sys.stdin)
    print("HEAD-SHA: {}".format(data.get("headSha")))
    for job in data.get("jobs", []):
        print("JOB: {} | {} | {}".format(job.get("databaseId"), job.get("name"), job.get("conclusion")))
        for step in job.get("steps", []):
            print("STEP: {} | {} | {}".format(job.get("databaseId"), step.get("name"), step.get("conclusion")))
    return 0


def main(argv):
    if len(argv) >= 2 and argv[1] == "jobs":
        return run_jobs()
    if len(argv) == 3 and argv[1] in ("junit", "coverage", "inventory"):
        return {"junit": run_junit, "coverage": run_coverage, "inventory": run_inventory}[argv[1]](argv[2])
    print("USAGE: pester_xml_summary.py junit|coverage|inventory <xml-path> | jobs (JSON on stdin)")
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
```

R6. Commit message files, written by the Write tool into `<session-scratchpad>`. Subject lines (body: one or two sentences naming
the files and the finding IDs; every message ends with the two trailer lines):

- `commit-msg-p0.txt`: `docs(743): record remediation cycle 1 baseline and anchors`
- `commit-msg-p1.txt`: `test(743): derive the drift-gate synthetic worktree root from the host OS`
- `commit-msg-p2.txt`: `test(743): derive the absent routing root from the host OS in four routing suites`
- `commit-msg-p3.txt`: `docs(743): record remediation cycle 1 final QC loop evidence`
- `commit-msg-p4c.txt` (P4-T11 contingency only): `test(743): derive a portable synthetic root in further failing Linux hook suites`
- `commit-msg-p4.txt`: `docs(743): record remediation cycle 1 CI verification evidence`
- `commit-msg-p5.txt`: `docs(743): close AC-6 and AC-10 on CI evidence for remediation cycle 1`

Trailer lines (verbatim, last two lines of every message):

```
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01FbvRAiYyVcNyhRL2ZaqP2S
```

R7. SP8 `<session-scratchpad>/locate-bats.sh`:

```sh
cache=$(cygpath -u "$(npm config get cache)")
find "$cache/_npx" -path '*/node_modules/bats/bin/bats' -type f
```

R8. Forbidden-path pattern (AC-20), used verbatim in P0-T10 and P3-T14:
`^(\.github/workflows/(_quality-checks|_drm-copilot-extension-tests|ci|_shell-coverage)\.yml|scripts/powershell/PoshQC/settings/pester\.runsettings\.psd1|\.claude/rules/|\.github/instructions/)`.

---

### Phase 0 — Policy Reads, Anchors, Edit-Site Detection, and Baseline Capture

- [x] [P0-T1] Read the policy files in the required order and write
  `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.md`. Order: `CLAUDE.md`,
  `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`,
  `.claude/rules/shell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/ci-workflows.md`,
  `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`,
  `.github/instructions/github-actions.instructions.md`,
  `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`.
  Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and the explicit file list in that order; the command
  `grep -c -E '^(Timestamp|Policy Order):' <FEATURE>/evidence/remediation-baseline/phase0-instructions-read.md` prints `2`.
- [x] [P0-T2] Record the cycle anchors into `<FEATURE>/evidence/remediation-baseline/anchors.<ts>.md` (several command
  pairs): `git rev-parse HEAD` (this value is `<START_SHA>`), `git rev-parse --abbrev-ref HEAD`,
  `git merge-base HEAD origin/main`, `git status --porcelain`, and
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743`. Acceptance: `<START_SHA>` begins with
  `dcb2abf1`; the branch name is `bug/ci-gaps-linux-pester-and-kcov-set-u-743`; the merge base equals
  `41217012d31d35c2ee33a50be50684affd2f5f43`; every line of the porcelain listing names a path under `<FEATURE>/` (expected: the
  untracked plan file and the `evidence/remediation-baseline/` artifacts), and a path outside `<FEATURE>/` stops the plan; the remote
  head equals `<START_SHA>`.
  Any other value stops the plan (BLOCKED, returned to the orchestrator).
- [x] [P0-T3] Write reference block R5 verbatim into `<session-scratchpad>/pester_xml_summary.py`, then run it with no
  arguments into `<FEATURE>/evidence/remediation-baseline/helper-usage.<ts>.md` with `ExpectedExitCode: 2`, holding only the
  command `poetry run python <session-scratchpad>/pester_xml_summary.py`. Acceptance: the output line begins `USAGE:` and the
  observed `EXIT_CODE:` is 2.
- [x] [P0-T4] [expect-fail] Capture the baseline Linux failure set into
  `<FEATURE>/evidence/regression-testing/linux-baseline-junit.<ts>.md` (several command pairs):
  `gh run download 36901896617 --name poshqc-linux-hook-test-results --dir <session-scratchpad>/linux-baseline-743`, then
  `poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/linux-baseline-743/pester-junit-linux-hooks.xml`,
  then `poetry run python <session-scratchpad>/pester_xml_summary.py inventory <session-scratchpad>/linux-baseline-743/pester-junit-linux-hooks.xml`.
  Acceptance (matches the recorded `ci-final-linux.2026-10-01T17-57.md` result): the `junit` output contains the line
  `JUNIT-ROOT: tests=3412 failures=12 errors=0` and exactly 12 `FAIL:` lines; the `inventory` output contains the line
  `INVENTORY-SUMMARY: pass=0 fail=12 missing=0 other-fail=0`. This is the fail-before evidence for AC-10 rows 1 to 12 and
  shows that the helper's inventory mode reports a failure when one exists.
- [x] [P0-T5] Capture the baseline Windows test and coverage values into
  `<FEATURE>/evidence/remediation-baseline/windows-baseline.<ts>.md` (several command pairs):
  `gh run view 36901896617 --log --job 110502826187`, filtered with `grep -F 'Tests Passed:'`;
  `gh run download 36901896617 --name poshqc-test-results --dir <session-scratchpad>/windows-baseline-743`; and
  `poetry run python <session-scratchpad>/pester_xml_summary.py coverage <session-scratchpad>/windows-baseline-743/powershell-coverage.xml`.
  Acceptance: the `Tests Passed:` line contains `Failed: 0,`; the coverage output is the line
  `PS-LINE-COVERAGE: covered=11236 missed=430 percent=96.31`. The percent value is the numeric baseline `B_PS` used by
  P4-T9 and P5-T2.
- [x] [P0-T6] Detect the drift-gate edit sites into
  `<FEATURE>/evidence/remediation-baseline/edit-sites-drift-gate.<ts>.md`: run
  `grep -n -F -e 'C:/worktrees/alpha' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`. Acceptance: exactly six
  lines are printed, with line numbers 46, 338, 345, 351, 357, and 365.
- [x] [P0-T7] Detect the routing edit sites into
  `<FEATURE>/evidence/remediation-baseline/edit-sites-routing.<ts>.md`: run
  `grep -n -F -e 'C:/synthetic-absent-root' tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`.
  Acceptance: exactly four lines are printed, one per file, with line numbers 303, 304, 301, and 298 respectively.
- [x] [P0-T8] Record the baseline line counts of the five files into
  `<FEATURE>/evidence/remediation-baseline/line-counts.<ts>.md`: run
  `wc -l tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`.
  Acceptance: five per-file counts are recorded as numbers, each at most 500 (no exact value is asserted).
- [x] [P0-T9] Record the baseline skip-addition count into
  `<FEATURE>/evidence/remediation-baseline/skip-count.<ts>.md` with `ExpectedExitCode: 1`, holding only the command
  `git diff -U0 41217012d31d35c2ee33a50be50684affd2f5f43 -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/ | grep -c -E '^\+.*-Skip([[:space:]]|$|:\$true)'`.
  Acceptance: the count prints `0` and the observed exit code is 1.
- [x] [P0-T10] Record the baseline forbidden-path count into
  `<FEATURE>/evidence/remediation-baseline/forbidden-paths.<ts>.md` with `ExpectedExitCode: 1`, holding only the command
  `git diff --name-only 41217012d31d35c2ee33a50be50684affd2f5f43 | grep -c -E '<R8 pattern>'` with the reference block R8
  pattern substituted verbatim. The same task also runs `git status --porcelain` into the artifact
  `<FEATURE>/evidence/remediation-baseline/forbidden-paths-status.<ts>.md` (no expectation field) so untracked paths are
  visible. Acceptance: the count prints `0` and exits 1; every line of the porcelain listing names a path under `<FEATURE>/`.
- [x] [P0-T11] Confirm the bats-core runner is obtainable into
  `<FEATURE>/evidence/remediation-baseline/bats-version.<ts>.md`: run `npx --yes bats --version`. Acceptance: exit 0 and the
  output line begins `Bats `. If it cannot run, record `BATS-DIRECT: UNAVAILABLE` and the P3-T6 and P5 AC-21 statements follow
  the unavailable branch.
- [x] [P0-T12] Locate the direct bats script: write reference block R7 into `<session-scratchpad>/locate-bats.sh` and run
  `sh <session-scratchpad>/locate-bats.sh` into `<FEATURE>/evidence/remediation-baseline/bats-direct.<ts>.md`.
  Acceptance: exactly one path ending `node_modules/bats/bin/bats` is printed (recorded with the `<npm-cache>` prefix in
  place of the host path); that value is `<BATS_DIRECT>`. When zero or several paths are printed, record
  `BATS-DIRECT: UNAVAILABLE`.
- [x] [P0-T13] Capture the PowerShell format baseline into
  `<FEATURE>/evidence/remediation-baseline/ps-format.<ts>.md`. Pre-pass observation: run `git status --porcelain` and
  `sha256sum` over the five files listed in P0-T8. Run the MCP tool `mcp__drm-copilot__run_poshqc_format` with
  `workspace_root` set to the item worktree. Post-pass observation: re-run the same two commands. Acceptance (success-case
  observation): the tool result has `ok: true`; the post-pass porcelain listing equals the pre-pass listing; the five
  post-pass hashes equal the five pre-pass hashes (the formatter changed no tracked file). The tool returns no `Formatted:`
  counts, so none is asserted.
- [x] [P0-T14] Capture the PowerShell analyze baseline into
  `<FEATURE>/evidence/remediation-baseline/ps-analyze.<ts>.md`: run the MCP tool `mcp__drm-copilot__run_poshqc_analyze` with
  `workspace_root` set to the item worktree. Acceptance: the tool result has `ok: true`. The finding set is empty in the
  executed plan's CI run (`Analyze PowerShell` step `success`, `ci-final-conclusions.2026-10-01T17-57.md`); no count is
  asserted from the tool.
- [x] [P0-T15] Capture the local PowerShell test baseline for the two hook folders into
  `<FEATURE>/evidence/remediation-baseline/ps-test-hooks.<ts>.md`, before any test edit: run the MCP tool
  `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the item worktree and `scan_folders` set to
  `["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]`. Acceptance: the tool result has `ok: true`. When it returns
  `ok: false`, record `LOCAL-BASELINE: FAILING` in the artifact, stop, and return to the orchestrator. No count or test name is
  asserted from the tool.
- [x] [P0-T16] Capture the local PowerShell test baseline for the full suite into
  `<FEATURE>/evidence/remediation-baseline/ps-test-full.<ts>.md`, before any test edit: run the MCP tool
  `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the item worktree and no `scan_folders`. Acceptance: the tool result
  has `ok: true`. When it returns `ok: false`, record `LOCAL-BASELINE: FAILING` in the artifact, stop, and return to the orchestrator.
  No count or coverage value is asserted from the tool.
- [x] [P0-T17] Commit and push the Phase 0 boundary: write `<session-scratchpad>/commit-msg-p0.txt` from reference block R6,
  then run `git add -- docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/remediation-baseline/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/regression-testing/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-plan.2026-10-01T18-07.md`,
  `git commit -F <session-scratchpad>/commit-msg-p0.txt -- docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/remediation-baseline/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/regression-testing/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-plan.2026-10-01T18-07.md`,
  `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743`, and
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743`, with `git rev-parse HEAD`, into
  `<FEATURE>/evidence/other/commit-push-p0.<ts>.md`. Acceptance: every command exits 0 and the remote head equals
  `git rev-parse HEAD`.

### Phase 1 — Portable Synthetic Root in the Drift-Gate Suite (AC-10 rows 1 to 8)

- [x] [P1-T1] Edit `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`: apply reference edit R1a (the
  `$script:SyntheticWorktree` definition in `BeforeAll`). Acceptance: `grep -c -F -e '$script:SyntheticWorktree = if ($IsWindows)' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`
  prints `1`. Record in `<FEATURE>/evidence/regression-testing/p1-t1-synthetic-worktree.<ts>.md`.
- [x] [P1-T2] Edit `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`: apply reference edit R1b (the line-46 JSON
  built by concatenation). Acceptance: `grep -c -F -e '+ $script:SyntheticWorktree +' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`
  prints `1`. Record in `<FEATURE>/evidence/regression-testing/p1-t2-json-root.<ts>.md`. The absence check
  `grep -c -F -e '"worktree_path":"C:/worktrees/alpha"' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`
  prints `0` (it printed `1` before this task) and exits 1; it is recorded alone, with `ExpectedExitCode: 1`, in
  `<FEATURE>/evidence/regression-testing/p1-t2-json-root-absent.<ts>.md`.
- [x] [P1-T3] Edit `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`: apply reference edit R1c (the line-338
  `-ForEach` row derives its root inline). Acceptance:
  `grep -c -F -e "else { '/worktrees/alpha' }" tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` prints `2`
  (the R1a line and the R1c row). Record in `<FEATURE>/evidence/regression-testing/p1-t3-foreach-root.<ts>.md`. The absence check
  `grep -c -F -e "Worktree = 'C:/worktrees/alpha'" tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` prints `0` (it printed
  `1` before) and exits 1; it is recorded alone, with `ExpectedExitCode: 1`, in
  `<FEATURE>/evidence/regression-testing/p1-t3-foreach-root-absent.<ts>.md`.
- [x] [P1-T4] Edit `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`: apply reference edit R1d at the four
  `Test-ParallelDriftFindingPresent` call sites. Acceptance:
  `grep -c -F -e '-WorktreePath $script:SyntheticWorktree' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` prints `4`.
  Record in `<FEATURE>/evidence/regression-testing/p1-t4-call-sites.<ts>.md`. The absence check
  `grep -c -F -e "-WorktreePath 'C:/worktrees/alpha'" tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` prints `0` (it printed
  `4` before) and exits 1; it is recorded alone, with `ExpectedExitCode: 1`, in
  `<FEATURE>/evidence/regression-testing/p1-t4-call-sites-absent.<ts>.md`.
- [x] [P1-T5] Verify the residual Windows literal count in `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` into
  `<FEATURE>/evidence/regression-testing/p1-t5-residual.<ts>.md`: run
  `grep -c -F -e 'C:/worktrees/alpha' tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`. Acceptance: the count prints `2`
  (the Windows branch of the R1a line and the Windows branch of the R1c row); P0-T6 recorded six.
- [x] [P1-T6] Verify the line count of `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` into
  `<FEATURE>/evidence/regression-testing/p1-t6-line-count.<ts>.md`: run
  `wc -l tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`. Acceptance: the count is at most 500.
- [x] [P1-T7] Run the PowerShell format step for the edited suite into
  `<FEATURE>/evidence/regression-testing/p1-t7-ps-format.<ts>.md`. Pre-pass observation: `git status --porcelain` and
  `sha256sum tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`. Run the MCP tool
  `mcp__drm-copilot__run_poshqc_format` (`workspace_root` = item worktree). Post-pass observation: re-run both commands.
  Acceptance: `ok: true`, and the post-pass hash and porcelain listing equal the pre-pass values. If the formatter changed the
  file, the formatted file is kept, P1-T1 to P1-T6 are re-checked against it, and this task is re-run into a new artifact until
  the hash is unchanged.
- [x] [P1-T8] Run the PowerShell analyze step into `<FEATURE>/evidence/regression-testing/p1-t8-ps-analyze.<ts>.md`: run the MCP
  tool `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` = item worktree). Acceptance: `ok: true`. The finding set is
  read from the CI `Analyze PowerShell` step in P4-T4.
- [x] [P1-T9] Run the Windows regression smoke for the Claude hook suites into
  `<FEATURE>/evidence/regression-testing/p1-t9-ps-test-claude-hooks.<ts>.md`: run the MCP tool
  `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the item worktree and `scan_folders` set to
  `["tests/scripts/claude-hooks"]`. Acceptance: `ok: true` (the P0-T15 baseline for the same folders was also `ok: true`). No count
  or test name is asserted; the per-test result is read from CI in P4-T9.
- [x] [P1-T10] Commit and push the Phase 1 boundary: write `<session-scratchpad>/commit-msg-p1.txt` from reference block R6, then
  run `git add --` and `git commit -F <session-scratchpad>/commit-msg-p1.txt --` with the paths
  `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-plan.2026-10-01T18-07.md`,
  then `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743`, then
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743` with `git rev-parse HEAD`, into
  `<FEATURE>/evidence/other/commit-push-p1.<ts>.md`. Acceptance: every command exits 0 and the remote head equals
  `git rev-parse HEAD`.

### Phase 2 — Portable Absent Root in the Four Routing Suites (AC-10 rows 9 to 12)

- [x] [P2-T1] Edit `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`: apply reference edits R2a and R2b in
  the `checkpoint seam` case `the default reader yields direct mode when the checkpoint file is absent`. Acceptance, each
  command run against that file: `grep -c -F -e '$absentRoot = if ($IsWindows)'` prints `1`; `grep -c -F -e '-Root $absentRoot'` prints `1`.
  Record in `<FEATURE>/evidence/regression-testing/p2-t1-claude-powershell-routing.<ts>.md`. The absence check
  `grep -c -F -e "-Root 'C:/synthetic-absent-root'"` on the same file prints `0` (it printed `1` before) and exits 1; it is recorded alone,
  with `ExpectedExitCode: 1`, in `<FEATURE>/evidence/regression-testing/p2-t1-claude-powershell-routing-absent.<ts>.md`.
- [x] [P2-T2] Edit `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`: apply reference edits R2a and R2b in the
  same-named case. Acceptance, each command run against that file: `grep -c -F -e '$absentRoot = if ($IsWindows)'` prints `1`;
  `grep -c -F -e '-Root $absentRoot'` prints `1`. Record in
  `<FEATURE>/evidence/regression-testing/p2-t2-claude-python-routing.<ts>.md`. The absence check
  `grep -c -F -e "-Root 'C:/synthetic-absent-root'"` on the same file prints `0` (it printed `1` before) and exits 1; it is recorded alone,
  with `ExpectedExitCode: 1`, in `<FEATURE>/evidence/regression-testing/p2-t2-claude-python-routing-absent.<ts>.md`.
- [x] [P2-T3] Edit `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`: apply reference edits R2a and R2b in the
  same-named case (the invocation is a single line). Acceptance, each command run against that file:
  `grep -c -F -e '$absentRoot = if ($IsWindows)'` prints `1`; `grep -c -F -e '-Root $absentRoot'` prints `1`.
  Record in `<FEATURE>/evidence/regression-testing/p2-t3-codex-powershell-routing.<ts>.md`. The absence check
  `grep -c -F -e "-Root 'C:/synthetic-absent-root'"` on the same file prints `0` (it printed `1` before) and exits 1; it is recorded alone,
  with `ExpectedExitCode: 1`, in `<FEATURE>/evidence/regression-testing/p2-t3-codex-powershell-routing-absent.<ts>.md`.
- [x] [P2-T4] Edit `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`: apply reference edits R2a and R2b in the
  same-named case (the invocation is a single line). Acceptance, each command run against that file:
  `grep -c -F -e '$absentRoot = if ($IsWindows)'` prints `1`; `grep -c -F -e '-Root $absentRoot'` prints `1`.
  Record in `<FEATURE>/evidence/regression-testing/p2-t4-codex-python-routing.<ts>.md`. The absence check
  `grep -c -F -e "-Root 'C:/synthetic-absent-root'"` on the same file prints `0` (it printed `1` before) and exits 1; it is recorded alone,
  with `ExpectedExitCode: 1`, in `<FEATURE>/evidence/regression-testing/p2-t4-codex-python-routing-absent.<ts>.md`.
- [x] [P2-T5] Verify the residual Windows literal in the four routing files into
  `<FEATURE>/evidence/regression-testing/p2-t5-residual.<ts>.md`: run
  `grep -c -F -e 'C:/synthetic-absent-root' tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`.
  Acceptance: four per-file lines are printed, each ending `:1` (only the Windows branch of the R2a line remains).
- [x] [P2-T6] Verify the line counts of the four routing files into `<FEATURE>/evidence/regression-testing/p2-t6-line-counts.<ts>.md`:
  run `wc -l` over the four paths of P2-T5. Acceptance: every count is at most 500.
- [x] [P2-T7] Run the PowerShell format step for the edited suites into
  `<FEATURE>/evidence/regression-testing/p2-t7-ps-format.<ts>.md`. Pre-pass observation: `git status --porcelain` and `sha256sum` over
  the four routing files. Run the MCP tool `mcp__drm-copilot__run_poshqc_format` (`workspace_root` = item worktree). Post-pass
  observation: re-run both commands. Acceptance: `ok: true`; the post-pass hashes and porcelain listing equal the pre-pass values. A
  changed file is kept, P2-T1 to P2-T6 are re-checked against it, and this task is re-run into a new artifact until the hashes are
  unchanged.
- [x] [P2-T8] Run the PowerShell analyze step into `<FEATURE>/evidence/regression-testing/p2-t8-ps-analyze.<ts>.md`: run the MCP
  tool `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` = item worktree). Acceptance: `ok: true`.
- [x] [P2-T9] Run the Windows regression smoke for both hook folders into
  `<FEATURE>/evidence/regression-testing/p2-t9-ps-test-hooks.<ts>.md`: run the MCP tool `mcp__drm-copilot__run_poshqc_test` with
  `workspace_root` set to the item worktree and `scan_folders` set to `["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]`.
  Acceptance: `ok: true` (the P0-T15 baseline for the same folders was also `ok: true`). No count or test name is asserted.
- [x] [P2-T10] Commit and push the Phase 2 boundary: write `<session-scratchpad>/commit-msg-p2.txt` from reference block R6, then
  run `git add --` and `git commit -F <session-scratchpad>/commit-msg-p2.txt --` with the paths
  `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-plan.2026-10-01T18-07.md`,
  then `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743`, then
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743` with `git rev-parse HEAD`, into
  `<FEATURE>/evidence/other/commit-push-p2.<ts>.md`. Acceptance: every command exits 0 and the remote head equals
  `git rev-parse HEAD`.

### Phase 3 — Final Local QC Loop (F3)

Loop rule. P3-T1 through P3-T14 are one pass of the local toolchain loop: PowerShell format, analyze, and test; bash format,
lint, and test; the Python parity test; supplementary workflow lint; and the static checks. If any step fails, or any step or
remediation changes a file, fix the cause and restart at P3-T1. Artifacts from an abandoned pass are kept, and each new pass
writes new timestamped artifacts. A fix that changes a test file is committed by re-running the Phase 1 or Phase 2 boundary
commit pattern into a new `commit-push-*.<ts>.md` artifact before P4-T1.

- [x] [P3-T1] QC step 1 (PowerShell format) over the whole worktree into `<FEATURE>/evidence/qa-gates/qc-ps-format.<ts>.md`.
  Pre-pass observation: `git status --porcelain` and `sha256sum` over the five files of P0-T8 plus every file listed in the latest
  P4-T11 artifact (none on the first pass). Run the MCP tool
  `mcp__drm-copilot__run_poshqc_format` (`workspace_root` = item worktree). Post-pass observation: re-run both commands.
  Acceptance (success-case observation): `ok: true`; the post-pass porcelain listing equals the pre-pass listing; the post-pass
  hashes equal the pre-pass hashes. No `Formatted:` count is asserted.
- [x] [P3-T2] QC step 2 (PowerShell analyze) into `<FEATURE>/evidence/qa-gates/qc-ps-analyze.<ts>.md`: run the MCP tool
  `mcp__drm-copilot__run_poshqc_analyze` (`workspace_root` = item worktree). Acceptance: `ok: true`. The finding set is read from the
  CI `Analyze PowerShell` step of the head run in P4-T4. Type checking does not apply to PowerShell.
- [x] [P3-T3] QC step 3 (PowerShell test; coverage is read from CI) into `<FEATURE>/evidence/qa-gates/qc-ps-test.<ts>.md`: run the MCP
  tool `mcp__drm-copilot__run_poshqc_test` (`workspace_root` = item worktree, no `scan_folders`). Acceptance: `ok: true`. The tool
  returns no counts or coverage, so the numeric Windows coverage for this step is the P4-T9 value from the same head. The P0-T16
  baseline for the same call was also `ok: true`.
- [x] [P3-T4] QC step 4 (bash format) into `<FEATURE>/evidence/qa-gates/qc-bash-format.<ts>.md`. Pre-pass observation:
  `git status --porcelain -- scripts/ tools/ .claude/lib/bash/ .claude/skills/` and
  `sha256sum scripts/bash/shell_qc_lib.sh scripts/bash/kcov_trace_env.sh`. Run `sh scripts/bash/shell-qc.sh format`. Post-pass
  observation: re-run both commands. Acceptance: exit 0; the post-pass porcelain listing and hashes equal the pre-pass values (the
  executed plan recorded `LOCAL-DRIFT: NONE`, so the formatter has nothing to rewrite). A changed path outside this plan's file list is
  restored with `git restore -- <path>`, recorded as `FORMAT-DRIFT: <path>`, and the plan outcome is returned to the orchestrator.
- [x] [P3-T5] QC step 5 (bash lint) into `<FEATURE>/evidence/qa-gates/qc-bash-check.<ts>.md` with `ExpectedExitCode: 0`: run
  `sh scripts/bash/shell-qc.sh check`. Acceptance: exit 0 and no output (the success-case output of this command was observed as
  empty in `qc-bash-check.2026-10-01T17-23.md`).
- [x] [P3-T6] QC step 6 (full bash test with the kcov simulation active) into
  `<FEATURE>/evidence/qa-gates/qc-shell-qc-test-full.<ts>.md`. Record `date -u +%Y-%m-%dT%H-%M-%S` as `RUN_START`, run
  `SHELL_QC_BATS_BIN=<BATS_DIRECT> sh scripts/bash/shell-qc.sh test` in the background with output redirected to
  `<session-scratchpad>/shell-qc-test-final.log`, then record the exit code from the completion notification and `RUN_END` from
  `date -u +%Y-%m-%dT%H-%M-%S`. The artifact's `Command:` field holds the full command line above with `<BATS_DIRECT>` replaced by the
  recorded `<npm-cache>` path form (this addresses the code-review Minor finding on AC-15 reproducibility). Acceptance: exit 0; the
  log contains a TAP plan line of the form `1..N` (recorded as a number; the earlier run printed `1..501`) and no line matching `not ok`
  (the command `grep -c -E '^not ok' <session-scratchpad>/shell-qc-test-final.log` prints `0` and exits 1; it is recorded alone, with
  `ExpectedExitCode: 1`, in `<FEATURE>/evidence/qa-gates/qc-shell-qc-test-not-ok.<ts>.md`); wall time derived from `RUN_START` and
  `RUN_END` is recorded (not gated). When P0-T11 or P0-T12 recorded `BATS-DIRECT: UNAVAILABLE`, record `LOCAL-FULL-RUN: UNAVAILABLE`;
  AC-21 then stays unchecked.
- [x] [P3-T7] QC step 7 (Python parity test) into `<FEATURE>/evidence/qa-gates/qc-pytest-claude-resource-contracts.<ts>.md`: run
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Acceptance: exit 0 and the summary line
  reports `passed` with no `failed` (the executed plan recorded `14 passed`). If the only failure is the known bundle-parity case
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (issue #510), record `KNOWN-ISSUE-510` with the output of
  `git status --porcelain --ignored -- .claude/state` and cite the CI `quality-checks7` job conclusion from P4-T4 for the AC-21 pytest part.
- [x] [P3-T8] Supplementary workflow lint into `<FEATURE>/evidence/qa-gates/qc-actionlint-direct.<ts>.md` with
  `ExpectedExitCode: 0`: run `actionlint .github/workflows/_poshqc.yml` (binary on PATH). Acceptance: exit 0 and no output, as in
  `qc-actionlint.2026-10-01T17-23.md`. The artifact states that this is supplementary evidence only and that the wrapper run named by
  AC-5 and AC-21 is the operator-run item above. No workflow file is edited by this plan, so the result is expected to match.
- [x] [P3-T9] Verify line counts for the edited files (AC-22) into `<FEATURE>/evidence/qa-gates/line-counts.<ts>.md`: run `wc -l`
  over the five files of P0-T8 plus every file listed in the latest P4-T11 artifact. Acceptance: every count is at most 500.
- [x] [P3-T10] Verify that the edited tests create no temporary files (AC-22) into `<FEATURE>/evidence/qa-gates/no-temp-files.<ts>.md`
  with `ExpectedExitCode: 1`, holding only the command
  `git diff -U0 dcb2abf1 -- tests/ | grep -c -E '^\+.*(mktemp|New-TemporaryFile|GetTempFileName|GetTempPath|TestDrive)'` where `dcb2abf1` is replaced by the
  40-character `<START_SHA>`. Acceptance: the count prints `0` and exits 1 (the diff covers only this cycle's test edits).
- [x] [P3-T11] Verify that no skip was added (AC-10) into `<FEATURE>/evidence/qa-gates/no-unconditional-skip.<ts>.md` with
  `ExpectedExitCode: 1`, holding only the command
  `git diff -U0 41217012d31d35c2ee33a50be50684affd2f5f43 -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/ | grep -c -E '^\+.*-Skip([[:space:]]|$|:\$true)'`.
  Acceptance: the count prints `0` and exits 1 (the P0-T9 baseline was also `0`).
- [x] [P3-T12] Verify that no skipped-result call was added into `<FEATURE>/evidence/qa-gates/no-set-itresult.<ts>.md` with
  `ExpectedExitCode: 1`, holding only the command
  `git diff -U0 41217012d31d35c2ee33a50be50684affd2f5f43 -- tests/scripts/codex-hooks/ tests/scripts/claude-hooks/ | grep -c -F -e 'Set-ItResult'`.
  Acceptance: the count prints `0` and exits 1.
- [x] [P3-T13] Verify the cycle scope (AC-20 and the Do-Not-Do list) into `<FEATURE>/evidence/qa-gates/scope-check.<ts>.md`: run
  `git diff --name-only <START_SHA>` (with the 40-character value substituted) and `git status --porcelain`. Acceptance: every listed
  path is one of the five test files of P0-T8, a file listed in the latest P4-T11 artifact, or lies under `<FEATURE>/`; no path under `.github/`, `.claude/rules/`,
  `.github/instructions/`, `scripts/`, `.claude/hooks/`, or `.codex/` is listed; the porcelain listing shows no path outside that set.
- [x] [P3-T14] Verify that no forbidden path is changed relative to the merge base into
  `<FEATURE>/evidence/qa-gates/scope-forbidden-paths.<ts>.md` with `ExpectedExitCode: 1`, holding only the command
  `git diff --name-only 41217012d31d35c2ee33a50be50684affd2f5f43 | grep -c -E '<R8 pattern>'` with the reference block R8 pattern
  substituted verbatim; the same task also runs `git status --porcelain` into the artifact
  `<FEATURE>/evidence/qa-gates/scope-forbidden-paths-status.<ts>.md` so untracked paths are visible. Acceptance: the count prints `0`
  and exits 1.
- [x] [P3-T15] Record the clean loop pass into `<FEATURE>/evidence/qa-gates/qc-loop-pass.<ts>.md`: the pass number, the artifact paths
  of P3-T1 through P3-T14 of that pass, and the output of `sha256sum` over the five files of P0-T8 plus every file listed in the
  latest P4-T11 artifact, run immediately after P3-T14.
  Acceptance: P3-T1 through P3-T14 all passed in the same pass without changing a file after P3-T1 (the post-pass hashes of P3-T1
  equal these hashes); every artifact path exists.
- [ ] [P3-T16] Commit and push the Phase 3 boundary: write `<session-scratchpad>/commit-msg-p3.txt` from reference block R6, then
  run `git add --` and `git commit -F <session-scratchpad>/commit-msg-p3.txt --` with the paths
  `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-plan.2026-10-01T18-07.md`
  (the test files are already committed by P1-T10, P2-T10, and the P4-T11 contingency commit; a pathspec without changes is accepted), then
  `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743`, then
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743` with `git rev-parse HEAD`, into
  `<FEATURE>/evidence/other/commit-push-p3.<ts>.md`. Acceptance: every command exits 0 and the remote head equals
  `git rev-parse HEAD`.

### Phase 4 — CI Verification on the Pushed Head (R1 to R3, AC-6, AC-10)

Loop rule. When P4-T10 lists further failures, P4-T11 fixes them, the loop restarts at P3-T1, and P4-T1 through P4-T9 repeat against a
new `<RUN_ID>` into new timestamped artifacts. The artifacts of the superseded run are kept.

- [ ] [P4-T1] Record the CI head into `<FEATURE>/evidence/qa-gates/ci-remediation-head.<ts>.md` (several command pairs):
  `git rev-parse HEAD` (this value is `<CI_SHA>`), `git status --porcelain -- scripts/ tests/ .github/ .claude/skills/ extensions/`, and
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743`. Acceptance: the porcelain listing prints nothing; the
  remote head equals `<CI_SHA>`.
- [ ] [P4-T2] Dispatch the verification run of `.github/workflows/ci.yml` (so the checks carry their `poshqc / ...` names) into
  `<FEATURE>/evidence/qa-gates/ci-remediation-run.<ts>.md`: record the dispatch time with `date -u +%Y-%m-%dT%H:%M:%SZ`, run
  `gh workflow run ci.yml --ref bug/ci-gaps-linux-pester-and-kcov-set-u-743`, and repeat
  `gh run list --workflow=ci.yml --branch bug/ci-gaps-linux-pester-and-kcov-set-u-743 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt`
  until it returns a run created after the dispatch time; its `databaseId` is `<RUN_ID>`. Acceptance: the run's `headSha` equals
  `<CI_SHA>`.
- [ ] [P4-T3] Wait for the run to complete into `<FEATURE>/evidence/qa-gates/ci-remediation-complete.<ts>.md`: start
  `gh run watch <RUN_ID>` in the background (Bash tool background mode), then run `gh run view <RUN_ID> --json status,conclusion`
  after the watch exits. Acceptance: `status` is `completed`. The overall conclusion is recorded and is not asserted here, because
  jobs owned by other items can fail independently.
- [ ] [P4-T4] Record the job and step conclusions (R1, R3, AC-6, AC-7, AC-16) into
  `<FEATURE>/evidence/qa-gates/ci-remediation-conclusions.<ts>.md`: run `gh run view <RUN_ID> --json jobs,headSha` piped into
  `poetry run python <session-scratchpad>/pester_xml_summary.py jobs`. Acceptance: the `HEAD-SHA:` line equals `<CI_SHA>`; the
  `JOB:` lines for `poshqc / PowerShell hook suites (Linux)` (its `databaseId` is `<LINUX_JOB_ID>`),
  `poshqc / PowerShell QC` (its `databaseId` is `<WINDOWS_JOB_ID>`), and `shell-coverage / Shell Coverage (Bats + kcov)` each end with
  `success`; the `STEP:` lines for `<WINDOWS_JOB_ID>` named `Format PowerShell` and `Analyze PowerShell` end with `success`. The conclusions
  of jobs owned by other items are recorded and not asserted. A `failure` of the Linux job proceeds to P4-T10 with AC-6 left unchecked. When the acceptance is not met, record the observed values in the artifact, leave this task unchecked, and continue to P4-T5.
- [ ] [P4-T5] Record the Linux log result (AC-6) into `<FEATURE>/evidence/qa-gates/ci-remediation-linux-log.<ts>.md`: run
  `gh run view <RUN_ID> --log --job <LINUX_JOB_ID>` filtered with `grep -F 'Tests Passed:'`. Acceptance: exactly one line is printed and it
  contains `Failed: 0,` (the line shape `Tests Passed: N, Failed: F, Skipped: S, ...` was observed on the baseline run). When the acceptance
  is not met, record the observed values in the artifact, leave this task unchecked, and continue to P4-T10; the task is re-run in the
  next Phase 4 loop iteration.
- [ ] [P4-T6] Record the Linux JUnit result (AC-6) into `<FEATURE>/evidence/qa-gates/ci-remediation-linux-junit.<ts>.md`: run
  `gh run download <RUN_ID> --name poshqc-linux-hook-test-results --dir <session-scratchpad>/linux-final-743-<RUN_ID>` and
  `poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/linux-final-743-<RUN_ID>/pester-junit-linux-hooks.xml`.
  Acceptance: the `JUNIT-ROOT:` line reports `failures=0 errors=0` (the `tests` value is recorded and is not asserted); no `FAIL:` line is
  printed; the `SUITE:` lines for `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`,
  `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`, and `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`
  report `failures=0` (AC-8 and AC-9 on Linux). When the acceptance is not met, record the observed values in the artifact, leave this
  task unchecked, and continue to P4-T10; the task is re-run in the next Phase 4 loop iteration.
- [ ] [P4-T7] Record the named AC-10 inventory result into `<FEATURE>/evidence/qa-gates/ci-remediation-inventory.<ts>.md`: run
  `poetry run python <session-scratchpad>/pester_xml_summary.py inventory <session-scratchpad>/linux-final-743-<RUN_ID>/pester-junit-linux-hooks.xml`.
  Acceptance: the output contains the line `INVENTORY-SUMMARY: pass=<12 + k> fail=0 missing=0 other-fail=0` and one `ROW n: PASS` line for
  each of the 12 + k rows, where k is the number of rows P4-T11 appended to the helper `INVENTORY` (k is 0 when P4-T11 recorded
  `CONTINGENCY: NOT-APPLICABLE`; with k = 0 the line is `INVENTORY-SUMMARY: pass=12 fail=0 missing=0 other-fail=0` and the rows are
  n = 1 to 12). The P0-T4 baseline for the same command was `pass=0 fail=12 missing=0 other-fail=0`, so this assertion could fail. When
  the acceptance is not met, record the observed values in the artifact, leave this task unchecked, and continue to P4-T10; the task is
  re-run in the next Phase 4 loop iteration.
- [ ] [P4-T8] Record the Windows log result (AC-7) into `<FEATURE>/evidence/qa-gates/ci-remediation-windows-log.<ts>.md`: run
  `gh run view <RUN_ID> --log --job <WINDOWS_JOB_ID>` filtered with `grep -F 'Tests Passed:'`. Acceptance: exactly one line is printed and
  it contains `Failed: 0,`. If the Windows job failed, this artifact also records the failing test lines from the same log, filtered with
  `grep -F '[-]'` (executed-plan deviation D11: no result file is uploaded when the job fails). When the acceptance is not met, record the
  observed values in the artifact, leave this task unchecked, and continue to P4-T10; the task is re-run in the next Phase 4 loop
  iteration.
- [ ] [P4-T9] Record the Windows JUnit and coverage results (AC-7, AC-21 coverage part) into
  `<FEATURE>/evidence/qa-gates/ci-remediation-windows-results.<ts>.md`: run
  `gh run download <RUN_ID> --name poshqc-test-results --dir <session-scratchpad>/windows-final-743-<RUN_ID>`, then
  `poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/windows-final-743-<RUN_ID>/pester-junit.xml`, then
  `poetry run python <session-scratchpad>/pester_xml_summary.py coverage <session-scratchpad>/windows-final-743-<RUN_ID>/powershell-coverage.xml`.
  When P4-T4 recorded the Windows job as `failure`, skip the download, record `WINDOWS-RESULTS: NOT-UPLOADED (D11)` in the artifact, and
  take the evidence from P4-T8.
  Acceptance: the `JUNIT-ROOT:` line reports `failures=0 errors=0`; no `FAIL:` line is printed; the `SUITE:` lines for the four
  suites `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`, `tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1`, `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` report `failures=0 errors=0`; the `PS-LINE-COVERAGE:` percent is
  at least 85.00 and at least the P0-T5 baseline `B_PS` (96.31); the covered and missed counts are recorded as numbers. When the
  acceptance is not met, record the observed values in the artifact, leave this task unchecked, and continue to P4-T10; the task is
  re-run in the next Phase 4 loop iteration.
- [ ] [P4-T10] Derive the further-failure set into `<FEATURE>/evidence/qa-gates/ci-remediation-further-failures.<ts>.md`: the set is the
  union of (a) the `OTHER-FAIL:` lines of the P4-T7 output, (b) any `FAIL:` line of the P4-T6 or P4-T9 output, and (c) when P4-T8 recorded
  failing `[-]` log lines, the file and test name of each, and (d) each of the three jobs whose `JOB:` line P4-T4 asserts, when that `JOB:` line does
  not end with `success`, and each `STEP:` line of those three jobs that ends with `failure`, `cancelled`, or `timed_out`, that no line
  from (a) to (c) accounts for, plus each P4-T6 or P4-T9 download that fails. A step whose conclusion is `skipped` is not a failure, and
  jobs owned by other items are not included. Each (d) item is recorded as `UNATTRIBUTED: <job name> | <step name>`, with `job` in place
  of the step name for a job-level item and `download <artifact name>` for a failed download. Record `FURTHER-FAILURES: NONE` when the union is empty; otherwise record
  `FURTHER-FAILURES:` followed by one line per failing test with its file path, and its failure message from the job log. The log filters
  run only in this otherwise case, one pair per failing job, each in its own artifact: `gh run view <RUN_ID> --log --job <job id>` filtered with
  `grep -F 'DriveNotFoundException'` into `<FEATURE>/evidence/qa-gates/ci-remediation-further-failures-drivenotfound-<job id>.<ts>.md`, and
  `gh run view <RUN_ID> --log --job <job id>` filtered with `grep -F 'Error:'` into
  `<FEATURE>/evidence/qa-gates/ci-remediation-further-failures-error-<job id>.<ts>.md`. Each of those artifacts carries `ExpectedExitCode: 1`
  when its filter prints nothing and carries no expectation field when it prints at least one line.
  Acceptance: the `ci-remediation-further-failures.<ts>.md` artifact contains exactly one `FURTHER-FAILURES:` declaration.
- [ ] [P4-T11] Contingency fix. When P4-T10 recorded `FURTHER-FAILURES: NONE`, record `CONTINGENCY: NOT-APPLICABLE (no further
  failures)` in `<FEATURE>/evidence/qa-gates/ci-remediation-contingency.<ts>.md` and this task is complete. Otherwise, apply the
  following steps in order. When P4-T10 recorded any `UNATTRIBUTED:` line, record it in the contingency artifact, report it to the
  orchestrator (BLOCKED), and stop.
  (1) A failing path outside `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/` is not edited: report it to the
  orchestrator (BLOCKED) and stop. For each file path P4-T10 listed under those two folders, steps (2) to (6) apply.
  (2) Before editing a listed file, record one command, `grep -c -F -e '-Skip'` followed by every listed file, into
  `<FEATURE>/evidence/qa-gates/ci-remediation-contingency-skip-before.<ts>.md` (`ExpectedExitCode: 1` when every printed count is `0`,
  otherwise no expectation field).
  (3) Edit each listed file with the portable pattern of reference block R3 (an OS-derived synthetic root; no skip; the asserted behavior
  is the same on both hosts); keep the file at 500 lines or fewer (a file above 460 lines is edited with one-line replacements only);
  record each edited file and its fix in `ci-remediation-contingency.<ts>.md`. A failure whose cause is not a host-specific path literal is
  reported to the orchestrator (BLOCKED) without editing.
  (4) For each new failing test, append one tuple to `INVENTORY` in `<session-scratchpad>/pester_xml_summary.py` (next row number after the
  last existing row, repository path of the file, and an `It`-name fragment), record each tuple in `ci-remediation-contingency.<ts>.md`
  as a new inventory row for P5-T1, and record the count of appended tuples as `k`. P4-T7 then asserts `pass=<12 + k>`.
  (5) Acceptance checks: `wc -l` for each edited file prints at most 500; one command, `grep -c -F -e '-Skip'` followed by every edited file, run after the edit
  into `<FEATURE>/evidence/qa-gates/ci-remediation-contingency-skip-after.<ts>.md` (`ExpectedExitCode: 1` when every printed count is `0`,
  otherwise no expectation field), prints the same count per file as the step (2) artifact recorded.
  (6) Commit the edited files: write `<session-scratchpad>/commit-msg-p4c.txt` from reference block R6, run `git add --` and
  `git commit -F <session-scratchpad>/commit-msg-p4c.txt --` with the paths of the edited test files and the `<FEATURE>/evidence/`
  folder, then `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743` and
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743` with `git rev-parse HEAD`, into
  `<FEATURE>/evidence/other/commit-push-contingency.<ts>.md`; every command exits 0 and the remote head equals `git rev-parse HEAD`.
  Then restart the loop at P3-T1. P3-T1 to P3-T16 and P4-T1 to P4-T10 are repeated, until P4-T10 records `FURTHER-FAILURES: NONE`. When the repeated P4-T10 lists further failures, P4-T11 is applied again into new timestamped artifacts.
- [ ] [P4-T12] Commit and push the Phase 4 boundary: write `<session-scratchpad>/commit-msg-p4.txt` from reference block R6, then run
  `git add --` and `git commit -F <session-scratchpad>/commit-msg-p4.txt --` with the paths
  `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-plan.2026-10-01T18-07.md`,
  then `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743`, then
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743` with `git rev-parse HEAD`, into
  `<FEATURE>/evidence/other/commit-push-p4.<ts>.md`. Acceptance: every command exits 0 and the remote head equals `git rev-parse HEAD`.

### Phase 5 — Inventory Closure, Acceptance Check-off, and Final Scope

- [ ] [P5-T1] Write the closed AC-10 inventory `<FEATURE>/evidence/qa-gates/linux-first-run-failures.<ts>.md` as a new timestamped copy of
  `<FEATURE>/evidence/qa-gates/linux-first-run-failures.2026-10-01T17-57.md`: keep its 21 rows, replace the `Fix` text of rows 1 to 12 with
  the reference block R4 descriptions, add any P4-T11 rows, and set every row's `Final status` to the literal
  `PASSING (remediation P4-T7)`. The literal `REMEDIATION-REQUIRED` also appears in the `Planned disposition` column of rows 1 to 12 and
  in the closing paragraph (line 33) of the source file, so the task also replaces the `Planned disposition` text of rows 1 to 12 with
  `remediation cycle 1 (P1-T1 to P2-T4)` and replaces the closing paragraph with
  `All rows are closed on the remediation inventory run (P4-T7). Unconditional-skip check: no-unconditional-skip.<ts>.md (P3-T11).`, where
  `<ts>` is the timestamp of the P3-T11 artifact. Acceptance: `grep -c -F -e 'PASSING (remediation P4-T7)' <that file>` prints the row count (21, plus the
  number of P4-T11 rows), and `grep -c -F -e 'REMEDIATION-REQUIRED' <that file>` prints `0` and exits 1. The first check is recorded in
  `<FEATURE>/evidence/qa-gates/inventory-closed-passing.<ts>.md`. The second is recorded alone, with `ExpectedExitCode: 1`, in
  `<FEATURE>/evidence/qa-gates/inventory-closed-absent.<ts>.md`. Neither command is written into the inventory file.
- [ ] [P5-T2] Write the coverage comparison `<FEATURE>/evidence/qa-gates/coverage-comparison.<ts>.md`: PowerShell baseline `B_PS` (P0-T5)
  and post-change (P4-T9) `covered`, `missed`, and `percent`, plus a statement that the changed files (the five files of P0-T8 plus every file listed in the P4-T11 artifacts) are tests and no production
  PowerShell file changed. Acceptance: every value is numeric; the post-change percent is at least 85.00 and at least `B_PS`; a missing
  value makes the outcome remediation-required.
- [ ] [P5-T3] Record the operator-run item into `<FEATURE>/evidence/other/operator-run-items.<ts>.md`: the exact command
  `pwsh -NoProfile -File scripts/dev-tools/run-actionlint.ps1 .github/workflows/_poshqc.yml` as an operator command that was not run by the
  executor, the expected result (exit 0, no findings), the destination `<FEATURE>/evidence/qa-gates/`, the paths of the supplementary
  direct-actionlint artifacts (`qc-actionlint-direct.<ts>.md` from P3-T8 and `qc-actionlint.2026-10-01T17-23.md`), and the statement that AC-5 and
  AC-21 remain unchecked. Acceptance: the artifact exists and contains the operator command verbatim once
  (`grep -c -F -e 'run-actionlint.ps1 .github/workflows/_poshqc.yml' <that file>` prints `1`). The check is recorded in
  `<FEATURE>/evidence/other/operator-run-items-check.<ts>.md`, not in the operator-run-items file.
- [ ] [P5-T4] Check off AC-6 in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`, changing only
  `- [ ] AC-6:` to `- [x] AC-6:`, after P4-T4, P4-T5, and P4-T6 passed. Record the run ID and `<LINUX_JOB_ID>` in
  `<FEATURE>/evidence/qa-gates/ac-6-run-record.<ts>.md` (the spec requires the run ID in `<FEATURE>/evidence/qa-gates/`). Acceptance:
  `grep -c -F -e '- [x] AC-6:' <spec.md path>` prints `1`.
- [ ] [P5-T5] Check off AC-10 in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md`, changing only
  `- [ ] AC-10:` to `- [x] AC-10:`, after P4-T7, P5-T1, and P3-T11 passed. Acceptance:
  `grep -c -F -e '- [x] AC-10:' <spec.md path>` prints `1`.
- [ ] [P5-T6] Verify the AC-5 and AC-21 state in `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md` into
  `<FEATURE>/evidence/qa-gates/spec-ac-state.<ts>.md`: run `grep -c -F -e '- [x] AC-' <spec.md path>` and
  `grep -c -F -e '- [ ] AC-' <spec.md path>`, then `grep -n -F -e '- [ ] AC-5:' -e '- [ ] AC-21:' <spec.md path>`. Acceptance: the counts are
  `20` and `2`, and the third command prints exactly the AC-5 and AC-21 lines. AC-21 is not checked because its actionlint wrapper step is not
  evidenced (operator-run item); AC-5 is not checked for the same reason.
- [ ] [P5-T7] Write the evidence index `<FEATURE>/evidence/other/ac-evidence-index.<ts>.md`: one line per AC-1 through AC-22 naming its
  satisfying artifact paths and status (`PASS`, `OPERATOR-PENDING`, or `REMEDIATION-REQUIRED`), then the plan outcome line and the
  Acceptance Criteria Status summary of the acceptance-criteria-tracking skill (source, total, checked, remaining, remaining items).
  Expected statuses: AC-5 and AC-21 `OPERATOR-PENDING`; all others `PASS`; outcome `OPERATOR-PENDING` (20 of 22 PASS; the wrapper run
  remains). Acceptance: `grep -c -E '^- AC-[0-9]+:' <that file>` prints `22`, one outcome line exists, and every AC's status agrees with its
  checkbox in `spec.md` (P5-T6). The `Items remaining` entry lists the remaining AC IDs inline on one line (for example
  `Items remaining: AC-5, AC-21`) and does not use lines beginning `- AC-`, so the count of `^- AC-` lines reflects only the 22 index lines.
- [ ] [P5-T8] Verify the post-CI scope into `<FEATURE>/evidence/other/post-ci-scope.<ts>.md`: run `git diff --name-only <CI_SHA>` (40-character
  value) and `git status --porcelain`. Acceptance: every listed path lies under `<FEATURE>/`; the artifact states that `<CI_SHA>` identifies the
  code verified by P4-T4 to P4-T9 and that only feature-folder documents changed after it.
- [ ] [P5-T9] Commit and push the final state: write `<session-scratchpad>/commit-msg-p5.txt` from reference block R6, then run `git add --`
  and `git commit -F <session-scratchpad>/commit-msg-p5.txt --` with the paths
  `docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/spec.md docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/evidence/ docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/remediation-plan.2026-10-01T18-07.md`,
  then `git push origin bug/ci-gaps-linux-pester-and-kcov-set-u-743`, then
  `git ls-remote origin refs/heads/bug/ci-gaps-linux-pester-and-kcov-set-u-743` with `git rev-parse HEAD`, then
  `git diff --name-only <CI_SHA> HEAD` with `git status --porcelain`, into `<FEATURE>/evidence/other/commit-push-final.<ts>.md` (written after the
  commit; it is committed by the commit/PR stage in a commit restricted to `<FEATURE>/`). The path-filter command
  `git diff --name-only <CI_SHA> HEAD | grep -c -v -F -e 'docs/features/active/2026-09-27-ci-gaps-linux-pester-and-kcov-set-u-743/'` runs into its own
  artifact `<FEATURE>/evidence/other/final-delta-docs-only.<ts>.md` with `ExpectedExitCode: 1`. Acceptance: every command of the first artifact exits
  0; the remote head equals `git rev-parse HEAD`; the path-filter count prints `0` and exits 1 (the final head differs from `<CI_SHA>` by feature-folder
  documents only, so the CI conclusions of P4-T4 describe every code, test, workflow, and skill file at the final head).
