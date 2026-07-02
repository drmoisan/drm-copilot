# Codex Mirror Governing Mechanism — Issue #272

Timestamp: 2026-07-02T19-20

Read `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` in full and the `codex_native_converter` test harness under `tests/scripts/dev_tools/codex_native_converter/`.

## Finding

`test_push_down_codex_and_agents_resource_contracts.py`'s `SCOPED_ROOTS = (Path(".codex"), Path(".agents"))` compares **repo-root** `.codex/**`/`.agents/**` against the bundled copies at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/**`/`.agents/**`. This repository has **no repo-root `.codex/` directory at all** (confirmed: `.codex/` does not exist at repo root). Therefore this test's byte-identity comparison does not, and cannot, cover `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` — there is no repo-root counterpart for it to compare against. Running this test (`poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`) passes but is not the governing mechanism for this specific file.

No test under `tests/scripts/dev_tools/codex_native_converter/` references `enforce-pr-author-skill.ps1` or the `"Converted hook"` header string by name (grep confirmed zero matches).

## Confirmed Governing Mechanism

The **authoritative** mechanism is the `codex_native_converter` CLI/pipeline itself: `python -m scripts.dev_tools.codex_native_converter apply --source-root . --source-ecosystem claude --selected-path .claude/hooks/enforce-pr-author-skill.ps1 --destination-root <dest> --artifact-root <artifact-dir>`. This is the tool that originally produced the bundled Codex hook mirror (per `pipeline.py`'s `TargetRole.HOOK` branch, which emits the 3-line `# Converted hook` header). The `_SUPPORTED_ROOTS[SourceEcosystem.CLAUDE]` inventory table (`scripts/dev_tools/codex_native_converter/inventory.py`) maps `.claude/hooks` as a supported source surface, and `--source-root` must be the **repository root** (not `.claude`) since the supported-roots paths are repo-root-relative.

Running this CLI against a scratch destination directory (not the real repo tree, to avoid unintended writes) confirmed the mapping: `.claude/hooks/enforce-pr-author-skill.ps1 -> direct -> hook -> .codex/hooks/enforce-pr-author-skill.ps1`, with `Validation outcome: pass`.

## Command Used for P4-T8 Verification

```
poetry run python -m scripts.dev_tools.codex_native_converter apply \
  --source-root . --source-ecosystem claude \
  --selected-path .claude/hooks/enforce-pr-author-skill.ps1 \
  --destination-root <scratchpad-dest> --artifact-root <scratchpad-artifacts>
```

The output at `<scratchpad-dest>/.codex/hooks/enforce-pr-author-skill.ps1` is the authoritative expected content and is compared (via `diff --strip-trailing-cr`) against the repository's bundled mirror in P4-T8.
