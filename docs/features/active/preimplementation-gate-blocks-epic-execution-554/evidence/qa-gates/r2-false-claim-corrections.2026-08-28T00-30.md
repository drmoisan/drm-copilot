# Remediation Cycle 2 — Verification of the Three False-Claim Corrections (B5 component 2)

Timestamp: 2026-08-28T02-12
Task: [P3-T8]
Command: `git show HEAD:<path>` piped to a byte-count-driven `head -c` prefix extraction and `cmp` against the post-append file, for each of the two appended artifacts; plus `git diff --stat 9fed8b9074354ac91b35dc6756fcf4935cfc1c89 -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` for the in-place rewrite; plus `sed`/`grep` quotation of each corrected statement as it now stands
EXIT_CODE: 0

All three locations previously asserted that Codex lines 197 and 206 were uncovered at the merge
base. All three are corrected. **None of the three still asserts that claim unqualified.**

---

## Location 1 — `policy-audit.2026-08-27T22-47.md`

- **Correction method applied:** appended, clearly-marked, dated correction notice. The original
  text is left byte-untouched.
- **Task that applied it:** **[P2-T1]**.
- **Why this method:** this is a superseded evidence artifact. Rewriting it would erase what the
  cycle-1 reviewer believed and when, which is the audit information a review record exists to
  preserve.

**Quotation of the corrected statement as it now stands:**

> **Corrected.** Lines 197 and 206 of
> `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` were COVERED at the merge base
> `1e991b86`. Merge-base line 213, inside `Test-ImplementationDelegation`, called
> `Test-PreparationModeDelegation`, and merge-base
> `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` reached both the
> non-`orchestrator` return and the all-conjuncts return through that call site. This branch removed
> the call site, orphaning the function on both surfaces, and the two lines lost coverage as a direct
> consequence. **The corrected derived Codex baseline is 120 of 120 pre-existing measurable lines
> covered.**

The notice names the two incorrect sites explicitly — line 173 and the derived-baseline figure at
line 181 — so every prior assertion in the file is now qualified by a dated correction in the same
file.

**Byte-untouchedness, verified by the count-free prefix comparison:** the prior text read from
`git show HEAD:docs/features/active/preimplementation-gate-blocks-epic-execution-554/policy-audit.2026-08-27T22-47.md`
is **20856 bytes**; the post-append file is **22759 bytes**; the first 20856 bytes of the post-append
file are **byte-identical** to the prior text (`cmp` reported no difference). The remainder of
**1903 bytes** consists solely of one blank line followed by the appended block. The comparison names
no line number, so it covers every line of the prior artifact — including its mirror-pair hashes, its
N2 accepted-shipping-exception statement, and its policy-reading-order footer.

---

## Location 2 — `evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md`

- **Correction method applied:** appended, clearly-marked, dated correction notice. The original
  text is left byte-untouched.
- **Task that applied it:** **[P2-T2]**.
- **Why this method:** same reasoning, and this artifact is additionally the auditable justification
  for an acceptance-criterion check-off, so the sequence of belief and correction is load-bearing.

**Quotation of the corrected statement as it now stands:**

> **Corrected.** Both lines were COVERED at the merge base `1e991b86`. Merge-base line 213, inside
> `Test-ImplementationDelegation`, called `Test-PreparationModeDelegation`, and merge-base
> `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` reached both the
> non-`orchestrator` return and the all-conjuncts return through that call site. This branch removed
> the call site, orphaning the function on both surfaces, and the two lines lost coverage. The
> corrected derived Codex baseline is 120 of 120 pre-existing measurable lines covered.

The notice explicitly upholds the artifact's verdict: **the acceptance criterion's check-off is
unchanged and the checkbox stays checked**, because the criterion is scoped to *changed* lines and
neither 197 nor 206 is a changed line. Arguments 1 and 2 of the corrected section are accepted in
full; only the second half of the third argument is withdrawn.

**Byte-untouchedness, verified by the same count-free prefix comparison:** the prior text is
**7915 bytes**; the post-append file is **9984 bytes**; the first 7915 bytes are **byte-identical**
to the prior text (`cmp` reported no difference). The remainder of **2069 bytes** consists solely of
one blank line followed by the appended block. The artifact's original `Timestamp:`, `Command:`, and
`EXIT_CODE:` fields remain the **first occurrences** of those field labels, at lines 3, 6, and 7, so
the artifact schema still parses.

---

## Location 3 — `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`

- **Correction method applied:** **in-place rewrite** of the comment block, seven lines replaced by
  twelve.
- **Task that applied it:** **[P2-T3]**.
- **Why this method:** the site is live source, not an evidence artifact. A source comment has no
  audit-trail function and its only obligation is to be true for a reader of the current file.
  Appending a contradicting notice below a false comment would leave the false statement standing in
  the file. **The git history preserves the superseded text**, which is recoverable at any time with
  `git show 9fed8b9074354ac91b35dc6756fcf4935cfc1c89:tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`.

**Quotation of the corrected statement as it now stands:**

```powershell
# Finding R2. Test-PreparationModeDelegation lost its only production call site
# when this branch replaced Test-ImplementationDelegation, so its body became
# uncovered on BOTH surfaces. The Codex copy kept only PARTIAL coverage from
# tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1: its two
# surviving direct callers reach the null branch and the marker-loop return,
# but neither the non-orchestrator return nor the all-conjuncts return, both of
# which were covered at the merge base through the removed call site. That
# residual is cycle-2 finding B5 and is closed by the two cases in
# tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1.
# The function is deliberately retained: spec.md lists it under "Not modified",
# and removing it would break that passing Codex legacy-contract test. These
# four cases restore coverage of all three conjuncts.
```

The phrase asserting that the Codex copy kept coverage without qualification is gone: a fixed-string
search for `the Codex copy kept coverage from` returns **0** matches in the file. The replacement
block contains the word `PARTIAL`. The file's `It` count is unchanged at **7**.

**Scope of the edit:** `git diff --stat` against the pre-cycle head `9fed8b90` reports
`1 file changed, 10 insertions(+), 5 deletions(-)` — a single 15-line hunk. No line outside the
replaced block differs.

---

## Summary of methods

| Location | Method | Task | Original text preserved by |
| --- | --- | --- | --- |
| `policy-audit.2026-08-27T22-47.md` | appended notice | [P2-T1] | the file itself, byte-untouched (prefix comparison) |
| `evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md` | appended notice | [P2-T2] | the file itself, byte-untouched (prefix comparison) |
| `tests/scripts/claude-hooks/…-classifier.Tests.ps1` | in-place rewrite | [P2-T3] | git history |

**The two evidence artifacts retain their original text byte-for-byte with the correction appended.**
**The source comment was rewritten in place, with the git history preserving the superseded text.**

Output Summary: All three false-claim locations are corrected. The two evidence artifacts each pass a
count-free byte-exact prefix comparison against their `git show HEAD:` text (20856 of 22759 bytes and
7915 of 9984 bytes respectively), confirming their prior text is byte-untouched with only the
appended block added. The source comment was rewritten in place within a single 15-line hunk, the
false phrase returns 0 matches, `PARTIAL` is present, and the `It` count is unchanged at 7.
EXIT_CODE 0.
