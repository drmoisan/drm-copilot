# Corpus run: validate-pr-author-output.ps1 (AC-10, issue #905)

Timestamp: 2026-10-11T15-05
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/corpus-pr-author.ps1 -Mode Before -Sha 2ef8d361e978ca8b7733a545d76a87e8418005ce
EXIT_CODE: 0
Output Summary: Before (unchanged hook): 124 distinct PR numbers; 620 DECISION lines (five per number); CONTROL-BLOCKS 124, CONTROL-ALLOWS 0; FALSE-POSITIVES 0 (every URL, PR_REF, GH_PR_CREATE, and GH_PR_EDIT form allowed).
CORPUS-COMMIT: 2ef8d361e978ca8b7733a545d76a87e8418005ce
ENUMERATION: git grep -h -o -I -E 'drm-copilot/pull/[0-9]+' <CORPUS-COMMIT> -- docs, distinct numbers ascending

Script SHA256 values (recorded by [P1-T1], `evidence/other/corpus-scripts.2026-10-11T15-01.md`):

- corpus-common.ps1: CF5B7CC93584EAEE664DA88F37CF3A2B5A6AFCBFB596C8D122D96DCC11D523F8
- corpus-pr-author.ps1: 08FBD108CDDAF2ECCDD0D89D9CE2DA93745424338622543B5088615F2E58CF82

## Before

