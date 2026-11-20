# P2-T1 consolidated executor review

Timestamp: 2026-10-18T07-46
Command: poetry run python SCRATCH/issue-980-review-p2t1.py
EXIT_CODE: 0
Output Summary: Five in-memory observations; two positive cases pass and three blocking defects are reproduced. P2-T1 is not accepted.

The [machine record](p2t1-executor-review.2026-10-18T07-46.json) retains the case descriptions, observed results and four production hashes at observation time. All snapshot and Git reads use injected memory metadata/bytes. The operational probe reads only synthetic committed example fixtures from drm-copilot. No consumer or production file changed.

| Finding | Observed behavior | Required correction |
| --- | --- | --- |
| P2T1-R1 | A valid runtime capture carries its application's source revision. The loader asks Git for the newly captured binary at that commit and raises when the capture is untracked. | Retain the revision without inventing a Git-blob requirement for runtime payloads. Schedule immutable object reads only for the applicable source/test semantics. |
| P2T1-R2 | A runtime payload reference with null revision points to selected src/capture.cs. The snapshot is ok, its category becomes evidence, and the configured source pin receives no Git read for that path. | Keep selected-source membership independent of later evidence/category projection. Authored references cannot remove selected source bytes from pinned input capture. |
| P2T1-R3 | The same complete directory child names return in opposite order, with unchanged identities/paths/content. The loader raises a metadata-changed error. | Normalize child order for freshness comparison while retaining duplicate/alias rejection and actual added/deleted/replaced-entry detection. |

A minimal configured snapshot and a referenced JSON runtime payload both load successfully. The current structured-payload resolution supports the JSON capture example; it is not an outstanding finding.

The first probe setup retained a combined role while removing all clients, so the profile validator correctly rejected it before the snapshot cases ran. The corrected synthetic setup explicitly uses the legacy-source role. That setup error is not a production defect or a passing probe. The subsequent five-case observation command completed, reproducing the three failures above. Final acceptance requires direct regressions, clean ordered gates, raw coverage, final staged-byte verification and corrected public-loader results.

The first local evidence-write command was rejected by the PreToolUse promotion guard with PROMOTION_MCP_ONLY_BLOCKED, which reported direct GitHub issue creation. That command only serialized local JSON/Markdown and contained no gh invocation or external action; no file was written. These records were subsequently written with the permitted structured file-edit tool. No hook bypass, policy change, GitHub operation or external publication occurred.

## Rejected command receipt

Tool: functions.exec calling tools.exec_command. Intended outputs were FEATURE/evidence/regression-testing/p2t1-executor-review.<write-time UTC>.json and the corresponding Markdown file. The command never executed, so its timestamp variable was not evaluated and zero files were created or changed. Only the host-specific scratch path is replaced below by the required literal SCRATCH; the remaining command text is retained.

Guard message:

```text
Command blocked by PreToolUse hook: PROMOTION_MCP_ONLY_BLOCKED: Direct GitHub issue creation via `gh` bypasses the approved drm-copilot MCP promotion path (`mcp__drm-copilot__new_potential_entry` -> `mcp__drm-copilot__potential_to_issue` -> `mcp__drm-copilot__new_active_feature_folder`). Use those MCP tools instead..
```

Rejected PowerShell command:

```powershell
$scratchPath = 'SCRATCH'; $result = Get-Content -Raw -LiteralPath (Join-Path $scratchPath 'issue-980-p2t1-review-results.json') | ConvertFrom-Json; $stamp = Get-Date -AsUTC -Format 'yyyy-MM-ddTHH-mm'; $evidencePath = 'docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing'; $result | Add-Member -NotePropertyName timestamp_utc -NotePropertyValue $stamp; $result | Add-Member -NotePropertyName review_outcome -NotePropertyValue 'corrections-required'; $result | Add-Member -NotePropertyName blocking_findings -NotePropertyValue @('P2T1-R1: Runtime evidence application revisions must not require a capture blob at that Git commit.', 'P2T1-R2: Evidence classification must not remove a configured selected source from pinned Git inputs.', 'P2T1-R3: Equivalent directory child ordering must not cause a freshness failure.'); $jsonPath = Join-Path $evidencePath "p2t1-executor-review.$stamp.json"; $result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding utf8; $body = @'
# P2-T1 consolidated executor review

Timestamp: STAMP
Command: poetry run python SCRATCH/issue-980-review-p2t1.py
EXIT_CODE: 0
Output Summary: Five in-memory observations; two positive cases pass and three blocking defects are reproduced. P2-T1 is not accepted.

The machine record in p2t1-executor-review.STAMP.json retains the input case descriptions, observed results and four production hashes at observation time. All repository reads in these cases use injected memory metadata/bytes and a fake Git reader. The probe reads only synthetic committed example fixtures from drm-copilot. No consumer or production file was changed.

| Finding | Observed behavior | Required correction |
| --- | --- | --- |
| P2T1-R1 | A valid runtime capture carries its application's source revision. The loader asks Git for the newly captured binary at that commit and raises when the capture is untracked. | Retain the revision without inventing a Git-blob requirement for runtime payloads. Only source/test or other explicitly pinned source semantics should request immutable objects. |
| P2T1-R2 | A runtime payload reference with null revision points to selected src/capture.cs. The snapshot is ok, its category becomes evidence, and the configured source pin receives no Git read for that path. | Keep selected-source membership independent of later evidence/category projection. Authored references cannot remove selected source bytes from pinned input capture. |
| P2T1-R3 | The same complete directory child names are returned in opposite order, with unchanged identities/paths/content. The loader raises a metadata-changed error. | Normalize child order for freshness comparison while retaining duplicate/alias rejection and actual added/deleted/replaced-entry detection. |

A minimal configured snapshot and a referenced JSON runtime payload both load successfully. The current structured-payload resolution already supports the JSON capture example; it is not an outstanding finding.

The first probe setup retained a combined role while removing all clients, so the accepted profile validator correctly rejected it before the snapshot cases ran. The corrected synthetic setup explicitly uses the legacy-source role. That setup error is not a production defect or a passing probe. The subsequent five-case observation command completed successfully, reproducing the three failures above. Final acceptance requires direct regression tests, clean ordered gates, raw coverage, final staged-byte verification and the corrected public-loader cases.
'@; $body = $body.Replace('STAMP', $stamp); $mdPath = Join-Path $evidencePath "p2t1-executor-review.$stamp.md"; Set-Content -LiteralPath $mdPath -Value $body -Encoding utf8; [pscustomobject]@{json=$jsonPath;markdown=$mdPath;blocking_findings=3;task_accepted=$false} | ConvertTo-Json -Compress
```
