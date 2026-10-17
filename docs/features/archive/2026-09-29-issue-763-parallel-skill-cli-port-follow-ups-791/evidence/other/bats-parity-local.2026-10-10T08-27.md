# Bats Parity Suite (Local) — [P4-T12]

Timestamp: 2026-10-10T08-27
Command: command -v python3 ; npx --yes bats tests/shell/parallel_mutation_remove_parity.bats (bats not run locally)
EXIT_CODE: N/A
CI-DEFERRED: yes
CI-DEFERRED-ACS: AC-10
Reason: operator constraint prohibits local bats execution
Output Summary:
- Pre-run check `command -v python3`: exit 0, printed `/c/Users/DanMoisan/repos/drm-copilot/.venv/Scripts/python3`; the `PARALLEL_PARITY_PYTHON` override is therefore not needed.
- The bats run itself was not performed under the operator constraint; the plan's CI-deferred branch is taken, so no local TAP output exists.
- The suite `tests/shell/parallel_mutation_remove_parity.bats` exists (100 lines) with the three named cases: `the remove parity corpus meets the declared floor`, `the harness interpreter is available to read the corpus`, `the bash lane reproduces every remove corpus fixture`; it is verified from the CI bats job log on the pull request.
- Pre-CI literal verification: the Python lane over the same 15-fixture corpus passed (`18 passed`, `evidence/other/python-parity-lane.2026-10-10T08-22.md`), and each fixture's argv was run through `sh .claude/lib/bash/remove-parallel-item.sh` with output equal to the fixture's expected stdout or stderr literal.
- AC-10 is left for CI confirmation in [P9-T1].
