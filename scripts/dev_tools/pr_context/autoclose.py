"""Reference classification and pending-primary selection for autoclose output.

Issue #622 moved these rules out of the collector so they can be tested without
running a full collection:

- D3: a closing target is either verified from GitHub PR metadata or the
  feature's deterministic pending primary, and the pending primary is kept only
  when GitHub reports it as an open issue.
- D5: a pending primary that is not an open issue is dropped and never printed;
  the caller renders a dedicated fallback line instead.
- D7: the logic lives in its own module so the collector stays within the
  500-line cap.
- D8: references are defensively prefixed with ``#`` before they are recorded.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Protocol

from .models import IssueDetails, normalize_reference

if TYPE_CHECKING:
    from collections.abc import Sequence


class ReferenceClassifier(Protocol):
    """Client able to classify a bare reference number as an issue or a PR."""

    def classify_entity(self, number: str) -> str | None:
        """Return ``"issue"``, ``"pull"``, or ``None`` for ``number``."""
        ...


class PendingIssueClient(ReferenceClassifier, Protocol):
    """Classifier that can also fetch issue details for a bare number."""

    def issue_details(self, number: str) -> IssueDetails:
        """Return the issue details for ``number``."""
        ...


@dataclass(frozen=True)
class PendingPrimarySelection:
    """Outcome of verifying the deterministic pending primary refs.

    Attributes:
        kept: Pending refs that remain eligible for the autoclose section.
        excluded: True when at least one pending ref was dropped.
        fetched_details: Issue details for every ref whose details were fetched,
            kept or excluded, keyed by the ref as given, so the caller can reuse
            them instead of fetching the same issue a second time.
    """

    kept: list[str]
    excluded: bool
    fetched_details: dict[str, IssueDetails] = field(
        default_factory=dict[str, IssueDetails]
    )


def _with_hash_prefix(ref: str) -> str:
    """Return ``ref`` with a leading ``#`` (D8 defensive prefixing)."""
    return ref if ref.startswith("#") else f"#{ref}"


def classify_references(
    *,
    gh: ReferenceClassifier,
    gh_available: bool,
    feature_issue_refs: Sequence[str],
    branch_refs: Sequence[str],
    path_refs: Sequence[str],
    referenced_issues: set[str],
    referenced_prs: set[str],
    invalid_refs: set[str],
) -> None:
    """Route feature, branch, and path references into the three reference sets.

    Args:
        gh: Client used to classify each reference when GitHub is available.
        gh_available: Whether the GitHub CLI is available.
        feature_issue_refs: References extracted from feature documents.
        branch_refs: References extracted from the branch name.
        path_refs: References extracted from changed paths.
        referenced_issues: Set that receives references classified as issues.
        referenced_prs: Set that receives references classified as PRs.
        invalid_refs: Set that receives references that are neither.

    Returns:
        None.

    Side Effects:
        Mutates ``referenced_issues``, ``referenced_prs``, and ``invalid_refs``.
    """
    # Feature refs are classified first, then branch and path refs, matching
    # the order the collector used before the move.
    ordered_refs = [*feature_issue_refs, *branch_refs, *path_refs]
    if not gh_available:
        # Without GitHub nothing can be classified, so every ref is recorded as
        # an issue mention; the caller labels the section as unverified.
        referenced_issues.update(_with_hash_prefix(ref) for ref in ordered_refs)
        return
    for ref in ordered_refs:
        formatted = _with_hash_prefix(ref)
        entity = gh.classify_entity(ref.lstrip("#"))
        # Route by the GitHub entity type; anything else is not a valid ref.
        if entity == "issue":
            referenced_issues.add(formatted)
        elif entity == "pull":
            referenced_prs.add(formatted)
        else:
            invalid_refs.add(formatted)


def select_pending_primary(
    *,
    gh: PendingIssueClient,
    gh_available: bool,
    pending_primary: Sequence[str],
) -> PendingPrimarySelection:
    """Keep only the pending primary refs that GitHub reports as open issues.

    Args:
        gh: Client used to classify refs and fetch issue details.
        gh_available: Whether the GitHub CLI is available.
        pending_primary: Deterministic pending primary refs, in order.

    Returns:
        The kept refs, whether any ref was excluded, and the details fetched
        for every ref whose details were requested.

    Side Effects:
        Calls ``gh.classify_entity`` for each ref and ``gh.issue_details`` at
        most once for each ref classified as an issue.
    """
    if not gh_available:
        # Nothing can be verified; keep every ref and let the builder append
        # the unverified annotation (D4).
        return PendingPrimarySelection(kept=list(pending_primary), excluded=False)
    kept: list[str] = []
    fetched_details: dict[str, IssueDetails] = {}
    excluded = False
    for ref in pending_primary:
        number = normalize_reference(ref)
        # A pull request or an unknown number is never a closing target, and
        # its details are not fetched.
        if gh.classify_entity(number) != "issue":
            excluded = True
            continue
        details = gh.issue_details(number)
        fetched_details[ref] = details
        # Only an open issue can be closed by the PR; any other state,
        # including an unknown one, excludes the ref.
        if details.state.lower() == "open":
            kept.append(ref)
        else:
            excluded = True
    return PendingPrimarySelection(
        kept=kept, excluded=excluded, fetched_details=fetched_details
    )
