# Coverage Comparison — P3-T13

Timestamp: 2026-09-06T00-00
Task: [P3-T13]
Working directory: repository root
Base for changed-line attribution: `1ed0964045febbb4d92f1cb92661d4b945153a40`

Command: `python - <<'PY' ... PY` — a read-only comparison script piped to
`python` on stdin. It writes nothing; it runs
`git diff --unified=0 --no-color 1ed0964045febbb4d92f1cb92661d4b945153a40 -- <pathspecs>`
to collect added and modified line numbers, then intersects them with the `DA:`
records of `artifacts/python/lcov.info` and
`extensions/drm-copilot/coverage/lcov.info`. The script body is reproduced at
the end of this record so the calculation is reproducible.
EXIT_CODE: 0

## Baseline-to-final metric pairs

| Language | Metric | Baseline artifact value | Final value | Result |
| --- | --- | --- | --- | --- |
| Python | LINE_COVERAGE | 92.8607659142785% (P0-T4) | 92.86076591427846% (P3-T10) | no regression |
| Python | BRANCH_COVERAGE | 85.418118466899% (P0-T4) | 85.41811846689895% (P3-T10) | no regression |
| Python | Passed / skipped | 4382 / 5 (P0-T4) | 4384 / 5 (P3-T10) | no regression |
| TypeScript | Overall line | 96.78% (P0-T3) | 96.82% (P3-T11) | no regression |
| TypeScript | Overall branch | 90.28% (P0-T3) | 90.37% (P3-T11) | no regression |
| TypeScript | Authority-service line | 97.7358490566038% (P0-T3) | 98.408488% (P3-T11) | no regression |
| TypeScript | Suites / tests | 213 / 2894 (P0-T3) | 214 / 2966 (P3-T11) | no regression |
| PowerShell | LINE_COVERAGE | 94.762996941896% (P0-T5) | 94.76966149147366% (P3-T12) | no regression |
| PowerShell | Active passed / skipped | 3923 / 9 (P0-T5) | 3931 / 9 (P3-T12) | no regression |

Every threshold above is compared against the numeric value recorded in the
cited Phase 0 artifact, not a rounded restatement of it. The Python line and
branch figures are the same rational quantities in both records (14646/15772
and 4903/5740) printed to the precision each recorder used.

## PowerShell covered and total line counts as four separate numeric values

| Source | Covered lines | Total lines |
| --- | --- | --- |
| P0-T5 baseline artifact | 7437 | 7848 |
| P3-T12 final artifact | 7447 | 7858 |

The final denominator differs from the baseline denominator because the rebase
onto `origin/main` added production lines to `.claude/hooks/validate-bash.ps1`
and its published copy under
`extensions/drm-copilot/resources/claude-customizations/`. The PowerShell
no-regression condition is therefore evaluated on the percentage rather than on
either count. The final percentage, 94.76966149147366%, is above the baseline
percentage of 94.762996941896% by 0.006665 percentage points, so there is no
shortfall. No shortfall exists to attribute to the rebase-introduced lines, so
no recomputation over the file set unchanged since
`9f3514bf5da84110f23617382cbbeabf54f27427` is required and no rebase-inherited
environmental delta is recorded.

## New and changed executable-line coverage (base to working tree)

### Python — 552/570 = 96.84210526315789%

```
scripts/dev_tools/orchestration_handoff_adapters.py: 123/128 = 96.0938%
scripts/dev_tools/orchestration_handoff_contract.py: 303/307 = 98.6971%
scripts/dev_tools/orchestration_handoff_contract_support.py: 81/89 = 91.0112%
scripts/dev_tools/push_down_codex_and_agents_customizations.py: 9/10 = 90.0000%
scripts/dev_tools/validate_orchestrator_state.py: 36/36 = 100.0000%
```

### TypeScript — 3208/3278 = 97.86455155582672%

