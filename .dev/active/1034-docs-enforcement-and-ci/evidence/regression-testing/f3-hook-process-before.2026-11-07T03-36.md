# F3 Hook Process Table at Head - Issue 1034 Remediation Cycle 2 (P1-T4)

Timestamp: 2026-11-07T03-36
Command: sh SCRATCH/issue-1034-c2-f3.sh Before (one real PowerShell 7 hook process per command against a consumer copy of .claude/hooks and .claude/lib under SCRATCH/consumer, with an enabled profile and no receipt; each process receives the envelope on standard input)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure. All eleven commands of the F3 results table print allow at exit 0 with the gate enabled and no receipt, which is the defect F3 reports. The step script exits 1 only in that state and 255 otherwise.

| Command | Profile | Decision | Exit | Reason | Row |
|---|---|---|---|---|---|
| `if gh pr checks 12; then gh pr merge 12 --merge; fi` | enabled | allow | 0 |  | pass |
| `for n in 12; do gh pr merge "$n" --merge; done` | enabled | allow | 0 |  | pass |
| `! gh pr merge 12` | enabled | allow | 0 |  | pass |
| `exec gh pr merge 12` | enabled | allow | 0 |  | pass |
| `while true; do gh pr merge 12 --merge; break; done` | enabled | allow | 0 |  | pass |
| `if false; then echo x; else gh pr merge 12; fi` | enabled | allow | 0 |  | pass |
| `until gh pr merge 12; do sleep 1; done` | enabled | allow | 0 |  | pass |
| `sudo gh pr merge 12` | enabled | allow | 0 |  | pass |
| `nice gh pr merge 12` | enabled | allow | 0 |  | pass |
| `coproc gh pr merge 12` | enabled | allow | 0 |  | pass |
| `find . -maxdepth 0 -exec gh pr merge 12 \;` | enabled | allow | 0 |  | pass |
