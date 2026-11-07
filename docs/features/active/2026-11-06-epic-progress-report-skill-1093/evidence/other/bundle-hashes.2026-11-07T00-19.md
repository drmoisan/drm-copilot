# Bundle Copy Hashes — Issue #1093

Timestamp: 2026-11-07T00-19
Command: sh SCRATCH/issue-1093-bundle.sh copy (copies each skill-folder file to `extensions/drm-copilot/resources/claude-customizations/<same path>` with `cp`, then compares `sha256sum` of the canonical file and the copy)
EXIT_CODE: 0
Output Summary: six byte copies written; each copy's SHA-256 equals its canonical file's.

| File (canonical path; bundle copy under `extensions/drm-copilot/resources/claude-customizations/`) | SHA-256 (canonical) | SHA-256 (bundle) | Result |
|---|---|---|---|
| `.claude/skills/epic-progress-report/SKILL.md` | `e884bf0ef28c0d0f29139f06bda875b394cb99ac9dced714bae701bb2394542a` | `e884bf0ef28c0d0f29139f06bda875b394cb99ac9dced714bae701bb2394542a` | equal |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` | `d9c71adb99f52c06053aaf726083ca84976330bb8a53a180157a55865e0921ac` | `d9c71adb99f52c06053aaf726083ca84976330bb8a53a180157a55865e0921ac` | equal |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | `15db7ffe43f23ad8cd7e1fdab417ea081c3a8691258dfd095ca1abc2f7e8ef49` | `15db7ffe43f23ad8cd7e1fdab417ea081c3a8691258dfd095ca1abc2f7e8ef49` | equal |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.State.ps1` | `f648138c53d80a613e95ed8397485facc70bc7e1c0c8a729c0f62b666a35d141` | `f648138c53d80a613e95ed8397485facc70bc7e1c0c8a729c0f62b666a35d141` | equal |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Metrics.ps1` | `7f4c2f206e5677da08f247c18410c462eecfdb8b8784e9b5fb3157ffc68d61ec` | `7f4c2f206e5677da08f247c18410c462eecfdb8b8784e9b5fb3157ffc68d61ec` | equal |
| `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Render.ps1` | `3f1283985dcecc0cf9c6ca14ab90db1b992721ebbc12461fb5717fc37a2792fb` | `3f1283985dcecc0cf9c6ca14ab90db1b992721ebbc12461fb5717fc37a2792fb` | equal |
