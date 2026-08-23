# P6-T26 Customization Compatibility Projection

Timestamp: 2026-08-23T01:26:20-04:00

## Scope and batch receipt

- Task: `[P2-T14]`
- Canonical issue: `484`
- Python batch ledger: `.codex/state/python-batch-budget.01a02c82-debe-78f2-9366-3d35e077da53.json`
- Batch transition before mutation: `prodFiles`/`testFiles` changed from `1/1` to `0/0`; `prodCap`/`testCap` remained `3/3`.
- Active batch after mutation: `2` production files and `0` test files; both paths are relative and distinct.
- A duplicate absolute spelling of the generic generator was removed from the ignored ledger after the hook counted the same file twice. The active set and caps remained unchanged.
- No test assertion, suppression, dependency, benchmark input, public validation condition, or checkpoint file was changed.

## Canonical and Python changes

- `.agents/skills/feature-review/SKILL.md`
  - SHA-256: `A52DC54CD520AA42AC8CC6CF527245948E8F84989B253D95184DBC9DB4723655`
  - Added the required atomic-planner compatibility wording inside the existing automatic remediation handoff.
- `.agents/skills/orchestrator-workflow/SKILL.md`
  - SHA-256: `2C3B11095536316F80E2ED923AED43452F2E7A5C115685B488E28B0611C80108`
  - Added the required `spawn_agent` availability and `NONE`/`TBD` placeholder compatibility wording inside the existing stronger guards.
  - Rephrased the existing direct-extension prohibition as the host-neutral `repository extension lifecycle commands` prohibition so complete Codex projections contain no raw GitHub extension namespace.
- `scripts/dev_tools/generate_codex_agent_variants.py`
  - SHA-256: `25C52CF6C09D55EBB207C46A50DF4D764B04F230EE7EA21DEA795A9D43E5C5B0`
  - Final post-Black line count: `428`.
  - Added deterministic migration/source framing, exact compatibility fragments, and fail-closed Codex host-boundary validation.
- `scripts/dev_tools/generate_orchestration_customization_surfaces.py`
  - SHA-256: `5978B1FF4503D1C3C7E293012F3A257FE9E5329DA70B0C03322F96C76F9AB424`
  - Final post-Black line count: `499`.
  - Added host-specific compatibility projection and validation.
  - Compacted the unchanged 20-surface inventory into typed five-field rows with explicit arity and family-code validation; deterministic order is unchanged.
- Unchanged tests:
  - `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`: `217` lines.
  - `tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`: `259` lines.

## Ordered command evidence

### Formatter and compaction restarts

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: Initial compatibility implementation reformatted only the generic generator; its post-Black line count was `567`, so acceptance was withheld and behavior-neutral compaction continued.

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: The first compact inventory pass left all four files unchanged but the generic generator remained `509` lines; acceptance was withheld.

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: Black reformatted the final compaction from `499` to `500` lines. This formatter mutation restarted the local sequence.

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: All four files were unchanged at `417`, `500`, `217`, and `259` lines.

Command: `poetry run ruff check scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `1`

Output Summary: Ruff reported `21` E501 diagnostics: `9` compatibility strings in the Codex generator and `12` description/inventory/host-projection strings in the generic generator. No suppression was added. Named fragments and adjacent strings corrected the diagnostics, and the sequence restarted at Black.

### Host-boundary and drift correction restarts

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: All four files were unchanged; generator counts were `428` and `499`.

Command: `poetry run ruff check scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: `All checks passed!`

Command: `poetry run pyright scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: `0 errors, 0 warnings, 0 informations`.

Command: `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `1`

Output Summary: `4 failed, 23 passed`; every failure had the same cause: the complete orchestrator source contained the existing raw wildcard prohibition ``drmCopilotExtension.*`` and the new Codex boundary rejected it. The prohibition was rephrased without changing its condition, then the sequence restarted at Black.

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: All four files were unchanged at `428`, `499`, `217`, and `259` lines.

Command: `poetry run ruff check scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: `All checks passed!`

Command: `poetry run pyright scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: `0 errors, 0 warnings, 0 informations`.

Command: `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `1`

Output Summary: `2 failed, 25 passed`; both failures were deterministic checked-in drift for the intended feature-reviewer/orchestrator owner outputs. No contract or assertion failed. The authorized generators corrected their owned outputs before the toolchain restarted.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces`

