# Phase 0 — Step S9 CI Green Gate Contract

Timestamp: 2026-06-24T17-40

Source: C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-24-13-02\.claude\skills\orchestrate\SKILL.md
Sections: "Step S9 — CI Green Gate" (lines ~150-196) and "Checkpoint Schema — CI Gate Fields".

## ci_gate object fields (all five the script must emit)

1. head_sha — the PR head SHA that the required checks were observed against.
2. pr_pipeline_run_id — the GitHub Actions run id for the PR Pipeline.
3. pr_pipeline_run_url — the URL of that run.
4. conclusion — one of `success`, `failure`, `pending`.
5. verified_at — ISO-8601 timestamp of when S9 recorded the result.

## conclusion derivation rules (three)

- success — when all required checks pass.
- failure — when any required check failed.
- pending — when any required check is still in progress.

## Input channel

`gh pr checks --required --json bucket,name,state,link,workflow` (or an equivalent JSON-emitting command).
The script consumes this JSON; the script itself MUST NOT invoke `gh` (gh is invoked by the orchestrator and the JSON is passed to the parser).

## Bucket mapping (per plan "gh bucket Enum Mapping" section)

- pass -> contributes to success
- fail -> forces failure
- cancel -> forces failure
- pending -> contributes to pending
- skipping -> non-blocking (neither failure nor pending; counts toward success)
- empty required-check set -> success (vacuously satisfied, documented)
- unknown/unrecognized bucket -> fail-fast error (forces failure with explicit error naming the value)

Derivation precedence:
1. Any fail or cancel -> failure.
2. Else any pending -> pending.
3. Else -> success.
