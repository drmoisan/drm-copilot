# Seam Test Module Size

Timestamp: 2026-08-08T15-25

Line counts in this artifact are total physical lines as reported by `wc -l`, not non-blank lines. This is the same basis used in [P2-T5] and [P8-T10], so no two measurements in this cycle mix bases.

## Python

Task: [P3-T10]

Command: `wc -l tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py`

EXIT_CODE: 0

Measured line count: 378

Verdict: strictly under the 500-line hard limit, with 122 lines of headroom. No split into `tests/scripts/dev_tools/_parallel_kickoff_seam_support.py` was required, so no helper module was created.

The count was taken after `poetry run black` had formatted the module, so it is the settled post-format value rather than a pre-format estimate.

Raw output:

```
378 tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py
```

## TypeScript

Task: [P4-T10]

Command: `wc -l extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts`

EXIT_CODE: 0

Measured line count: 299

Verdict: strictly under the 500-line hard limit, with 201 lines of headroom. No move of the extraction and rendering helpers into `extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam-support.ts` was required, so no support module was created.

The count was taken after `npm --prefix extensions/drm-copilot run format` had run Prettier over the module, so it is the settled post-format value rather than a pre-format estimate.

Raw output:

```
299 extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts
```
