# Remediation Inputs — expose-commit-script (#74)

## Required fixes

1. **Fix extension formatting gate failure**
   - **Files:** `extensions/scaffold-extension/package.json` (and any formatter-touched extension files)
   - **Expected behavior:** check-only formatter passes with zero style diffs.
   - **Acceptance criteria:** repository quality gate for extension format is green.
   - **Verification commands:**
     - `npm --prefix extensions/scaffold-extension run format`
     - `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/*.ts" "*.json" "*.cjs"`

2. **Re-run extension toolchain after formatting**
   - **Files:** `extensions/scaffold-extension/src/extension.ts`, `extensions/scaffold-extension/test/*.ts`, `extensions/scaffold-extension/package.json`
   - **Expected behavior:** lint, typecheck, and tests all pass in the post-format state.
   - **Acceptance criteria:** no regressions in command registration, cwd/args behavior, and error-path tests.
   - **Verification commands:**
     - `npm --prefix extensions/scaffold-extension run lint`
     - `npm --prefix extensions/scaffold-extension run typecheck`
     - `npm --prefix extensions/scaffold-extension run test -- --runInBand`

3. **Raise integration fidelity for staged-artifact validation**
   - **Files:** `extensions/scaffold-extension/test/extension.integration.test.ts` (or dedicated companion integration test file)
   - **Expected behavior:** at least one integration scenario validates artifact generation semantics from a real collector execution path over a deterministic fixture approach (policy-compliant, no external dependencies).
   - **Acceptance criteria:** AC “integration tests verify end-to-end artifact generation … with staged changes” can be marked PASS instead of PARTIAL.
   - **Verification commands:**
     - `npm --prefix extensions/scaffold-extension run test -- --runInBand -t "collectCommitContext"`

4. **Refresh PR context after remediation commits**
   - **Files:** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`
   - **Expected behavior:** summary/appendix reflect real base-vs-head commit range instead of base=head parity.
   - **Acceptance criteria:** audit traceability from summary artifact becomes reliable.
   - **Verification commands:**
     - `poetry run python -m scripts.dev_tools.pr_context.collector --base development`

## Do-not-do list

- Do not weaken policies, suppressions, or quality gates to force green.
- Do not introduce scope creep beyond the four fixes above.
- Do not silently skip coverage/verification evidence updates.
- Do not rewrite unrelated extension behavior.

## Acceptance criteria not yet fully met

1. **Integration end-to-end artifact generation with staged changes** — currently PARTIAL due mocked artifact-text generation path.
   - **Minimum change to meet:** add one higher-fidelity integration test for real collector output behavior (deterministic fixture approach).
2. **PR readiness gate** — currently blocked by formatter check failure.
   - **Minimum change to meet:** format/fix extension manifest and rerun full extension quality sequence successfully.
