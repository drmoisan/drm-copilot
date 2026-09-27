# Detection Verdicts Unchanged, Final (P14-T5)

Timestamp: 2026-09-27T18-01
Command: poetry run pytest -v tests/scripts/dev_tools -k conflict_fixture_reproduces ; sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 -FullNameFilter "*Blast-radius contention parity*"
EXIT_CODE: 0
Output Summary: PASS. Run on the merged tree (HEAD 4dc5d488945ff59fb3ebbc67312b7bb87491072f). The block B36 Python selection (CMD-PY-TEST-K with expression conflict_fixture_reproduces) collected 30 of 5190 nodes (15 verdict and 15 reasons nodes over the 15 top-level conflict fixtures) and printed "30 passed, 5160 deselected", exit 0. The Pester parity file filtered with the B36 filter *Blast-radius contention parity* (a Describe-level name, which the FullName filter matches without template expansion) printed TotalCount=80, PassedCount=30, FailedCount=0, exit 0. PassedCount is at least 1, so the filter selected tests.

## Python (block B36)

```text
collecting ... collected 5190 items / 5160 deselected / 30 selected
test_conflict_fixture_reproduces_the_expected_verdict[conflict-contract] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-file] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-directory-vs-glob] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-empty-vs-empty] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-empty-vs-nonempty] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-glob-concrete] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-glob-undecidable] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-mergeable-csproj-no-edge] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-mergeable-glob-still-contends] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-module-overlap] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-multi-reason] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-none-disjoint] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-path-overlap] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-shared-surface] PASSED
test_conflict_fixture_reproduces_the_expected_verdict[conflict-sibling-prefix-disjoint] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-contract] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-file] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-directory-vs-glob] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-empty-vs-empty] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-empty-vs-nonempty] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-glob-concrete] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-glob-undecidable] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-mergeable-csproj-no-edge] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-mergeable-glob-still-contends] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-module-overlap] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-multi-reason] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-none-disjoint] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-path-overlap] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-shared-surface] PASSED
test_conflict_fixture_reproduces_the_expected_reasons[conflict-sibling-prefix-disjoint] PASSED
===================== 30 passed, 5160 deselected in 0.81s =====================
```

(Every node ID above is prefixed by tests/scripts/dev_tools/test_blast_radius_parity.py:: in the raw output.)

## PowerShell (parity file, B36 filter)

```text
TotalCount=80
PassedCount=30
FailedCount=0
(exit 0)
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