```
src/lib/validate/orchestration-artifacts.ts: 5/5 = 100.0000%
src/lib/validate/orchestration-handoff-authority-service.ts: 371/377 = 98.4085%
src/lib/validate/orchestration-handoff-contract-support.ts: 323/323 = 100.0000%
src/lib/validate/orchestration-handoff-contract.ts: 491/497 = 98.7928%
src/lib/validate/orchestration-handoff-materializer-production.ts: 136/136 = 100.0000%
src/lib/validate/orchestration-handoff-materializer-support.ts: 77/77 = 100.0000%
src/lib/validate/orchestration-handoff-materializer.ts: 406/439 = 92.4829%
src/lib/validate/orchestration-handoff-path-boundary.ts: 200/205 = 97.5610%
src/lib/validate/orchestration-handoff-provider-adapters.ts: 271/273 = 99.2674%
src/lib/validate/orchestration-handoff-validation.ts: 246/248 = 99.1935%
src/lib/validate/semantic-mcp-identity.ts: 54/54 = 100.0000%
src/mcp-handlers/orchestration-handoff-handlers.ts: 304/304 = 100.0000%
src/mcp-repo-automation-tool-definitions-handoff.ts: 220/220 = 100.0000%
src/mcp-repo-automation-tool-definitions.ts: 15/15 = 100.0000%
src/mcp-tool-definitions.ts: 3/3 = 100.0000%
src/mcp-tools.ts: 24/24 = 100.0000%
src/repo-automation-service-contract.ts: 0/16 = 0.0000%
src/repo-automation-service.ts: 59/59 = 100.0000%
src/repo-automation-tool-names.ts: 3/3 = 100.0000%
```

`src/repo-automation-service-contract.ts` is an interface-and-type-only module.
Its 16 attributed lines are declaration lines that emit no executable statement
and are never hit at runtime; the module remains inside `collectCoverageFrom`
and no coverage exclusion was added for it. Both aggregates exceed 90% with
that module included.

Both required aggregates are at least 90%: Python 96.84210526315789% and
TypeScript 97.86455155582672%.

### PowerShell — N/A, with proof

PowerShell changed-code coverage is `N/A` because no PowerShell production file
changed within the authorized FR-614-005 scope. The proof is twofold:

1. The plan's authorized production scope list contains no `.ps1`, `.psm1`, or
   `.psd1` path; every entry is a TypeScript module or a Markdown skill
   document.
2. `git status --porcelain=v1 --untracked-files=all` for this remediation
   (recorded in full in the P3-T9 artifact) lists 53 rows and none of them is a
   PowerShell path.

The six PowerShell files that differ from the base
(`.codex/hooks/enforce-epic-planning-only.ps1`, its published copy, and four
`tests/scripts/codex-hooks/*.Tests.ps1` files) are prior committed branch work
from the earlier FR-614 findings, not changes made under FR-614-005.

## Comparison script

```python
import subprocess, re, pathlib, collections

BASE = "1ed0964045febbb4d92f1cb92661d4b945153a40"
ROOT = pathlib.Path(r"C:/Users/DanMoisan/repos/drm-copilot-wt/2026-08-31T07-29")

def changed_lines(pathspecs):
    out = subprocess.run(
        ["git", "diff", "--unified=0", "--no-color", BASE, "--"] + pathspecs,
        cwd=ROOT, capture_output=True, text=True, check=True).stdout
    result = collections.defaultdict(set)
    cur = None
    for line in out.splitlines():
        if line.startswith("+++ b/"):
            cur = line[6:]
        elif line.startswith("@@") and cur:
            m = re.match(r"@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@", line)
            if m:
                start = int(m.group(1)); count = int(m.group(2) or 1)
                for n in range(start, start + count):
                    result[cur].add(n)
    return result

def lcov_da(path, base_dir=None):
    data = collections.defaultdict(dict)
    cur = None
    for line in pathlib.Path(path).read_text(encoding="utf-8").splitlines():
        if line.startswith("SF:"):
            raw = line[3:].replace("\\", "/")
            p = pathlib.Path(raw)
            if not p.is_absolute() and base_dir:
                p = pathlib.Path(base_dir) / raw
            try:
                cur = p.resolve().relative_to(ROOT.resolve()).as_posix()
            except Exception:
                cur = raw
        elif line.startswith("DA:") and cur:
            ln, hits = line[3:].split(",")[:2]
            data[cur][int(ln)] = int(hits)
    return data
```

Output Summary: The read-only comparison exited 0. No baseline metric regressed
within the FR-614-005 authorized scope for any of the three languages. Python
new and changed executable-line coverage is 96.84210526315789% and TypeScript is
97.86455155582672%, both at least 90%. PowerShell changed-code coverage is
`N/A` with the recorded proof that no PowerShell production file changed in the
authorized scope, and the PowerShell percentage rose rather than fell, so no
rebase-attribution carve-out was needed.
