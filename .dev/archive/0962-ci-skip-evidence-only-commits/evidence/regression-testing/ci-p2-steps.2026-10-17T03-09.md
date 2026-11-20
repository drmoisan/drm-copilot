# P7-T8 Proof steps P2.2 and P2.3

Timestamp: 2026-10-17T03-09
Command: gh run view 38997218418 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Code Quality")) | [.name, ([.steps[] | select(.conclusion == "success")] | length)] | @tsv ; gh run view 38997218418 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Code Quality")) | .name as $job | .steps[] | select(.conclusion == "success") | [$job, .name] | @tsv ; gh run view 38997218418 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Code Quality")) | .steps[] | select(.name == "Run tests with Pytest") | .conclusion
EXIT_CODE: 0
Output Summary: See verbatim output; expected four jobs with 2 succeeded steps (Set up job, Complete job) and Run tests with Pytest skipped four times.


## `gh run view 38997218418 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Code Quality")) | [.name, ([.steps[] | select(.conclusion == "success")] | length)] | @tsv`

exit: 0

```text
quality-checks7 / Code Quality & Tests (3.13)	2
quality-checks7 / Code Quality & Tests (3.10)	2
quality-checks7 / Code Quality & Tests (3.12)	2
quality-checks7 / Code Quality & Tests (3.11)	2
```

## `gh run view 38997218418 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Code Quality")) | .name as $job | .steps[] | select(.conclusion == "success") | [$job, .name] | @tsv`

exit: 0

```text
quality-checks7 / Code Quality & Tests (3.13)	Set up job
quality-checks7 / Code Quality & Tests (3.13)	Complete job
quality-checks7 / Code Quality & Tests (3.10)	Set up job
quality-checks7 / Code Quality & Tests (3.10)	Complete job
quality-checks7 / Code Quality & Tests (3.12)	Set up job
quality-checks7 / Code Quality & Tests (3.12)	Complete job
quality-checks7 / Code Quality & Tests (3.11)	Set up job
quality-checks7 / Code Quality & Tests (3.11)	Complete job
```

## `gh run view 38997218418 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Code Quality")) | .steps[] | select(.name == "Run tests with Pytest") | .conclusion`

exit: 0

```text
skipped
skipped
skipped
skipped
```
