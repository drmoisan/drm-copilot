---
name: pester-order-and-codespace-host-failures
description: Full tests/scripts Pester runs on the Linux Codespace fail ~249 tests on main, and Pester runs directories in file-system order, so failure sets differ between checkouts
metadata:
  type: project
---

On the Linux Codespace host (observed 2026-11-03, issue 1020), a single-process `Invoke-PoshQCTest -ScanFolders tests/scripts` on unchanged `main` fails about 249 tests (C: drive fixtures, `/repo` permission, `pwsh` not found). Pester enumerates `tests/scripts` in file-system directory order, not sorted order. When `tests/scripts/dev-tools` runs before `codex-scripts`, all 160 `Resolve-CodexRouting.Parity.Tests.ps1` cases fail too, because a dev-tools suite leaves state that breaks `Get-Command pwsh -CommandType Application`. JUnit export can also throw on 0x1B characters in failure messages, which leaves `pester-junit.xml` holding only its header.

**Why:** a baseline captured on another host (Windows, 0 failures) cannot be compared with a Codespace run. A plan acceptance condition of the form "every failing name is in the baseline" then fails for reasons unrelated to the change.

**How to apply:** before you accept a full-run comparison, check that the baseline came from the same host. If it did not, build a same-host merge-base reference (`git clone --shared` into SCRATCH, then check out MERGE_BASE) and compare failing names against it with an `Invoke-Pester -PassThru` script. Check `ls -U tests/scripts` to see the order each checkout runs in. Leave the task unchecked when its literal acceptance still fails, and escalate.
