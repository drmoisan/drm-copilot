# P2-T4 Fail-Before Exception Dossier: Bats Suite (PD6)

Timestamp: 2026-10-09T23-25
Command: tail -n 1 .codex/codex-web-setup.sh; grep -c -F "list_root_solution_files" .codex/codex-web-setup.sh; grep -c -F "TaskMaster.sln" .codex/codex-web-setup.sh
EXIT_CODE: 0
Output Summary:
- Command 1 (tail): EXIT 0; printed `main "$@"`.
- Command 2 (discovery-function grep): EXIT 1 (grep -c exits 1 on a zero count); printed 0.
- Command 3 (solution grep): EXIT 0; printed 6. Last command, so top-level EXIT_CODE 0.
- Result: alternative proof recorded; fail-before requirement satisfied by this dossier.

WhyFailingRunImpossible: The suite `tests/shell/test_codex_web_setup_codex_copy.bats` sources `.codex/codex-web-setup.sh` in its `setup`, and on BASE_SHA the last line of that script runs `main "$@"` unconditionally. A pre-fix run would therefore execute the full setup against the host (writes to `$HOME/.bashrc` and package installation), so no safe failing run can be produced before the source guard exists.

## Alternative Proof

- `tail -n 1` prints `main "$@"`: the script has no source guard on BASE_SHA, so C824-1, which asserts the guard line, cannot pass before the fix.
- The discovery-function grep prints 0: `list_root_solution_files` does not exist in the script, so C824-2 through C824-7, which call the discovery functions, cannot pass before the fix.
- The solution grep prints 6: the script hard-codes `TaskMaster.sln` six times, so C824-8, C824-12, and C824-15, which assert behavior that the fixed name contradicts, cannot pass before the fix.
- The suite first runs in P5-T16, after the source guard exists.
