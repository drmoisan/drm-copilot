# pester-fixtures-platform-independent — User Story

- Issue: #1067
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-03

## Story Statement

- As the repository maintainer who runs the PowerShell suites on Linux and Windows, I want the `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` suites to pass on both hosts without host-specific fixtures, so that a Linux run is a reliable signal and a failure points at a real defect rather than at a Windows-only path.

## Problem / Why

On Linux, 89 of the 921 tests in the two trees fail, all in 17 suites, because the fixtures use drive-letter paths, backslash expectations, a fixed Windows platform shape, and real writes under `/repo`. The failures hide four production defects that behave differently by host or by working directory. CI runs these suites only on `windows-latest`, so the failures do not appear there.

## Personas & Scenarios

- Persona: repository maintainer
  - Develops in a Linux Codespace and on Windows; merges through the required `poshqc / PowerShell QC` check.
  - Needs a single-process Pester run to report 0 failures on either host, so that order dependence and real regressions are visible.
  - Constraint: tests create no temporary files and make no real file-system writes; the repository is public, so fixtures carry no personal paths.
- Scenario: validating a change on Linux
  - The maintainer changes a dev-tools script in the Codespace and runs Invoke-Pester over both trees in one process.
  - Today 89 unrelated failures appear, and the maintainer must compare them with a baseline to find any new failure.
  - After this change the run reports 0 failures, so any failure is caused by the change under test. The Windows shards still pass on the pull request.

## Acceptance Criteria

Acceptance criteria for this full-bug item are tracked in `spec.md` `## Acceptance Criteria` only. This story adds no separate criteria.

## Non-Goals

- Adding these trees to the `ubuntu-latest` PowerShell CI leg (an open owner decision recorded in `spec.md`).
- Changes to `tests/scripts/dev-tools/run-actionlint.Tests.ps1` (sibling issue #1066).
- A shared test helper, `-Skip` conditions, TestDrive, or temporary files.