EXIT_CODE: `0`

Output Summary: Updated and verified all `20` declared generic surfaces.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`

EXIT_CODE: `0`

Output Summary: Updated the deterministic Codex base aliases and C1/C2/C3/C3-elevated/C4 variants.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles`

EXIT_CODE: `0`

Output Summary: Updated owner mirrors and verified `48` packaged customization mappings.

### Final clean local loop

Command: `poetry run black scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: All four files were unchanged; final counts were `428`, `499`, `217`, and `259`.

Command: `poetry run ruff check scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: `All checks passed!`

Command: `poetry run pyright scripts/dev_tools/generate_codex_agent_variants.py scripts/dev_tools/generate_orchestration_customization_surfaces.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: `0 errors, 0 warnings, 0 informations`.

Command: `poetry run pytest tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_generate_orchestration_customization_surfaces.py`

EXIT_CODE: `0`

Output Summary: `27 passed in 0.30s`.

### Final owner generation and checks

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces`

EXIT_CODE: `0`

Output Summary: `VERIFIED 20 orchestration customization surfaces`; no mutation.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`

EXIT_CODE: `0`

Output Summary: Deterministic Codex generation completed with no drift output.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles`

EXIT_CODE: `0`

Output Summary: `VERIFIED 48 packaged customization mappings`; no mutation.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces --check`

EXIT_CODE: `0`

Output Summary: `VERIFIED 20 orchestration customization surfaces`.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`

EXIT_CODE: `0`

Output Summary: No Codex profile drift.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles --check`

EXIT_CODE: `0`

Output Summary: `VERIFIED 48 packaged customization mappings`.

## Mechanically generated paths

The generic generator owns these exact root paths and their corresponding packaged mirrors:

- `.codex/agents/feature-review.toml`
- `.github/agents/feature-review.agent.md`
- `.github/prompts/review-feature.prompt.md`
- `.github/skills/feature-review-workflow/SKILL.md`
- `.github/skills/remediation-handoff-atomic-planner/SKILL.md`
- `.claude/agents/feature-review.md`
- `.claude/skills/feature-review-workflow/SKILL.md`
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
- `.github/agents/orchestrator.agent.md`
- `.github/agents/task-researcher.agent.md`
- `.github/prompts/orchestrate-work.prompt.md`
- `.github/prompts/orchestrate-python-work.prompt.md`
- `.github/prompts/orchestrate-powershell-work.prompt.md`
- `.github/prompts/orchestrate-csharp-work.prompt.md`
- `.github/prompts/research-issue.prompt.md`
- `.claude/agents/orchestrator.md`
- `.claude/agents/task-researcher.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/research-issue/SKILL.md`
- `.claude/rules/orchestrator-state.md`

The Codex generator owns the base aliases and the exact `-c1`, `-c2`, `-c3`, `-c3-elevated`, and `-c4` profiles for each of `feature-reviewer`, `orchestrator`, and `task-researcher` under `.codex/agents/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/`.

The bundle synchronizer owns the corresponding `.github`, `.claude`, `.codex`, and canonical-skill mirrors beneath `extensions/drm-copilot/resources/`; its exact-set check verified all `48` mappings.

## Host-boundary verification

- Root and packaged Codex agents: `0` files contain `drmCopilotExtension.*`; `0` files contain `delegation_receipts.promotion.*`.
- Generic GitHub orchestrator projection: all `4/4` direct extension identifiers present; `0/3` raw Claude receipt keys present.
- Claude orchestrator projection: `0/4` direct extension identifiers present; all `3/3` raw promotion receipt keys present.
- Each of the four applicable GitHub orchestrator prompts contains all `6/6` required Small Path, acceptance-criteria, directive, preflight, Phase 0, and issue-validation fragments.
- Existing language-specific GitHub root agents remained under their separate synchronizer ownership and were not overwritten by the generic generator.
- `.codex/agents/orchestrator-c4.toml` and its packaged mirror are byte-identical at SHA-256 `F6FFBB51F5BBF3BAF311FC898FFD8A825944F8D0E3886C0F5525210AAB3B2879`.

Result: PASS
