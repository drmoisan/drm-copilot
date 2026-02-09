# Remediation Inputs: 2026-02-04-extension-tests-fail-in-container-12

Timestamp: 2026-02-09T15-50

## Required Fixes (Enumerated)

1) **Scope trim by splitting into three branches**
    - **Goal:** Split the current branch into three focused branches and keep Issue #12 scope clean.
    - **Branch A:** `chore/test-coverage-expansion` (test expansions + tooling test fixes)
       - **Commits:** `5b6d0e4`, `2496634`
       - **Expected contents:** dev-tools test expansions, test fixes, supporting helper changes.
    - **Branch B:** `feature/agents-skills-docs` (agent/skills upgrades + documentation)
       - **Commits:** `b1353f9`, `d8755a8`
       - **Expected contents:** `.github/agents/*`, `.github/skills/*`, doc-only notes.
    - **Branch C:** `bugfix/extension-tests-failing-in-container-#12` (core in-scope feature delivery)
       - **Commits:** `00d059d`, `2f67b88` (optionally `dd5b5f7` if you want issue docs)
       - **Expected contents:** Jest unit tests for extension, removal of `vscode-test` harness, `package.json` script updates, docs updates.
    - **Acceptance criteria:** `feature-audit.2026-02-09T15-50.md` criterion “No unintended behavior changes outside the defined scope” changes from FAIL → PASS.
    - **Verification:** For each branch, run `git show --name-only <commit>` to confirm file lists, then re-generate PR context (`poetry run python -m scripts.dev_tools.pr_context.collector --base origin/feature/import-pre-built-functionality`) and confirm each branch diff matches its intended scope.

2) **Align README testing guidance with new scripts**
   - **Files:** `README.md`
   - **Expected behavior:** README must state that `npm test` and `npm run test:integration` execute Jest unit tests (no GUI), and remove or clarify the GUI-only integration test language.
   - **Acceptance criteria:** `feature-audit.2026-02-09T15-50.md` criterion “Docs/config references updated to match the new behavior” changes to PASS.
   - **Verification:** Review README content and confirm it matches `package.json` scripts.

3) **Run PowerShell toolchain and record evidence** (completed in audit)
    - **Files:** `scripts/dev-tools/format-powershell.ps1`, `tests/scripts/dev-tools/format-powershell.Tests.ps1`
    - **Expected behavior:** PowerShell formatting, analysis, and tests must pass per repo policy.
    - **Acceptance criteria:** `policy-audit.2026-02-09T15-50.md` PowerShell tooling sections move to PASS.
    - **Verification commands (already executed):**
       - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
       - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
       - `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

4) **Verify repro in dev container (Branch C)**
   - **Files:** N/A
   - **Expected behavior:** Run Jest tests in a dev container to validate the repro environment explicitly.
   - **Acceptance criteria:** `feature-audit.2026-02-09T15-50.md` criterion “Repro steps now produce expected behavior in all documented environments” moves to PASS.
   - **Verification command:** `npm run test:unit` executed inside the dev container.

## Acceptance Criteria Not Yet Met

- No unintended behavior changes outside the defined scope (FAIL — branch not yet split)
- Full toolchain pass completed (PARTIAL — formatting steps were check-only; dev container run not verified)
- Docs/config references updated to match the new behavior (PARTIAL — README mismatch)
- Repro steps now produce expected behavior in all documented environments (PARTIAL — dev container run not verified)

## Do Not Do

- Do **not** broaden scope further beyond Issue #12 requirements.
- Do **not** weaken or bypass repo policies (no suppressions or config relaxations).
- Do **not** skip PowerShell QC or omit evidence for toolchain runs.
- Do **not** add new dependencies unless explicitly required by Issue #12.
