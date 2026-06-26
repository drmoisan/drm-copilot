# F10 Acceptance Criteria Verification

Timestamp: 2026-06-26T12-20

Line-by-line pass/fail for each F10 acceptance criterion with the supporting
evidence.

## AC-F10-1 — All 16 modules ported with behavior parity — PASS

All 16 in-scope `codex_native_converter/*.py` modules are ported to
`extensions/drm-copilot/src/lib/codex-native-converter/`:
models, models-intermediate, inventory, classifier (+classifier-claude),
section-intent, parser, mapping, rewrites (+rewrites-rules), validation, pipeline
(+pipeline-render), intermediate-state, reporting (+reporting-render),
pipeline-traces (`_pipeline_traces`), reporting-topology (`_reporting_topology`),
engine (+engine-pipeline), cli. Enum values, type shapes, classification logic,
parsing, mapping, rewrites, validation findings, pipeline orchestration,
intermediate-state serialization, reporting, engine review/apply flows, CLI
review/apply behavior, and error/report strings are preserved verbatim.
Evidence: ported source files plus the hermetic Jest suites under
`test/lib/codex-native-converter/` (1387 tests pass; see
`f10-final-test-coverage.md`).

## AC-F10-2 — Files split as planned; none > 500 lines — PASS

Planned splits in place: classifier.ts + classifier-claude.ts; rewrites.ts +
rewrites-rules.ts; engine.ts + engine-pipeline.ts; pipeline.ts +
pipeline-render.ts; reporting.ts + reporting-render.ts. No file in
`src/lib/codex-native-converter/**` or `test/lib/codex-native-converter/**`
exceeds 500 lines (largest src: validation.ts 372; largest test:
reporting.test.ts 400). Evidence: `wc -l` size check executed at QA time.

## AC-F10-3 — Service invokes in-process port; no Python spawn; service <= 500 — PASS

`RepoAutomationService.runCodexNativeConverter()` delegates to
`codex-native-converter-service-call.ts` via `this.fileSystem`; no
`runtimeKind: "python"` / `codex_native_converter.py` spawn path remains
reachable from that method. `repo-automation-service.ts` is 494 lines.
Evidence: `repo-automation-service.ts` (rewired method), workflows.ts (Python
builder removed; `RunCodexNativeConverterInput` still exported),
`codex-converter-extension-test-search.md`.

## AC-F10-4 — Return contract preserved — PASS

The service result returns `tool: "run_codex_native_converter"`, the exact
summary `Ran bundled codex-native-converter in <mode> mode for '<ecosystem>'.`,
and a single normalized artifact path equal to the conversion-report parent
directory. Review never writes a destination; apply writes only with no blocking
findings. Evidence: `codex-native-converter-service-call.test.ts`,
`repo-automation-service.codex-native-converter.test.ts`, `engine.test.ts`.

## AC-F10-5 — Typer replaced by TS arg parser; error strings + exit code preserved; no typer dep — PASS

`cli.ts` exposes `resolveSourceEcosystem`, `resolveRunOptions`, `printRunSummary`,
`review`, `apply` with verbatim error strings (`source_root must point to an
existing directory.`, `apply mode requires --destination-root.`,
`source_ecosystem must be 'github-copilot' or 'claude'.`) and the apply
non-zero-exit-equivalent on blocking findings. No `typer` runtime dependency is
introduced. Evidence: `cli.test.ts` (15 tests).

## AC-F10-6 — Hermetic Jest tests covering all 16 Python test files; T1 invariant coverage — PASS

All Jest tests inject `InMemoryFileSystem` (no real filesystem, no temp files, no
subprocess) and live under `test/lib/codex-native-converter/`. The classifier
suite includes exhaustive table-driven invariant coverage for the T1 classifier
modules. Evidence: `test/lib/codex-native-converter/*.test.ts`,
`property-test-tooling-note.md`.

## AC-F10-7 — New files meet coverage policy — PASS

Every `src/lib/codex-native-converter/**` file meets line >= 85% and branch
>= 75%. No regression on changed lines (overall src/lib line 96.45% -> 97.03%,
branch 88.07% -> 88.28%). Evidence: `f10-final-test-coverage.md`,
`f10-coverage-delta.md`.

## AC-F10-8 — Format, lint, type-check, test all pass in one clean pass — PASS

Format EXIT 0 (all unchanged), lint EXIT 0 (0 errors), typecheck EXIT 0 (0
errors), test EXIT 0 (115 suites, 1387 tests). Evidence: `f10-final-format.md`,
`f10-final-lint.md`, `f10-final-typecheck.md`, `f10-final-test-coverage.md`.

## AC-F10-9 — F1 modules reused; protected paths unmodified — PASS

`file-system.ts` and `subprocess-runner.ts` are reused (not re-ported; no
additive extension was required). `command-runtime.ts`, the `"python"` branch,
and all `scripts/dev_tools/**` / `resources/**/*.py` are unmodified (verified via
`git diff --quiet`). Evidence: git diff check at QA time.

## AC-F10-10 — Reworked MCP tests preserve schema/dispatch assertions; no Python-spawn assertions — PASS

`mcp-tools.codex-native-converter.test.ts`,
`codex-native-converter-handlers.test.ts`, and
`mcp-tool-inputs.codex-native-converter.test.ts` preserve their input-schema and
dispatch assertions and assert the in-process path; none asserts a
`codex_native_converter.py` Python spawn. Evidence:
`codex-converter-spawn-test-search.md`.

## Outcome

All 10 acceptance criteria pass with cited evidence.

Note (evidence-path deviation): the plan named
`evidence/qa-gates/f10-acceptance.md`; this matches the written path. Sibling P9
artifacts use `f10-`-prefixed names to avoid overwriting the F9 feature's
final-QC artifacts in the shared qa-gates folder.
