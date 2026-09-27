# Phase 3 Python Mutation Demonstration (P3-T3) [expect-fail]

Timestamp: 2026-09-27T15-18

[expect-fail] note: for each flipped in-memory copy, the consumer's per-case assertion (test_case_verdict_matches_corpus) is expected to fail. The flip changes only the direction and the verdict expectation (a must-conflict case becomes must-not-conflict with no reasons; a must-not-conflict case becomes must-conflict with its paired case's reasons), so the verdict assertion is the one that fails. Each unflipped control is expected to pass. No file on disk is modified and no temporary file is created.

Command: poetry run python `<scratchpad>`/python_mutation_demo.py g1-plan-poetry-lock g1-plan-different-surfaces g2-glob-vs-dir g2-dir-vs-sibling-glob
EXIT_CODE: 0

Output:

```
CONTROL g1-plan-poetry-lock unflipped passed
MUTATION g1-plan-poetry-lock raised AssertionError names_case=True message=g1-plan-poetry-lock produced conflict=True, expected conflict=False.
CONTROL g1-plan-different-surfaces unflipped passed
MUTATION g1-plan-different-surfaces raised AssertionError names_case=True message=g1-plan-different-surfaces produced conflict=False, expected conflict=True.
CONTROL g2-glob-vs-dir unflipped passed
MUTATION g2-glob-vs-dir raised AssertionError names_case=True message=g2-glob-vs-dir produced conflict=True, expected conflict=False.
CONTROL g2-dir-vs-sibling-glob unflipped passed
MUTATION g2-dir-vs-sibling-glob raised AssertionError names_case=True message=g2-dir-vs-sibling-glob produced conflict=False, expected conflict=True.
```

Command: git status --porcelain -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
EXIT_CODE: 0
Output: (empty)

Command: git diff --exit-code HEAD -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
EXIT_CODE: 0
Output: (empty)

Output Summary: The driver exited 0 (every flip raised). Four CONTROL lines show each unflipped case passes; four MUTATION lines report "raised AssertionError names_case=True", and each message begins with the flipped case id. One must-conflict and one must-not-conflict case were flipped per gap (gap 1: g1-plan-poetry-lock, g1-plan-different-surfaces; gap 2: g2-glob-vs-dir, g2-dir-vs-sibling-glob), one at a time. The porcelain capture is empty and the anchored diff exits 0, so git reports no difference in the corpus file.
