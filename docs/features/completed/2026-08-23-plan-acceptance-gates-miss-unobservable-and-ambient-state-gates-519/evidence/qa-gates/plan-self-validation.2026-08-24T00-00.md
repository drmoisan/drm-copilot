# Final QC — plan self-validation, twice — [P8-T12]

Timestamp: 2026-08-26T10-44
Task: [P8-T12]

This plan is subject to the defect it repairs, so it is validated against the rules it adds. Two runs are recorded. The first loads the rule modules from this worktree and is the run that gates. The second calls the published MCP server and is the unchanged-contract check.

## Run 1 — worktree-source validation (the gating run)

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md --workspace-root .`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Output Summary: exit code 0. The entire captured stream — both stdout and stderr, merged by the redirect — is the single line `plan validation passed: docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md`. **The recorded stderr carries no line naming G7, G8, G8b, or G9, and no `PLAN GATE WARNING: ` line of any kind was emitted.**

The exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between the command and the capture.

### Verbatim output

```text
plan validation passed: docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md
```

### The `PLAN GATE WARNING: ` lines, reproduced

The gate emitted **zero** warning lines. There is therefore nothing to reproduce verbatim and no acceptance reason to record for any such line. Warnings, when present, are printed to stderr prefixed with `PLAN GATE WARNING: `; the redirect merged stderr into the same capture, so a warning would have appeared in the single-line stream above.

### Re-run after the Phase 8 checkbox updates

[P8-T13] and the Phase 8 check-offs change checkbox state in the plan document after this validation was first taken, so the same command was re-issued against the final plan text at 2026-08-26T10-55. It **exited 0** and emitted the identical single line, with no `PLAN GATE WARNING: ` line and no line naming G7, G8, G8b, or G9. The recorded result therefore describes the plan as it now stands on disk, not an earlier revision of it.

### Falsifiability control

A validation that reports success for every input gates nothing. The same command was therefore re-issued against a path that does not exist, `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/no-such-plan.md`, and **exited 1**. The gate discriminates: it does not exit 0 unconditionally.

### Why this run is the one that gates

This invocation is `python -m scripts.dev_tools.validate_orchestration_artifacts` executed with the worktree as the working directory, so it imports `scripts/dev_tools/plan_gate_discrimination.py` and, through its rule-group seam, `scripts/dev_tools/plan_gate_observability.py` from **this branch**. G7, G8, and G8b run unconditionally; G9 runs because `--workspace-root .` supplies the repository context. The four new rules are therefore exercised against this plan's own text.

## Run 2 — published MCP server (the unchanged-contract check)

Tool: `validate_orchestration_artifacts`, with `artifact_type` set to `plan` and `artifact_path` set to `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md`
Server: the published package `@danmoisan/drm-copilot-mcp`, resolved by `npx -y` exactly as `.mcp.json` configures it
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Output Summary: the call returned `"ok": true` with `"isError": false` and **no `warnings` field**, which is how the MCP surface represents zero warnings. The result carries **zero blocking findings**. The tool's `summary` is `Validated plan artifact at 'docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md'.`

### Verbatim result

```json
{"result":{"content":[{"type":"text","text":"{\n  \"ok\": true,\n  \"tool\": \"validate_orchestration_artifacts\",\n  \"workspace_root\": \"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65\",\n  \"summary\": \"Validated plan artifact at 'docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md'.\"\n}"}],"structuredContent":{"ok":true,"tool":"validate_orchestration_artifacts","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65","summary":"Validated plan artifact at 'docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/plan.2026-08-23T23-22.md'."},"isError":false},"jsonrpc":"2.0","id":3}
```

### Transport note, recorded so the method is auditable rather than implied

The executing agent's tool schema in this session does not expose `mcp__drm-copilot__validate_orchestration_artifacts`; only the four PoshQC MCP tools are exposed to it. The call was therefore made directly against the same server over its stdio JSON-RPC transport: the server was launched with `npx -y @danmoisan/drm-copilot-mcp`, the working directory set to this worktree, and the sequence `initialize`, `notifications/initialized`, `tools/list`, `tools/call` was written to its stdin. This reaches the identical tool implementation a client harness would reach and differs only in the harness that carries the request. The `tools/list` response confirmed the server advertises a tool named `validate_orchestration_artifacts`, and the `tools/call` response reproduced above is that tool's result.

### Why this run is NOT the one that gates

The MCP server is the published `@danmoisan/drm-copilot-mcp` package, resolved from the registry by `npx -y`. It is built from a released commit on `main`, and the module this change adds does not exist on `main`. That is verified rather than assumed:

```text
$ git cat-file -e main:extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts
fatal: path 'extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts' exists on disk, but not in 'main'
EXIT=128
```

The branch carrying this change is unmerged, so no published build can contain the new rule module and the published server therefore **does not carry the rules added by this change**. Its `ok: true` result attests only that the plan still satisfies the pre-existing contract — the plan artifact type still parses, the phase and task-identifier format is still accepted, and G1 through G6 still produce no blocking finding. It cannot and does not attest anything about the four new rules. That is the whole content of this check: the MCP input-schema property-key set for the plan artifact type is unchanged, which [P4-T6] evidenced by diff, and the published surface continues to accept and validate the artifact unchanged.

## Verdict

**PASS.** Both runs carry `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The worktree-source run exits 0 with no line naming G7, G8, G8b, or G9 and zero `PLAN GATE WARNING: ` lines, and is shown to discriminate by a negative control that exits 1. The MCP run records an ok result with zero blocking findings, and the artifact states why that run does not gate.
