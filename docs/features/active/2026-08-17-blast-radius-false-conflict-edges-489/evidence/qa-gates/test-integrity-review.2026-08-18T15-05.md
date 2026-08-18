# Test-Integrity Review Over the Branch Diff (Issue #489, AC-H3)

Timestamp: 2026-08-18T15-05
Command: `git diff main -- tests/ extensions/drm-copilot/test/ | pwsh -NoProfile -Command '$input | Select-String -Pattern "tempfile|mkstemp|TemporaryFile|New-TemporaryItem"'`
EXIT_CODE: 0
Output Summary: the command executed successfully and returned zero matches. No
test on this branch creates a temporary file; every new test input is either an
in-memory literal or a committed fixture.

## Review conclusion

No assertion was removed without a documented behavior-change replacement, no
exception check was broadened, and no test was weakened to make it pass. Four
pre-existing assertions changed value; each is a behavior-change update with
named AC traceability, recorded per file below. The remaining changes are
additions.

## Per-file disposition

### Committed fixtures (additions only, no assertion changed)

| File | Disposition |
| --- | --- |
| `tests/fixtures/blast_radius/derivation-mandate-read-excluded.json` | NEW. Expected block computed from the live library, not hand-written. |
| `tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json` | NEW. Same. |
| `tests/fixtures/blast_radius/derivation-artifacts-segment-removed.json` | NEW. Same. |
| `tests/fixtures/blast_radius/derivation-cross-corpus-doc-glob-rejected.json` | NEW. Same. |
| `tests/fixtures/blast_radius/derivation-letterless-contract-rejected.json` | NEW. Same. |
| `tests/fixtures/blast_radius/validation-mandate-read-self-consistent.json` | NEW. Same. |
| `tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json` | Committed in Phase 1; unmodified since. Placed in a subdirectory so the two top-level parity enumerations do not see it. |

No fixture was deleted. The parity floor `MINIMUM_FIXTURE_COUNT = 26` is
untouched and the on-disk top-level count rose from 26 to 32.

### Python test files

