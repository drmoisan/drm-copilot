# 2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding (Remediation Plan, Cycle 1)

- **Issue:** #543
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-02T05-58
- **Status:** Ready for preflight
- **Version:** 1.1
- **Work Mode:** full-bug
- **Branch:** `bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`
- **Requirements source:** `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-inputs.2026-10-02T05-58.md`, findings R1 (PA-1, CR-1) and R2 (PA-2, CR-2), both Blocking and autonomous. Acceptance criterion source: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`, `## Acceptance Criteria`, AC-19 (line 332, currently unchecked).
- **Supporting inputs:** `policy-audit.2026-10-02T05-58.md`, `code-review.2026-10-02T05-58.md`, `feature-audit.2026-10-02T05-58.md`, and the original plan `plan.2026-09-29T16-06.md`, all in the same feature folder.

**Scope statement:** Evidence-only remediation. No production file and no test file is changed by this plan. R1 regenerates the TypeScript coverage for the full Jest suite with the configured `lcov` reporter, records lcov-derived per-file values for the five changed TypeScript production files, and re-ticks AC-19 only when every gate passes. R2 follows `remediation-inputs.2026-10-02T05-58.md` R2 required changes 1 to 4: in each of the 35 artifacts under `evidence/regression-testing/` and `evidence/qa-gates/` it replaces the value on the existing line-3 `Timestamp:` row with the corrected value and inserts one correction line directly below it, renames no file, rewrites no cross-reference, and records deviations D1, D2, D3, and D-TIMESTAMPS in the original plan. If any R1 gate fails, the plan stops before AC-19 is ticked and reports that a plan revision is required (remediation-inputs R1 step 5 test additions); tests are not added under this plan.

**Fail-closed evidence rule:** Every evidence-producing task names its artifact. A task stays unchecked while its artifact is absent, incomplete, or carries a placeholder in place of a numeric value. A failed stop condition makes the cycle outcome BLOCKED, never PASS.

