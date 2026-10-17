# Expect-fail run, new tests against the unmodified module (P1-T9)

Timestamp: 2026-10-16T02-49

Command: pwsh -NoProfile -NonInteractive -Command '... (INLINE-PESTER-9 catalogue entry, SCRATCH/issue-930/P1-T9.sh line 2)'

EXIT_CODE: 0

Output Summary: Expected failure observed (failure is read from the printed counts; the wrapper reaches its final `exit 0` after the junit file is parsed). Output was filtered through grep to the named lines, so the wrapper exit code itself was not read from the pipe; the NODE lines are printed only on the path that ends in `exit 0`.
- RUN-NOTE: child exit code 5 (non-zero, the expected Pester failure exit)
- TESTS=629 FAILURES=5 ERRORS=0 (t=624 baseline plus 5)
- NODE AC930-APPLY-INVOKES-POETRY-INSTALL MATCHES=1 RESULT=FAIL
- NODE AC930-DRYRUN-INVOKES-POETRY-INSTALL MATCHES=1 RESULT=FAIL
- NODE AC930-POETRY-INSTALL-ORDER MATCHES=1 RESULT=FAIL
- NODE AC930-POETRY-INSTALL-FAILURE-PROPAGATES MATCHES=1 RESULT=FAIL
- NODE AC930-SKIP-PROJECT-INSTALL-KEEPS-POETRY-TOOL-INSTALL MATCHES=1 RESULT=FAIL
- NODE AC06-POETRY-PIP-FALLBACK MATCHES=1 RESULT=PASS
- NODE AC06-NONPOETRY-RETHROW MATCHES=1 RESULT=PASS
- NODE AC06-BOOTSTRAP-DRYRUN-NOSIDEEFFECTS MATCHES=1 RESULT=PASS
- NODE AC07-DRYRUN-COMMITTED-MANIFEST MATCHES=1 RESULT=PASS
- No repository file was modified by this task.
