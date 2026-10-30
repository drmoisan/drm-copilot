# P3-T1 initial mutation review

Timestamp: 2026-10-18 11:12:43 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-initial-probes.py`

EXIT_CODE: 1

## Output Summary

Two positive cases pass: exact collection creation preserves unrelated inputs, and unchanged bytes skip without invalidating authority. Two boundary cases fail: an opaque evidence-payload grant accepts a structured evidence-reference with a different ID; changing only complete directory-child enumeration order raises `Metadata changed during workspace capture`.

The source files changed during this preliminary run, so this result is provisional and is not final source-bound acceptance evidence. [Structured output](p3t1-executor-review-initial.2026-10-18T11-12.json) retains the initial/final hashes, actual results and source-stability flag. A bounded repeat of only the failing cases will bind the findings to stable source bytes. No production file was changed by the verifier.
