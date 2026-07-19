# Plan/Spec Reconciliation Record — Issue #370

- Timestamp: 2026-07-19T00-15
- Directive: RECONCILIATION REVISION OF AN APPROVED PLAN (revise in place)
- Plan revised in place: `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/plan.2026-07-17T15-08.md` (no sibling plan file created; Version 1.0 -> 1.1)
- Spec revised: `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/spec.md` (Version 0.2 -> 0.3)
- User story revised: `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/user-story.md`

## Ground-Truth Verification Performed

- `pyproject.toml` `[tool.poetry.scripts]` lines 59-76 read: all `dev.discovery.*` console-script entries match the directive's landed mapping (module:function per tool, including `main_dotnet`/`main_vsto` on `stack_cli` and the nine validate entries).
- `__main__`-guard grep over `scripts/dev_tools/`: confirms `discovery/init_cli.py`, `discovery/analyzer/cli.py`, and `discovery/analyzer/stack_cli.py` contain no `__main__` guard (only `analyzer/__main__.py` exists), falsifying uniform `python -m` invocation.
- `add_argument` counts spot-checked: init 3 args, coverage/parity reports 2, completion report 3, analyzers 3, scenario generator 5 — consistent with the directive's arg composition.

## Reconciliation Edits (Summary)

1. Plan Scope Summary: mapping table replaced with landed `module:function` entries under `scripts.dev_tools` / `scripts.dev_tools.discovery`; added per-tool landed CLI-arg composition list; substrate paragraph rewritten to the interpreter `-c` invocation mechanism with justification; upstream note rewritten from design-against-planned to merged waves 0/1/2.
2. Phase 1 (P1-T1): `argsPrefix` note updated from `-m` to `-c` invocation.
3. Phase 2 (P2-T1/P2-T2): mapping table now carries module + function + arg composition; helper builds the `-c` argv; tests assert the reconciled argv per tool (per-kind validate positional path, init required `target_dir`, analyzer `--json`, scenario three required inputs, two-input completion report), landed stdout artifact parsing, cwd, and error propagation.
4. Phase 4 (P4-T1/P4-T2): `artifact_type` enum fixed to the eight landed kinds plus `all`; report_type-aware required inputs (`input_path` vs `coverage_input`+`parity_input`); init `target_dir` required; scenario generation three required inputs; test matrix extended for per-report_type missing-field cases.
5. Phase 5 (P5-T2/P5-T4): inputSchema `required` arrays reconciled per tool; `report_type` conditional inputs documented as resolver-enforced; contract-test assertions updated.
6. Phase 7 (P7-T4): reconciliation-documentation audit replaces the design-against-planned audit; grep target updated to `scripts.dev_tools`.
7. Test Plan and Open Questions/Notes: updated to landed stdout contracts, merged upstream status, `-c` mechanism, and #367/#369 non-impact notes.
8. spec.md: substrate correction, API/CLI surface table, Data & State invocation model, upstream-status risk bullet, testing bullet, and ACs 2/4/5/7/8 reconciled; DoD and coverage/domain-neutrality/toolchain requirements unchanged.
9. user-story.md: substrate paragraph, parity-report and init scenarios, ACs (mirrors of spec ACs), and the live-E2E non-goal reconciled.

Unchanged by design: phase structure (0-8), 7-tool public MCP surface and VS Code command ids, five-touch-point lockstep, runtime Python-kind design, file-extraction tasks, evidence locations, and coverage gates (per-file `{ lines: 85, branches: 75 }`).

## Self-Preflight Result

- Phase headings `### Phase N — <Title>` and `- [ ] [P#-T#]` task IDs: verified sequential per phase, all unchecked.
- Evidence paths: all resolve to `docs/features/active/2026-07-17-legacy-discovery-mcp-vscode-370/evidence/<kind>/`; grep for forbidden `artifacts/` evidence paths returned no matches.
- Phase 0 baseline and Phase 8 final-QA coverage tasks with numeric coverage requirements: present and unchanged.
- MCP validator note: the `mcp__drm-copilot__validate_orchestration_artifacts` tool is not available in this planner session's toolset; the structural contract checks above were performed manually and the validator run must be executed by the calling agent as the confirmation gate.
