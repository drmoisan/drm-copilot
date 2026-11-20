# P3-T1 first-report input digest integration finding

Timestamp: 2026-10-18 11:23:53 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-report-view-probe.py`

EXIT_CODE: 1

## Output Summary

The corrected report-view identity check now permits the exact Markdown/JSON relationship, but aggregate validation returns `REPORT_RESULT` when the configured reports directory is initially absent. The structured companion retains the stable mutation source hashes and the actual finding.

Inspection of the accepted `validation_inputs.report_input_digest` shows that missing report descendants are excluded using `reports_root + '/'`, while the exact missing root is retained. Creating the first report removes that missing-path entry, changing the projected digest even though only report output state changed. The helper's stated contract excludes report absence from discovery input facts. The coordinator was asked to disposition this bounded prior-boundary integration correction; the verifier has changed no production file. The initialized-directory positive will distinguish this issue from the now-corrected report-view identity rule.
