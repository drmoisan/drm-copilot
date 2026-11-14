# Research: root Prettier check fails on three docs-analyzer JSON fixtures (issue #1179)

Timestamp: 2026-11-14T00-00 (the researcher has no shell, so the host clock could not be read; the stamp is the date only and the time is a placeholder)
OWNER-DIRECTIVE-DECISION: OD-1 | unclassified | refused | - | OD-1 is autonomous-mode task direction only; it is not a recorded checkpoint entry and no class applies, so no behavior changed (research proceeded to completion regardless).

## Limits of this research

- The researcher has Read, Grep, Glob, WebFetch and Write only. It could not run `npm run format:check`, `npx prettier --check`, or `git`. Question 5 is therefore answered by static enumeration of the check's input set, not by a run. The exact Prettier diff per file is inferred from file content, not produced by Prettier. The orchestrator or executor must run the check once before and after the change.

## Q1. What the root check runs and what Prettier wants

- `package.json` (repo root) script `format:check`: `node run-node-tool.cjs prettier/bin/prettier.cjs --no-error-on-unmatched-pattern --check "src/**/*.{ts,tsx,js,mjs,cjs,json}" "tests/**/*.{ts,tsx,js,mjs,cjs,json}" "eslint.config.mjs" "jest.config.cjs" "tsconfig*.json" "run-*.cjs"`. The sibling `format` script is identical with `--write`. Prettier is `^3.9.10` in devDependencies.
- No Prettier config exists at the root (no `.prettierrc*`, no `prettier.config.*`, no `prettier` key in `package.json`, no `.editorconfig`), so Prettier 3 defaults apply: `printWidth` 80, 2-space indent, `endOfLine: lf`.
- `.prettierignore` holds exactly: a comment (`Fixtures keep exact bytes (CRLF, intentionally invalid JSON); see issue #848.`) and `tests/fixtures/`.
- The three files live under `tests/scripts/claude-lib/docs/fixtures/`, which is inside the `tests/**/*.json` glob and not covered by the `tests/fixtures/` ignore entry (that entry is anchored to the repo-root `tests/fixtures/` directory).
- Inferred diff (from reading the files):
  - `python-native-corpus.json`: single-line objects longer than 80 columns (the `console_scripts`, `native_input_scanner_diagnostics` and `diagnostic_classes` entries) are expanded to one key per line; short expanded arrays such as `native_source_roots` collapse to `["native"]`.
  - `config-surface-corpus.json`: already expanded style; the diff is expected to be array/object collapse or expansion at the 80-column boundary. The exact hunks are unknown without a run.
  - `python-surface-corpus.json` (largest, about 3.5k lines): same class of differences; not inspected line by line.
  - String contents (embedded Python source with `\n`, `\x6d` text, BOM characters) are never altered by Prettier's JSON printer, and key order and number literals are preserved.

## Q2. Do consumers depend on fixture bytes?

All consumers parse the JSON semantically and use only parsed values. Verified by reading each loader:

- Pester suites read with `[System.IO.File]::ReadAllText(..., UTF8Encoding($false))` then `ConvertFrom-DocsJsonText`, and assert `$parsed.Findings.Count | Should -Be 0`: `DocsAnalyzerConfigFiles.Tests.ps1`, `DocsAnalyzerArchitecture.Tests.ps1`, `DocsAnalyzerPythonCli.Tests.ps1`, `DocsAnalyzerPythonHttp.Tests.ps1`, `DocsAnalyzerPythonApi.Tests.ps1` (each via `$script:CorpusPath`), `DocsAnalyzerPythonNative.Parity.Tests.ps1` (`Read-TestFixture`), `DocsInventorySnapshot.Tests.ps1` and `DocsInventoryProperties.Tests.ps1` (`Read-TestCorpus`), `DocsPythonNativeProtocol.Tests.ps1` (inline reads of `python-surface-corpus.json` and `python-native-corpus.json`).
- `tests/scripts/claude-lib/docs/python/test_docs_python_native_corpus.py` loads with `json.loads((FIXTURES / name).read_text(encoding="utf-8"))` (`_load`, `_fixtures`) and uses only parsed `inputs`, `native_inputs`, `expected_elements`, `native_only_elements`, `console_scripts`, `diagnostic_classes`.
- Digest assertions (`source_sha256`, `Get-DocsDeclarationSha256`, the `Parity` and `Properties` suites) hash the embedded Python or config source text taken from the parsed `inputs` values, not the fixture file bytes. Reformatting does not change a decoded string value, so those digests are unchanged. The feature-1031 evidence `digest-recheck.*.md` likewise compares per-element declaration digests, not a file hash.
- No consumer was found that hashes the whole fixture file, asserts its length, line count or offsets, or reads fixture text by position. The DocsInventorySnapshot and DocsInventoryProperties suites build snapshots from parsed inputs; the only file-level pin found is the JSON-parses-with-zero-findings assertion.
- Mirrors: a repo-wide search for the three file names (excluding `node_modules`) matched only the tests above, the issue/spec/promoted records, and historical feature docs under `docs/features/active/`. No copy exists under `extensions/drm-copilot/resources/`, no other fixture embeds them, and no pack manifest lists them.
- A repo CRLF concern does not apply: `.gitattributes` has `* text=auto eol=lf` (per the execution-environment brief), the files are valid JSON, and Prettier's default `endOfLine: lf` matches.

