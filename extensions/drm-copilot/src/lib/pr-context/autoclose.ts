/**
 * Autoclose derivation for the PR context collector.
 *
 * Purpose:
 *     Port of `dev_tools/pr_context/autoclose.py` plus the two close-candidate
 *     and autoclose section builders of `render_pr_helpers.py`. Issue #622
 *     gathers these rules in one module:
 *     - D2: prose citations are mentions only; author auto-close lists the
 *       author's own assertions.
 *     - D3: a closing target is verified from GitHub PR metadata, or is the
 *       deterministic pending primary when GitHub reports it as an open issue.
 *     - D4: with GitHub unavailable and a non-empty list, the list is kept and
 *       an unverified annotation line is appended.
 *     - D5: a pending primary that is not an open issue is never printed; a
 *       dedicated fallback line is rendered instead.
 *     - D7: the builders moved here from `render-pr-helpers.ts` (which
 *       re-exports them) so each file stays under the 500-line cap.
 *     - D8: references are defensively prefixed with `#`.
 *
 * Responsibilities:
 *     - `classifyReferences`, `selectPendingPrimary`.
 *     - `buildCloseCandidatesSection`, `buildIssuesToAutocloseSection`.
 */

import {
  compareCodePoint,
  AUTOCLOSE_PENDING_NOT_OPEN_TEXT,
  AUTOCLOSE_UNVERIFIED_ANNOTATION,
  type IssueDetails,
  formatList,
  normalizeReference,
  section,
} from "./models";
import { type GhClient } from "./gh-client-core";

/** Options for the reference-classification loop. */
export interface ClassifyReferencesOptions {
  gh: Pick<GhClient, "classifyEntity">;
  ghAvailable: boolean;
  featureIssueRefs: string[];
  branchRefs: string[];
  pathRefs: string[];
  referencedIssuesSet: Set<string>;
  referencedPrsSet: Set<string>;
  invalidRefsSet: Set<string>;
}

/**
 * Classify feature/branch/path references into the issue/PR/invalid sets.
 *
 * Mirrors Python `classify_references`: when gh is available, classify each
 * feature ref and each branch/path ref via `classifyEntity`; otherwise add all
 * feature, branch, and path refs to the issue set.
 *
 * @param options Classification inputs and the mutable target sets.
 */
export function classifyReferences(options: ClassifyReferencesOptions): void {
  const {
    gh,
    ghAvailable,
    featureIssueRefs,
    branchRefs,
    pathRefs,
    referencedIssuesSet,
    referencedPrsSet,
    invalidRefsSet,
  } = options;

  if (ghAvailable) {
    // Classify the feature refs first, then the combined branch/path refs.
    for (const ref of featureIssueRefs) {
      classifyOne(
        gh,
        ref,
        referencedIssuesSet,
        referencedPrsSet,
        invalidRefsSet,
      );
    }
    for (const ref of [...branchRefs, ...pathRefs]) {
      classifyOne(
        gh,
        ref,
        referencedIssuesSet,
        referencedPrsSet,
        invalidRefsSet,
      );
    }
  } else {
    // gh unavailable: every ref is treated as an (unverified) issue.
    for (const ref of featureIssueRefs) {
      referencedIssuesSet.add(formatRef(ref));
    }
    for (const ref of [...branchRefs, ...pathRefs]) {
      referencedIssuesSet.add(formatRef(ref));
    }
  }
}