```text
MODE: Before
CORPUS-COMMIT: 2ef8d361e978ca8b7733a545d76a87e8418005ce
ENUMERATION: git grep -h -o -I -E 'drm-copilot/pull/[0-9]+' <CORPUS-COMMIT> -- docs, distinct numbers ascending
PR-NUMBERS: 1, 119, 209, 295, 302, 304, 307, 308, 311, 314, 322, 323, 326, 330, 332, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 401, 410, 427, 449, 450, 451, 453, 454, 455, 456, 457, 458, 494, 496, 497, 503, 540, 541, 548, 557, 558, 560, 563, 564, 569, 571, 572, 579, 580, 581, 582, 603, 604, 605, 607, 624, 638, 641, 642, 644, 650, 651, 652, 653, 654, 656, 681, 682, 683, 684, 685, 691, 698, 700, 701, 702, 703, 704, 705, 718, 719, 720, 721, 725, 726, 727, 728, 729, 730, 731, 747, 748, 777, 778, 779, 782, 800, 801, 808, 809, 811, 817, 831, 853, 854, 855, 856, 857, 858, 859, 862, 863, 871, 881
DECISION: URL | #1 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/1.
DECISION: PR_REF | #1 | ALLOW |  | Created PR #1 for the feature branch.
DECISION: GH_PR_CREATE | #1 | ALLOW |  | Ran gh pr create; the new pull request is #1.
DECISION: GH_PR_EDIT | #1 | ALLOW |  | Ran gh pr edit on #1 to update the body.
DECISION: CONTROL_REFS_ONLY | #1 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #1
DECISION: URL | #119 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/119.
DECISION: PR_REF | #119 | ALLOW |  | Created PR #119 for the feature branch.
DECISION: GH_PR_CREATE | #119 | ALLOW |  | Ran gh pr create; the new pull request is #119.
DECISION: GH_PR_EDIT | #119 | ALLOW |  | Ran gh pr edit on #119 to update the body.
DECISION: CONTROL_REFS_ONLY | #119 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #119
DECISION: URL | #209 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/209.
DECISION: PR_REF | #209 | ALLOW |  | Created PR #209 for the feature branch.
DECISION: GH_PR_CREATE | #209 | ALLOW |  | Ran gh pr create; the new pull request is #209.
DECISION: GH_PR_EDIT | #209 | ALLOW |  | Ran gh pr edit on #209 to update the body.
DECISION: CONTROL_REFS_ONLY | #209 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #209
DECISION: URL | #295 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/295.
DECISION: PR_REF | #295 | ALLOW |  | Created PR #295 for the feature branch.
DECISION: GH_PR_CREATE | #295 | ALLOW |  | Ran gh pr create; the new pull request is #295.
DECISION: GH_PR_EDIT | #295 | ALLOW |  | Ran gh pr edit on #295 to update the body.
DECISION: CONTROL_REFS_ONLY | #295 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #295
DECISION: URL | #302 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/302.
DECISION: PR_REF | #302 | ALLOW |  | Created PR #302 for the feature branch.
DECISION: GH_PR_CREATE | #302 | ALLOW |  | Ran gh pr create; the new pull request is #302.
DECISION: GH_PR_EDIT | #302 | ALLOW |  | Ran gh pr edit on #302 to update the body.
DECISION: CONTROL_REFS_ONLY | #302 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #302
DECISION: URL | #304 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/304.
DECISION: PR_REF | #304 | ALLOW |  | Created PR #304 for the feature branch.
DECISION: GH_PR_CREATE | #304 | ALLOW |  | Ran gh pr create; the new pull request is #304.
DECISION: GH_PR_EDIT | #304 | ALLOW |  | Ran gh pr edit on #304 to update the body.
DECISION: CONTROL_REFS_ONLY | #304 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #304
DECISION: URL | #307 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/307.
DECISION: PR_REF | #307 | ALLOW |  | Created PR #307 for the feature branch.
DECISION: GH_PR_CREATE | #307 | ALLOW |  | Ran gh pr create; the new pull request is #307.
DECISION: GH_PR_EDIT | #307 | ALLOW |  | Ran gh pr edit on #307 to update the body.
DECISION: CONTROL_REFS_ONLY | #307 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #307
DECISION: URL | #308 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/308.
DECISION: PR_REF | #308 | ALLOW |  | Created PR #308 for the feature branch.
DECISION: GH_PR_CREATE | #308 | ALLOW |  | Ran gh pr create; the new pull request is #308.
DECISION: GH_PR_EDIT | #308 | ALLOW |  | Ran gh pr edit on #308 to update the body.
DECISION: CONTROL_REFS_ONLY | #308 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #308
DECISION: URL | #311 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/311.
DECISION: PR_REF | #311 | ALLOW |  | Created PR #311 for the feature branch.
DECISION: GH_PR_CREATE | #311 | ALLOW |  | Ran gh pr create; the new pull request is #311.
DECISION: GH_PR_EDIT | #311 | ALLOW |  | Ran gh pr edit on #311 to update the body.
DECISION: CONTROL_REFS_ONLY | #311 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #311
DECISION: URL | #314 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/314.
DECISION: PR_REF | #314 | ALLOW |  | Created PR #314 for the feature branch.
DECISION: GH_PR_CREATE | #314 | ALLOW |  | Ran gh pr create; the new pull request is #314.
DECISION: GH_PR_EDIT | #314 | ALLOW |  | Ran gh pr edit on #314 to update the body.
DECISION: CONTROL_REFS_ONLY | #314 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #314
DECISION: URL | #322 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/322.
DECISION: PR_REF | #322 | ALLOW |  | Created PR #322 for the feature branch.
DECISION: GH_PR_CREATE | #322 | ALLOW |  | Ran gh pr create; the new pull request is #322.
DECISION: GH_PR_EDIT | #322 | ALLOW |  | Ran gh pr edit on #322 to update the body.
DECISION: CONTROL_REFS_ONLY | #322 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #322
DECISION: URL | #323 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/323.
DECISION: PR_REF | #323 | ALLOW |  | Created PR #323 for the feature branch.
DECISION: GH_PR_CREATE | #323 | ALLOW |  | Ran gh pr create; the new pull request is #323.
DECISION: GH_PR_EDIT | #323 | ALLOW |  | Ran gh pr edit on #323 to update the body.
DECISION: CONTROL_REFS_ONLY | #323 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #323
DECISION: URL | #326 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/326.
DECISION: PR_REF | #326 | ALLOW |  | Created PR #326 for the feature branch.
DECISION: GH_PR_CREATE | #326 | ALLOW |  | Ran gh pr create; the new pull request is #326.
DECISION: GH_PR_EDIT | #326 | ALLOW |  | Ran gh pr edit on #326 to update the body.
DECISION: CONTROL_REFS_ONLY | #326 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #326
DECISION: URL | #330 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/330.
DECISION: PR_REF | #330 | ALLOW |  | Created PR #330 for the feature branch.
DECISION: GH_PR_CREATE | #330 | ALLOW |  | Ran gh pr create; the new pull request is #330.
DECISION: GH_PR_EDIT | #330 | ALLOW |  | Ran gh pr edit on #330 to update the body.
DECISION: CONTROL_REFS_ONLY | #330 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #330
DECISION: URL | #332 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/332.
DECISION: PR_REF | #332 | ALLOW |  | Created PR #332 for the feature branch.
DECISION: GH_PR_CREATE | #332 | ALLOW |  | Ran gh pr create; the new pull request is #332.
DECISION: GH_PR_EDIT | #332 | ALLOW |  | Ran gh pr edit on #332 to update the body.
DECISION: CONTROL_REFS_ONLY | #332 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #332
DECISION: URL | #374 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/374.
DECISION: PR_REF | #374 | ALLOW |  | Created PR #374 for the feature branch.
DECISION: GH_PR_CREATE | #374 | ALLOW |  | Ran gh pr create; the new pull request is #374.
DECISION: GH_PR_EDIT | #374 | ALLOW |  | Ran gh pr edit on #374 to update the body.
DECISION: CONTROL_REFS_ONLY | #374 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #374
DECISION: URL | #375 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/375.
DECISION: PR_REF | #375 | ALLOW |  | Created PR #375 for the feature branch.
DECISION: GH_PR_CREATE | #375 | ALLOW |  | Ran gh pr create; the new pull request is #375.
DECISION: GH_PR_EDIT | #375 | ALLOW |  | Ran gh pr edit on #375 to update the body.
DECISION: CONTROL_REFS_ONLY | #375 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #375
DECISION: URL | #376 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/376.
DECISION: PR_REF | #376 | ALLOW |  | Created PR #376 for the feature branch.
DECISION: GH_PR_CREATE | #376 | ALLOW |  | Ran gh pr create; the new pull request is #376.
DECISION: GH_PR_EDIT | #376 | ALLOW |  | Ran gh pr edit on #376 to update the body.
DECISION: CONTROL_REFS_ONLY | #376 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #376
DECISION: URL | #377 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/377.
DECISION: PR_REF | #377 | ALLOW |  | Created PR #377 for the feature branch.
DECISION: GH_PR_CREATE | #377 | ALLOW |  | Ran gh pr create; the new pull request is #377.
DECISION: GH_PR_EDIT | #377 | ALLOW |  | Ran gh pr edit on #377 to update the body.
DECISION: CONTROL_REFS_ONLY | #377 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #377
DECISION: URL | #378 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/378.
DECISION: PR_REF | #378 | ALLOW |  | Created PR #378 for the feature branch.
DECISION: GH_PR_CREATE | #378 | ALLOW |  | Ran gh pr create; the new pull request is #378.
DECISION: GH_PR_EDIT | #378 | ALLOW |  | Ran gh pr edit on #378 to update the body.
DECISION: CONTROL_REFS_ONLY | #378 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #378
DECISION: URL | #379 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/379.
DECISION: PR_REF | #379 | ALLOW |  | Created PR #379 for the feature branch.
DECISION: GH_PR_CREATE | #379 | ALLOW |  | Ran gh pr create; the new pull request is #379.
DECISION: GH_PR_EDIT | #379 | ALLOW |  | Ran gh pr edit on #379 to update the body.
DECISION: CONTROL_REFS_ONLY | #379 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #379
DECISION: URL | #380 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/380.
DECISION: PR_REF | #380 | ALLOW |  | Created PR #380 for the feature branch.
DECISION: GH_PR_CREATE | #380 | ALLOW |  | Ran gh pr create; the new pull request is #380.
DECISION: GH_PR_EDIT | #380 | ALLOW |  | Ran gh pr edit on #380 to update the body.
DECISION: CONTROL_REFS_ONLY | #380 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #380
DECISION: URL | #381 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/381.
DECISION: PR_REF | #381 | ALLOW |  | Created PR #381 for the feature branch.
DECISION: GH_PR_CREATE | #381 | ALLOW |  | Ran gh pr create; the new pull request is #381.
DECISION: GH_PR_EDIT | #381 | ALLOW |  | Ran gh pr edit on #381 to update the body.
DECISION: CONTROL_REFS_ONLY | #381 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #381
DECISION: URL | #382 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/382.
DECISION: PR_REF | #382 | ALLOW |  | Created PR #382 for the feature branch.
DECISION: GH_PR_CREATE | #382 | ALLOW |  | Ran gh pr create; the new pull request is #382.
DECISION: GH_PR_EDIT | #382 | ALLOW |  | Ran gh pr edit on #382 to update the body.
DECISION: CONTROL_REFS_ONLY | #382 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #382
DECISION: URL | #383 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/383.
DECISION: PR_REF | #383 | ALLOW |  | Created PR #383 for the feature branch.
DECISION: GH_PR_CREATE | #383 | ALLOW |  | Ran gh pr create; the new pull request is #383.
DECISION: GH_PR_EDIT | #383 | ALLOW |  | Ran gh pr edit on #383 to update the body.
DECISION: CONTROL_REFS_ONLY | #383 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #383
DECISION: URL | #384 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/384.
DECISION: PR_REF | #384 | ALLOW |  | Created PR #384 for the feature branch.
DECISION: GH_PR_CREATE | #384 | ALLOW |  | Ran gh pr create; the new pull request is #384.
DECISION: GH_PR_EDIT | #384 | ALLOW |  | Ran gh pr edit on #384 to update the body.
DECISION: CONTROL_REFS_ONLY | #384 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #384
DECISION: URL | #385 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/385.
DECISION: PR_REF | #385 | ALLOW |  | Created PR #385 for the feature branch.
DECISION: GH_PR_CREATE | #385 | ALLOW |  | Ran gh pr create; the new pull request is #385.
DECISION: GH_PR_EDIT | #385 | ALLOW |  | Ran gh pr edit on #385 to update the body.
DECISION: CONTROL_REFS_ONLY | #385 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #385
DECISION: URL | #386 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/386.
DECISION: PR_REF | #386 | ALLOW |  | Created PR #386 for the feature branch.
DECISION: GH_PR_CREATE | #386 | ALLOW |  | Ran gh pr create; the new pull request is #386.
DECISION: GH_PR_EDIT | #386 | ALLOW |  | Ran gh pr edit on #386 to update the body.
DECISION: CONTROL_REFS_ONLY | #386 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #386
DECISION: URL | #387 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/387.
DECISION: PR_REF | #387 | ALLOW |  | Created PR #387 for the feature branch.
DECISION: GH_PR_CREATE | #387 | ALLOW |  | Ran gh pr create; the new pull request is #387.
DECISION: GH_PR_EDIT | #387 | ALLOW |  | Ran gh pr edit on #387 to update the body.
DECISION: CONTROL_REFS_ONLY | #387 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #387
DECISION: URL | #388 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/388.
DECISION: PR_REF | #388 | ALLOW |  | Created PR #388 for the feature branch.
DECISION: GH_PR_CREATE | #388 | ALLOW |  | Ran gh pr create; the new pull request is #388.
DECISION: GH_PR_EDIT | #388 | ALLOW |  | Ran gh pr edit on #388 to update the body.
DECISION: CONTROL_REFS_ONLY | #388 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #388
DECISION: URL | #401 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/401.
DECISION: PR_REF | #401 | ALLOW |  | Created PR #401 for the feature branch.
DECISION: GH_PR_CREATE | #401 | ALLOW |  | Ran gh pr create; the new pull request is #401.
DECISION: GH_PR_EDIT | #401 | ALLOW |  | Ran gh pr edit on #401 to update the body.
DECISION: CONTROL_REFS_ONLY | #401 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #401
DECISION: URL | #410 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/410.
DECISION: PR_REF | #410 | ALLOW |  | Created PR #410 for the feature branch.
DECISION: GH_PR_CREATE | #410 | ALLOW |  | Ran gh pr create; the new pull request is #410.
DECISION: GH_PR_EDIT | #410 | ALLOW |  | Ran gh pr edit on #410 to update the body.
DECISION: CONTROL_REFS_ONLY | #410 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #410
DECISION: URL | #427 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/427.
DECISION: PR_REF | #427 | ALLOW |  | Created PR #427 for the feature branch.
DECISION: GH_PR_CREATE | #427 | ALLOW |  | Ran gh pr create; the new pull request is #427.
DECISION: GH_PR_EDIT | #427 | ALLOW |  | Ran gh pr edit on #427 to update the body.
DECISION: CONTROL_REFS_ONLY | #427 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #427
DECISION: URL | #449 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/449.
DECISION: PR_REF | #449 | ALLOW |  | Created PR #449 for the feature branch.
DECISION: GH_PR_CREATE | #449 | ALLOW |  | Ran gh pr create; the new pull request is #449.
DECISION: GH_PR_EDIT | #449 | ALLOW |  | Ran gh pr edit on #449 to update the body.
DECISION: CONTROL_REFS_ONLY | #449 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #449
DECISION: URL | #450 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/450.
DECISION: PR_REF | #450 | ALLOW |  | Created PR #450 for the feature branch.
DECISION: GH_PR_CREATE | #450 | ALLOW |  | Ran gh pr create; the new pull request is #450.
DECISION: GH_PR_EDIT | #450 | ALLOW |  | Ran gh pr edit on #450 to update the body.
DECISION: CONTROL_REFS_ONLY | #450 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #450
DECISION: URL | #451 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/451.
DECISION: PR_REF | #451 | ALLOW |  | Created PR #451 for the feature branch.
DECISION: GH_PR_CREATE | #451 | ALLOW |  | Ran gh pr create; the new pull request is #451.
DECISION: GH_PR_EDIT | #451 | ALLOW |  | Ran gh pr edit on #451 to update the body.
DECISION: CONTROL_REFS_ONLY | #451 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #451
DECISION: URL | #453 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/453.
DECISION: PR_REF | #453 | ALLOW |  | Created PR #453 for the feature branch.
DECISION: GH_PR_CREATE | #453 | ALLOW |  | Ran gh pr create; the new pull request is #453.
DECISION: GH_PR_EDIT | #453 | ALLOW |  | Ran gh pr edit on #453 to update the body.
DECISION: CONTROL_REFS_ONLY | #453 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #453
DECISION: URL | #454 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/454.
DECISION: PR_REF | #454 | ALLOW |  | Created PR #454 for the feature branch.
DECISION: GH_PR_CREATE | #454 | ALLOW |  | Ran gh pr create; the new pull request is #454.
DECISION: GH_PR_EDIT | #454 | ALLOW |  | Ran gh pr edit on #454 to update the body.
DECISION: CONTROL_REFS_ONLY | #454 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #454
DECISION: URL | #455 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/455.
DECISION: PR_REF | #455 | ALLOW |  | Created PR #455 for the feature branch.
DECISION: GH_PR_CREATE | #455 | ALLOW |  | Ran gh pr create; the new pull request is #455.
DECISION: GH_PR_EDIT | #455 | ALLOW |  | Ran gh pr edit on #455 to update the body.
DECISION: CONTROL_REFS_ONLY | #455 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #455
DECISION: URL | #456 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/456.
DECISION: PR_REF | #456 | ALLOW |  | Created PR #456 for the feature branch.
DECISION: GH_PR_CREATE | #456 | ALLOW |  | Ran gh pr create; the new pull request is #456.
DECISION: GH_PR_EDIT | #456 | ALLOW |  | Ran gh pr edit on #456 to update the body.
DECISION: CONTROL_REFS_ONLY | #456 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #456
DECISION: URL | #457 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/457.
DECISION: PR_REF | #457 | ALLOW |  | Created PR #457 for the feature branch.
DECISION: GH_PR_CREATE | #457 | ALLOW |  | Ran gh pr create; the new pull request is #457.
DECISION: GH_PR_EDIT | #457 | ALLOW |  | Ran gh pr edit on #457 to update the body.
DECISION: CONTROL_REFS_ONLY | #457 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #457
DECISION: URL | #458 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/458.
DECISION: PR_REF | #458 | ALLOW |  | Created PR #458 for the feature branch.
DECISION: GH_PR_CREATE | #458 | ALLOW |  | Ran gh pr create; the new pull request is #458.
DECISION: GH_PR_EDIT | #458 | ALLOW |  | Ran gh pr edit on #458 to update the body.
DECISION: CONTROL_REFS_ONLY | #458 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #458
DECISION: URL | #494 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/494.
DECISION: PR_REF | #494 | ALLOW |  | Created PR #494 for the feature branch.
DECISION: GH_PR_CREATE | #494 | ALLOW |  | Ran gh pr create; the new pull request is #494.
DECISION: GH_PR_EDIT | #494 | ALLOW |  | Ran gh pr edit on #494 to update the body.
DECISION: CONTROL_REFS_ONLY | #494 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #494
DECISION: URL | #496 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/496.
DECISION: PR_REF | #496 | ALLOW |  | Created PR #496 for the feature branch.
DECISION: GH_PR_CREATE | #496 | ALLOW |  | Ran gh pr create; the new pull request is #496.
DECISION: GH_PR_EDIT | #496 | ALLOW |  | Ran gh pr edit on #496 to update the body.
DECISION: CONTROL_REFS_ONLY | #496 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #496
DECISION: URL | #497 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/497.
DECISION: PR_REF | #497 | ALLOW |  | Created PR #497 for the feature branch.
DECISION: GH_PR_CREATE | #497 | ALLOW |  | Ran gh pr create; the new pull request is #497.
DECISION: GH_PR_EDIT | #497 | ALLOW |  | Ran gh pr edit on #497 to update the body.
DECISION: CONTROL_REFS_ONLY | #497 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #497
DECISION: URL | #503 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/503.
DECISION: PR_REF | #503 | ALLOW |  | Created PR #503 for the feature branch.
DECISION: GH_PR_CREATE | #503 | ALLOW |  | Ran gh pr create; the new pull request is #503.
DECISION: GH_PR_EDIT | #503 | ALLOW |  | Ran gh pr edit on #503 to update the body.
DECISION: CONTROL_REFS_ONLY | #503 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #503
DECISION: URL | #540 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/540.
DECISION: PR_REF | #540 | ALLOW |  | Created PR #540 for the feature branch.
DECISION: GH_PR_CREATE | #540 | ALLOW |  | Ran gh pr create; the new pull request is #540.
DECISION: GH_PR_EDIT | #540 | ALLOW |  | Ran gh pr edit on #540 to update the body.
DECISION: CONTROL_REFS_ONLY | #540 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #540
DECISION: URL | #541 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/541.
DECISION: PR_REF | #541 | ALLOW |  | Created PR #541 for the feature branch.
DECISION: GH_PR_CREATE | #541 | ALLOW |  | Ran gh pr create; the new pull request is #541.
DECISION: GH_PR_EDIT | #541 | ALLOW |  | Ran gh pr edit on #541 to update the body.
DECISION: CONTROL_REFS_ONLY | #541 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #541
DECISION: URL | #548 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/548.
DECISION: PR_REF | #548 | ALLOW |  | Created PR #548 for the feature branch.
DECISION: GH_PR_CREATE | #548 | ALLOW |  | Ran gh pr create; the new pull request is #548.
DECISION: GH_PR_EDIT | #548 | ALLOW |  | Ran gh pr edit on #548 to update the body.
DECISION: CONTROL_REFS_ONLY | #548 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #548
DECISION: URL | #557 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/557.
DECISION: PR_REF | #557 | ALLOW |  | Created PR #557 for the feature branch.
DECISION: GH_PR_CREATE | #557 | ALLOW |  | Ran gh pr create; the new pull request is #557.
DECISION: GH_PR_EDIT | #557 | ALLOW |  | Ran gh pr edit on #557 to update the body.
DECISION: CONTROL_REFS_ONLY | #557 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #557
DECISION: URL | #558 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/558.
DECISION: PR_REF | #558 | ALLOW |  | Created PR #558 for the feature branch.
DECISION: GH_PR_CREATE | #558 | ALLOW |  | Ran gh pr create; the new pull request is #558.
DECISION: GH_PR_EDIT | #558 | ALLOW |  | Ran gh pr edit on #558 to update the body.
DECISION: CONTROL_REFS_ONLY | #558 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #558
DECISION: URL | #560 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/560.
DECISION: PR_REF | #560 | ALLOW |  | Created PR #560 for the feature branch.
DECISION: GH_PR_CREATE | #560 | ALLOW |  | Ran gh pr create; the new pull request is #560.
DECISION: GH_PR_EDIT | #560 | ALLOW |  | Ran gh pr edit on #560 to update the body.
DECISION: CONTROL_REFS_ONLY | #560 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #560
DECISION: URL | #563 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/563.
DECISION: PR_REF | #563 | ALLOW |  | Created PR #563 for the feature branch.
DECISION: GH_PR_CREATE | #563 | ALLOW |  | Ran gh pr create; the new pull request is #563.
DECISION: GH_PR_EDIT | #563 | ALLOW |  | Ran gh pr edit on #563 to update the body.
DECISION: CONTROL_REFS_ONLY | #563 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #563
DECISION: URL | #564 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/564.
DECISION: PR_REF | #564 | ALLOW |  | Created PR #564 for the feature branch.
DECISION: GH_PR_CREATE | #564 | ALLOW |  | Ran gh pr create; the new pull request is #564.
DECISION: GH_PR_EDIT | #564 | ALLOW |  | Ran gh pr edit on #564 to update the body.
DECISION: CONTROL_REFS_ONLY | #564 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #564
DECISION: URL | #569 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/569.
DECISION: PR_REF | #569 | ALLOW |  | Created PR #569 for the feature branch.
DECISION: GH_PR_CREATE | #569 | ALLOW |  | Ran gh pr create; the new pull request is #569.
DECISION: GH_PR_EDIT | #569 | ALLOW |  | Ran gh pr edit on #569 to update the body.
DECISION: CONTROL_REFS_ONLY | #569 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #569
DECISION: URL | #571 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/571.
DECISION: PR_REF | #571 | ALLOW |  | Created PR #571 for the feature branch.
DECISION: GH_PR_CREATE | #571 | ALLOW |  | Ran gh pr create; the new pull request is #571.
DECISION: GH_PR_EDIT | #571 | ALLOW |  | Ran gh pr edit on #571 to update the body.
DECISION: CONTROL_REFS_ONLY | #571 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #571
DECISION: URL | #572 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/572.
DECISION: PR_REF | #572 | ALLOW |  | Created PR #572 for the feature branch.
DECISION: GH_PR_CREATE | #572 | ALLOW |  | Ran gh pr create; the new pull request is #572.
DECISION: GH_PR_EDIT | #572 | ALLOW |  | Ran gh pr edit on #572 to update the body.
DECISION: CONTROL_REFS_ONLY | #572 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #572
DECISION: URL | #579 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/579.
DECISION: PR_REF | #579 | ALLOW |  | Created PR #579 for the feature branch.
DECISION: GH_PR_CREATE | #579 | ALLOW |  | Ran gh pr create; the new pull request is #579.
DECISION: GH_PR_EDIT | #579 | ALLOW |  | Ran gh pr edit on #579 to update the body.
DECISION: CONTROL_REFS_ONLY | #579 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #579
DECISION: URL | #580 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/580.
DECISION: PR_REF | #580 | ALLOW |  | Created PR #580 for the feature branch.
DECISION: GH_PR_CREATE | #580 | ALLOW |  | Ran gh pr create; the new pull request is #580.
DECISION: GH_PR_EDIT | #580 | ALLOW |  | Ran gh pr edit on #580 to update the body.
DECISION: CONTROL_REFS_ONLY | #580 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #580
DECISION: URL | #581 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/581.
DECISION: PR_REF | #581 | ALLOW |  | Created PR #581 for the feature branch.
DECISION: GH_PR_CREATE | #581 | ALLOW |  | Ran gh pr create; the new pull request is #581.
DECISION: GH_PR_EDIT | #581 | ALLOW |  | Ran gh pr edit on #581 to update the body.
DECISION: CONTROL_REFS_ONLY | #581 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #581
DECISION: URL | #582 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/582.
DECISION: PR_REF | #582 | ALLOW |  | Created PR #582 for the feature branch.
DECISION: GH_PR_CREATE | #582 | ALLOW |  | Ran gh pr create; the new pull request is #582.
DECISION: GH_PR_EDIT | #582 | ALLOW |  | Ran gh pr edit on #582 to update the body.
DECISION: CONTROL_REFS_ONLY | #582 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #582
DECISION: URL | #603 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/603.
DECISION: PR_REF | #603 | ALLOW |  | Created PR #603 for the feature branch.
DECISION: GH_PR_CREATE | #603 | ALLOW |  | Ran gh pr create; the new pull request is #603.
DECISION: GH_PR_EDIT | #603 | ALLOW |  | Ran gh pr edit on #603 to update the body.
DECISION: CONTROL_REFS_ONLY | #603 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #603
DECISION: URL | #604 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/604.
DECISION: PR_REF | #604 | ALLOW |  | Created PR #604 for the feature branch.
DECISION: GH_PR_CREATE | #604 | ALLOW |  | Ran gh pr create; the new pull request is #604.
DECISION: GH_PR_EDIT | #604 | ALLOW |  | Ran gh pr edit on #604 to update the body.
DECISION: CONTROL_REFS_ONLY | #604 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #604
DECISION: URL | #605 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/605.
DECISION: PR_REF | #605 | ALLOW |  | Created PR #605 for the feature branch.
DECISION: GH_PR_CREATE | #605 | ALLOW |  | Ran gh pr create; the new pull request is #605.
DECISION: GH_PR_EDIT | #605 | ALLOW |  | Ran gh pr edit on #605 to update the body.
DECISION: CONTROL_REFS_ONLY | #605 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #605
DECISION: URL | #607 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/607.
DECISION: PR_REF | #607 | ALLOW |  | Created PR #607 for the feature branch.
DECISION: GH_PR_CREATE | #607 | ALLOW |  | Ran gh pr create; the new pull request is #607.
DECISION: GH_PR_EDIT | #607 | ALLOW |  | Ran gh pr edit on #607 to update the body.
DECISION: CONTROL_REFS_ONLY | #607 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #607
DECISION: URL | #624 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/624.
DECISION: PR_REF | #624 | ALLOW |  | Created PR #624 for the feature branch.
DECISION: GH_PR_CREATE | #624 | ALLOW |  | Ran gh pr create; the new pull request is #624.
DECISION: GH_PR_EDIT | #624 | ALLOW |  | Ran gh pr edit on #624 to update the body.
DECISION: CONTROL_REFS_ONLY | #624 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #624
DECISION: URL | #638 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/638.
DECISION: PR_REF | #638 | ALLOW |  | Created PR #638 for the feature branch.
DECISION: GH_PR_CREATE | #638 | ALLOW |  | Ran gh pr create; the new pull request is #638.
DECISION: GH_PR_EDIT | #638 | ALLOW |  | Ran gh pr edit on #638 to update the body.
DECISION: CONTROL_REFS_ONLY | #638 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #638
DECISION: URL | #641 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/641.
DECISION: PR_REF | #641 | ALLOW |  | Created PR #641 for the feature branch.
DECISION: GH_PR_CREATE | #641 | ALLOW |  | Ran gh pr create; the new pull request is #641.
DECISION: GH_PR_EDIT | #641 | ALLOW |  | Ran gh pr edit on #641 to update the body.
DECISION: CONTROL_REFS_ONLY | #641 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #641
DECISION: URL | #642 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/642.
DECISION: PR_REF | #642 | ALLOW |  | Created PR #642 for the feature branch.
DECISION: GH_PR_CREATE | #642 | ALLOW |  | Ran gh pr create; the new pull request is #642.
DECISION: GH_PR_EDIT | #642 | ALLOW |  | Ran gh pr edit on #642 to update the body.
DECISION: CONTROL_REFS_ONLY | #642 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #642
DECISION: URL | #644 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/644.
DECISION: PR_REF | #644 | ALLOW |  | Created PR #644 for the feature branch.
DECISION: GH_PR_CREATE | #644 | ALLOW |  | Ran gh pr create; the new pull request is #644.
DECISION: GH_PR_EDIT | #644 | ALLOW |  | Ran gh pr edit on #644 to update the body.
DECISION: CONTROL_REFS_ONLY | #644 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #644
DECISION: URL | #650 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/650.
DECISION: PR_REF | #650 | ALLOW |  | Created PR #650 for the feature branch.
DECISION: GH_PR_CREATE | #650 | ALLOW |  | Ran gh pr create; the new pull request is #650.
DECISION: GH_PR_EDIT | #650 | ALLOW |  | Ran gh pr edit on #650 to update the body.
DECISION: CONTROL_REFS_ONLY | #650 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #650
DECISION: URL | #651 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/651.
DECISION: PR_REF | #651 | ALLOW |  | Created PR #651 for the feature branch.
DECISION: GH_PR_CREATE | #651 | ALLOW |  | Ran gh pr create; the new pull request is #651.
DECISION: GH_PR_EDIT | #651 | ALLOW |  | Ran gh pr edit on #651 to update the body.
DECISION: CONTROL_REFS_ONLY | #651 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #651
DECISION: URL | #652 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/652.
DECISION: PR_REF | #652 | ALLOW |  | Created PR #652 for the feature branch.
DECISION: GH_PR_CREATE | #652 | ALLOW |  | Ran gh pr create; the new pull request is #652.
DECISION: GH_PR_EDIT | #652 | ALLOW |  | Ran gh pr edit on #652 to update the body.
DECISION: CONTROL_REFS_ONLY | #652 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #652
DECISION: URL | #653 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/653.
DECISION: PR_REF | #653 | ALLOW |  | Created PR #653 for the feature branch.
DECISION: GH_PR_CREATE | #653 | ALLOW |  | Ran gh pr create; the new pull request is #653.
DECISION: GH_PR_EDIT | #653 | ALLOW |  | Ran gh pr edit on #653 to update the body.
DECISION: CONTROL_REFS_ONLY | #653 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #653
DECISION: URL | #654 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/654.
DECISION: PR_REF | #654 | ALLOW |  | Created PR #654 for the feature branch.
DECISION: GH_PR_CREATE | #654 | ALLOW |  | Ran gh pr create; the new pull request is #654.
DECISION: GH_PR_EDIT | #654 | ALLOW |  | Ran gh pr edit on #654 to update the body.
DECISION: CONTROL_REFS_ONLY | #654 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #654
DECISION: URL | #656 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/656.
DECISION: PR_REF | #656 | ALLOW |  | Created PR #656 for the feature branch.
DECISION: GH_PR_CREATE | #656 | ALLOW |  | Ran gh pr create; the new pull request is #656.
DECISION: GH_PR_EDIT | #656 | ALLOW |  | Ran gh pr edit on #656 to update the body.
DECISION: CONTROL_REFS_ONLY | #656 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #656
DECISION: URL | #681 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/681.
DECISION: PR_REF | #681 | ALLOW |  | Created PR #681 for the feature branch.
DECISION: GH_PR_CREATE | #681 | ALLOW |  | Ran gh pr create; the new pull request is #681.
DECISION: GH_PR_EDIT | #681 | ALLOW |  | Ran gh pr edit on #681 to update the body.
DECISION: CONTROL_REFS_ONLY | #681 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #681
DECISION: URL | #682 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/682.
DECISION: PR_REF | #682 | ALLOW |  | Created PR #682 for the feature branch.
DECISION: GH_PR_CREATE | #682 | ALLOW |  | Ran gh pr create; the new pull request is #682.
DECISION: GH_PR_EDIT | #682 | ALLOW |  | Ran gh pr edit on #682 to update the body.
DECISION: CONTROL_REFS_ONLY | #682 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #682
DECISION: URL | #683 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/683.
DECISION: PR_REF | #683 | ALLOW |  | Created PR #683 for the feature branch.
DECISION: GH_PR_CREATE | #683 | ALLOW |  | Ran gh pr create; the new pull request is #683.
DECISION: GH_PR_EDIT | #683 | ALLOW |  | Ran gh pr edit on #683 to update the body.
DECISION: CONTROL_REFS_ONLY | #683 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #683
DECISION: URL | #684 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/684.
DECISION: PR_REF | #684 | ALLOW |  | Created PR #684 for the feature branch.
DECISION: GH_PR_CREATE | #684 | ALLOW |  | Ran gh pr create; the new pull request is #684.
DECISION: GH_PR_EDIT | #684 | ALLOW |  | Ran gh pr edit on #684 to update the body.
DECISION: CONTROL_REFS_ONLY | #684 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #684
DECISION: URL | #685 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/685.
DECISION: PR_REF | #685 | ALLOW |  | Created PR #685 for the feature branch.
DECISION: GH_PR_CREATE | #685 | ALLOW |  | Ran gh pr create; the new pull request is #685.
DECISION: GH_PR_EDIT | #685 | ALLOW |  | Ran gh pr edit on #685 to update the body.
DECISION: CONTROL_REFS_ONLY | #685 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #685
DECISION: URL | #691 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/691.
DECISION: PR_REF | #691 | ALLOW |  | Created PR #691 for the feature branch.
DECISION: GH_PR_CREATE | #691 | ALLOW |  | Ran gh pr create; the new pull request is #691.
DECISION: GH_PR_EDIT | #691 | ALLOW |  | Ran gh pr edit on #691 to update the body.
DECISION: CONTROL_REFS_ONLY | #691 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #691
DECISION: URL | #698 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/698.
DECISION: PR_REF | #698 | ALLOW |  | Created PR #698 for the feature branch.
DECISION: GH_PR_CREATE | #698 | ALLOW |  | Ran gh pr create; the new pull request is #698.
DECISION: GH_PR_EDIT | #698 | ALLOW |  | Ran gh pr edit on #698 to update the body.
DECISION: CONTROL_REFS_ONLY | #698 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #698
DECISION: URL | #700 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/700.
DECISION: PR_REF | #700 | ALLOW |  | Created PR #700 for the feature branch.
DECISION: GH_PR_CREATE | #700 | ALLOW |  | Ran gh pr create; the new pull request is #700.
DECISION: GH_PR_EDIT | #700 | ALLOW |  | Ran gh pr edit on #700 to update the body.
DECISION: CONTROL_REFS_ONLY | #700 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #700
DECISION: URL | #701 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/701.
DECISION: PR_REF | #701 | ALLOW |  | Created PR #701 for the feature branch.
DECISION: GH_PR_CREATE | #701 | ALLOW |  | Ran gh pr create; the new pull request is #701.
DECISION: GH_PR_EDIT | #701 | ALLOW |  | Ran gh pr edit on #701 to update the body.
DECISION: CONTROL_REFS_ONLY | #701 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #701
DECISION: URL | #702 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/702.
DECISION: PR_REF | #702 | ALLOW |  | Created PR #702 for the feature branch.
DECISION: GH_PR_CREATE | #702 | ALLOW |  | Ran gh pr create; the new pull request is #702.
DECISION: GH_PR_EDIT | #702 | ALLOW |  | Ran gh pr edit on #702 to update the body.
DECISION: CONTROL_REFS_ONLY | #702 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #702
DECISION: URL | #703 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/703.
DECISION: PR_REF | #703 | ALLOW |  | Created PR #703 for the feature branch.
DECISION: GH_PR_CREATE | #703 | ALLOW |  | Ran gh pr create; the new pull request is #703.
DECISION: GH_PR_EDIT | #703 | ALLOW |  | Ran gh pr edit on #703 to update the body.
DECISION: CONTROL_REFS_ONLY | #703 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #703
DECISION: URL | #704 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/704.
DECISION: PR_REF | #704 | ALLOW |  | Created PR #704 for the feature branch.
DECISION: GH_PR_CREATE | #704 | ALLOW |  | Ran gh pr create; the new pull request is #704.
DECISION: GH_PR_EDIT | #704 | ALLOW |  | Ran gh pr edit on #704 to update the body.
DECISION: CONTROL_REFS_ONLY | #704 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #704
DECISION: URL | #705 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/705.
DECISION: PR_REF | #705 | ALLOW |  | Created PR #705 for the feature branch.
DECISION: GH_PR_CREATE | #705 | ALLOW |  | Ran gh pr create; the new pull request is #705.
DECISION: GH_PR_EDIT | #705 | ALLOW |  | Ran gh pr edit on #705 to update the body.
DECISION: CONTROL_REFS_ONLY | #705 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #705
DECISION: URL | #718 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/718.
DECISION: PR_REF | #718 | ALLOW |  | Created PR #718 for the feature branch.
DECISION: GH_PR_CREATE | #718 | ALLOW |  | Ran gh pr create; the new pull request is #718.
DECISION: GH_PR_EDIT | #718 | ALLOW |  | Ran gh pr edit on #718 to update the body.
DECISION: CONTROL_REFS_ONLY | #718 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #718
DECISION: URL | #719 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/719.
DECISION: PR_REF | #719 | ALLOW |  | Created PR #719 for the feature branch.
DECISION: GH_PR_CREATE | #719 | ALLOW |  | Ran gh pr create; the new pull request is #719.
DECISION: GH_PR_EDIT | #719 | ALLOW |  | Ran gh pr edit on #719 to update the body.
DECISION: CONTROL_REFS_ONLY | #719 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #719
DECISION: URL | #720 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/720.
DECISION: PR_REF | #720 | ALLOW |  | Created PR #720 for the feature branch.
DECISION: GH_PR_CREATE | #720 | ALLOW |  | Ran gh pr create; the new pull request is #720.
DECISION: GH_PR_EDIT | #720 | ALLOW |  | Ran gh pr edit on #720 to update the body.
DECISION: CONTROL_REFS_ONLY | #720 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #720
DECISION: URL | #721 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/721.
DECISION: PR_REF | #721 | ALLOW |  | Created PR #721 for the feature branch.
DECISION: GH_PR_CREATE | #721 | ALLOW |  | Ran gh pr create; the new pull request is #721.
DECISION: GH_PR_EDIT | #721 | ALLOW |  | Ran gh pr edit on #721 to update the body.
DECISION: CONTROL_REFS_ONLY | #721 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #721
DECISION: URL | #725 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/725.
DECISION: PR_REF | #725 | ALLOW |  | Created PR #725 for the feature branch.
DECISION: GH_PR_CREATE | #725 | ALLOW |  | Ran gh pr create; the new pull request is #725.
DECISION: GH_PR_EDIT | #725 | ALLOW |  | Ran gh pr edit on #725 to update the body.
DECISION: CONTROL_REFS_ONLY | #725 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #725
DECISION: URL | #726 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/726.
DECISION: PR_REF | #726 | ALLOW |  | Created PR #726 for the feature branch.
DECISION: GH_PR_CREATE | #726 | ALLOW |  | Ran gh pr create; the new pull request is #726.
DECISION: GH_PR_EDIT | #726 | ALLOW |  | Ran gh pr edit on #726 to update the body.
DECISION: CONTROL_REFS_ONLY | #726 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #726
DECISION: URL | #727 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/727.
DECISION: PR_REF | #727 | ALLOW |  | Created PR #727 for the feature branch.
DECISION: GH_PR_CREATE | #727 | ALLOW |  | Ran gh pr create; the new pull request is #727.
DECISION: GH_PR_EDIT | #727 | ALLOW |  | Ran gh pr edit on #727 to update the body.
DECISION: CONTROL_REFS_ONLY | #727 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #727
DECISION: URL | #728 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/728.
DECISION: PR_REF | #728 | ALLOW |  | Created PR #728 for the feature branch.
DECISION: GH_PR_CREATE | #728 | ALLOW |  | Ran gh pr create; the new pull request is #728.
DECISION: GH_PR_EDIT | #728 | ALLOW |  | Ran gh pr edit on #728 to update the body.
DECISION: CONTROL_REFS_ONLY | #728 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #728
DECISION: URL | #729 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/729.
DECISION: PR_REF | #729 | ALLOW |  | Created PR #729 for the feature branch.
DECISION: GH_PR_CREATE | #729 | ALLOW |  | Ran gh pr create; the new pull request is #729.
DECISION: GH_PR_EDIT | #729 | ALLOW |  | Ran gh pr edit on #729 to update the body.
DECISION: CONTROL_REFS_ONLY | #729 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #729
DECISION: URL | #730 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/730.
DECISION: PR_REF | #730 | ALLOW |  | Created PR #730 for the feature branch.
DECISION: GH_PR_CREATE | #730 | ALLOW |  | Ran gh pr create; the new pull request is #730.
DECISION: GH_PR_EDIT | #730 | ALLOW |  | Ran gh pr edit on #730 to update the body.
DECISION: CONTROL_REFS_ONLY | #730 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #730
DECISION: URL | #731 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/731.
DECISION: PR_REF | #731 | ALLOW |  | Created PR #731 for the feature branch.
DECISION: GH_PR_CREATE | #731 | ALLOW |  | Ran gh pr create; the new pull request is #731.
DECISION: GH_PR_EDIT | #731 | ALLOW |  | Ran gh pr edit on #731 to update the body.
DECISION: CONTROL_REFS_ONLY | #731 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #731
DECISION: URL | #747 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/747.
DECISION: PR_REF | #747 | ALLOW |  | Created PR #747 for the feature branch.
DECISION: GH_PR_CREATE | #747 | ALLOW |  | Ran gh pr create; the new pull request is #747.
DECISION: GH_PR_EDIT | #747 | ALLOW |  | Ran gh pr edit on #747 to update the body.
DECISION: CONTROL_REFS_ONLY | #747 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #747
DECISION: URL | #748 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/748.
DECISION: PR_REF | #748 | ALLOW |  | Created PR #748 for the feature branch.
DECISION: GH_PR_CREATE | #748 | ALLOW |  | Ran gh pr create; the new pull request is #748.
DECISION: GH_PR_EDIT | #748 | ALLOW |  | Ran gh pr edit on #748 to update the body.
DECISION: CONTROL_REFS_ONLY | #748 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #748
DECISION: URL | #777 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/777.
DECISION: PR_REF | #777 | ALLOW |  | Created PR #777 for the feature branch.
DECISION: GH_PR_CREATE | #777 | ALLOW |  | Ran gh pr create; the new pull request is #777.
DECISION: GH_PR_EDIT | #777 | ALLOW |  | Ran gh pr edit on #777 to update the body.
DECISION: CONTROL_REFS_ONLY | #777 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #777
DECISION: URL | #778 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/778.
DECISION: PR_REF | #778 | ALLOW |  | Created PR #778 for the feature branch.
DECISION: GH_PR_CREATE | #778 | ALLOW |  | Ran gh pr create; the new pull request is #778.
DECISION: GH_PR_EDIT | #778 | ALLOW |  | Ran gh pr edit on #778 to update the body.
DECISION: CONTROL_REFS_ONLY | #778 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #778
DECISION: URL | #779 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/779.
DECISION: PR_REF | #779 | ALLOW |  | Created PR #779 for the feature branch.
DECISION: GH_PR_CREATE | #779 | ALLOW |  | Ran gh pr create; the new pull request is #779.
DECISION: GH_PR_EDIT | #779 | ALLOW |  | Ran gh pr edit on #779 to update the body.
DECISION: CONTROL_REFS_ONLY | #779 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #779
DECISION: URL | #782 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/782.
DECISION: PR_REF | #782 | ALLOW |  | Created PR #782 for the feature branch.
DECISION: GH_PR_CREATE | #782 | ALLOW |  | Ran gh pr create; the new pull request is #782.
DECISION: GH_PR_EDIT | #782 | ALLOW |  | Ran gh pr edit on #782 to update the body.
DECISION: CONTROL_REFS_ONLY | #782 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #782
DECISION: URL | #800 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/800.
DECISION: PR_REF | #800 | ALLOW |  | Created PR #800 for the feature branch.
DECISION: GH_PR_CREATE | #800 | ALLOW |  | Ran gh pr create; the new pull request is #800.
DECISION: GH_PR_EDIT | #800 | ALLOW |  | Ran gh pr edit on #800 to update the body.
DECISION: CONTROL_REFS_ONLY | #800 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #800
DECISION: URL | #801 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/801.
DECISION: PR_REF | #801 | ALLOW |  | Created PR #801 for the feature branch.
DECISION: GH_PR_CREATE | #801 | ALLOW |  | Ran gh pr create; the new pull request is #801.
DECISION: GH_PR_EDIT | #801 | ALLOW |  | Ran gh pr edit on #801 to update the body.
DECISION: CONTROL_REFS_ONLY | #801 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #801
DECISION: URL | #808 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/808.
DECISION: PR_REF | #808 | ALLOW |  | Created PR #808 for the feature branch.
DECISION: GH_PR_CREATE | #808 | ALLOW |  | Ran gh pr create; the new pull request is #808.
DECISION: GH_PR_EDIT | #808 | ALLOW |  | Ran gh pr edit on #808 to update the body.
DECISION: CONTROL_REFS_ONLY | #808 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #808
DECISION: URL | #809 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/809.
DECISION: PR_REF | #809 | ALLOW |  | Created PR #809 for the feature branch.
DECISION: GH_PR_CREATE | #809 | ALLOW |  | Ran gh pr create; the new pull request is #809.
DECISION: GH_PR_EDIT | #809 | ALLOW |  | Ran gh pr edit on #809 to update the body.
DECISION: CONTROL_REFS_ONLY | #809 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #809
DECISION: URL | #811 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/811.
DECISION: PR_REF | #811 | ALLOW |  | Created PR #811 for the feature branch.
DECISION: GH_PR_CREATE | #811 | ALLOW |  | Ran gh pr create; the new pull request is #811.
DECISION: GH_PR_EDIT | #811 | ALLOW |  | Ran gh pr edit on #811 to update the body.
DECISION: CONTROL_REFS_ONLY | #811 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #811
DECISION: URL | #817 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/817.
DECISION: PR_REF | #817 | ALLOW |  | Created PR #817 for the feature branch.
DECISION: GH_PR_CREATE | #817 | ALLOW |  | Ran gh pr create; the new pull request is #817.
DECISION: GH_PR_EDIT | #817 | ALLOW |  | Ran gh pr edit on #817 to update the body.
DECISION: CONTROL_REFS_ONLY | #817 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #817
DECISION: URL | #831 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/831.
DECISION: PR_REF | #831 | ALLOW |  | Created PR #831 for the feature branch.
DECISION: GH_PR_CREATE | #831 | ALLOW |  | Ran gh pr create; the new pull request is #831.
DECISION: GH_PR_EDIT | #831 | ALLOW |  | Ran gh pr edit on #831 to update the body.
DECISION: CONTROL_REFS_ONLY | #831 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #831
DECISION: URL | #853 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/853.
DECISION: PR_REF | #853 | ALLOW |  | Created PR #853 for the feature branch.
DECISION: GH_PR_CREATE | #853 | ALLOW |  | Ran gh pr create; the new pull request is #853.
DECISION: GH_PR_EDIT | #853 | ALLOW |  | Ran gh pr edit on #853 to update the body.
DECISION: CONTROL_REFS_ONLY | #853 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #853
DECISION: URL | #854 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/854.
DECISION: PR_REF | #854 | ALLOW |  | Created PR #854 for the feature branch.
DECISION: GH_PR_CREATE | #854 | ALLOW |  | Ran gh pr create; the new pull request is #854.
DECISION: GH_PR_EDIT | #854 | ALLOW |  | Ran gh pr edit on #854 to update the body.
DECISION: CONTROL_REFS_ONLY | #854 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #854
DECISION: URL | #855 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/855.
DECISION: PR_REF | #855 | ALLOW |  | Created PR #855 for the feature branch.
DECISION: GH_PR_CREATE | #855 | ALLOW |  | Ran gh pr create; the new pull request is #855.
DECISION: GH_PR_EDIT | #855 | ALLOW |  | Ran gh pr edit on #855 to update the body.
DECISION: CONTROL_REFS_ONLY | #855 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #855
DECISION: URL | #856 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/856.
DECISION: PR_REF | #856 | ALLOW |  | Created PR #856 for the feature branch.
DECISION: GH_PR_CREATE | #856 | ALLOW |  | Ran gh pr create; the new pull request is #856.
DECISION: GH_PR_EDIT | #856 | ALLOW |  | Ran gh pr edit on #856 to update the body.
DECISION: CONTROL_REFS_ONLY | #856 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #856
DECISION: URL | #857 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/857.
DECISION: PR_REF | #857 | ALLOW |  | Created PR #857 for the feature branch.
DECISION: GH_PR_CREATE | #857 | ALLOW |  | Ran gh pr create; the new pull request is #857.
DECISION: GH_PR_EDIT | #857 | ALLOW |  | Ran gh pr edit on #857 to update the body.
DECISION: CONTROL_REFS_ONLY | #857 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #857
DECISION: URL | #858 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/858.
DECISION: PR_REF | #858 | ALLOW |  | Created PR #858 for the feature branch.
DECISION: GH_PR_CREATE | #858 | ALLOW |  | Ran gh pr create; the new pull request is #858.
DECISION: GH_PR_EDIT | #858 | ALLOW |  | Ran gh pr edit on #858 to update the body.
DECISION: CONTROL_REFS_ONLY | #858 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #858
DECISION: URL | #859 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/859.
DECISION: PR_REF | #859 | ALLOW |  | Created PR #859 for the feature branch.
DECISION: GH_PR_CREATE | #859 | ALLOW |  | Ran gh pr create; the new pull request is #859.
DECISION: GH_PR_EDIT | #859 | ALLOW |  | Ran gh pr edit on #859 to update the body.
DECISION: CONTROL_REFS_ONLY | #859 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #859
DECISION: URL | #862 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/862.
DECISION: PR_REF | #862 | ALLOW |  | Created PR #862 for the feature branch.
DECISION: GH_PR_CREATE | #862 | ALLOW |  | Ran gh pr create; the new pull request is #862.
DECISION: GH_PR_EDIT | #862 | ALLOW |  | Ran gh pr edit on #862 to update the body.
DECISION: CONTROL_REFS_ONLY | #862 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #862
DECISION: URL | #863 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/863.
DECISION: PR_REF | #863 | ALLOW |  | Created PR #863 for the feature branch.
DECISION: GH_PR_CREATE | #863 | ALLOW |  | Ran gh pr create; the new pull request is #863.
DECISION: GH_PR_EDIT | #863 | ALLOW |  | Ran gh pr edit on #863 to update the body.
DECISION: CONTROL_REFS_ONLY | #863 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #863
DECISION: URL | #871 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/871.
DECISION: PR_REF | #871 | ALLOW |  | Created PR #871 for the feature branch.
DECISION: GH_PR_CREATE | #871 | ALLOW |  | Ran gh pr create; the new pull request is #871.
DECISION: GH_PR_EDIT | #871 | ALLOW |  | Ran gh pr edit on #871 to update the body.
DECISION: CONTROL_REFS_ONLY | #871 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #871
DECISION: URL | #881 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/881.
DECISION: PR_REF | #881 | ALLOW |  | Created PR #881 for the feature branch.
DECISION: GH_PR_CREATE | #881 | ALLOW |  | Ran gh pr create; the new pull request is #881.
DECISION: GH_PR_EDIT | #881 | ALLOW |  | Ran gh pr edit on #881 to update the body.
DECISION: CONTROL_REFS_ONLY | #881 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author agent output does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #881
CONTROL-BLOCKS: 124
CONTROL-ALLOWS: 0
FALSE-POSITIVES: 0
```

