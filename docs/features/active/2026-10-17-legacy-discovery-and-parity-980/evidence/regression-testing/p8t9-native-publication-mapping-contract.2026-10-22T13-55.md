# P8-T9 Approved native publication classification and mapping contract

Timestamp: 2026-10-22T13-55
Task: [P8-T9] Enable approved native publication classifications and mappings before hook creation.
Result: PASS

## Behavior verified (Python and TypeScript parity)

- Inventory (`codex_native_converter/inventory.py`, `codex-native-converter/inventory.ts`): `.github/hooks` joins the GitHub Copilot supported roots and `.claude/lib` joins the Claude supported roots. `.github/workflows` and every other unlisted path remain undiscovered.
- Classification (`classifier.py` + new `classifier_claude.py`; `classifier.ts` + `classifier-claude.ts`):
  - `.github/hooks/*.ps1|*.py` -> `hook-definition` / direct / `hook` (required).
  - `.github/hooks/*.json` -> `permissions-or-settings` / decomposed / `mcp-config` with a registration note (required).
  - any other `.github/hooks/**` resource (README, templates) -> unsupported and optional, with the note that documentation and templates have no native runtime surface; no instruction-only restriction is represented as a native control.
  - `.claude/lib/**/*.psm1|*.psd1|*.ps1` -> `host-adapter-reference` / direct / `hook` (required) with a verbatim-publication note.
  - any other `.claude/lib/**` resource (bash libraries, docs) -> unsupported and optional.
  - an unrelated `.github` path such as `.github/workflows/ci.yml` stays unsupported and required-for-review, exactly as before.
- Mapping (`mapping.py`, `mapping.ts`): a `hook`-role helper keeps its library-relative name under `.codex/lib/<library>/<file>`; a hook handler maps to `.codex/hooks/<normalized>.ps1`; a hook registration maps to `.codex/config.toml`.
- Rendering (`pipeline.py`, `pipeline-render.ts`): a `.codex/lib` helper is emitted verbatim after reference rewrites; handler hooks keep the "Converted hook" wrapper.
- Reference rewrites (`rewrites.py` + new `rewrites_detection.py`; `rewrites.ts` + `rewrites-rules.ts`): three new GitHub hook rules (registration -> `.codex/config.toml`, handler -> `.codex/hooks/<name>.ps1`, directory -> `.codex/hooks/`) and one Claude helper rule (`.claude/lib/` -> `.codex/lib/`), in the same catalog positions in both runtimes; the unresolved-runtime detector now flags leftover `.github/hooks/` and `.claude/lib/` references.
- Push-down (`agentic_sync.py`, `copilot-customizations-engine.ts`): `.github/hooks` is a scoped Copilot root in sorted position, so the Copilot publisher copies published hooks with the other `.github` trees (verified: five scoped files copied, including the hook).
- Codex bundle publication (`push_down_codex_and_agents_customizations.py`, `codex-agents-customizations.ts`): a directory-level virtual mapping publishes every file stored under `resources/lib/discovery-validation/` to `.codex/lib/discovery-validation/` with the same name, so the P9-T1 helper modules need no per-file entry; `.codex/lib/discovery-validation` is a published virtual root; the directory lists nothing until resources are stored and creates no destination tree.
- Validation (`validation.py`, `validation.ts`): no code change was required; the mapping-record and duplicate-target rules already govern the new roles, and the unresolved-reference check reads the extended detector table. Two hook registrations in one run would collide on `.codex/config.toml` and surface as the existing `duplicate-target-path` blocking finding, which is the intended "review and merge intentionally" behavior.

## Tests

- Python: six classifier tests, two inventory tests, two mapping tests, two rewrite tests and two end-to-end review runs over the new committed fixture `tests/fixtures/codex_native_converter/native_surfaces/` (hook handler, registration, README, unrelated workflow, PowerShell helper, bash helper); a `ROOT_FOLDERS` contract test; two Codex virtual-directory publication tests; the Copilot copy test now covers the hook root. 186 focused tests pass; every pre-existing assertion is retained.
- TypeScript: inventory seeds and expectations, five classifier matrix rows, two mapping cases, two rewrite cases, two render cases, the Copilot root-folder enumeration order, and two Codex directory-publication cases. 49 suites/639 focused tests and the full 310-suite population pass.

## File accounting

- New authored code: `scripts/dev_tools/codex_native_converter/classifier_claude.py` (Claude classification path relocated with the new helper branch so classifier.py stays under 500 lines), `scripts/dev_tools/codex_native_converter/rewrites_detection.py` (detector relocated so rewrites.py stays under 500 lines), fixture tree `tests/fixtures/codex_native_converter/native_surfaces/`.
- Changed existing code: the nine Python and nine TypeScript production files listed above plus eight Python and seven TypeScript test files.
- No generated mirrors were produced; no resource file was added. The approved mapping is in place for P9-T1 to publish the helper modules and update the core pack manifests.

## Acceptance statement

The existing publishing/conversion pipeline can classify and deliver the approved native surfaces (GitHub hook handlers and registrations, PowerShell helper libraries) before P9-T1 creates helper files. No unrelated path becomes supported (workflows, bash helpers and hook documentation stay unsupported), and no instruction-only restriction is represented as a native control. Helper and hook mirror verification remains with each P9 task and final publication.

## Carried notes

- `scripts/dev_tools/agentic_sync.py` (820 lines) and `tests/scripts/dev_tools/test_agentic_sync.py` (598 lines) already exceeded the 500-line limit before this task; each received a one-line root addition and one short contract test respectively. `scripts/dev_tools/push_down_copilot_customizations.py` (504 lines) was not modified; it reads `ROOT_FOLDERS` from agentic_sync. These pre-existing overruns are recorded for the P11 closing review.
