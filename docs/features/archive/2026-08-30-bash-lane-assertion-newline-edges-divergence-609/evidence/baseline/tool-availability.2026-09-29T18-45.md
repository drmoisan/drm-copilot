# Tool Availability (P0-T3)

Timestamp: 2026-10-01T23:13:00-04:00
Command: command -v bats kcov shfmt shellcheck python3   (run through the Bash tool as a plain command; the plan's `sh -c '...'` wrapper was not used per operator rule Option A)
EXIT_CODE: 0 (the exit code is not a presence signal)
Output Summary: three paths printed (shfmt, shellcheck, python3); no path for bats or kcov.

Raw output:
```
/c/Users/DanMoisan/AppData/Local/Microsoft/WinGet/Packages/mvdan.shfmt_Microsoft.Winget.Source_8wekyb3d8bbwe/shfmt
/c/Users/DanMoisan/AppData/Local/Microsoft/WinGet/Packages/koalaman.shellcheck_Microsoft.Winget.Source_8wekyb3d8bbwe/shellcheck
/c/Users/DanMoisan/repos/drm-copilot/.venv/Scripts/python3
```

Second command: echo "${BASH_VERSION-}"
EXIT_CODE: 0
Output Summary: 5.2.37(1)-release

## Flags (derived only from the `command -v` output)
BATS: absent
KCOV: absent
SHFMT: present
SHELLCHECK: present
PYTHON3: present
SH-IS-BASH: yes

## Operator policy overlay (Option A, 2026-10-01)
- The worktree isolation guard policy refuses commands whose text contains the shell-entry words, so the plan's `sh scripts/<shell-dir>/shell-qc.sh ...`, `bats ...`, `kcov`, `sh .claude/lib/<shell-dir>/report-lane-assertion.sh ...` and `sh -n ...` commands are not run locally by operator decision. For execution purposes the four shell-toolchain flags BATS, KCOV, SHFMT, and SHELLCHECK are therefore treated as absent-by-guard: the tools may exist on PATH (shfmt and shellcheck do, per the raw output above) but the plan's invocations of them are withheld.
- The literal flag lines above record the real `command -v` observation. The authority for every withheld gate is the CI job `shell-coverage` (Shell Coverage (Bats + kcov)) on the pushed head.
- See deviations D3, D4, D5 in the other evidence artifacts for the affected tasks.
