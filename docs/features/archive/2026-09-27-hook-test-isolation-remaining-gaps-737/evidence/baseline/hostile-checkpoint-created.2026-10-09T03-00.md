# P1 hostile checkpoint creation

Timestamp: 2026-10-09T03-00
Command: Route C: one pwsh -NoProfile -File invocation (scratchpad t108): write the single-line hostile epic checkpoint, print CHECKPOINT-CREATED and CHECKPOINT-LISTED-IN-STATUS, run CR-PESTER-LIST over LIST-POP inside try, remove the file in finally, print CHECKPOINT-PRESENT-AFTER
EXIT_CODE: 0
Output Summary:
CHECKPOINT-CREATED: True
CHECKPOINT-LISTED-IN-STATUS: 0

Execution note: three earlier invocations of this task (02:43, 02:47, 02:51) were discarded. In each, a suite dot-sourced by Pester assigned the common variable name path (to C:\repo\worktrees\item-a-101), so the cleanup in the finally block targeted the wrong path and the file stayed on disk after the run (found and removed by hand each time). The accepted invocation uses read-only, uniquely named variables and .NET file calls in the finally block; its printed CHECKPOINT-PRESENT-AFTER is False and the file was confirmed absent on disk afterwards (see hostile-checkpoint-deleted). The file was never staged or committed.
