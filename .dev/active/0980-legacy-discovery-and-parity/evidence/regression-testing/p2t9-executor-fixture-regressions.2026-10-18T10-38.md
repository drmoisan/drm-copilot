# P2-T9 corrected fixture and mandatory-safety probes

Timestamp: 2026-10-18 10:38:47 UTC

Command: `poetry run python SCRATCH/issue-980-p2t9-additional-probes.py 'feature evidence switch True' 'feature evidence switch False' 'required open legacy question with approved target switch True' 'required open legacy question with approved target switch False' 'disabled completion switches cannot waive claim evidence integrity'`

EXIT_CODE: 1

## Output Summary

All five behavioral assertions passed. The helper intentionally returned nonzero because production bytes changed during the run; this is not final source-bound acceptance. The two feature-evidence switch settings now use a valid inferred contract with no unsupported transition entries. Required legacy uncertainty blocks completion when configured and remains explicitly unknown when that switch is disabled; a separate approved target criterion does not rewrite it. The target parity fixture is explicitly partial so it does not make an unrelated full-parity claim. Disabling all completion switches and selecting no planning prerequisite still rejects corrupted runtime evidence.

The consolidated bounded review has identified only the previously corrected unchanged-report defect. Final verification must bind the full case set to the specialist's frozen source hashes after its ordered gates. See [structured results](p2t9-executor-fixture-regressions.2026-10-18T10-38.json).
