---
name: scratch-pester-runner-strict-mode-leak
description: A scratch Pester launcher that sets Set-StrictMode leaks it into every suite it runs and produces failures that no PoshQC run shows; also Write-Output -NoEnumerate wraps a string in a List
metadata:
  type: feedback
---

Do not put `Set-StrictMode -Version Latest` in a scratch Pester launcher (shuffled-order runs, named-file JUnit runs). Strict mode set at the launcher's script scope propagates into the test files it invokes, and 1020-style suites that read `.Count` on an empty array or expand an unset `<name>` placeholder then fail identically in every seed while they pass under `Invoke-PoshQCTest`.

**Why:** On issue 1033 the three seeded shuffled runs reported the same two `DocsSurface`/`DocsSchema` failures in every seed; they vanished once the strict-mode line was removed from the runner. Treating them as order dependence would have been wrong.

**How to apply:** Before reporting an order dependence, confirm the failure also appears in a PoshQC run of the same files; if it appears only under the scratch runner, check the runner's own preference and strict-mode settings first. Related: `Write-Output -NoEnumerate 'text'` returns a `List[object]` in PowerShell 7, so a record accessor that must keep arrays whole should use `return , $value` only when the value is an `IList`, and tests must read it as `(f).Count`, never `@(f).Count` (see [[powershell-comma-return-and-paired-sort-pitfalls]]).
