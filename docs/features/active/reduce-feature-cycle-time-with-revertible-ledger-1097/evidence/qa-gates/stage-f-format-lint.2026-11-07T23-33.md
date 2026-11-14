# Stage F Format, Lint, and Type Gate (P3-T1)

Timestamp: 2026-11-07T23-33
Command: over the .py, .ts, and .ps1 files of the diff from the merge base of origin/main and HEAD (7 Python, 5 TypeScript, 1 PowerShell, including scripts/dev_tools/plan_gate_document.py): poetry run black --check, poetry run ruff check --no-fix, poetry run pyright; in extensions/drm-copilot npx prettier --check, npx eslint, npx tsc -p tsconfig.jest.json --noEmit; sh-launched PowerShell 7 with Invoke-PoshQCFormat and a no-op -WriteFile, and a direct Invoke-ScriptAnalyzer run with scripts/powershell/PoshQC/settings/pssa.settings.psd1 (launchers stored under SCRATCH)
EXIT_CODE: 0
Output Summary:
  Python files: scripts/dev_tools/plan_gate_document.py, plan_gate_discrimination.py, validate_orchestration_artifacts.py; tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py, test_plan_gate_document_parity.py, test_validate_orchestration_artifacts_plan_gates.py, test_plan_gate_document_docs.py.
  Black: 7 files would be left unchanged (no file to reformat). Ruff: All checks passed! (0 findings). Pyright: 0 errors, 0 warnings, 0 informations.
  TypeScript files: src/lib/validate/plan-gate-document.ts, plan-gate-discrimination.ts, orchestration-artifacts.ts; test/lib/validate/plan-gate-document-parity.test.ts, plan-gate-guideline-cutoff.test.ts.
  Prettier: All matched files use Prettier code style! ESLint: 0 findings. tsc against the Jest project: 0 errors.
  PowerShell: tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1: PoshQC log 1 Already formatted line, 0 Formatted lines; analyzer (direct run) 0 findings.
  No tool changed a file; no repair was needed.
