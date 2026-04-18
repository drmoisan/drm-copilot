Timestamp: 2026-04-18T17:44:00
Command: derived-from merge base `d742a7f8efef1ec95500edca6b2bd525bb78b819`, `extensions/drm-copilot/coverage/coverage-summary.json`, and `poetry run pytest --cov=scripts/dev_tools --cov=extensions/drm-copilot/resources/templates --cov=extensions/drm-copilot/resources/scripts/dev_tools --cov-report=term-missing tests/scripts/dev_tools/test_resolve_file_prompt.py tests/extensions/drm_copilot/resources/templates -q`
EXIT_CODE: 0
Output Summary: PASS - Deterministic changed-scope coverage proof is available for the reviewed atomic-plan prompt source files. TypeScript changed source files are all at or above 92.70% line coverage in `coverage-summary.json`, and the remediated Python prompt-resolution source files are at or above 91% statement coverage in the current pytest coverage report. The changed-scope coverage-proof gate can therefore clear `remediation required` for this feature's reviewed runtime path.

## Merge-base scope
- Base branch: `origin/development`
- Merge base: `d742a7f8efef1ec95500edca6b2bd525bb78b819`
- Reviewed runtime/command source files in scope:
  - `extensions/drm-copilot/src/document-workflow-commands.ts`
  - `extensions/drm-copilot/src/extension-command-helpers.ts`
  - `extensions/drm-copilot/src/extension.ts`
  - `extensions/drm-copilot/src/mcp-tool-inputs.ts`
  - `extensions/drm-copilot/src/mcp-tools.ts`
  - `extensions/drm-copilot/src/repo-automation-service.ts`
  - `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py`
  - `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py`
  - `scripts/dev_tools/resolve_file_prompt.py`

## TypeScript changed-scope coverage proof
- `extensions/drm-copilot/src/document-workflow-commands.ts` — Lines 92.70%, Functions 100.00%, Branches 80.00%
- `extensions/drm-copilot/src/extension-command-helpers.ts` — Lines 99.39%, Functions 100.00%, Branches 93.54%
- `extensions/drm-copilot/src/extension.ts` — Lines 99.11%, Functions 100.00%, Branches 94.11%
- `extensions/drm-copilot/src/mcp-tool-inputs.ts` — Lines 94.31%, Functions 93.75%, Branches 97.05%
- `extensions/drm-copilot/src/mcp-tools.ts` — Lines 95.40%, Functions 100.00%, Branches 69.44%
- `extensions/drm-copilot/src/repo-automation-service.ts` — Lines 100.00%, Functions 100.00%, Branches 79.68%
- Deterministic disposition: PASS for changed TypeScript source-file line coverage.

## Python changed-scope coverage proof
- `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py` — Statements 91% (191 statements, 18 missed)
- `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py` — Statements 100% (18 statements, 0 missed)
- `scripts/dev_tools/resolve_file_prompt.py` — Statements 93% (183 statements, 13 missed)
- Deterministic disposition: PASS for changed Python prompt-resolution source-file statement coverage.

## Gate conclusion
- Runtime blocker status: closed by `evidence/regression-testing/p1-t3.resolve-atomic-plan-prompt-pass-after.2026-04-18T17-44.md`
- Regression fidelity status: closed by refreshed `evidence/regression-testing/py-resolve-atomic-plan-prompt.2026-04-17T19-54.md` and `evidence/regression-testing/ts-resolve-atomic-plan-prompt.2026-04-17T19-54.md`
- Coverage-proof status: closed for the reviewed changed prompt-resolution source scope