| File | Disposition |
| --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` | NEW (14 cases). Directory-shaped rejection, subtree-glob admission, line-suffixed citation admission, `artifacts/**` rejection, cross-corpus doc-glob rejection and retention, letterless contract rejection and retention. |
| `tests/scripts/dev_tools/test_blast_radius_normalization.py` | NEW (10 cases). Exclusion-helper rules plus `normalize_declared_radius` purity, idempotence, observed-source rejection, and full rejected-class filtering. |
| `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py` | NEW (9 cases). Reader behavior and symmetric derive/validate exclusion. |
| `tests/scripts/dev_tools/test_blast_radius_verification_integrity.py` | Phase 1 before-state pin retained verbatim; three after-state cases ADDED (P3-T9). No before-state assertion was altered or relaxed. |
| `tests/scripts/dev_tools/test_blast_radius_config.py` | Two behavior-change updates, both traceable to AC-A2/AC-F1; see the table below. File remained line-neutral at 499 lines. Lines 180-191 and 444-463 of the pre-change file are untouched (AC-F2), confirmed by inspecting the diff hunk headers: the only hunks are at 382-388 and 404-425. |
| `tests/scripts/dev_tools/test_blast_radius_extraction.py` | Two behavior-change updates, both traceable to AC-B2/AC-B3; see the table below. |

### PowerShell test files

| File | Disposition |
| --- | --- |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` | NEW (12 cases). Exclusion-helper rules plus the end-to-end facade exclusion Describe. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | NEW file receiving the relocated `Committed blast-radius truth table shape` Describe verbatim (P4-T5), amended with the seven-module pin, the removed-umbrella negative pin, and two `mandate_reads` shape checks. Relocation reason: the 500-line limit. No relocated assertion was dropped; the `Location-bucket modules` and `Disjoint work items` Contexts travelled with the Describe. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` | Lost the relocated Describe (moved, not deleted) and GAINED the verification-integrity before/after Describe (3 cases). |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` | Export-surface pin updated from five to six names (behavior change, AC-C1); three `Get-NormalizedDeclaredRadius` cases added. BOM restored after a scripted edit dropped it. |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` | Cardinality pin updated from twelve to seven (behavior change, AC-A2); four `Get-ConfigMandateRead` cases added; one import added for the relocated function. |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` | Known-segment pin rewritten (behavior change, AC-B2/AC-B3); one glob pin retargeted (behavior change, AC-B4); ten rejection/retention cases and two letterless cases added; one import added for the relocated function. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1` | Net zero diff. A Describe was added and then relocated to `BlastRadiusNormalization.Tests.ps1` under the 500-line limit; the file is byte-identical to `main`. |

### TypeScript test files

| File | Disposition |
| --- | --- |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | Three cases ADDED: `mandate_reads` carried verbatim, the new serialized key order, and omission when the source declares none. No existing assertion changed. |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | Two EXISTING pins STRENGTHENED, not weakened: the carriage pin gained `expect(document).not.toHaveProperty("mandate_reads")` and the emission-order pin gained a comment recording why the key is absent from that source document. No new case landed here (file headroom was 26 lines). |

## Changed assertions, with traceability

| File | Pre-change assertion | Post-change assertion | AC | Why this is a behavior change, not a weakening |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` | `$pairs.Count \| Should -Be 12` | `$pairs.Count \| Should -Be 7` | AC-A2 | The ratified module map has seven members. The expected value tracks the delivered content; the pin is still exact-count, not relaxed to a range or a lower bound. |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` | `$exported.Count \| Should -Be 5` | `$exported.Count \| Should -Be 6` | AC-C1 | `Get-NormalizedDeclaredRadius` is a required facade export. The pin is still exact-count. The `-ForEach` name list gained the sixth name, so each export is still individually asserted. |
| `tests/scripts/dev_tools/test_blast_radius_extraction.py` | `test_classify_path_token_accepts_each_known_top_level_segment` asserted `f"{segment}nested/item"` classifies concrete, with `"artifacts/"` in the parametrize list | Asserts `f"{segment}nested/item.py"` classifies concrete; `"artifacts/"` dropped from the list | AC-B2, AC-B3 | An extensionless token is now a directory reference and correctly rejected, so the old form pinned removed behavior. `artifacts/` is no longer a known segment, so retaining it would have passed for the wrong reason. Rejection of the old shapes is separately and positively asserted in `test_blast_radius_extraction_rules.py`. |
| `tests/scripts/dev_tools/test_blast_radius_extraction.py` | CRLF-plan prose citation `docs/features/active/sample/evidence/baseline/` expected in the output | Prose citation `docs/features/active/sample/evidence/note.md` expected in the output | AC-B2 | The test's purpose is that prose lines contribute paths alongside task bodies and phase headings. A directory citation no longer exercises the prose source at all, so the citation was changed to a file; all three sources are still asserted and the assertion is still an exact tuple equality. |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` | Known-segment `-ForEach` over twelve segments asserting `"${_}thing"` is concrete | `-ForEach` over eleven segments asserting `"${_}thing/**"` is a glob | AC-B2, AC-B3 | Mirror of the Python change above, for the same reasons. |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` | `records a wildcard token as a glob` used `docs/features/**` | Uses `docs/research/**` | AC-B4 | A corpus-spanning `docs/features/` glob is now rejected by design, so the old token pinned removed behavior. The test's purpose (a recursive glob under a known segment classifies as a glob) is preserved, and the rejection of `docs/features/**` is separately and positively asserted. |

## Constraints verified

- No temporary file created in any test (command above, zero matches).
- Every new test input is an in-memory literal or a committed fixture.
- No test was deleted. One Describe was relocated between files under the
  500-line limit and one duplicate idempotence case, added and removed within
  the same task, never landed; its behavior is pinned Python-side in
  `test_blast_radius_normalization.py`.
- No suppression comment was added in any language: zero `# noqa`, zero
  `# type: ignore`, zero `eslint-disable`, zero `@ts-expect-error`, and zero new
  `SuppressMessageAttribute`.
- Every changed test file measures <= 500 lines.