BEFORE-FALSE-POSITIVES: 0

## After

Timestamp: 2026-10-11T23-01
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/corpus-pr-author.ps1 -Mode After -Sha 2ef8d361e978ca8b7733a545d76a87e8418005ce
EXIT_CODE: 0
Output Summary: After (converted validator, envelope input through `-InputText`): the PR-NUMBERS line equals the [P1-T5] line (124 numbers); 620 DECISION lines; CONTROL-BLOCKS 124, CONTROL-ALLOWS 0; FALSE-POSITIVES 0. Scripts unchanged since [P1-T1] (corpus-common.ps1 CF5B7CC9..., corpus-pr-author.ps1 08FBD108..., re-verified with sha256sum). `origin/main` re-fetched before the run: tip 2ef8d361e978ca8b7733a545d76a87e8418005ce, equal to CORPUS_SHA.

```text
MODE: After
CORPUS-COMMIT: 2ef8d361e978ca8b7733a545d76a87e8418005ce
ENUMERATION: git grep -h -o -I -E 'drm-copilot/pull/[0-9]+' <CORPUS-COMMIT> -- docs, distinct numbers ascending
PR-NUMBERS: 1, 119, 209, 295, 302, 304, 307, 308, 311, 314, 322, 323, 326, 330, 332, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 401, 410, 427, 449, 450, 451, 453, 454, 455, 456, 457, 458, 494, 496, 497, 503, 540, 541, 548, 557, 558, 560, 563, 564, 569, 571, 572, 579, 580, 581, 582, 603, 604, 605, 607, 624, 638, 641, 642, 644, 650, 651, 652, 653, 654, 656, 681, 682, 683, 684, 685, 691, 698, 700, 701, 702, 703, 704, 705, 718, 719, 720, 721, 725, 726, 727, 728, 729, 730, 731, 747, 748, 777, 778, 779, 782, 800, 801, 808, 809, 811, 817, 831, 853, 854, 855, 856, 857, 858, 859, 862, 863, 871, 881
DECISION: URL | #1 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/1.
DECISION: PR_REF | #1 | ALLOW |  | Created PR #1 for the feature branch.
DECISION: GH_PR_CREATE | #1 | ALLOW |  | Ran gh pr create; the new pull request is #1.
DECISION: GH_PR_EDIT | #1 | ALLOW |  | Ran gh pr edit on #1 to update the body.
DECISION: CONTROL_REFS_ONLY | #1 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #1
DECISION: URL | #119 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/119.
DECISION: PR_REF | #119 | ALLOW |  | Created PR #119 for the feature branch.
DECISION: GH_PR_CREATE | #119 | ALLOW |  | Ran gh pr create; the new pull request is #119.
DECISION: GH_PR_EDIT | #119 | ALLOW |  | Ran gh pr edit on #119 to update the body.
DECISION: CONTROL_REFS_ONLY | #119 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #119
DECISION: URL | #209 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/209.
DECISION: PR_REF | #209 | ALLOW |  | Created PR #209 for the feature branch.
DECISION: GH_PR_CREATE | #209 | ALLOW |  | Ran gh pr create; the new pull request is #209.
DECISION: GH_PR_EDIT | #209 | ALLOW |  | Ran gh pr edit on #209 to update the body.
DECISION: CONTROL_REFS_ONLY | #209 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #209
DECISION: URL | #295 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/295.
DECISION: PR_REF | #295 | ALLOW |  | Created PR #295 for the feature branch.
DECISION: GH_PR_CREATE | #295 | ALLOW |  | Ran gh pr create; the new pull request is #295.
DECISION: GH_PR_EDIT | #295 | ALLOW |  | Ran gh pr edit on #295 to update the body.
DECISION: CONTROL_REFS_ONLY | #295 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #295
DECISION: URL | #302 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/302.
DECISION: PR_REF | #302 | ALLOW |  | Created PR #302 for the feature branch.
DECISION: GH_PR_CREATE | #302 | ALLOW |  | Ran gh pr create; the new pull request is #302.
DECISION: GH_PR_EDIT | #302 | ALLOW |  | Ran gh pr edit on #302 to update the body.
DECISION: CONTROL_REFS_ONLY | #302 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #302
DECISION: URL | #304 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/304.
DECISION: PR_REF | #304 | ALLOW |  | Created PR #304 for the feature branch.
DECISION: GH_PR_CREATE | #304 | ALLOW |  | Ran gh pr create; the new pull request is #304.
DECISION: GH_PR_EDIT | #304 | ALLOW |  | Ran gh pr edit on #304 to update the body.
DECISION: CONTROL_REFS_ONLY | #304 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #304
DECISION: URL | #307 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/307.
DECISION: PR_REF | #307 | ALLOW |  | Created PR #307 for the feature branch.
DECISION: GH_PR_CREATE | #307 | ALLOW |  | Ran gh pr create; the new pull request is #307.
DECISION: GH_PR_EDIT | #307 | ALLOW |  | Ran gh pr edit on #307 to update the body.
DECISION: CONTROL_REFS_ONLY | #307 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #307
DECISION: URL | #308 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/308.
DECISION: PR_REF | #308 | ALLOW |  | Created PR #308 for the feature branch.
DECISION: GH_PR_CREATE | #308 | ALLOW |  | Ran gh pr create; the new pull request is #308.
DECISION: GH_PR_EDIT | #308 | ALLOW |  | Ran gh pr edit on #308 to update the body.
DECISION: CONTROL_REFS_ONLY | #308 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #308
DECISION: URL | #311 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/311.
DECISION: PR_REF | #311 | ALLOW |  | Created PR #311 for the feature branch.
DECISION: GH_PR_CREATE | #311 | ALLOW |  | Ran gh pr create; the new pull request is #311.
DECISION: GH_PR_EDIT | #311 | ALLOW |  | Ran gh pr edit on #311 to update the body.
DECISION: CONTROL_REFS_ONLY | #311 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #311
DECISION: URL | #314 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/314.
DECISION: PR_REF | #314 | ALLOW |  | Created PR #314 for the feature branch.
DECISION: GH_PR_CREATE | #314 | ALLOW |  | Ran gh pr create; the new pull request is #314.
DECISION: GH_PR_EDIT | #314 | ALLOW |  | Ran gh pr edit on #314 to update the body.
DECISION: CONTROL_REFS_ONLY | #314 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #314
DECISION: URL | #322 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/322.
DECISION: PR_REF | #322 | ALLOW |  | Created PR #322 for the feature branch.
DECISION: GH_PR_CREATE | #322 | ALLOW |  | Ran gh pr create; the new pull request is #322.
DECISION: GH_PR_EDIT | #322 | ALLOW |  | Ran gh pr edit on #322 to update the body.
DECISION: CONTROL_REFS_ONLY | #322 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #322
DECISION: URL | #323 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/323.
DECISION: PR_REF | #323 | ALLOW |  | Created PR #323 for the feature branch.
DECISION: GH_PR_CREATE | #323 | ALLOW |  | Ran gh pr create; the new pull request is #323.
DECISION: GH_PR_EDIT | #323 | ALLOW |  | Ran gh pr edit on #323 to update the body.
DECISION: CONTROL_REFS_ONLY | #323 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #323
DECISION: URL | #326 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/326.
DECISION: PR_REF | #326 | ALLOW |  | Created PR #326 for the feature branch.
DECISION: GH_PR_CREATE | #326 | ALLOW |  | Ran gh pr create; the new pull request is #326.
DECISION: GH_PR_EDIT | #326 | ALLOW |  | Ran gh pr edit on #326 to update the body.
DECISION: CONTROL_REFS_ONLY | #326 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #326
DECISION: URL | #330 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/330.
DECISION: PR_REF | #330 | ALLOW |  | Created PR #330 for the feature branch.
DECISION: GH_PR_CREATE | #330 | ALLOW |  | Ran gh pr create; the new pull request is #330.
DECISION: GH_PR_EDIT | #330 | ALLOW |  | Ran gh pr edit on #330 to update the body.
DECISION: CONTROL_REFS_ONLY | #330 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #330
DECISION: URL | #332 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/332.
DECISION: PR_REF | #332 | ALLOW |  | Created PR #332 for the feature branch.
DECISION: GH_PR_CREATE | #332 | ALLOW |  | Ran gh pr create; the new pull request is #332.
DECISION: GH_PR_EDIT | #332 | ALLOW |  | Ran gh pr edit on #332 to update the body.
DECISION: CONTROL_REFS_ONLY | #332 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #332
DECISION: URL | #374 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/374.
DECISION: PR_REF | #374 | ALLOW |  | Created PR #374 for the feature branch.
DECISION: GH_PR_CREATE | #374 | ALLOW |  | Ran gh pr create; the new pull request is #374.
DECISION: GH_PR_EDIT | #374 | ALLOW |  | Ran gh pr edit on #374 to update the body.
DECISION: CONTROL_REFS_ONLY | #374 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #374
DECISION: URL | #375 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/375.
DECISION: PR_REF | #375 | ALLOW |  | Created PR #375 for the feature branch.
DECISION: GH_PR_CREATE | #375 | ALLOW |  | Ran gh pr create; the new pull request is #375.
DECISION: GH_PR_EDIT | #375 | ALLOW |  | Ran gh pr edit on #375 to update the body.
DECISION: CONTROL_REFS_ONLY | #375 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #375
DECISION: URL | #376 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/376.
DECISION: PR_REF | #376 | ALLOW |  | Created PR #376 for the feature branch.
DECISION: GH_PR_CREATE | #376 | ALLOW |  | Ran gh pr create; the new pull request is #376.
DECISION: GH_PR_EDIT | #376 | ALLOW |  | Ran gh pr edit on #376 to update the body.
DECISION: CONTROL_REFS_ONLY | #376 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #376
DECISION: URL | #377 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/377.
DECISION: PR_REF | #377 | ALLOW |  | Created PR #377 for the feature branch.
DECISION: GH_PR_CREATE | #377 | ALLOW |  | Ran gh pr create; the new pull request is #377.
DECISION: GH_PR_EDIT | #377 | ALLOW |  | Ran gh pr edit on #377 to update the body.
DECISION: CONTROL_REFS_ONLY | #377 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #377
DECISION: URL | #378 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/378.
DECISION: PR_REF | #378 | ALLOW |  | Created PR #378 for the feature branch.
DECISION: GH_PR_CREATE | #378 | ALLOW |  | Ran gh pr create; the new pull request is #378.
DECISION: GH_PR_EDIT | #378 | ALLOW |  | Ran gh pr edit on #378 to update the body.
DECISION: CONTROL_REFS_ONLY | #378 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #378
DECISION: URL | #379 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/379.
DECISION: PR_REF | #379 | ALLOW |  | Created PR #379 for the feature branch.
DECISION: GH_PR_CREATE | #379 | ALLOW |  | Ran gh pr create; the new pull request is #379.
DECISION: GH_PR_EDIT | #379 | ALLOW |  | Ran gh pr edit on #379 to update the body.
DECISION: CONTROL_REFS_ONLY | #379 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #379
DECISION: URL | #380 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/380.
DECISION: PR_REF | #380 | ALLOW |  | Created PR #380 for the feature branch.
DECISION: GH_PR_CREATE | #380 | ALLOW |  | Ran gh pr create; the new pull request is #380.
DECISION: GH_PR_EDIT | #380 | ALLOW |  | Ran gh pr edit on #380 to update the body.
DECISION: CONTROL_REFS_ONLY | #380 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #380
DECISION: URL | #381 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/381.
DECISION: PR_REF | #381 | ALLOW |  | Created PR #381 for the feature branch.
DECISION: GH_PR_CREATE | #381 | ALLOW |  | Ran gh pr create; the new pull request is #381.
DECISION: GH_PR_EDIT | #381 | ALLOW |  | Ran gh pr edit on #381 to update the body.
DECISION: CONTROL_REFS_ONLY | #381 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #381
DECISION: URL | #382 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/382.
DECISION: PR_REF | #382 | ALLOW |  | Created PR #382 for the feature branch.
DECISION: GH_PR_CREATE | #382 | ALLOW |  | Ran gh pr create; the new pull request is #382.
DECISION: GH_PR_EDIT | #382 | ALLOW |  | Ran gh pr edit on #382 to update the body.
DECISION: CONTROL_REFS_ONLY | #382 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #382
DECISION: URL | #383 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/383.
DECISION: PR_REF | #383 | ALLOW |  | Created PR #383 for the feature branch.
DECISION: GH_PR_CREATE | #383 | ALLOW |  | Ran gh pr create; the new pull request is #383.
DECISION: GH_PR_EDIT | #383 | ALLOW |  | Ran gh pr edit on #383 to update the body.
DECISION: CONTROL_REFS_ONLY | #383 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #383
DECISION: URL | #384 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/384.
DECISION: PR_REF | #384 | ALLOW |  | Created PR #384 for the feature branch.
DECISION: GH_PR_CREATE | #384 | ALLOW |  | Ran gh pr create; the new pull request is #384.
DECISION: GH_PR_EDIT | #384 | ALLOW |  | Ran gh pr edit on #384 to update the body.
DECISION: CONTROL_REFS_ONLY | #384 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #384
DECISION: URL | #385 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/385.
DECISION: PR_REF | #385 | ALLOW |  | Created PR #385 for the feature branch.
DECISION: GH_PR_CREATE | #385 | ALLOW |  | Ran gh pr create; the new pull request is #385.
DECISION: GH_PR_EDIT | #385 | ALLOW |  | Ran gh pr edit on #385 to update the body.
DECISION: CONTROL_REFS_ONLY | #385 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #385
DECISION: URL | #386 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/386.
DECISION: PR_REF | #386 | ALLOW |  | Created PR #386 for the feature branch.
DECISION: GH_PR_CREATE | #386 | ALLOW |  | Ran gh pr create; the new pull request is #386.
DECISION: GH_PR_EDIT | #386 | ALLOW |  | Ran gh pr edit on #386 to update the body.
DECISION: CONTROL_REFS_ONLY | #386 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #386
DECISION: URL | #387 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/387.
DECISION: PR_REF | #387 | ALLOW |  | Created PR #387 for the feature branch.
DECISION: GH_PR_CREATE | #387 | ALLOW |  | Ran gh pr create; the new pull request is #387.
DECISION: GH_PR_EDIT | #387 | ALLOW |  | Ran gh pr edit on #387 to update the body.
DECISION: CONTROL_REFS_ONLY | #387 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #387
DECISION: URL | #388 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/388.
DECISION: PR_REF | #388 | ALLOW |  | Created PR #388 for the feature branch.
DECISION: GH_PR_CREATE | #388 | ALLOW |  | Ran gh pr create; the new pull request is #388.
DECISION: GH_PR_EDIT | #388 | ALLOW |  | Ran gh pr edit on #388 to update the body.
DECISION: CONTROL_REFS_ONLY | #388 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #388
DECISION: URL | #401 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/401.
DECISION: PR_REF | #401 | ALLOW |  | Created PR #401 for the feature branch.
DECISION: GH_PR_CREATE | #401 | ALLOW |  | Ran gh pr create; the new pull request is #401.
DECISION: GH_PR_EDIT | #401 | ALLOW |  | Ran gh pr edit on #401 to update the body.
DECISION: CONTROL_REFS_ONLY | #401 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #401
DECISION: URL | #410 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/410.
DECISION: PR_REF | #410 | ALLOW |  | Created PR #410 for the feature branch.
DECISION: GH_PR_CREATE | #410 | ALLOW |  | Ran gh pr create; the new pull request is #410.
DECISION: GH_PR_EDIT | #410 | ALLOW |  | Ran gh pr edit on #410 to update the body.
DECISION: CONTROL_REFS_ONLY | #410 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #410
DECISION: URL | #427 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/427.
DECISION: PR_REF | #427 | ALLOW |  | Created PR #427 for the feature branch.
DECISION: GH_PR_CREATE | #427 | ALLOW |  | Ran gh pr create; the new pull request is #427.
DECISION: GH_PR_EDIT | #427 | ALLOW |  | Ran gh pr edit on #427 to update the body.
DECISION: CONTROL_REFS_ONLY | #427 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #427
DECISION: URL | #449 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/449.
DECISION: PR_REF | #449 | ALLOW |  | Created PR #449 for the feature branch.
DECISION: GH_PR_CREATE | #449 | ALLOW |  | Ran gh pr create; the new pull request is #449.
DECISION: GH_PR_EDIT | #449 | ALLOW |  | Ran gh pr edit on #449 to update the body.
DECISION: CONTROL_REFS_ONLY | #449 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #449
DECISION: URL | #450 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/450.
DECISION: PR_REF | #450 | ALLOW |  | Created PR #450 for the feature branch.
DECISION: GH_PR_CREATE | #450 | ALLOW |  | Ran gh pr create; the new pull request is #450.
DECISION: GH_PR_EDIT | #450 | ALLOW |  | Ran gh pr edit on #450 to update the body.
DECISION: CONTROL_REFS_ONLY | #450 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #450
DECISION: URL | #451 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/451.
DECISION: PR_REF | #451 | ALLOW |  | Created PR #451 for the feature branch.
DECISION: GH_PR_CREATE | #451 | ALLOW |  | Ran gh pr create; the new pull request is #451.
DECISION: GH_PR_EDIT | #451 | ALLOW |  | Ran gh pr edit on #451 to update the body.
DECISION: CONTROL_REFS_ONLY | #451 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #451
DECISION: URL | #453 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/453.
DECISION: PR_REF | #453 | ALLOW |  | Created PR #453 for the feature branch.
DECISION: GH_PR_CREATE | #453 | ALLOW |  | Ran gh pr create; the new pull request is #453.
DECISION: GH_PR_EDIT | #453 | ALLOW |  | Ran gh pr edit on #453 to update the body.
DECISION: CONTROL_REFS_ONLY | #453 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #453
DECISION: URL | #454 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/454.
DECISION: PR_REF | #454 | ALLOW |  | Created PR #454 for the feature branch.
DECISION: GH_PR_CREATE | #454 | ALLOW |  | Ran gh pr create; the new pull request is #454.
DECISION: GH_PR_EDIT | #454 | ALLOW |  | Ran gh pr edit on #454 to update the body.
DECISION: CONTROL_REFS_ONLY | #454 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #454
DECISION: URL | #455 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/455.
DECISION: PR_REF | #455 | ALLOW |  | Created PR #455 for the feature branch.
DECISION: GH_PR_CREATE | #455 | ALLOW |  | Ran gh pr create; the new pull request is #455.
DECISION: GH_PR_EDIT | #455 | ALLOW |  | Ran gh pr edit on #455 to update the body.
DECISION: CONTROL_REFS_ONLY | #455 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #455
DECISION: URL | #456 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/456.
DECISION: PR_REF | #456 | ALLOW |  | Created PR #456 for the feature branch.
DECISION: GH_PR_CREATE | #456 | ALLOW |  | Ran gh pr create; the new pull request is #456.
DECISION: GH_PR_EDIT | #456 | ALLOW |  | Ran gh pr edit on #456 to update the body.
DECISION: CONTROL_REFS_ONLY | #456 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #456
DECISION: URL | #457 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/457.
DECISION: PR_REF | #457 | ALLOW |  | Created PR #457 for the feature branch.
DECISION: GH_PR_CREATE | #457 | ALLOW |  | Ran gh pr create; the new pull request is #457.
DECISION: GH_PR_EDIT | #457 | ALLOW |  | Ran gh pr edit on #457 to update the body.
DECISION: CONTROL_REFS_ONLY | #457 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #457
DECISION: URL | #458 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/458.
DECISION: PR_REF | #458 | ALLOW |  | Created PR #458 for the feature branch.
DECISION: GH_PR_CREATE | #458 | ALLOW |  | Ran gh pr create; the new pull request is #458.
DECISION: GH_PR_EDIT | #458 | ALLOW |  | Ran gh pr edit on #458 to update the body.
DECISION: CONTROL_REFS_ONLY | #458 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #458
DECISION: URL | #494 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/494.
DECISION: PR_REF | #494 | ALLOW |  | Created PR #494 for the feature branch.
DECISION: GH_PR_CREATE | #494 | ALLOW |  | Ran gh pr create; the new pull request is #494.
DECISION: GH_PR_EDIT | #494 | ALLOW |  | Ran gh pr edit on #494 to update the body.
DECISION: CONTROL_REFS_ONLY | #494 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #494
DECISION: URL | #496 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/496.
DECISION: PR_REF | #496 | ALLOW |  | Created PR #496 for the feature branch.
DECISION: GH_PR_CREATE | #496 | ALLOW |  | Ran gh pr create; the new pull request is #496.
DECISION: GH_PR_EDIT | #496 | ALLOW |  | Ran gh pr edit on #496 to update the body.
DECISION: CONTROL_REFS_ONLY | #496 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #496
DECISION: URL | #497 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/497.
DECISION: PR_REF | #497 | ALLOW |  | Created PR #497 for the feature branch.
DECISION: GH_PR_CREATE | #497 | ALLOW |  | Ran gh pr create; the new pull request is #497.
DECISION: GH_PR_EDIT | #497 | ALLOW |  | Ran gh pr edit on #497 to update the body.
DECISION: CONTROL_REFS_ONLY | #497 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #497
DECISION: URL | #503 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/503.
DECISION: PR_REF | #503 | ALLOW |  | Created PR #503 for the feature branch.
DECISION: GH_PR_CREATE | #503 | ALLOW |  | Ran gh pr create; the new pull request is #503.
DECISION: GH_PR_EDIT | #503 | ALLOW |  | Ran gh pr edit on #503 to update the body.
DECISION: CONTROL_REFS_ONLY | #503 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #503
DECISION: URL | #540 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/540.
DECISION: PR_REF | #540 | ALLOW |  | Created PR #540 for the feature branch.
DECISION: GH_PR_CREATE | #540 | ALLOW |  | Ran gh pr create; the new pull request is #540.
DECISION: GH_PR_EDIT | #540 | ALLOW |  | Ran gh pr edit on #540 to update the body.
DECISION: CONTROL_REFS_ONLY | #540 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #540
DECISION: URL | #541 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/541.
DECISION: PR_REF | #541 | ALLOW |  | Created PR #541 for the feature branch.
DECISION: GH_PR_CREATE | #541 | ALLOW |  | Ran gh pr create; the new pull request is #541.
DECISION: GH_PR_EDIT | #541 | ALLOW |  | Ran gh pr edit on #541 to update the body.
DECISION: CONTROL_REFS_ONLY | #541 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #541
DECISION: URL | #548 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/548.
DECISION: PR_REF | #548 | ALLOW |  | Created PR #548 for the feature branch.
DECISION: GH_PR_CREATE | #548 | ALLOW |  | Ran gh pr create; the new pull request is #548.
DECISION: GH_PR_EDIT | #548 | ALLOW |  | Ran gh pr edit on #548 to update the body.
DECISION: CONTROL_REFS_ONLY | #548 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #548
DECISION: URL | #557 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/557.
DECISION: PR_REF | #557 | ALLOW |  | Created PR #557 for the feature branch.
DECISION: GH_PR_CREATE | #557 | ALLOW |  | Ran gh pr create; the new pull request is #557.
DECISION: GH_PR_EDIT | #557 | ALLOW |  | Ran gh pr edit on #557 to update the body.
DECISION: CONTROL_REFS_ONLY | #557 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #557
DECISION: URL | #558 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/558.
DECISION: PR_REF | #558 | ALLOW |  | Created PR #558 for the feature branch.
DECISION: GH_PR_CREATE | #558 | ALLOW |  | Ran gh pr create; the new pull request is #558.
DECISION: GH_PR_EDIT | #558 | ALLOW |  | Ran gh pr edit on #558 to update the body.
DECISION: CONTROL_REFS_ONLY | #558 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #558
DECISION: URL | #560 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/560.
DECISION: PR_REF | #560 | ALLOW |  | Created PR #560 for the feature branch.
DECISION: GH_PR_CREATE | #560 | ALLOW |  | Ran gh pr create; the new pull request is #560.
DECISION: GH_PR_EDIT | #560 | ALLOW |  | Ran gh pr edit on #560 to update the body.
DECISION: CONTROL_REFS_ONLY | #560 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #560
DECISION: URL | #563 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/563.
DECISION: PR_REF | #563 | ALLOW |  | Created PR #563 for the feature branch.
DECISION: GH_PR_CREATE | #563 | ALLOW |  | Ran gh pr create; the new pull request is #563.
DECISION: GH_PR_EDIT | #563 | ALLOW |  | Ran gh pr edit on #563 to update the body.
DECISION: CONTROL_REFS_ONLY | #563 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #563
DECISION: URL | #564 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/564.
DECISION: PR_REF | #564 | ALLOW |  | Created PR #564 for the feature branch.
DECISION: GH_PR_CREATE | #564 | ALLOW |  | Ran gh pr create; the new pull request is #564.
DECISION: GH_PR_EDIT | #564 | ALLOW |  | Ran gh pr edit on #564 to update the body.
DECISION: CONTROL_REFS_ONLY | #564 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #564
DECISION: URL | #569 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/569.
DECISION: PR_REF | #569 | ALLOW |  | Created PR #569 for the feature branch.
DECISION: GH_PR_CREATE | #569 | ALLOW |  | Ran gh pr create; the new pull request is #569.
DECISION: GH_PR_EDIT | #569 | ALLOW |  | Ran gh pr edit on #569 to update the body.
DECISION: CONTROL_REFS_ONLY | #569 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #569
DECISION: URL | #571 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/571.
DECISION: PR_REF | #571 | ALLOW |  | Created PR #571 for the feature branch.
DECISION: GH_PR_CREATE | #571 | ALLOW |  | Ran gh pr create; the new pull request is #571.
DECISION: GH_PR_EDIT | #571 | ALLOW |  | Ran gh pr edit on #571 to update the body.
DECISION: CONTROL_REFS_ONLY | #571 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #571
DECISION: URL | #572 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/572.
DECISION: PR_REF | #572 | ALLOW |  | Created PR #572 for the feature branch.
DECISION: GH_PR_CREATE | #572 | ALLOW |  | Ran gh pr create; the new pull request is #572.
DECISION: GH_PR_EDIT | #572 | ALLOW |  | Ran gh pr edit on #572 to update the body.
DECISION: CONTROL_REFS_ONLY | #572 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #572
DECISION: URL | #579 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/579.
DECISION: PR_REF | #579 | ALLOW |  | Created PR #579 for the feature branch.
DECISION: GH_PR_CREATE | #579 | ALLOW |  | Ran gh pr create; the new pull request is #579.
DECISION: GH_PR_EDIT | #579 | ALLOW |  | Ran gh pr edit on #579 to update the body.
DECISION: CONTROL_REFS_ONLY | #579 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #579
DECISION: URL | #580 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/580.
DECISION: PR_REF | #580 | ALLOW |  | Created PR #580 for the feature branch.
DECISION: GH_PR_CREATE | #580 | ALLOW |  | Ran gh pr create; the new pull request is #580.
DECISION: GH_PR_EDIT | #580 | ALLOW |  | Ran gh pr edit on #580 to update the body.
DECISION: CONTROL_REFS_ONLY | #580 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #580
DECISION: URL | #581 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/581.
DECISION: PR_REF | #581 | ALLOW |  | Created PR #581 for the feature branch.
DECISION: GH_PR_CREATE | #581 | ALLOW |  | Ran gh pr create; the new pull request is #581.
DECISION: GH_PR_EDIT | #581 | ALLOW |  | Ran gh pr edit on #581 to update the body.
DECISION: CONTROL_REFS_ONLY | #581 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #581
DECISION: URL | #582 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/582.
DECISION: PR_REF | #582 | ALLOW |  | Created PR #582 for the feature branch.
DECISION: GH_PR_CREATE | #582 | ALLOW |  | Ran gh pr create; the new pull request is #582.
DECISION: GH_PR_EDIT | #582 | ALLOW |  | Ran gh pr edit on #582 to update the body.
DECISION: CONTROL_REFS_ONLY | #582 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #582
DECISION: URL | #603 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/603.
DECISION: PR_REF | #603 | ALLOW |  | Created PR #603 for the feature branch.
DECISION: GH_PR_CREATE | #603 | ALLOW |  | Ran gh pr create; the new pull request is #603.
DECISION: GH_PR_EDIT | #603 | ALLOW |  | Ran gh pr edit on #603 to update the body.
DECISION: CONTROL_REFS_ONLY | #603 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #603
DECISION: URL | #604 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/604.
DECISION: PR_REF | #604 | ALLOW |  | Created PR #604 for the feature branch.
DECISION: GH_PR_CREATE | #604 | ALLOW |  | Ran gh pr create; the new pull request is #604.
DECISION: GH_PR_EDIT | #604 | ALLOW |  | Ran gh pr edit on #604 to update the body.
DECISION: CONTROL_REFS_ONLY | #604 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #604
DECISION: URL | #605 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/605.
DECISION: PR_REF | #605 | ALLOW |  | Created PR #605 for the feature branch.
DECISION: GH_PR_CREATE | #605 | ALLOW |  | Ran gh pr create; the new pull request is #605.
DECISION: GH_PR_EDIT | #605 | ALLOW |  | Ran gh pr edit on #605 to update the body.
DECISION: CONTROL_REFS_ONLY | #605 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #605
DECISION: URL | #607 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/607.
DECISION: PR_REF | #607 | ALLOW |  | Created PR #607 for the feature branch.
DECISION: GH_PR_CREATE | #607 | ALLOW |  | Ran gh pr create; the new pull request is #607.
DECISION: GH_PR_EDIT | #607 | ALLOW |  | Ran gh pr edit on #607 to update the body.
DECISION: CONTROL_REFS_ONLY | #607 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #607
DECISION: URL | #624 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/624.
DECISION: PR_REF | #624 | ALLOW |  | Created PR #624 for the feature branch.
DECISION: GH_PR_CREATE | #624 | ALLOW |  | Ran gh pr create; the new pull request is #624.
DECISION: GH_PR_EDIT | #624 | ALLOW |  | Ran gh pr edit on #624 to update the body.
DECISION: CONTROL_REFS_ONLY | #624 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #624
DECISION: URL | #638 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/638.
DECISION: PR_REF | #638 | ALLOW |  | Created PR #638 for the feature branch.
DECISION: GH_PR_CREATE | #638 | ALLOW |  | Ran gh pr create; the new pull request is #638.
DECISION: GH_PR_EDIT | #638 | ALLOW |  | Ran gh pr edit on #638 to update the body.
DECISION: CONTROL_REFS_ONLY | #638 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #638
DECISION: URL | #641 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/641.
DECISION: PR_REF | #641 | ALLOW |  | Created PR #641 for the feature branch.
DECISION: GH_PR_CREATE | #641 | ALLOW |  | Ran gh pr create; the new pull request is #641.
DECISION: GH_PR_EDIT | #641 | ALLOW |  | Ran gh pr edit on #641 to update the body.
DECISION: CONTROL_REFS_ONLY | #641 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #641
DECISION: URL | #642 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/642.
DECISION: PR_REF | #642 | ALLOW |  | Created PR #642 for the feature branch.
DECISION: GH_PR_CREATE | #642 | ALLOW |  | Ran gh pr create; the new pull request is #642.
DECISION: GH_PR_EDIT | #642 | ALLOW |  | Ran gh pr edit on #642 to update the body.
DECISION: CONTROL_REFS_ONLY | #642 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #642
DECISION: URL | #644 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/644.
DECISION: PR_REF | #644 | ALLOW |  | Created PR #644 for the feature branch.
DECISION: GH_PR_CREATE | #644 | ALLOW |  | Ran gh pr create; the new pull request is #644.
DECISION: GH_PR_EDIT | #644 | ALLOW |  | Ran gh pr edit on #644 to update the body.
DECISION: CONTROL_REFS_ONLY | #644 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #644
DECISION: URL | #650 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/650.
DECISION: PR_REF | #650 | ALLOW |  | Created PR #650 for the feature branch.
DECISION: GH_PR_CREATE | #650 | ALLOW |  | Ran gh pr create; the new pull request is #650.
DECISION: GH_PR_EDIT | #650 | ALLOW |  | Ran gh pr edit on #650 to update the body.
DECISION: CONTROL_REFS_ONLY | #650 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #650
DECISION: URL | #651 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/651.
DECISION: PR_REF | #651 | ALLOW |  | Created PR #651 for the feature branch.
DECISION: GH_PR_CREATE | #651 | ALLOW |  | Ran gh pr create; the new pull request is #651.
DECISION: GH_PR_EDIT | #651 | ALLOW |  | Ran gh pr edit on #651 to update the body.
DECISION: CONTROL_REFS_ONLY | #651 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #651
DECISION: URL | #652 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/652.
DECISION: PR_REF | #652 | ALLOW |  | Created PR #652 for the feature branch.
DECISION: GH_PR_CREATE | #652 | ALLOW |  | Ran gh pr create; the new pull request is #652.
DECISION: GH_PR_EDIT | #652 | ALLOW |  | Ran gh pr edit on #652 to update the body.
DECISION: CONTROL_REFS_ONLY | #652 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #652
DECISION: URL | #653 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/653.
DECISION: PR_REF | #653 | ALLOW |  | Created PR #653 for the feature branch.
DECISION: GH_PR_CREATE | #653 | ALLOW |  | Ran gh pr create; the new pull request is #653.
DECISION: GH_PR_EDIT | #653 | ALLOW |  | Ran gh pr edit on #653 to update the body.
DECISION: CONTROL_REFS_ONLY | #653 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #653
DECISION: URL | #654 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/654.
DECISION: PR_REF | #654 | ALLOW |  | Created PR #654 for the feature branch.
DECISION: GH_PR_CREATE | #654 | ALLOW |  | Ran gh pr create; the new pull request is #654.
DECISION: GH_PR_EDIT | #654 | ALLOW |  | Ran gh pr edit on #654 to update the body.
DECISION: CONTROL_REFS_ONLY | #654 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #654
DECISION: URL | #656 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/656.
DECISION: PR_REF | #656 | ALLOW |  | Created PR #656 for the feature branch.
DECISION: GH_PR_CREATE | #656 | ALLOW |  | Ran gh pr create; the new pull request is #656.
DECISION: GH_PR_EDIT | #656 | ALLOW |  | Ran gh pr edit on #656 to update the body.
DECISION: CONTROL_REFS_ONLY | #656 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #656
DECISION: URL | #681 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/681.
DECISION: PR_REF | #681 | ALLOW |  | Created PR #681 for the feature branch.
DECISION: GH_PR_CREATE | #681 | ALLOW |  | Ran gh pr create; the new pull request is #681.
DECISION: GH_PR_EDIT | #681 | ALLOW |  | Ran gh pr edit on #681 to update the body.
DECISION: CONTROL_REFS_ONLY | #681 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #681
DECISION: URL | #682 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/682.
DECISION: PR_REF | #682 | ALLOW |  | Created PR #682 for the feature branch.
DECISION: GH_PR_CREATE | #682 | ALLOW |  | Ran gh pr create; the new pull request is #682.
DECISION: GH_PR_EDIT | #682 | ALLOW |  | Ran gh pr edit on #682 to update the body.
DECISION: CONTROL_REFS_ONLY | #682 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #682
DECISION: URL | #683 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/683.
DECISION: PR_REF | #683 | ALLOW |  | Created PR #683 for the feature branch.
DECISION: GH_PR_CREATE | #683 | ALLOW |  | Ran gh pr create; the new pull request is #683.
DECISION: GH_PR_EDIT | #683 | ALLOW |  | Ran gh pr edit on #683 to update the body.
DECISION: CONTROL_REFS_ONLY | #683 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #683
DECISION: URL | #684 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/684.
DECISION: PR_REF | #684 | ALLOW |  | Created PR #684 for the feature branch.
DECISION: GH_PR_CREATE | #684 | ALLOW |  | Ran gh pr create; the new pull request is #684.
DECISION: GH_PR_EDIT | #684 | ALLOW |  | Ran gh pr edit on #684 to update the body.
DECISION: CONTROL_REFS_ONLY | #684 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #684
DECISION: URL | #685 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/685.
DECISION: PR_REF | #685 | ALLOW |  | Created PR #685 for the feature branch.
DECISION: GH_PR_CREATE | #685 | ALLOW |  | Ran gh pr create; the new pull request is #685.
DECISION: GH_PR_EDIT | #685 | ALLOW |  | Ran gh pr edit on #685 to update the body.
DECISION: CONTROL_REFS_ONLY | #685 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #685
DECISION: URL | #691 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/691.
DECISION: PR_REF | #691 | ALLOW |  | Created PR #691 for the feature branch.
DECISION: GH_PR_CREATE | #691 | ALLOW |  | Ran gh pr create; the new pull request is #691.
DECISION: GH_PR_EDIT | #691 | ALLOW |  | Ran gh pr edit on #691 to update the body.
DECISION: CONTROL_REFS_ONLY | #691 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #691
DECISION: URL | #698 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/698.
DECISION: PR_REF | #698 | ALLOW |  | Created PR #698 for the feature branch.
DECISION: GH_PR_CREATE | #698 | ALLOW |  | Ran gh pr create; the new pull request is #698.
DECISION: GH_PR_EDIT | #698 | ALLOW |  | Ran gh pr edit on #698 to update the body.
DECISION: CONTROL_REFS_ONLY | #698 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #698
DECISION: URL | #700 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/700.
DECISION: PR_REF | #700 | ALLOW |  | Created PR #700 for the feature branch.
DECISION: GH_PR_CREATE | #700 | ALLOW |  | Ran gh pr create; the new pull request is #700.
DECISION: GH_PR_EDIT | #700 | ALLOW |  | Ran gh pr edit on #700 to update the body.
DECISION: CONTROL_REFS_ONLY | #700 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #700
DECISION: URL | #701 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/701.
DECISION: PR_REF | #701 | ALLOW |  | Created PR #701 for the feature branch.
DECISION: GH_PR_CREATE | #701 | ALLOW |  | Ran gh pr create; the new pull request is #701.
DECISION: GH_PR_EDIT | #701 | ALLOW |  | Ran gh pr edit on #701 to update the body.
DECISION: CONTROL_REFS_ONLY | #701 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #701
DECISION: URL | #702 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/702.
DECISION: PR_REF | #702 | ALLOW |  | Created PR #702 for the feature branch.
DECISION: GH_PR_CREATE | #702 | ALLOW |  | Ran gh pr create; the new pull request is #702.
DECISION: GH_PR_EDIT | #702 | ALLOW |  | Ran gh pr edit on #702 to update the body.
DECISION: CONTROL_REFS_ONLY | #702 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #702
DECISION: URL | #703 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/703.
DECISION: PR_REF | #703 | ALLOW |  | Created PR #703 for the feature branch.
DECISION: GH_PR_CREATE | #703 | ALLOW |  | Ran gh pr create; the new pull request is #703.
DECISION: GH_PR_EDIT | #703 | ALLOW |  | Ran gh pr edit on #703 to update the body.
DECISION: CONTROL_REFS_ONLY | #703 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #703
DECISION: URL | #704 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/704.
DECISION: PR_REF | #704 | ALLOW |  | Created PR #704 for the feature branch.
DECISION: GH_PR_CREATE | #704 | ALLOW |  | Ran gh pr create; the new pull request is #704.
DECISION: GH_PR_EDIT | #704 | ALLOW |  | Ran gh pr edit on #704 to update the body.
DECISION: CONTROL_REFS_ONLY | #704 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #704
DECISION: URL | #705 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/705.
DECISION: PR_REF | #705 | ALLOW |  | Created PR #705 for the feature branch.
DECISION: GH_PR_CREATE | #705 | ALLOW |  | Ran gh pr create; the new pull request is #705.
DECISION: GH_PR_EDIT | #705 | ALLOW |  | Ran gh pr edit on #705 to update the body.
DECISION: CONTROL_REFS_ONLY | #705 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #705
DECISION: URL | #718 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/718.
DECISION: PR_REF | #718 | ALLOW |  | Created PR #718 for the feature branch.
DECISION: GH_PR_CREATE | #718 | ALLOW |  | Ran gh pr create; the new pull request is #718.
DECISION: GH_PR_EDIT | #718 | ALLOW |  | Ran gh pr edit on #718 to update the body.
DECISION: CONTROL_REFS_ONLY | #718 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #718
DECISION: URL | #719 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/719.
DECISION: PR_REF | #719 | ALLOW |  | Created PR #719 for the feature branch.
DECISION: GH_PR_CREATE | #719 | ALLOW |  | Ran gh pr create; the new pull request is #719.
DECISION: GH_PR_EDIT | #719 | ALLOW |  | Ran gh pr edit on #719 to update the body.
DECISION: CONTROL_REFS_ONLY | #719 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #719
DECISION: URL | #720 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/720.
DECISION: PR_REF | #720 | ALLOW |  | Created PR #720 for the feature branch.
DECISION: GH_PR_CREATE | #720 | ALLOW |  | Ran gh pr create; the new pull request is #720.
DECISION: GH_PR_EDIT | #720 | ALLOW |  | Ran gh pr edit on #720 to update the body.
DECISION: CONTROL_REFS_ONLY | #720 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #720
DECISION: URL | #721 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/721.
DECISION: PR_REF | #721 | ALLOW |  | Created PR #721 for the feature branch.
DECISION: GH_PR_CREATE | #721 | ALLOW |  | Ran gh pr create; the new pull request is #721.
DECISION: GH_PR_EDIT | #721 | ALLOW |  | Ran gh pr edit on #721 to update the body.
DECISION: CONTROL_REFS_ONLY | #721 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #721
DECISION: URL | #725 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/725.
DECISION: PR_REF | #725 | ALLOW |  | Created PR #725 for the feature branch.
DECISION: GH_PR_CREATE | #725 | ALLOW |  | Ran gh pr create; the new pull request is #725.
DECISION: GH_PR_EDIT | #725 | ALLOW |  | Ran gh pr edit on #725 to update the body.
DECISION: CONTROL_REFS_ONLY | #725 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #725
DECISION: URL | #726 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/726.
DECISION: PR_REF | #726 | ALLOW |  | Created PR #726 for the feature branch.
DECISION: GH_PR_CREATE | #726 | ALLOW |  | Ran gh pr create; the new pull request is #726.
DECISION: GH_PR_EDIT | #726 | ALLOW |  | Ran gh pr edit on #726 to update the body.
DECISION: CONTROL_REFS_ONLY | #726 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #726
DECISION: URL | #727 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/727.
DECISION: PR_REF | #727 | ALLOW |  | Created PR #727 for the feature branch.
DECISION: GH_PR_CREATE | #727 | ALLOW |  | Ran gh pr create; the new pull request is #727.
DECISION: GH_PR_EDIT | #727 | ALLOW |  | Ran gh pr edit on #727 to update the body.
DECISION: CONTROL_REFS_ONLY | #727 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #727
DECISION: URL | #728 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/728.
DECISION: PR_REF | #728 | ALLOW |  | Created PR #728 for the feature branch.
DECISION: GH_PR_CREATE | #728 | ALLOW |  | Ran gh pr create; the new pull request is #728.
DECISION: GH_PR_EDIT | #728 | ALLOW |  | Ran gh pr edit on #728 to update the body.
DECISION: CONTROL_REFS_ONLY | #728 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #728
DECISION: URL | #729 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/729.
DECISION: PR_REF | #729 | ALLOW |  | Created PR #729 for the feature branch.
DECISION: GH_PR_CREATE | #729 | ALLOW |  | Ran gh pr create; the new pull request is #729.
DECISION: GH_PR_EDIT | #729 | ALLOW |  | Ran gh pr edit on #729 to update the body.
DECISION: CONTROL_REFS_ONLY | #729 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #729
DECISION: URL | #730 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/730.
DECISION: PR_REF | #730 | ALLOW |  | Created PR #730 for the feature branch.
DECISION: GH_PR_CREATE | #730 | ALLOW |  | Ran gh pr create; the new pull request is #730.
DECISION: GH_PR_EDIT | #730 | ALLOW |  | Ran gh pr edit on #730 to update the body.
DECISION: CONTROL_REFS_ONLY | #730 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #730
DECISION: URL | #731 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/731.
DECISION: PR_REF | #731 | ALLOW |  | Created PR #731 for the feature branch.
DECISION: GH_PR_CREATE | #731 | ALLOW |  | Ran gh pr create; the new pull request is #731.
DECISION: GH_PR_EDIT | #731 | ALLOW |  | Ran gh pr edit on #731 to update the body.
DECISION: CONTROL_REFS_ONLY | #731 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #731
DECISION: URL | #747 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/747.
DECISION: PR_REF | #747 | ALLOW |  | Created PR #747 for the feature branch.
DECISION: GH_PR_CREATE | #747 | ALLOW |  | Ran gh pr create; the new pull request is #747.
DECISION: GH_PR_EDIT | #747 | ALLOW |  | Ran gh pr edit on #747 to update the body.
DECISION: CONTROL_REFS_ONLY | #747 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #747
DECISION: URL | #748 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/748.
DECISION: PR_REF | #748 | ALLOW |  | Created PR #748 for the feature branch.
DECISION: GH_PR_CREATE | #748 | ALLOW |  | Ran gh pr create; the new pull request is #748.
DECISION: GH_PR_EDIT | #748 | ALLOW |  | Ran gh pr edit on #748 to update the body.
DECISION: CONTROL_REFS_ONLY | #748 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #748
DECISION: URL | #777 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/777.
DECISION: PR_REF | #777 | ALLOW |  | Created PR #777 for the feature branch.
DECISION: GH_PR_CREATE | #777 | ALLOW |  | Ran gh pr create; the new pull request is #777.
DECISION: GH_PR_EDIT | #777 | ALLOW |  | Ran gh pr edit on #777 to update the body.
DECISION: CONTROL_REFS_ONLY | #777 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #777
DECISION: URL | #778 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/778.
DECISION: PR_REF | #778 | ALLOW |  | Created PR #778 for the feature branch.
DECISION: GH_PR_CREATE | #778 | ALLOW |  | Ran gh pr create; the new pull request is #778.
DECISION: GH_PR_EDIT | #778 | ALLOW |  | Ran gh pr edit on #778 to update the body.
DECISION: CONTROL_REFS_ONLY | #778 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #778
DECISION: URL | #779 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/779.
DECISION: PR_REF | #779 | ALLOW |  | Created PR #779 for the feature branch.
DECISION: GH_PR_CREATE | #779 | ALLOW |  | Ran gh pr create; the new pull request is #779.
DECISION: GH_PR_EDIT | #779 | ALLOW |  | Ran gh pr edit on #779 to update the body.
DECISION: CONTROL_REFS_ONLY | #779 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #779
DECISION: URL | #782 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/782.
DECISION: PR_REF | #782 | ALLOW |  | Created PR #782 for the feature branch.
DECISION: GH_PR_CREATE | #782 | ALLOW |  | Ran gh pr create; the new pull request is #782.
DECISION: GH_PR_EDIT | #782 | ALLOW |  | Ran gh pr edit on #782 to update the body.
DECISION: CONTROL_REFS_ONLY | #782 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #782
DECISION: URL | #800 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/800.
DECISION: PR_REF | #800 | ALLOW |  | Created PR #800 for the feature branch.
DECISION: GH_PR_CREATE | #800 | ALLOW |  | Ran gh pr create; the new pull request is #800.
DECISION: GH_PR_EDIT | #800 | ALLOW |  | Ran gh pr edit on #800 to update the body.
DECISION: CONTROL_REFS_ONLY | #800 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #800
DECISION: URL | #801 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/801.
DECISION: PR_REF | #801 | ALLOW |  | Created PR #801 for the feature branch.
DECISION: GH_PR_CREATE | #801 | ALLOW |  | Ran gh pr create; the new pull request is #801.
DECISION: GH_PR_EDIT | #801 | ALLOW |  | Ran gh pr edit on #801 to update the body.
DECISION: CONTROL_REFS_ONLY | #801 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #801
DECISION: URL | #808 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/808.
DECISION: PR_REF | #808 | ALLOW |  | Created PR #808 for the feature branch.
DECISION: GH_PR_CREATE | #808 | ALLOW |  | Ran gh pr create; the new pull request is #808.
DECISION: GH_PR_EDIT | #808 | ALLOW |  | Ran gh pr edit on #808 to update the body.
DECISION: CONTROL_REFS_ONLY | #808 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #808
DECISION: URL | #809 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/809.
DECISION: PR_REF | #809 | ALLOW |  | Created PR #809 for the feature branch.
DECISION: GH_PR_CREATE | #809 | ALLOW |  | Ran gh pr create; the new pull request is #809.
DECISION: GH_PR_EDIT | #809 | ALLOW |  | Ran gh pr edit on #809 to update the body.
DECISION: CONTROL_REFS_ONLY | #809 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #809
DECISION: URL | #811 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/811.
DECISION: PR_REF | #811 | ALLOW |  | Created PR #811 for the feature branch.
DECISION: GH_PR_CREATE | #811 | ALLOW |  | Ran gh pr create; the new pull request is #811.
DECISION: GH_PR_EDIT | #811 | ALLOW |  | Ran gh pr edit on #811 to update the body.
DECISION: CONTROL_REFS_ONLY | #811 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #811
DECISION: URL | #817 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/817.
DECISION: PR_REF | #817 | ALLOW |  | Created PR #817 for the feature branch.
DECISION: GH_PR_CREATE | #817 | ALLOW |  | Ran gh pr create; the new pull request is #817.
DECISION: GH_PR_EDIT | #817 | ALLOW |  | Ran gh pr edit on #817 to update the body.
DECISION: CONTROL_REFS_ONLY | #817 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #817
DECISION: URL | #831 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/831.
DECISION: PR_REF | #831 | ALLOW |  | Created PR #831 for the feature branch.
DECISION: GH_PR_CREATE | #831 | ALLOW |  | Ran gh pr create; the new pull request is #831.
DECISION: GH_PR_EDIT | #831 | ALLOW |  | Ran gh pr edit on #831 to update the body.
DECISION: CONTROL_REFS_ONLY | #831 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #831
DECISION: URL | #853 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/853.
DECISION: PR_REF | #853 | ALLOW |  | Created PR #853 for the feature branch.
DECISION: GH_PR_CREATE | #853 | ALLOW |  | Ran gh pr create; the new pull request is #853.
DECISION: GH_PR_EDIT | #853 | ALLOW |  | Ran gh pr edit on #853 to update the body.
DECISION: CONTROL_REFS_ONLY | #853 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #853
DECISION: URL | #854 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/854.
DECISION: PR_REF | #854 | ALLOW |  | Created PR #854 for the feature branch.
DECISION: GH_PR_CREATE | #854 | ALLOW |  | Ran gh pr create; the new pull request is #854.
DECISION: GH_PR_EDIT | #854 | ALLOW |  | Ran gh pr edit on #854 to update the body.
DECISION: CONTROL_REFS_ONLY | #854 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #854
DECISION: URL | #855 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/855.
DECISION: PR_REF | #855 | ALLOW |  | Created PR #855 for the feature branch.
DECISION: GH_PR_CREATE | #855 | ALLOW |  | Ran gh pr create; the new pull request is #855.
DECISION: GH_PR_EDIT | #855 | ALLOW |  | Ran gh pr edit on #855 to update the body.
DECISION: CONTROL_REFS_ONLY | #855 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #855
DECISION: URL | #856 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/856.
DECISION: PR_REF | #856 | ALLOW |  | Created PR #856 for the feature branch.
DECISION: GH_PR_CREATE | #856 | ALLOW |  | Ran gh pr create; the new pull request is #856.
DECISION: GH_PR_EDIT | #856 | ALLOW |  | Ran gh pr edit on #856 to update the body.
DECISION: CONTROL_REFS_ONLY | #856 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #856
DECISION: URL | #857 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/857.
DECISION: PR_REF | #857 | ALLOW |  | Created PR #857 for the feature branch.
DECISION: GH_PR_CREATE | #857 | ALLOW |  | Ran gh pr create; the new pull request is #857.
DECISION: GH_PR_EDIT | #857 | ALLOW |  | Ran gh pr edit on #857 to update the body.
DECISION: CONTROL_REFS_ONLY | #857 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #857
DECISION: URL | #858 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/858.
DECISION: PR_REF | #858 | ALLOW |  | Created PR #858 for the feature branch.
DECISION: GH_PR_CREATE | #858 | ALLOW |  | Ran gh pr create; the new pull request is #858.
DECISION: GH_PR_EDIT | #858 | ALLOW |  | Ran gh pr edit on #858 to update the body.
DECISION: CONTROL_REFS_ONLY | #858 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #858
DECISION: URL | #859 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/859.
DECISION: PR_REF | #859 | ALLOW |  | Created PR #859 for the feature branch.
DECISION: GH_PR_CREATE | #859 | ALLOW |  | Ran gh pr create; the new pull request is #859.
DECISION: GH_PR_EDIT | #859 | ALLOW |  | Ran gh pr edit on #859 to update the body.
DECISION: CONTROL_REFS_ONLY | #859 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #859
DECISION: URL | #862 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/862.
DECISION: PR_REF | #862 | ALLOW |  | Created PR #862 for the feature branch.
DECISION: GH_PR_CREATE | #862 | ALLOW |  | Ran gh pr create; the new pull request is #862.
DECISION: GH_PR_EDIT | #862 | ALLOW |  | Ran gh pr edit on #862 to update the body.
DECISION: CONTROL_REFS_ONLY | #862 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #862
DECISION: URL | #863 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/863.
DECISION: PR_REF | #863 | ALLOW |  | Created PR #863 for the feature branch.
DECISION: GH_PR_CREATE | #863 | ALLOW |  | Ran gh pr create; the new pull request is #863.
DECISION: GH_PR_EDIT | #863 | ALLOW |  | Ran gh pr edit on #863 to update the body.
DECISION: CONTROL_REFS_ONLY | #863 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #863
DECISION: URL | #871 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/871.
DECISION: PR_REF | #871 | ALLOW |  | Created PR #871 for the feature branch.
DECISION: GH_PR_CREATE | #871 | ALLOW |  | Ran gh pr create; the new pull request is #871.
DECISION: GH_PR_EDIT | #871 | ALLOW |  | Ran gh pr edit on #871 to update the body.
DECISION: CONTROL_REFS_ONLY | #871 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #871
DECISION: URL | #881 | ALLOW |  | Opened the pull request at https://github.com/drmoisan/drm-copilot/pull/881.
DECISION: PR_REF | #881 | ALLOW |  | Created PR #881 for the feature branch.
DECISION: GH_PR_CREATE | #881 | ALLOW |  | Ran gh pr create; the new pull request is #881.
DECISION: GH_PR_EDIT | #881 | ALLOW |  | Ran gh pr edit on #881 to update the body.
DECISION: CONTROL_REFS_ONLY | #881 | BLOCK | PR_AUTHOR_OUTPUT_NO_PR: the pr-author last assistant message does not reference a PR URL or PR number; it must report the created or updated pull request. | Refs #881
CONTROL-BLOCKS: 124
CONTROL-ALLOWS: 0
FALSE-POSITIVES: 0
```

AFTER-FALSE-POSITIVES: 0
