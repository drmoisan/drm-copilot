# Remediation Baseline — Shell Lane (CI)

Timestamp: 2026-08-10T21-40
Issue: #462
Task: [P0-T2]
Branch: `drm-copilot-wt-2026-08-10T09-25`
Baseline head: `f7711fb42b3d3351b1a89871859fbf6b33ffede1`

## Command 1 — locate the green run at the baseline head

Command: `gh run list --commit f7711fb42b3d3351b1a89871859fbf6b33ffede1 --json databaseId,name,conclusion,url`

EXIT_CODE: 0

Output Summary:

```
[{"conclusion":"success","databaseId":31414978694,"name":"CI","url":"https://github.com/drmoisan/drm-copilot/actions/runs/31414978694"},
 {"conclusion":"success","databaseId":31414978545,"name":"Publish Extension to VS Code Marketplace","url":"https://github.com/drmoisan/drm-copilot/actions/runs/31414978545"},
 {"conclusion":"success","databaseId":31414584576,"name":"Shell Coverage (reusable)","url":"https://github.com/drmoisan/drm-copilot/actions/runs/31414584576"}]
```

Three runs at the baseline head, all `success`. The shell-lane run is `31414584576`
(`Shell Coverage (reusable)`).

Note: the full 40-character SHA is required. `gh run list --commit f7711fb4` returns `[]` with
exit 0 and locates nothing.

## Command 2 — confirm run identity

Command: `gh run view 31414584576 --json url,conclusion,headSha,event,displayTitle,status`

EXIT_CODE: 0

Output Summary:

```
{"conclusion":"success","displayTitle":"Shell Coverage (reusable)","event":"workflow_dispatch",
 "headSha":"f7711fb42b3d3351b1a89871859fbf6b33ffede1","status":"completed",
 "url":"https://github.com/drmoisan/drm-copilot/actions/runs/31414584576"}
```

`headSha` equals the baseline head exactly. Conclusion `success`.

## Command 3 — extract the numeric coverage baseline

Command: `gh run view 31414584576 --log | grep -E "Bash coverage \(lines\): [0-9]"`

EXIT_CODE: 0

Output Summary:

```
Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-08-10T17:37:31.9039960Z Bash coverage (lines): 92.4%
```

**Baseline bash line coverage: 92.4%.**

The digit-anchored pattern `[0-9]` is mandatory. The unanchored form
`grep -E "Bash coverage \(lines\)"` additionally matches three `shell-qc.sh` usage-banner lines
whose literal text is `"Bash coverage (lines): NN.N%" summary.`; recording the placeholder `NN.N%`
would be a false baseline. The value recorded here is numeric and was matched by the anchored form.

## Baseline Summary

| Field | Value |
| --- | --- |
| Run URL | https://github.com/drmoisan/drm-copilot/actions/runs/31414584576 |
| Run ID | 31414584576 |
| Workflow | Shell Coverage (reusable), `workflow_dispatch` |
| headSha | `f7711fb42b3d3351b1a89871859fbf6b33ffede1` |
| Conclusion | success |
| Bash coverage (lines) | 92.4% |
| Threshold (`.claude/rules/quality-tiers.md`) | >= 85.0% — satisfied at baseline |

Output Summary: Green shell-coverage run confirmed at the exact baseline head
`f7711fb42b3d3351b1a89871859fbf6b33ffede1` with numeric line coverage 92.4%. This is the
no-regression reference value for the terminal P5-T3 dispatch.
