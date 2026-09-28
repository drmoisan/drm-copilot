# Phase 4 Pester Mutation Demonstration (P4-T3) [expect-fail]

Timestamp: 2026-09-27T15-30

[expect-fail] note: each flipped in-memory corpus, passed to the Pester consumer through the CorpusOverride parameter (New-PesterContainer -Data), is expected to make the "reports the corpus verdict for" It of the flipped case fail. Flipping a case's direction also breaks the corpus pairing meta-test in the "Corpus contract" context (a pair then shares one direction), so one additional expected failure is recorded per flip. The control run (no flip) is expected to pass the full suite. No file on disk is modified and no temporary file is created.

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/pester-mutation.ps1 -CaseId g1-plan-poetry-lock -NoFlip
EXIT_CODE: 0
Output:

```
CaseId=g1-plan-poetry-lock Flipped=False TotalCount=26 PassedCount=25 FailedCount=0 SkippedCount=1
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/pester-mutation.ps1 -CaseId g1-plan-poetry-lock
EXIT_CODE: 0
Output:

```
CaseId=g1-plan-poetry-lock Flipped=True TotalCount=26 PassedCount=23 FailedCount=2 SkippedCount=1
FAILED: BlastRadius regression corpus for issue 452.Corpus contract.resolves every pairing to an opposite-direction case of the same gap
FAILED: BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-poetry-lock
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/pester-mutation.ps1 -CaseId g1-plan-different-surfaces
EXIT_CODE: 0
Output:

```
CaseId=g1-plan-different-surfaces Flipped=True TotalCount=26 PassedCount=23 FailedCount=2 SkippedCount=1
FAILED: BlastRadius regression corpus for issue 452.Corpus contract.resolves every pairing to an opposite-direction case of the same gap
FAILED: BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-different-surfaces
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/pester-mutation.ps1 -CaseId g2-glob-vs-dir
EXIT_CODE: 0
Output:

```
CaseId=g2-glob-vs-dir Flipped=True TotalCount=26 PassedCount=23 FailedCount=2 SkippedCount=1
FAILED: BlastRadius regression corpus for issue 452.Corpus contract.resolves every pairing to an opposite-direction case of the same gap
FAILED: BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-glob-vs-dir
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/pester-mutation.ps1 -CaseId g2-dir-vs-sibling-glob
EXIT_CODE: 0
Output:

```
CaseId=g2-dir-vs-sibling-glob Flipped=True TotalCount=26 PassedCount=23 FailedCount=2 SkippedCount=1
FAILED: BlastRadius regression corpus for issue 452.Corpus contract.resolves every pairing to an opposite-direction case of the same gap
FAILED: BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-dir-vs-sibling-glob
```

Command: git status --porcelain -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
EXIT_CODE: 0
Output: (empty)

Command: git diff --exit-code HEAD -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json
EXIT_CODE: 0
Output: (empty)

Output Summary: The control prints FailedCount=0 with TotalCount 26, so the override path runs the full suite unchanged. Each of the four flips (one must-conflict and one must-not-conflict case per gap, one at a time) prints FailedCount=2 and a FAILED line containing "reports the corpus verdict for" followed by the flipped case id; the second failure in each run is the pairing meta-test in the "Corpus contract" context, an expected consequence of flipping a direction. The porcelain capture is empty and the anchored diff exits 0, so git reports no difference in the corpus file.
