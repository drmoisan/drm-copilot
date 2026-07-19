# Phase 2 — Link-Resolution Recheck, consumer-onboarding.md Only (Remediation Cycle 1)

Timestamp: 2026-07-19T08-06
Command: grep -n "](" docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md
EXIT_CODE: 0

Output Summary:

5 link occurrences in the corrected file (was 6 before the Phase 1 edit, per
`git show HEAD:docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md | grep -n
"]("`):

| Link target | Occurrences before | Occurrences after |
|---|---|---|
| `README.md#domain-neutrality-invariant` | 1 | 1 |
| `running-the-workflow.md` | 3 | 2 |
| `domain-profile.md` | 1 | 1 |
| `workflow.md` | 1 | 1 |

The Phase 1 rewrite of item 2 (P1-T1) removed the retired sentence "the same package that
exposes the MCP tools in [`running-the-workflow.md`](running-the-workflow.md)" (the original
claim linked to `running-the-workflow.md` while asserting the retired npm-package delivery
mechanism); the corrected item 2 no longer references `running-the-workflow.md` because it
no longer discusses the MCP-server npm package's tool surface at all. This accounts for the
one-occurrence reduction. No new link target was introduced by the Phase 1 edit: the
resulting target set (`README.md#domain-neutrality-invariant`, `running-the-workflow.md`,
`domain-profile.md`, `workflow.md`) is an unchanged subset of the original target set, and
all four targets are cross-checked against the original inventory
(`evidence/qa-gates/link-resolution.2026-07-19T07-14.md`), which confirmed each resolves to
a file present in `docs/engineering/legacy-discovery-and-parity/`. The link set for
`consumer-onboarding.md` is otherwise unchanged from the original inventory; the sole
change is a same-target-set occurrence-count reduction from 6 to 5, caused by removing a
now-inaccurate reference embedded in the retired claim, not by adding a new target.