/** Classify a single reference into the appropriate set. */
function classifyOne(
  gh: Pick<GhClient, "classifyEntity">,
  ref: string,
  issuesSet: Set<string>,
  prsSet: Set<string>,
  invalidSet: Set<string>,
): void {
  const formatted = formatRef(ref);
  const entity = gh.classifyEntity(ref.replace(/^#+/u, ""));
  // Route by the GitHub entity type; anything else is not a valid ref.
  if (entity === "issue") {
    issuesSet.add(formatted);
  } else if (entity === "pull") {
    prsSet.add(formatted);
  } else {
    invalidSet.add(formatted);
  }
}

/** Prefix a reference with `#` when not already present (D8). */
function formatRef(ref: string): string {
  return ref.startsWith("#") ? ref : `#${ref}`;
}

/** Outcome of verifying the deterministic pending primary refs. */
export interface PendingPrimarySelection {
  /** Pending refs that remain eligible for the autoclose section. */
  readonly kept: string[];
  /** True when at least one pending ref was dropped. */
  readonly excluded: boolean;
  /**
   * Issue details for every ref whose details were fetched, kept or excluded,
   * keyed by the ref as given, so callers can reuse them instead of fetching
   * the same issue a second time.
   */
  readonly fetchedDetails: ReadonlyMap<string, IssueDetails>;
}

/**
 * Keep only the pending primary refs that GitHub reports as open issues.
 *
 * Mirrors Python `select_pending_primary`. With gh unavailable every ref is
 * kept and nothing is fetched. Otherwise a ref that does not classify as an
 * issue is excluded without a fetch; an issue is fetched once and kept only
 * when its state is open (case-insensitive).
 *
 * @param options The gh client, availability flag, and pending refs.
 * @returns The kept refs, the exclusion flag, and the fetched details.
 */
export function selectPendingPrimary(options: {
  gh: Pick<GhClient, "classifyEntity" | "issueDetails">;
  ghAvailable: boolean;
  pendingPrimary: readonly string[];
}): PendingPrimarySelection {
  const { gh, ghAvailable, pendingPrimary } = options;
  if (!ghAvailable) {
    // Nothing can be verified; keep every ref and let the builder append the
    // unverified annotation (D4).
    return {
      kept: [...pendingPrimary],
      excluded: false,
      fetchedDetails: new Map(),
    };
  }
  const kept: string[] = [];
  const fetchedDetails = new Map<string, IssueDetails>();
  let excluded = false;
  for (const ref of pendingPrimary) {
    const numberRef = normalizeReference(ref);
    // A pull request or an unknown number is never a closing target, and its
    // details are not fetched.
    if (gh.classifyEntity(numberRef) !== "issue") {
      excluded = true;
      continue;
    }
    const details = gh.issueDetails(numberRef);
    fetchedDetails.set(ref, details);
    // Only an open issue can be closed by the PR; any other state, including
    // an unknown one, excludes the ref.
    if (details.state.toLowerCase() === "open") {
      kept.push(ref);
    } else {
      excluded = true;
    }
  }
  return { kept, excluded, fetchedDetails };
}

/**
 * Render the close-candidate section grouped by verification source.
 *
 * Mirrors Python `build_close_candidates_section`. Under D2, author auto-close
 * lists `authorAsserted` alone, and referenced issues that are neither
 * verified nor author-asserted are listed as detected only.
 *
 * @param params Verified/author-asserted/referenced refs and reason strings.
 * @returns The formatted close-candidates section.
 */
export function buildCloseCandidatesSection(params: {
  verified: string[];
  authorAsserted: string[];
  referenced: string[];
  verifiedReason: string;
  authorReason: string;
}): string {
  const { verified, authorAsserted, referenced, verifiedReason, authorReason } =
    params;
  // D2: prose citations are mentions only, so they never join author
  // auto-close; they stay in the detected list unless already a closing ref.
  const authorAutoClose = [...new Set(authorAsserted)].sort(compareCodePoint);
  const closing = new Set([...verified, ...authorAsserted]);
  const referencedOnly = [...new Set(referenced)]
    .filter((ref) => !closing.has(ref))
    .sort(compareCodePoint);

  return [
    section("Close candidates"),
    "Auto-close issues (verified from GitHub PR metadata):",
    formatList(verified, verifiedReason),
    "",
    "Auto-close issues (author asserted):",
    formatList(authorAutoClose, authorReason),
    "",
    "Referenced issues (detected):",
    formatList(referencedOnly, "(none)"),
  ].join("\n");
}

/**
 * Render the approved autoclose section from verified and pending refs.
 *
 * Mirrors Python `build_issues_to_autoclose_section`: verified first, then
 * pending deterministic refs not already verified. A non-empty list is
 * followed by the unverified annotation when gh is unavailable (D4). An empty
 * list renders the not-open text when a pending primary was excluded (D5),
 * otherwise the PASS vs non-PASS conservative fallback text.
 * When gh is unavailable, an empty list renders the GitHub-CLI-unavailable
 * text ahead of every empty-list fallback (issue #588).
 *
 * @param params Verified/pending refs and observed readiness signals, plus
 *     `ghAvailable` (optional, default `true`; when `false` a non-empty list
 *     is annotated as unverified, D10) and `pendingPrimaryExcluded` (optional,
 *     default `false`; when `true` an empty list reports the excluded pending
 *     primary).
 * @returns The formatted autoclose section.
 */
export function buildIssuesToAutocloseSection(params: {
  verified: string[];
  pendingPrimary: string[];
  readinessSignals: string[];
  ghAvailable?: boolean;
  pendingPrimaryExcluded?: boolean;
}): string {
  const {
    verified,
    pendingPrimary,
    readinessSignals,
    ghAvailable = true,
    pendingPrimaryExcluded = false,
  } = params;
  // Verified issues first, then pending deterministic issues not yet verified.
  const ordered: string[] = [];
  for (const issue of [...verified, ...pendingPrimary]) {
    if (issue && !ordered.includes(issue)) {
      ordered.push(issue);
    }
  }

  // Precedence: a non-empty list always renders (annotated when unverified);
  // an empty list reports an excluded pending primary first, because that is
  // the most specific reason, then the readiness-based fallbacks.
  let body: string;
  if (ordered.length > 0) {
    body = formatList(ordered, "(none)");
    if (!ghAvailable) {
      body = `${body}\n${AUTOCLOSE_UNVERIFIED_ANNOTATION}`;
    }
  } else if (!ghAvailable) {
    // Unavailable text takes precedence: the absence claims below are only
    // meaningful when verification ran (issue #588).
    body = "None (GitHub CLI unavailable; closing issues not verified)";
  } else if (pendingPrimaryExcluded) {
    body = AUTOCLOSE_PENDING_NOT_OPEN_TEXT;
  } else if (readinessSignals.some((signal) => signal === "PASS")) {
    body =
      "None (no verified closing issues and no deterministic pending issue)";
  } else {
    body = "None (no verified closing issues and readiness not PASS)";
  }

  return [section("Issues to autoclose (verified or pending)"), body].join(
    "\n",
  );
}
