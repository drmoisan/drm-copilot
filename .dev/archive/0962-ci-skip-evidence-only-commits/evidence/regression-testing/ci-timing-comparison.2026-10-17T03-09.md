# P7-T13 Timing comparison for AC-33

Timestamp: 2026-10-17T03-09
Command: gh run view 38997218418 --repo drmoisan/drm-copilot --json createdAt,updatedAt ; gh pr view 967 --repo drmoisan/drm-copilot --json mergeStateStatus,mergeable,reviewDecision
EXIT_CODE: 0
Output Summary: Baseline full run 1321 s; docs-only run 31 s; difference 1290 s. P7-T7 to P7-T11 met their expected values; P7-T12 reported mergeStateStatus UNKNOWN (GitHub still computing; not BLOCKED by checks, 11/11 required pass).

BASELINE-RUN: 38896898318 | 1321
DOCS-ONLY-RUN: 38997218418 | 31
DIFFERENCE-SECONDS: 1290
CHECK-RUN-NAME-FORM: full (required contexts carry the caller prefix; job-level skipped jobs report their bare caller or job name)
AC-33: PASS

## `gh run view 38997218418 --repo drmoisan/drm-copilot --json createdAt,updatedAt`

exit: 0

```text
{"createdAt":"2026-10-17T03:02:05Z","updatedAt":"2026-10-17T03:02:36Z"}
```

## `gh pr view 967 --repo drmoisan/drm-copilot --json mergeStateStatus,mergeable,reviewDecision`

exit: 0

```text
{"mergeStateStatus":"UNKNOWN","mergeable":"UNKNOWN","reviewDecision":""}
```