## Q3. Existing ignore convention

- `.prettierignore` ignores only `tests/fixtures/` (issue #848), with the stated reason that those fixtures need exact bytes (CRLF, intentionally invalid JSON). The convention is "ignore only where bytes matter". The three docs fixtures are valid, LF, semantically consumed JSON, so they do not meet the stated reason.
- `tests/fixtures/` JSON files are therefore not checked; apart from the three files, no other `.json`, `.js`, `.mjs` or `.cjs` file exists under `tests/` outside `tests/fixtures/` (Grep counts by file type: JSON 3 files, JS 0 files; TS files are `tests/unit/vscode-test-removal.test.ts`, `jest-config-resolution.test.ts`, `hello-typescript.test.ts`). `src/` holds one file, `src/hello-typescript.ts`.
- JSON is outside the file-size gate (`FileSizePolicy.psm1` allowed extensions: `.py .ps1 .psm1 .ts .tsx .js .cjs .mjs .cs .sh .bats`), so reformatting growth has no file-size consequence; none of the three is in `config/file-size-baseline.json`.

## Q4. CI placement

- No workflow under `.github/workflows/` runs `format:check` or Prettier (Grep over the directory returned no match). `_root-typescript-tests.yml` (job `root-typescript-tests`, matrix `windows-latest` and `ubuntu-latest`, Node 26.13.0) runs `npm ci` then `npm test`; `npm test` is `node run-jest.cjs`, with `pretest` (`compile` and `lint`) running first.
- Option A (recommended): add one step after "Install root dependencies" in `_root-typescript-tests.yml`: name "Check root formatting", `run: npm run format:check`. No job is added, so `ci.yml`, the `needs:` list of `ci-required-gate`, `CiRequiredGateWorkflow.Tests.ps1`, the required-contexts list, and the six copies of the execution-environment brief (which name jobs and check names, not steps of this workflow) need no change. Existing pins on this file: `test_host_environment_contracts.py::test_development_node_workflow_matches_host_baseline` (node-version regex only, unaffected); `CiChangeScopeWorkflow.Tests.ps1` and `CiRequiredGate*.Tests.ps1` reference the job id only. A grep of `tests/` for `format:check` and the step names found no pin on step lists.
- Docs-only behavior: per the brief, `root-typescript-tests` is skipped at job level on a docs-only run and `CI Required Gate` accepts `skipped` for it, so the new step does not run on docs-only commits. That is acceptable; fixture or code changes are non-docs paths (`tests/` is not allowlisted) and run the full set.
- Option B (rejected): a new `ci.yml` job. It requires adding the job to `ci-required-gate` `needs:`, updating `CiRequiredGateWorkflow.Tests.ps1` and `Invoke-CiRequiredGate` skippable-set handling, `.github/workflows/README.md`, and all six brief copies plus the required-context refresh. Cost with no benefit over Option A.
- Runs on Windows too: with `eol=lf` checkout and Prettier `endOfLine: lf`, line endings agree. The step also needs `package-lock.json` Prettier (already installed by `npm ci`).
- Workflow-change rule: `modified-workflow-needs-green-run` requires a green run on the branch head, which exercises the new step on both OSes.

## Q5. Does the check fail on anything else?

- Not run (no shell). Static enumeration of the check's input set: JSON under `tests/**` = the three fixtures only (plus ignored `tests/fixtures/**`); TS under `tests/**` = 3 files; `src/**` = `src/hello-typescript.ts`; plus `eslint.config.mjs`, `jest.config.cjs`, `tsconfig*.json`, `run-*.cjs` at the root. The issue states the failure set is the three fixtures; whether the 3 test files, `src/hello-typescript.ts` and root configs are Prettier-clean is unverified. The executor must run `npm --prefix <repo root> run format:check` before the edit (expect exactly three listed files) and after.

## Q6. Recommendation

Reformat the three fixtures with Prettier (`npm run format`, scoped to those three paths or the full script) and add the `format:check` step to `_root-typescript-tests.yml` (Option A). Do not add them to `.prettierignore`.

Rationale: every consumer decodes the JSON and no consumer pins bytes, hashes, lengths or offsets; embedded digests are over decoded source strings that Prettier does not change; no mirror or bundle copy exists. Ignoring them would contradict the `.prettierignore` convention (ignore only where exact bytes matter) and leave the CI check permanently blind to these files. Reformatting is verified safe by running the affected suites once (parallel, one gate at a time): the Pester docs suites listed in Q2 via `Invoke-PoshQCParallelTest`, and `test_docs_python_native_corpus.py` in one `pytest -n auto` run.

Rejected alternatives: `.prettierignore` entry (hides valid JSON, no byte-pinning justification); new CI job (job-list, gate, test and six-copy brief churn).

## Required file changes

- `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`, `python-native-corpus.json`, `python-surface-corpus.json`: Prettier-format only, no content change.
- `.github/workflows/_root-typescript-tests.yml`: one added step.
- Optional: `.github/workflows/README.md` if it lists steps of this workflow (only job-level rows were found).

## Testing Implications

- Before/after `npm run format:check` (expect red with 3 files, then green).
- Semantic-equality proof: parse each fixture before and after and compare the decoded value (a scratch script, not committed; no temp files in tests).
- Regression: one parallel Pester run covering `tests/scripts/claude-lib/docs`, and one `pytest -n auto` for `tests/scripts/claude-lib/docs/python/test_docs_python_native_corpus.py`.
- No new test code is required; a workflow-text test for the new step is optional and would add a pin to maintain.

## Pre-Mortem

- Review checklists: a reviewer may flag a workflow change without a green run; mitigation: the plan records a green `CI` run on the branch head covering both OS legs of `Root TypeScript Tests` (rule `modified-workflow-needs-green-run`).
- Coverage: no production code changes, so no coverage movement; the plan states "not applicable: fixtures and workflow YAML only" and does not claim a coverage delta.
- Mirror parity: Option A touches no mirrored or bundled file and no job name, so the six execution-environment copies stay unchanged; the plan must confirm that no listed fact (job list, required contexts) changes, and the contract tests `test_execution_environment_brief_contracts.py` and `CiRequiredGateWorkflow.Tests.ps1` stay green.
- File size: JSON is outside the size gate and none of the three is baselined; the formatted files grow in line count, which is not gated. Not a failure risk.
- Test isolation: running the docs Pester suites and the pytest corpus test must use the parallel gates only (one `Invoke-PoshQCParallelTest`, one `pytest -n auto`); no focused-run evidence is presented as a gate, and no temp files are created.
- CI-only behavior: the new step first runs on Windows and Linux in CI; line endings are LF via `.gitattributes` and Prettier defaults, but a root file other than the three (TS tests, `src/hello-typescript.ts`, root configs) could be unclean and fail only there. Mitigation: run `format:check` locally in full before pushing, and fix any additional file in the same change. The step is skipped on docs-only runs, so a green docs-only run is not evidence for it.
- Evidence: the exact Prettier diff and the check results are not yet produced; the plan must record before and after `format:check` output (Timestamp, Command, EXIT_CODE, Output Summary) under `evidence/baseline/` and `evidence/qa-gates/` with the clock-read stamp.