**Evidence location:** All evidence resolves under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/<kind>/`, with `<kind>` drawn from `remediation-baseline`, `qa-gates`, and `other`. No artifact of this plan is written under `evidence/regression-testing/` (P2-T5 depends on that). `extensions/drm-copilot/coverage/lcov.info` is a gitignored tool output that the evidence cites; it is not an evidence artifact.

---

## Decisions fixed by this plan

1. **R1 command.** The coverage run is `npm run test:coverage --prefix extensions/drm-copilot -- --coverageReporters=text`. The `test:coverage` script (`extensions/drm-copilot/package.json` line 213) expands to `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` in `extensions/drm-copilot/`, and the trailing argument appends the `text` reporter. The effective reporter set is `lcov`, `text-summary`, and `text`, which is the configured pair in `extensions/drm-copilot/jest.config.cjs` line 18 plus `text`. The `--prefix` form runs with `extensions/drm-copilot/` as the working directory without a `cd` chain. No prohibited flag (`--passWithNoTests`, `--onlyChanged`, `--lastCommit`; `extensions/drm-copilot/run-jest.cjs` line 9) is passed. This one run satisfies the command intent of AC-19 and writes `extensions/drm-copilot/coverage/lcov.info` (`coverageDirectory`, `jest.config.cjs` line 19).
2. **R1 lcov fields.** The lcov file is `extensions/drm-copilot/coverage/lcov.info`. Each record starts with an `SF:` line whose value is `src\lib\validate\<file>.ts` on this host (observed form; the script also accepts forward slashes and absolute paths ending in the same suffix), carries `DA:<line>,<hits>` rows, and carries `LF:`, `LH:`, `BRF:`, and `BRH:` rows before `end_of_record`. Line percentage is `LH/LF` and branch percentage is `BRH/BRF`, both floored to two decimals, which is the rounding Istanbul uses for the `text` table. The 85% line and 75% branch floors are evaluated with integer arithmetic on the raw counts.
3. **R1 baseline.** No baseline lcov artifact exists. The baseline per-file values are the `text` rows recorded in `evidence/baseline/baseline-typescript-test-coverage.2026-10-02T05-01.md` lines 13-17 (pre-change code). Regenerating a baseline lcov would require running the suite against the merge-base code and is outside this evidence-only cycle. The comparison rule is no decrease: each lcov-derived post-change percentage must be greater than or equal to the recorded baseline percentage.
4. **R2 corrected value (derivation).** The corrected `Timestamp:` value for each of the 35 artifacts is the "Corrected `Timestamp:` value" column of the R2 table in `remediation-inputs.2026-10-02T05-58.md` (lines 71-107): the reviewer-observed file write time, read from the host file system before any edit and floored to the minute. That table is a fixed, in-repository source, so a third party re-reading it obtains the same 35 values. The commit-time derivation offered as an example in the delegation was not adopted: a file committed in a later minute than it was written would receive a value later than its write time, which violates the R2 definition of done. Commit times are used instead as a falsifiable cross-check (P2-T1): every corrected value must be at or before the author time of the last commit that touched the file at `ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81`, and the three fail-before values must be at or before their fix commits.
5. **R2 no rename, no reference rewrite.** Per R2 required change 3 (`remediation-inputs.2026-10-02T05-58.md` line 113) and the orchestrator ruling for this revision, which supersedes the earlier rename instruction, no file is renamed and no cross-reference in any file is rewritten. Each of the 35 files keeps its current path. Its filename suffix retains the composed value and is not a clock reading; the D-TIMESTAMPS entry (P2-T3) states this. Because no path changes, every existing in-repository reference to these files remains valid, and this plan carries no reference inventory.
6. **R2 content rule.** In each of the 35 files the only changes are: the value on line 3 (the existing first `Timestamp:` row, R2 required change 1) and one inserted line 4 whose text is R2 required change 2 verbatim (`remediation-inputs.2026-10-02T05-58.md` line 112; text fixed below). No `Command:`, `EXIT_CODE:`, or `ExpectedExitCode:` line, no recorded output, and no path reference changes (R2 required change 4). P2-T4 and P3-T4 verify this byte for byte against the blobs at `ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81`.
7. **D1 definition.** D1 is recorded as the evidence defines it (`evidence/baseline/phase0-instructions-read.md` line 23 and `evidence/baseline/scope-confirmation.2026-10-02T05-01.md` line 61: merge adaptation after `ef80c57d` was merged), not as the shorter "orchestrator-supplied anchors" wording in the remediation-inputs.
8. **Out of scope for this cycle.** N1 / PA-3 (the 18 Phase 0 artifacts with a reused `05-01` value), the second `Timestamp:` row at line 31 of `evidence/other/python-batch-budget.2026-10-02T05-01.md`, CR-3, CR-6, CR-7 (optional code or test changes), and CR-8 (PR wording, handled at PR authoring). `scripts/dev_tools/validate_orchestration_artifacts.py`, `.claude/**`, and `.github/**` are not modified.
9. **No production or test code change is required.** The executor transcription of the final run shows every changed TypeScript production file above both floors (`final-typescript-test-coverage.2026-10-02T06-35.md` lines 15-19: lowest 91.62% lines and 84.28% branches). If the lcov-derived values disagree, the plan stops at P1-T5 and reports.

## Fixed R2 mapping (35 artifacts)

Directory prefix: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/`. "File name" is the current filename, which this plan does not change. Values are transcribed from `remediation-inputs.2026-10-02T05-58.md` lines 73-107.

| # | Kind | File name | Recorded value | Corrected value | Observed write time |
|---|---|---|---|---|---|
| 1 | regression-testing | fail-before-python.2026-10-02T05-20.md | 2026-10-02T05-20 | 2026-10-02T05-15 | 05:15:41 |
| 2 | regression-testing | fail-before-typescript.2026-10-02T05-20.md | 2026-10-02T05-20 | 2026-10-02T05-16 | 05:16:17 |
| 3 | regression-testing | pass-after-python.2026-10-02T05-30.md | 2026-10-02T05-30 | 2026-10-02T05-18 | 05:18:53 |
| 4 | regression-testing | pass-after-typescript.2026-10-02T05-40.md | 2026-10-02T05-40 | 2026-10-02T05-21 | 05:21:40 |
| 5 | regression-testing | python-launch-binding-suite.2026-10-02T05-45.md | 2026-10-02T05-45 | 2026-10-02T05-23 | 05:23:31 |
| 6 | regression-testing | python-launch-evidence-suite.2026-10-02T05-45.md | 2026-10-02T05-45 | 2026-10-02T05-24 | 05:24:18 |
| 7 | regression-testing | typescript-launch-binding-suite.2026-10-02T05-55.md | 2026-10-02T05-55 | 2026-10-02T05-27 | 05:27:17 |
| 8 | regression-testing | typescript-evidence-and-dispatch-suites.2026-10-02T06-00.md | 2026-10-02T06-00 | 2026-10-02T05-28 | 05:28:41 |
| 9 | regression-testing | fail-before-guidance.2026-10-02T06-05.md | 2026-10-02T06-05 | 2026-10-02T05-29 | 05:29:45 |
| 10 | regression-testing | pass-after-guidance.2026-10-02T06-10.md | 2026-10-02T06-10 | 2026-10-02T05-33 | 05:33:49 |
| 11 | regression-testing | targeted-python.2026-10-02T06-15.md | 2026-10-02T06-15 | 2026-10-02T05-34 | 05:34:53 |
| 12 | regression-testing | targeted-typescript.2026-10-02T06-15.md | 2026-10-02T06-15 | 2026-10-02T05-35 | 05:35:28 |
| 13 | regression-testing | generated-orchestrator-invariant.2026-10-02T06-20.md | 2026-10-02T06-20 | 2026-10-02T05-36 | 05:36:01 |
| 14 | qa-gates | final-python-format.2026-10-02T06-25.md | 2026-10-02T06-25 | 2026-10-02T05-38 | 05:38:35 |
| 15 | qa-gates | final-python-lint.2026-10-02T06-25.md | 2026-10-02T06-25 | 2026-10-02T05-38 | 05:38:38 |
| 16 | qa-gates | final-python-typecheck.2026-10-02T06-25.md | 2026-10-02T06-25 | 2026-10-02T05-38 | 05:38:42 |
| 17 | qa-gates | final-python-architecture.2026-10-02T06-25.md | 2026-10-02T06-25 | 2026-10-02T05-38 | 05:38:46 |
| 18 | qa-gates | final-python-test-coverage.2026-10-02T06-25.md | 2026-10-02T06-25 | 2026-10-02T05-38 | 05:38:52 |
| 19 | qa-gates | final-python-per-file-coverage.2026-10-02T06-25.md | 2026-10-02T06-25 | 2026-10-02T05-38 | 05:38:59 |
| 20 | qa-gates | final-python-contract.2026-10-02T06-25.md | 2026-10-02T06-25 | 2026-10-02T05-39 | 05:39:15 |
| 21 | qa-gates | final-python-integration.2026-10-02T06-25.md | 2026-10-02T06-25 | 2026-10-02T05-39 | 05:39:33 |
| 22 | qa-gates | loop-restarts.2026-10-02T06-30.md | 2026-10-02T06-30 | 2026-10-02T05-40 | 05:40:27 |
| 23 | qa-gates | final-typescript-format.2026-10-02T06-35.md | 2026-10-02T06-35 | 2026-10-02T05-44 | 05:44:58 |
| 24 | qa-gates | final-typescript-lint.2026-10-02T06-35.md | 2026-10-02T06-35 | 2026-10-02T05-45 | 05:45:00 |
| 25 | qa-gates | final-typescript-typecheck.2026-10-02T06-35.md | 2026-10-02T06-35 | 2026-10-02T05-45 | 05:45:03 |
| 26 | qa-gates | final-typescript-architecture.2026-10-02T06-35.md | 2026-10-02T06-35 | 2026-10-02T05-45 | 05:45:06 |
| 27 | qa-gates | final-typescript-test-coverage.2026-10-02T06-35.md | 2026-10-02T06-35 | 2026-10-02T05-45 | 05:45:12 |
| 28 | qa-gates | final-typescript-contract.2026-10-02T06-35.md | 2026-10-02T06-35 | 2026-10-02T05-45 | 05:45:18 |
| 29 | qa-gates | final-typescript-integration.2026-10-02T06-35.md | 2026-10-02T06-35 | 2026-10-02T05-45 | 05:45:22 |
| 30 | qa-gates | coverage-delta-verification.2026-10-02T06-45.md | 2026-10-02T06-45 | 2026-10-02T05-46 | 05:46:46 |
| 31 | qa-gates | final-qa-clean-pass.2026-10-02T06-45.md | 2026-10-02T06-45 | 2026-10-02T05-47 | 05:47:02 |
| 32 | qa-gates | scope-exclusions.2026-10-02T06-50.md | 2026-10-02T06-50 | 2026-10-02T05-47 | 05:47:13 |
| 33 | qa-gates | scope-verification.2026-10-02T06-50.md | 2026-10-02T06-50 | 2026-10-02T05-47 | 05:47:33 |
| 34 | qa-gates | line-counts-final.2026-10-02T06-50.md | 2026-10-02T06-50 | 2026-10-02T05-47 | 05:47:54 |
| 35 | qa-gates | acceptance-checkoff.2026-10-02T06-55.md | 2026-10-02T06-55 | 2026-10-02T05-48 | 05:48:23 |

Each of the 35 files carries exactly one `Timestamp:` row, on line 3, and no correction line at planning time (observed with a recursive search of both directories, which returned 13 and 22 rows respectively, all on line 3). No line in either directory uses a CRLF ending at planning time; the scripts preserve whatever ending line 3 carries.

Inserted line 4 of every corrected file, with `<recorded value>` replaced by that row's "Recorded value" (the text is R2 required change 2 verbatim): `Timestamp-Correction: original value <recorded value> was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper bound on the command run time.`

## Constants

- Pre-remediation implementation head: `ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81` (the audited head).
- Merge base with `origin/main`: `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd` (D2).
- Fix commits for the fail-before ordering check: `af88dd58` (Python fix), `23db0a97` (TypeScript fix), `7ee6d91b` (guidance fix).

## Execution notes

- **Shell.** No PowerShell runs through the shell: no `pwsh`, no `.sh` wrapper. No Pester run is needed by this plan. Heredocs and `cmd; echo` chains are refused, so every command runs alone; commit messages are written with the Write tool to a scratchpad file and committed with `git commit -F <file>`. Multi-line `poetry run python -c` is a no-op; every Python helper is a scratchpad `.py` file run with `poetry run python <scratchpad>/<name>.py` from the worktree root. `<scratchpad>` is the executor session's scratchpad directory, outside the repository.
- **Clock.** Every new artifact's `Timestamp:` value is read with `date +%Y-%m-%dT%H-%M` immediately before the recorded command runs (for an artifact that records no command, immediately before writing it). The same value is the artifact's filename `<ts>`. A reading is never reused across tasks and never composed or estimated.
- **Artifact fields.** Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is non-zero also carries `ExpectedExitCode: <int>`.
- **Content restriction on new artifacts.** No artifact written by this plan may contain a line that begins with `Timestamp-Correction:`; quote that text mid-line or inside backticks. P2-T6 counts files with exactly one such line and expects 35.
- **No rename.** No task runs `git mv`, and no task edits any file other than the 35 artifacts, `plan.2026-09-29T16-06.md`, `spec.md` (P1-T6), this plan's checkboxes, and the new artifacts this plan names.
- **Stops.** A stop condition means: do not run later tasks, leave the failed task unchecked, and report the task ID, the command, and its output to the orchestrator. Do not retry a write-mode script (P2-T2) after a run that wrote any file.
- **Hooks.** If a hook denies a staging, commit, or push command, stop and report; do not route around it.
- **Commit and push.** Each phase ends with a commit-and-push task. Staging is `git add -A -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`. The push is `git push origin bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543` (no force).

## Scratchpad scripts (write verbatim)

`<scratchpad>/ts_coverage_543.py` (P1-T3, P1-T4):

```python
"""Per-file TypeScript coverage and added-line checks for issue 543 (remediation R1)."""

import re
import subprocess
import sys
from pathlib import Path

LCOV = Path("extensions/drm-copilot/coverage/lcov.info")
BASE = "ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd"
TARGETS = [
    "src/lib/validate/epic-orchestrator-state-launch-binding.ts",
    "src/lib/validate/epic-planner-launch-evidence.ts",
    "src/lib/validate/epic-planner-readiness-integrity.ts",
    "src/lib/validate/epic-planner-state-core.ts",
    "src/lib/validate/orchestration-artifacts.ts",
]
HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")
FIELDS = ("LF", "LH", "BRF", "BRH")


def parse_lcov(text):
    records = []
    current = None
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith("SF:"):
            current = {"sf": line[3:].replace("\\", "/"), "da": {}}
        elif current is None:
            continue
        elif line == "end_of_record":
            records.append(current)
            current = None
        elif line.startswith("DA:"):
            parts = line[3:].split(",")
            current["da"][int(parts[0])] = int(parts[1])
        else:
            key, _, value = line.partition(":")
            if key in FIELDS:
                current[key] = int(value)
    return records


def find(records, target):
    found = [r for r in records if r["sf"] == target or r["sf"].endswith("/" + target)]
    if len(found) != 1 or any(key not in found[0] for key in FIELDS):
        return None
    return found[0]


def floor_pct(covered, total):
    return 100.0 if total == 0 else (covered * 10000 // total) / 100


def per_file(records):
    failures = 0
    for target in TARGETS:
        rec = find(records, target)
        if rec is None:
            print(f"MISSING-RECORD {target}")
            failures += 1
            continue
        lf, lh, brf, brh = (rec[key] for key in FIELDS)
        ok = lh * 100 >= 85 * lf and brh * 100 >= 75 * brf
        failures += 0 if ok else 1
        print(
            f"{target} LF={lf} LH={lh} BRF={brf} BRH={brh} "
            f"line={floor_pct(lh, lf):.2f} branch={floor_pct(brh, brf):.2f} "
            f"floors={'PASS' if ok else 'FAIL'}"
        )
    print(f"SUMMARY files={len(TARGETS)} failures={failures}")
    return 0 if failures == 0 else 1


def added_lines(target):
    result = subprocess.run(
        ["git", "diff", "-U0", BASE, "HEAD", "--", "extensions/drm-copilot/" + target],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    added = set()
    for line in result.stdout.splitlines():
        match = HUNK.match(line)
        if match:
            start = int(match.group(1))
            count = int(match.group(2)) if match.group(2) is not None else 1
            added.update(range(start, start + count))
    return added


def added_check(records):
    added_total = 0
    uncovered_total = 0
    for target in TARGETS:
        rec = find(records, target)
        if rec is None:
            print(f"MISSING-RECORD {target}")
            return 1
        lines = added_lines(target)
        executable = [n for n in lines if n in rec["da"]]
        uncovered = sorted(n for n in lines if rec["da"].get(n) == 0)
        added_total += len(lines)
        uncovered_total += len(uncovered)
        listed = ",".join(str(n) for n in uncovered) or "none"
        print(
            f"{target} added={len(lines)} executable_added={len(executable)} "
            f"uncovered_added={listed}"
        )
    print(f"SUMMARY added_total={added_total} uncovered_total={uncovered_total}")
    return 0 if added_total > 0 and uncovered_total == 0 else 1


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    records = parse_lcov(LCOV.read_text(encoding="utf-8"))
    if mode == "per-file":
        return per_file(records)
    if mode == "added":
        return added_check(records)
    print("usage: ts_coverage_543.py per-file|added")
    return 2


if __name__ == "__main__":
    sys.exit(main())
```

`<scratchpad>/mapping_543.py` (imported by the three R2 scripts; `MAPPING` is the 35-row table above as `(kind, file-name stem, recorded value, corrected value)`; the file path is built from the recorded value because no file is renamed):

```python
"""Fixed R2 mapping for issue 543, transcribed from the remediation plan."""

FEATURE = "docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543"
PRE_REMEDIATION_COMMIT = "ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81"
CORRECTION_TEMPLATE = (
    "Timestamp-Correction: original value {old} was composed on a fixed schedule "
    "rather than read from the host clock; the corrected value is the artifact's "
    "observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper "
    "bound on the command run time."
)
RT = "regression-testing"
QA = "qa-gates"
MAPPING = [
    (RT, "fail-before-python", "2026-10-02T05-20", "2026-10-02T05-15"),
    (RT, "fail-before-typescript", "2026-10-02T05-20", "2026-10-02T05-16"),
    (RT, "pass-after-python", "2026-10-02T05-30", "2026-10-02T05-18"),
    (RT, "pass-after-typescript", "2026-10-02T05-40", "2026-10-02T05-21"),
    (RT, "python-launch-binding-suite", "2026-10-02T05-45", "2026-10-02T05-23"),
    (RT, "python-launch-evidence-suite", "2026-10-02T05-45", "2026-10-02T05-24"),
    (RT, "typescript-launch-binding-suite", "2026-10-02T05-55", "2026-10-02T05-27"),
    (RT, "typescript-evidence-and-dispatch-suites", "2026-10-02T06-00", "2026-10-02T05-28"),
    (RT, "fail-before-guidance", "2026-10-02T06-05", "2026-10-02T05-29"),
    (RT, "pass-after-guidance", "2026-10-02T06-10", "2026-10-02T05-33"),
    (RT, "targeted-python", "2026-10-02T06-15", "2026-10-02T05-34"),
    (RT, "targeted-typescript", "2026-10-02T06-15", "2026-10-02T05-35"),
    (RT, "generated-orchestrator-invariant", "2026-10-02T06-20", "2026-10-02T05-36"),
    (QA, "final-python-format", "2026-10-02T06-25", "2026-10-02T05-38"),
    (QA, "final-python-lint", "2026-10-02T06-25", "2026-10-02T05-38"),
    (QA, "final-python-typecheck", "2026-10-02T06-25", "2026-10-02T05-38"),
    (QA, "final-python-architecture", "2026-10-02T06-25", "2026-10-02T05-38"),
    (QA, "final-python-test-coverage", "2026-10-02T06-25", "2026-10-02T05-38"),
    (QA, "final-python-per-file-coverage", "2026-10-02T06-25", "2026-10-02T05-38"),
    (QA, "final-python-contract", "2026-10-02T06-25", "2026-10-02T05-39"),
    (QA, "final-python-integration", "2026-10-02T06-25", "2026-10-02T05-39"),
    (QA, "loop-restarts", "2026-10-02T06-30", "2026-10-02T05-40"),
    (QA, "final-typescript-format", "2026-10-02T06-35", "2026-10-02T05-44"),
    (QA, "final-typescript-lint", "2026-10-02T06-35", "2026-10-02T05-45"),
    (QA, "final-typescript-typecheck", "2026-10-02T06-35", "2026-10-02T05-45"),
    (QA, "final-typescript-architecture", "2026-10-02T06-35", "2026-10-02T05-45"),
    (QA, "final-typescript-test-coverage", "2026-10-02T06-35", "2026-10-02T05-45"),
    (QA, "final-typescript-contract", "2026-10-02T06-35", "2026-10-02T05-45"),
    (QA, "final-typescript-integration", "2026-10-02T06-35", "2026-10-02T05-45"),
    (QA, "coverage-delta-verification", "2026-10-02T06-45", "2026-10-02T05-46"),
    (QA, "final-qa-clean-pass", "2026-10-02T06-45", "2026-10-02T05-47"),
    (QA, "scope-exclusions", "2026-10-02T06-50", "2026-10-02T05-47"),
    (QA, "scope-verification", "2026-10-02T06-50", "2026-10-02T05-47"),
    (QA, "line-counts-final", "2026-10-02T06-50", "2026-10-02T05-47"),
    (QA, "acceptance-checkoff", "2026-10-02T06-55", "2026-10-02T05-48"),
]


def artifact_path(kind, name, recorded):
    return f"{FEATURE}/evidence/{kind}/{name}.{recorded}.md"


def corrected_bytes(original, old, new):
    """Return original with the line-3 value replaced and the correction line inserted, or None."""
    text = original.decode("utf-8", errors="surrogateescape")
    lines = text.splitlines(keepends=True)
    expected = f"Timestamp: {old}"
    if len(lines) < 4 or lines[2].rstrip("\r\n") != expected:
        return None
    if lines[3].startswith("Timestamp-Correction:"):
        return None
    eol = lines[2][len(expected):]
    lines[2] = f"Timestamp: {new}{eol}"
    lines.insert(3, CORRECTION_TEMPLATE.format(old=old) + eol)
    return "".join(lines).encode("utf-8", errors="surrogateescape")
```

`<scratchpad>/crosscheck_r2_543.py` (P2-T1):

```python
"""Cross-check the R2 corrected timestamps against commit times for issue 543."""

import subprocess
import sys

from mapping_543 import MAPPING, PRE_REMEDIATION_COMMIT, artifact_path

DATE_FORMAT = "--date=format-local:%Y-%m-%dT%H-%M"
ORDERING = [
    ("fail-before-python", "af88dd58"),
    ("fail-before-typescript", "23db0a97"),
    ("fail-before-guidance", "7ee6d91b"),
]


def commit_minute(*args):
    result = subprocess.run(
        ["git", "log", "-1", "--format=%ad", DATE_FORMAT, *args],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return result.stdout.strip()


def main():
    late = 0
    corrected = {}
    for kind, name, old, new in MAPPING:
        last = commit_minute(PRE_REMEDIATION_COMMIT, "--", artifact_path(kind, name, old))
        status = "OK" if last and new <= last else "LATE"
        late += status == "LATE"
        corrected[name] = new
        print(f"{kind}/{name} recorded={old} corrected={new} last_commit={last} {status}")
    violations = 0
    for name, sha in ORDERING:
        fix_time = commit_minute(sha)
        status = "OK" if corrected[name] <= fix_time else "AFTER-FIX"
        violations += status != "OK"
        print(f"ORDER {name} corrected={corrected[name]} fix={sha} fix_time={fix_time} {status}")
    print(f"SUMMARY rows={len(MAPPING)} late={late} ordering_violations={violations}")
    return 0 if late == 0 and violations == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
```

`<scratchpad>/apply_r2_543.py` (P2-T2; run once only). It checks all 35 files before writing any file, so a precondition failure leaves the tree unchanged:

```python
"""Correct the line-3 Timestamp value of the 35 R2 artifacts for issue 543, in place."""

import sys
from pathlib import Path

from mapping_543 import MAPPING, artifact_path, corrected_bytes


def main():
    pending = []
    for kind, name, old, new in MAPPING:
        path = Path(artifact_path(kind, name, old))
        if not path.is_file():
            print(f"MISSING {path.as_posix()}")
            return 1
        updated = corrected_bytes(path.read_bytes(), old, new)
        if updated is None:
            print(f"UNEXPECTED-LINE3 {path.as_posix()}")
            return 1
        pending.append((path, updated))
    for path, updated in pending:
        path.write_bytes(updated)
        print(f"CORRECTED {path.as_posix()}")
    print(f"SUMMARY corrected={len(pending)} renamed=0")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

`<scratchpad>/verify_r2_543.py` (P2-T4, P3-T4). For each file it requires the index blob to equal, byte for byte, the `ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81` blob at the same path with only the line-3 value replaced and line 4 inserted:

```python
"""Verify the R2 correction for issue 543 against the pre-remediation blobs."""

import subprocess
import sys

from mapping_543 import (
    CORRECTION_TEMPLATE,
    MAPPING,
    PRE_REMEDIATION_COMMIT,
    artifact_path,
    corrected_bytes,
)

PROTECTED = ("Command:", "EXIT_CODE:", "ExpectedExitCode:")


def show(spec):
    result = subprocess.run(["git", "show", spec], capture_output=True)
    return result.returncode, result.stdout


def text_lines(blob):
    return blob.decode("utf-8", errors="replace").splitlines()


def protected_lines(blob):
    return [line for line in text_lines(blob) if line.startswith(PROTECTED)]


def main():
    matches = 0
    for kind, name, old, new in MAPPING:
        path = artifact_path(kind, name, old)
        base_code, base = show(f"{PRE_REMEDIATION_COMMIT}:{path}")
        index_code, staged = show(f":{path}")
        reasons = []
        expected = corrected_bytes(base, old, new) if base_code == 0 else None
        if expected is None:
            reasons.append("base-line3")
        if index_code != 0:
            reasons.append("path-not-in-index")
        if staged != expected:
            reasons.append("content")
        if protected_lines(staged) != protected_lines(base):
            reasons.append("command-or-exit-line-changed")
        stamps = [line for line in text_lines(staged) if line.startswith("Timestamp:")]
        if stamps != [f"Timestamp: {new}"]:
            reasons.append("timestamp-rows")
        corrections = [line for line in text_lines(staged) if line.startswith("Timestamp-Correction:")]
        if corrections != [CORRECTION_TEMPLATE.format(old=old)]:
            reasons.append("correction-rows")
        if reasons:
            print(f"MISMATCH {path} {','.join(reasons)}")
        else:
            matches += 1
            print(f"MATCH {path}")
    print(f"SUMMARY match={matches} mismatch={len(MAPPING) - matches}")
    return 0 if matches == len(MAPPING) else 1


if __name__ == "__main__":
    sys.exit(main())
```

## Plan Deviations section text (P2-T3)

Append the block below, verbatim, to the end of `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md`, preceded by one blank line. Replace `<P2-T1 ts>` with the actual timestamp in the P2-T1 artifact's filename. Change nothing else in that file.

```markdown
## Plan Deviations

Recorded in remediation cycle 1 by task P2-T3 of `remediation-plan.2026-10-02T05-58.md`, as required by `remediation-inputs.2026-10-02T05-58.md` (R2, required change 3). D1 to D3 were applied during the original execution and are cited by the evidence named with each entry. D-TIMESTAMPS was applied in remediation cycle 1.

D1 (merge adaptation): `origin/main` at `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd` was merged into the branch (merge commit `1b6b06e2`) before Phase 1. Planning-time line numbers in this plan were re-derived before each edit, and edited constructs were located by construct rather than by line number. Sub-items D1.2 to D1.4 are recorded in the regression-testing artifacts that cite them. Sources: `evidence/baseline/phase0-instructions-read.md` line 23 and `evidence/baseline/scope-confirmation.2026-10-02T05-01.md` line 61. The remediation-inputs phrase "orchestrator-supplied anchors" describes D2; D1 is recorded here as the evidence defines it (merge adaptation, `evidence/baseline/phase0-instructions-read.md` line 23).

D2 (literal merge-base SHA): every `(git merge-base origin/main HEAD)` anchor in this plan was executed as the literal SHA `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`. Source: `evidence/baseline/scope-anchor.2026-10-02T05-01.md` line 11.

D3 (no sh-pwsh route): under the operator decision of 2026-10-01 (Option A), no `sh` wrapper and no `pwsh` invocation was used. PowerShell state observations were replaced by native commands (`Route: native (D3)`), and Pester runs by the PoshQC MCP test tool with counts read from `artifacts/pester/pester-junit.xml` (`Route: poshqc-mcp (D3)`). Source: `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`.

D-TIMESTAMPS (composed evidence timestamps): the 35 artifacts listed in the R2 table of `remediation-inputs.2026-10-02T05-58.md`, under `evidence/regression-testing/` and `evidence/qa-gates/`, carried `Timestamp:` values that were composed on a fixed schedule rather than read from the host clock. In remediation cycle 1 the value on each artifact's existing first `Timestamp:` row was replaced with the reviewer-observed file write time from that table, floored to the minute, and one correction line was added directly below that row; no other content of these artifacts was changed. The files were not renamed. Their filename suffixes retain the composed values and are not clock readings. Cross-references to these files were left unchanged and remain valid because no path changed. The derivation, the cross-check against commit times, and the full value mapping are in `evidence/other/timestamp-correction.<P2-T1 ts>.md`.
```

---

### Phase 0 — Policy reads and remediation baseline capture

- [x] [P0-T1] Read the policy files in `policy-compliance-order` order and write `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/phase0-instructions-read.md`.
  - Files, in order: `CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/typescript.md`; `.claude/rules/typescript-suppressions.md`; `.claude/rules/quality-tiers.md`; `.claude/rules/tonality.md`; `.claude/rules/plan-acceptance-gates.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`; then the requirements input `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-inputs.2026-10-02T05-58.md`.
  - Acceptance: the artifact exists with `Timestamp:` (host clock), `Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> TypeScript rules -> quality tiers -> tonality -> plan acceptance gates -> evidence conventions`, and `Files Read:` listing the ten files above in that order. No Phase 1 task begins before this artifact exists.

- [x] [P0-T2] Capture the repository state baseline in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/state-anchor.<ts>.md` by running, each alone from the worktree root: `git rev-parse HEAD`; `git status --porcelain`; `git merge-base --is-ancestor ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd HEAD`; `git diff --stat ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81 HEAD -- extensions scripts tests .claude .github .agents .codex`; `git diff --stat ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81 HEAD -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence`.
  - Acceptance: the artifact carries the four fields, records the 40-character HEAD SHA (referred to below as the remediation start SHA), the porcelain output, exit 0 for the `--is-ancestor` check, and empty output for both `git diff --stat` commands. Stop condition: a porcelain path outside `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`, a non-zero `--is-ancestor` exit, or any `git diff --stat` output stops the plan, because R1 assumes the audited code and R2 assumes the audited evidence blobs.

- [x] [P0-T3] Capture the TypeScript per-file coverage baseline by running `grep -nF '.ts |' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/baseline/baseline-typescript-test-coverage.2026-10-02T05-01.md` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/baseline-typescript-per-file-coverage.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` that lists exactly five matched lines (planning-time lines 13-17) and the numeric baseline `% Lines` / `% Branch` per file: `epic-orchestrator-state-launch-binding.ts` 96 / 92.79, `epic-planner-launch-evidence.ts` 91.64 / 80.61, `epic-planner-readiness-integrity.ts` 91.48 / 82.81, `epic-planner-state-core.ts` 98.26 / 93.51, `orchestration-artifacts.ts` 100 / 97.43. The summary states that these are text-table values from the original pre-change run and that no baseline lcov exists (decision 3). Stop condition: a match count other than five, or any value differing from the list above.

- [x] [P0-T4] Capture the lcov-absence baseline by running `ls -l --time-style=+%Y-%m-%dT%H-%M-%S extensions/drm-copilot/coverage/lcov.info` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/lcov-absence.<ts>.md`.
  - Acceptance: the artifact carries the four fields. Expected branch: `EXIT_CODE: 2` with `ExpectedExitCode: 2` and the `No such file or directory` message in `Output Summary:`. Alternate branch, explicitly allowed: if the file exists (`EXIT_CODE: 0`), record `ExpectedExitCode: 0` and the printed write time; P1-T2 then requires a write time later than this value.

- [x] [P0-T5] Capture the acceptance-criteria checkbox baseline of `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` by running `grep -c '^- \[x\] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` and `grep -c '^- \[ \] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`, and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/spec-checkboxes.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and records `20` checked (19 criteria plus the `Medium` severity box) and `4` unchecked (AC-19 at line 332 plus the `Blocker`, `High`, and `Low` boxes at lines 23, 24, 26). Stop condition: any other pair of counts.

- [x] [P0-T6] Capture the timestamp inventory baseline by running `grep -rn '^Timestamp' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/regression-testing docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates` and writing `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/timestamp-inventory.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and the full output, which has exactly 35 lines. Each line is `<path>:3:Timestamp: <recorded value>` for one row of the "Fixed R2 mapping" table, and every table row appears once. Because the pattern `^Timestamp` also matches the correction-line label, the 35-line count also establishes that no correction line exists yet. Stop condition: any count other than 35, any line number other than 3, or any path or value not in the table.

- [x] [P0-T7] Commit and push the Phase 0 baseline artifacts under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/remediation-baseline/` together with this plan file: run `git add -A -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`, write the message `docs(543): record remediation cycle 1 baselines` to `<scratchpad>/commit-msg-543-p0.txt` followed by one blank line and the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, run `git commit -F <scratchpad>/commit-msg-543-p0.txt`, then `git push origin bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`.
  - Acceptance: `git show --name-only --format= HEAD` lists only paths under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`; `git status --porcelain -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543` prints nothing; `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`.

### Phase 1 — R1: TypeScript lcov coverage and AC-19

- [x] [P1-T1] Run the full Jest suite with coverage for `extensions/drm-copilot/` and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-coverage-run.<ts>.md`. Read the clock, then run `npm run test:coverage --prefix extensions/drm-copilot -- --coverageReporters=text > <scratchpad>/jest-coverage-543.log 2>&1` from the worktree root; then extract with `grep -nE 'Test Suites:|Tests:|Lines +:|Branches +:' <scratchpad>/jest-coverage-543.log` and `grep -nE '(launch-binding|launch-evidence|readiness-integrity|state-core|orchestration-artifacts)\.ts' <scratchpad>/jest-coverage-543.log`.
  - Acceptance: the artifact carries `Timestamp:` (read immediately before the npm command), `Command:` (the npm command, plus the expansion `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=text` in `extensions/drm-copilot/`, citing `extensions/drm-copilot/package.json` line 213), `EXIT_CODE: 0` for the npm command, and an `Output Summary:` that quotes verbatim the `Test Suites:` line, the `Tests:` line, the text-summary `Lines` and `Branches` lines, and the five `text` table rows whose first cell is exactly `epic-orchestrator-state-launch-binding.ts`, `epic-planner-launch-evidence.ts`, `epic-planner-readiness-integrity.ts`, `epic-planner-state-core.ts`, and `orchestration-artifacts.ts`. The `Tests:` line contains no `failed` count. The summary compares the counts with the previous full run (`250` suites, `3794` tests) and states any difference. Exit 0 also establishes that every `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` is met. Stop condition: a non-zero exit or any failed test.

- [x] [P1-T2] Confirm that P1-T1 wrote `extensions/drm-copilot/coverage/lcov.info` by running `ls -l --time-style=+%Y-%m-%dT%H-%M-%S extensions/drm-copilot/coverage/lcov.info`, and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-lcov-file.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and the printed size and write time. The write time, truncated to the minute, is at or after the P1-T1 `Timestamp:` value, and, when P0-T4 took its alternate branch, later than the write time P0-T4 recorded. Stop condition: a non-zero exit or an earlier write time.

- [x] [P1-T3] Write `<scratchpad>/ts_coverage_543.py` verbatim from "Scratchpad scripts", run `poetry run python <scratchpad>/ts_coverage_543.py per-file` from the worktree root, and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-lcov-per-file.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the five per-file lines verbatim, each with numeric `LF`, `LH`, `BRF`, `BRH`, `line=`, `branch=`, and `floors=PASS`, plus the line `SUMMARY files=5 failures=0`. The values are read from the `SF:` records for `src/lib/validate/epic-orchestrator-state-launch-binding.ts`, `src/lib/validate/epic-planner-launch-evidence.ts`, `src/lib/validate/epic-planner-readiness-integrity.ts`, `src/lib/validate/epic-planner-state-core.ts`, and `src/lib/validate/orchestration-artifacts.ts` in `extensions/drm-copilot/coverage/lcov.info`. Stop condition: a non-zero exit, a `MISSING-RECORD` line, or any `floors=FAIL`; AC-19 is then not ticked and the orchestrator is told that a plan revision is required.

- [x] [P1-T4] Run `poetry run python <scratchpad>/ts_coverage_543.py added` from the worktree root (it runs `git diff -U0 ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd HEAD -- extensions/drm-copilot/src/lib/validate/<file>` for each of the five files and intersects the added lines with the `DA:<line>,0` rows of `extensions/drm-copilot/coverage/lcov.info`), and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-added-line-coverage.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the five per-file lines verbatim (`added=`, `executable_added=`, `uncovered_added=none`) and the line `SUMMARY added_total=<n> uncovered_total=0` with `<n>` greater than 0. A zero `added_total` fails the task, because it means the anchor found no change. Stop condition: a non-zero exit or any uncovered added line.

- [x] [P1-T5] Write the consolidated R1 verdict to `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/typescript-lcov-coverage.<ts>.md`.
  - Acceptance: the artifact carries `Timestamp:` (host clock at writing), `Command:` naming the two P1-T3 and P1-T4 commands it consolidates, `EXIT_CODE: 0` (both consolidated commands exited 0), `Inputs:` naming the P1-T1, P1-T2, P1-T3, P1-T4, and P0-T3 artifact paths, the lcov path `extensions/drm-copilot/coverage/lcov.info` with its P1-T2 write time, and an `Output Summary:` with one table row per production file: `LF`, `LH`, `BRF`, `BRH`, lcov line %, lcov branch %, P0-T3 baseline `% Lines` and `% Branch`, and the P1-T1 `text` row `% Lines` and `% Branch` (recorded for information). The artifact ends with `Verdict: PASS` only when all of these hold: P1-T1 exit 0 with no failed test; P1-T2 write time at or after P1-T1; every file at or above 85% lines and 75% branches by the P1-T3 integer check; every lcov line % and branch % at or above its P0-T3 baseline value; P1-T4 `uncovered_total=0` with `added_total` greater than 0. Otherwise it ends with `Verdict: FAIL` and the failing condition, and the plan stops; AC-19 is not ticked.

- [x] [P1-T6] Re-tick AC-19 in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` only after P1-T5 records `Verdict: PASS`: on line 332, the criterion that begins with the command `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary`, change `- [ ]` to `- [x]` and change nothing else. Then run `grep -c '^- \[x\] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`, `grep -c '^- \[ \] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`, and `git diff -U0 HEAD -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`, and record them in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/ac19-checkoff.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and records `21` checked and `3` unchecked (P0-T5 baseline 20 and 4). The `git diff -U0 HEAD` output has exactly one hunk with one removed and one added line, which differ only in `[ ]` versus `[x]`. The artifact cites `typescript-lcov-coverage.<ts>.md` (P1-T5) as the AC-19 evidence.

- [x] [P1-T7] Commit and push the Phase 1 artifacts under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/` and the `spec.md` change: run `git add -A -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`, write `docs(543): record TypeScript lcov coverage and re-tick AC-19` to `<scratchpad>/commit-msg-543-p1.txt` followed by one blank line and the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, run `git commit -F <scratchpad>/commit-msg-543-p1.txt`, then `git push origin bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`.
  - Acceptance: `git show --name-only --format= HEAD` lists only paths under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`; `git status --porcelain -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543` prints nothing; `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`.

### Phase 2 — R2: in-place timestamp correction and plan deviations

- [x] [P2-T1] Write `<scratchpad>/mapping_543.py` and `<scratchpad>/crosscheck_r2_543.py` verbatim from "Scratchpad scripts", run `poetry run python <scratchpad>/crosscheck_r2_543.py` from the worktree root, and write the correction record `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/timestamp-correction.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, a `Derivation:` section that restates decision 4 (source table, minute flooring, why commit-time derivation was not adopted, the cross-check rule) and decision 5 (no rename, no reference rewrite, filename suffixes retain composed values and are not clock readings), a `Mapping:` table with the 35 rows of the "Fixed R2 mapping" table using full repository-relative paths, recorded value, corrected value, and observed write time, and an `Output Summary:` quoting the 35 row lines (each ending `OK`), the three `ORDER` lines (each ending `OK`), and `SUMMARY rows=35 late=0 ordering_violations=0`. It also records that the remediation-inputs verification command `grep -rln "^Timestamp: 2026-10-02T06-" .../evidence/` is scoped to `evidence/regression-testing/` in P2-T5, because artifacts written in this cycle under other evidence kinds carry genuine host-clock values that may fall in hour 06. The artifact contains no line beginning with the correction-line label. Stop condition: a non-zero exit, any `LATE`, or any `AFTER-FIX`; no file is edited.

- [x] [P2-T2] Write `<scratchpad>/apply_r2_543.py` verbatim from "Scratchpad scripts", run `poetry run python <scratchpad>/apply_r2_543.py` once from the worktree root (it checks all 35 files under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/` first, then, in place and at the same paths, replaces the line-3 value and inserts line 4; it renames nothing and edits no other file), and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/timestamp-correction-apply.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and an `Output Summary:` quoting the 35 `CORRECTED` lines, one per row of the "Fixed R2 mapping" table at its unchanged path, and the success-case line `SUMMARY corrected=35 renamed=0`. Stop condition: a non-zero exit or a `MISSING` or `UNEXPECTED-LINE3` line (the script then wrote no file); do not re-run the script after a run that printed any `CORRECTED` line.

- [x] [P2-T3] Append the "Plan Deviations section text" block verbatim to the end of `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md`, substituting the P2-T1 filename timestamp for `<P2-T1 ts>`, and record the check in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/plan-deviations-check.<ts>.md` by running `grep -n '^## Plan Deviations$' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md` and `git diff -U0 HEAD -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0`. The `grep` prints exactly one match, on a line after planning-time line 482 (the last line of the file, the final P10-T6 acceptance line). The `git diff -U0 HEAD` output contains added lines only, in one hunk after line 482, and no removed line; the single permitted exception is line 482 shown as removed and re-added with identical text, which occurs only when the file had no final newline. The section contains the entries `D1 (merge adaptation)`, `D2 (literal merge-base SHA)`, `D3 (no sh-pwsh route)`, and `D-TIMESTAMPS (composed evidence timestamps)`; the D-TIMESTAMPS entry contains the sentence `Their filename suffixes retain the composed values and are not clock readings.`; and no `<P2-T1 ts>` placeholder remains.

- [x] [P2-T4] Stage and verify the correction: run `git add -A -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`, write `<scratchpad>/verify_r2_543.py` verbatim, run `poetry run python <scratchpad>/verify_r2_543.py`, then run `git diff --cached --name-status HEAD -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543` and `git status --porcelain -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`, and record all three in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/timestamp-correction-verification.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0` for the verifier, 35 `MATCH` lines, and `SUMMARY match=35 mismatch=0`. Each `MATCH` establishes, for one file at its unchanged path, that the staged blob equals byte for byte the `ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81` blob at the same path with only the line-3 value replaced by the corrected value and line 4 inserted with the fixed correction text; that its `Command:`, `EXIT_CODE:`, and `ExpectedExitCode:` lines are unchanged; that it has exactly one `Timestamp:` row, equal to the corrected value; and that it has exactly one correction line. The `--name-status` output contains no `R` and no `D` line and lists exactly: the 35 mapping paths with status `M`, `plan.2026-09-29T16-06.md` and `remediation-plan.2026-10-02T05-58.md` with status `M` (the latter carries this plan's own check-offs), and the P2-T1, P2-T2, and P2-T3 artifacts with status `A`. The porcelain output contains no `??` line under the feature folder. Stop condition: any `MISMATCH` line, any `R` or `D` status, or any other listed path.

- [x] [P2-T5] Run the R2 absence checks from `remediation-inputs.2026-10-02T05-58.md` against `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/regression-testing/`: `grep -rln "^Timestamp: 2026-10-02T06-" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/regression-testing/` and `grep -rln "^Timestamp: 2026-10-02T05-\(20\|30\|40\|45\|55\)" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/regression-testing/`, and record them in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/timestamp-absence-checks.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 1`, and `ExpectedExitCode: 1`; both commands print no path and exit 1. The `$` anchor of the remediation-inputs form is omitted so that a CRLF line ending cannot make the search vacuous; none of the 13 corrected regression-testing values begins with one of the five listed minutes. The search is content-only (`-l` lists files whose content matches), so the composed values that remain in the unchanged filename suffixes do not affect it. The qa-gates half of the hour-06 check is carried by the P2-T4 `timestamp-rows` verification, because Phase 1 artifacts in `evidence/qa-gates/` carry genuine values that may fall in hour 06.

- [x] [P2-T6] Run the R2 count checks: `grep -rc "^Timestamp-Correction:" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/ | grep -c ":1$"` and `grep -c "D-TIMESTAMPS" docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md`, and record them in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/timestamp-correction-counts.<ts>.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0`; the first command prints `35` and the second prints `2` (the introductory paragraph and the D-TIMESTAMPS entry of the appended section; the original plan contains no `D-TIMESTAMPS` text at planning time).

- [x] [P2-T7] Validate the amended original plan `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md` by running `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md`, and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/original-plan-validation.<ts>.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0` for the CLI, whose stdout contains `plan validation passed:` followed by the path; the artifact states that the MCP validator is run by the orchestrator, because it is not in atomic-executor's tool surface. Any `PLAN GATE WARNING: ` lines are quoted verbatim. Stop condition: a non-zero CLI exit.

- [ ] [P2-T8] Commit and push the Phase 2 changes under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`: run `git add -A -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`, write `docs(543): correct composed evidence timestamps and record plan deviations` to `<scratchpad>/commit-msg-543-p2.txt` followed by one blank line and the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, run `git commit -F <scratchpad>/commit-msg-543-p2.txt`, then `git push origin bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`.
  - Acceptance: `git show --name-only --format= HEAD` lists only paths under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`; `git status --porcelain -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543` prints nothing; `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`.

### Phase 3 — Final QA and scope verification

No production or test file is written by this plan, so no language toolchain loop (format, lint, type check, test) applies. P3-T1 proves that condition; if it fails, the plan stops and a revision adds the full TypeScript or Python QA loop.

- [ ] [P3-T1] Verify the remediation scope by running `git diff --name-only <remediation start SHA from P0-T2> HEAD` (the SHA is substituted from the P0-T2 artifact), `git diff --name-only ecbe5ba1838d3da89c59c6c407f9e6f43c1cca81 HEAD -- extensions scripts tests .claude .github .agents .codex`, and `git status --porcelain -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543 extensions scripts tests .claude .github .agents .codex`, and record them in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/remediation-scope-check.<ts>.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0`. Every path printed by the first command is under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`; the second command prints nothing; the scoped `git status --porcelain` prints at most one line, ` M docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-plan.2026-10-02T05-58.md` (this plan's own check-offs). The summary states that no language QA loop is required because zero production and zero test files changed. Stop condition: any path outside the feature folder from the first command, any output from the second command, or any porcelain line other than the permitted remediation-plan line.

- [ ] [P3-T2] Run the evidence-location validator `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` from the worktree root and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/evidence-locations.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and records that the output contains no `VIOLATION:` line (the validator prints nothing on success; `scripts/dev_tools/validate_evidence_locations.py` lines 101-105).

- [ ] [P3-T3] Re-check the committed acceptance-criteria state of `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` with `grep -c '^- \[x\] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` and `grep -c '^- \[ \] ' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md`, and record them in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/spec-checkboxes-final.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, and records `21` checked and `3` unchecked, and records that `git diff --quiet HEAD -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/spec.md` exits 0, so the counted state is the committed state.

- [ ] [P3-T4] Re-run `poetry run python <scratchpad>/verify_r2_543.py` against the committed state of `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/` (after P2-T8 the index equals `HEAD`), and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/timestamp-correction-final.<ts>.md`.
  - Acceptance: the artifact carries the four fields, `EXIT_CODE: 0`, 35 `MATCH` lines, and `SUMMARY match=35 mismatch=0`.

- [ ] [P3-T5] Validate this remediation plan `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-plan.2026-10-02T05-58.md` by running `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/remediation-plan.2026-10-02T05-58.md`, and record it in `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/remediation-plan-validation.<ts>.md`.
  - Acceptance: the artifact carries the four fields and `EXIT_CODE: 0` for the CLI, whose stdout contains `plan validation passed:`; the artifact states that the MCP validator is run by the orchestrator, because it is not in atomic-executor's tool surface. Any `PLAN GATE WARNING: ` lines are quoted verbatim. Stop condition: a non-zero CLI exit.

- [ ] [P3-T6] Commit and push the Phase 3 artifacts under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/qa-gates/` and the checked-off plan: run `git add -A -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543`, write `docs(543): record remediation cycle 1 final verification` to `<scratchpad>/commit-msg-543-p3.txt` followed by one blank line and the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, run `git commit -F <scratchpad>/commit-msg-543-p3.txt`, then `git push origin bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`.
  - Acceptance: `git show --name-only --format= HEAD` lists only paths under `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/`; `git status --porcelain -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543` prints nothing; `git rev-parse HEAD` equals `git rev-parse origin/bug/epic-planner-ready-gate-demands-codex-only-launch-binding-543`.
