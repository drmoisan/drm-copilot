"""Unit tests for autoclose reference classification and pending selection.

Issue #622 (D3, D5, D8) moved the reference classification loop and the
pending-primary selection into ``scripts.dev_tools.pr_context.autoclose``. These
tests exercise both functions with an in-memory GitHub client double.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from scripts.dev_tools.pr_context.autoclose import (
    classify_references,
    select_pending_primary,
)
from scripts.dev_tools.pr_context.models import IssueDetails


@dataclass
class FakePendingIssueClient:
    """In-memory ``PendingIssueClient`` recording every ``issue_details`` call.

    ``classifications`` and ``states`` map bare numbers to the entity type and
    issue state; ``detail_calls`` records ``issue_details`` arguments in order.
    """

    classifications: dict[str, str | None] = field(
        default_factory=dict[str, str | None]
    )
    states: dict[str, str] = field(default_factory=dict[str, str])
    detail_calls: list[str] = field(default_factory=list[str])

    def classify_entity(self, number: str) -> str | None:
        """Return the configured entity type, or ``None`` when unknown."""
        return self.classifications.get(number)

    def issue_details(self, number: str) -> IssueDetails:
        """Record the call and return details carrying the configured state."""
        self.detail_calls.append(number)
        return IssueDetails(
            number=number,
            title=f"Issue {number}",
            state=self.states.get(number, "(unknown)"),
            labels=[],
            assignees=[],
            author="octocat",
            created_at="2026-01-01T00:00:00Z",
            updated_at="2026-01-01T00:00:00Z",
            body="",
            comments=[],
        )


def _open_issue_client(state: str) -> FakePendingIssueClient:
    """Return a client that reports ``#5`` as an issue in ``state``."""
    return FakePendingIssueClient(classifications={"5": "issue"}, states={"5": state})


def test_select_pending_primary_keeps_open_issue() -> None:
    """An open pending primary issue is kept and nothing is excluded."""
    # Arrange
    gh = _open_issue_client("open")

    # Act
    selection = select_pending_primary(gh=gh, gh_available=True, pending_primary=["#5"])

    # Assert
    assert selection.kept == ["#5"], "an open issue must be kept"
    assert selection.excluded is False, "no ref was dropped"


def test_select_pending_primary_keeps_uppercase_open_issue() -> None:
    """The state comparison is case-insensitive, so ``OPEN`` is kept."""
    # Arrange
    gh = _open_issue_client("OPEN")

    # Act
    selection = select_pending_primary(gh=gh, gh_available=True, pending_primary=["#5"])

    # Assert
    assert selection.kept == ["#5"], "an OPEN issue must be kept"
    assert selection.excluded is False, "no ref was dropped"


def test_select_pending_primary_excludes_closed_issue() -> None:
    """A closed pending primary issue is dropped and reported as excluded."""
    # Arrange
    gh = _open_issue_client("closed")

    # Act
    selection = select_pending_primary(gh=gh, gh_available=True, pending_primary=["#5"])

    # Assert
    assert selection.kept == [], "a closed issue must not be kept"
    assert selection.excluded is True, "the closed issue must be reported as dropped"
    assert set(selection.fetched_details) == {"#5"}, "details are cached for reuse"


def test_select_pending_primary_excludes_unknown_state() -> None:
    """An issue whose state is ``(unknown)`` is dropped (fail closed)."""
    # Arrange
    gh = _open_issue_client("(unknown)")

    # Act
    selection = select_pending_primary(gh=gh, gh_available=True, pending_primary=["#5"])

    # Assert
    assert selection.kept == [], "an unknown state must not be kept"
    assert selection.excluded is True, "the unknown-state ref must be dropped"


def test_select_pending_primary_excludes_pull_request() -> None:
    """A pending ref classified as a pull request is dropped without a fetch."""
    # Arrange
    gh = FakePendingIssueClient(classifications={"5": "pull"})

    # Act
    selection = select_pending_primary(gh=gh, gh_available=True, pending_primary=["#5"])

    # Assert
    assert selection.kept == [], "a pull request is never a closing target"
    assert selection.excluded is True, "the pull request must be reported as dropped"
    assert gh.detail_calls == [], "issue details are not fetched for a pull request"


def test_select_pending_primary_excludes_unclassified_ref() -> None:
    """A pending ref GitHub cannot classify is dropped without a fetch."""
    # Arrange
    gh = FakePendingIssueClient()

    # Act
    selection = select_pending_primary(gh=gh, gh_available=True, pending_primary=["#5"])

    # Assert
    assert selection.kept == [], "an unclassified ref must not be kept"
    assert selection.excluded is True, "the unclassified ref must be dropped"
    assert gh.detail_calls == [], "issue details are not fetched for unknown refs"


def test_select_pending_primary_keeps_all_refs_when_gh_unavailable() -> None:
    """Without GitHub every pending ref is kept and nothing is fetched."""
    # Arrange
    gh = FakePendingIssueClient()

    # Act
    selection = select_pending_primary(
        gh=gh, gh_available=False, pending_primary=["#5", "#6"]
    )

    # Assert
    assert selection.kept == ["#5", "#6"], "unverifiable refs are kept in order"
    assert selection.excluded is False, "nothing can be excluded without GitHub"
    assert selection.fetched_details == {}, "no details are fetched without GitHub"
    assert gh.detail_calls == [], "no issue_details call is made without GitHub"


def test_select_pending_primary_fetches_each_issue_at_most_once() -> None:
    """Details are fetched once for the issue and never for the pull request."""
    # Arrange
    gh = FakePendingIssueClient(
        classifications={"5": "issue", "6": "pull"}, states={"5": "open"}
    )

    # Act
    selection = select_pending_primary(
        gh=gh, gh_available=True, pending_primary=["#5", "#6"]
    )

    # Assert
    assert gh.detail_calls == ["5"], "only the issue is fetched, exactly once"
    assert list(selection.fetched_details) == ["#5"], "only #5 details are cached"


def test_select_pending_primary_reports_mixed_outcomes() -> None:
    """Open, closed, and pull refs yield only the open issue as kept."""
    # Arrange
    gh = FakePendingIssueClient(
        classifications={"5": "issue", "6": "issue", "7": "pull"},
        states={"5": "open", "6": "closed"},
    )

    # Act
    selection = select_pending_primary(
        gh=gh, gh_available=True, pending_primary=["#5", "#6", "#7"]
    )

    # Assert
    assert selection.kept == ["#5"], "only the open issue is kept"
    assert selection.excluded is True, "the closed issue and the PR are dropped"


def _classify(
    gh: FakePendingIssueClient,
    *,
    gh_available: bool,
    refs: tuple[list[str], list[str], list[str]],
) -> tuple[set[str], set[str], set[str]]:
    """Classify feature, branch, and path ``refs``; return issue, PR, invalid sets."""
    issues: set[str] = set()
    prs: set[str] = set()
    invalid: set[str] = set()
    classify_references(
        gh=gh,
        gh_available=gh_available,
        feature_issue_refs=refs[0],
        branch_refs=refs[1],
        path_refs=refs[2],
        referenced_issues=issues,
        referenced_prs=prs,
        invalid_refs=invalid,
    )
    return issues, prs, invalid


def test_classify_references_routes_issue_pull_and_invalid() -> None:
    """Refs are routed into issue, PR, and invalid sets by entity type."""
    # Arrange
    gh = FakePendingIssueClient(classifications={"1": "issue", "2": "pull"})

    # Act
    issues, prs, invalid = _classify(
        gh, gh_available=True, refs=(["#1"], ["#2"], ["#3"])
    )

    # Assert
    assert issues == {"#1"}, "the issue ref lands in referenced_issues"
    assert prs == {"#2"}, "the pull ref lands in referenced_prs"
    assert invalid == {"#3"}, "the unclassified ref lands in invalid_refs"


def test_classify_references_adds_raw_refs_when_gh_unavailable() -> None:
    """Without GitHub every ref is recorded as an issue mention."""
    # Arrange
    gh = FakePendingIssueClient(classifications={"2": "pull"})

    # Act
    issues, prs, invalid = _classify(
        gh, gh_available=False, refs=(["#1"], ["#2"], ["#3"])
    )

    # Assert
    assert issues == {"#1", "#2", "#3"}, "every ref is recorded as an issue"
    assert prs == set(), "no PR can be identified without GitHub"
    assert invalid == set(), "no ref can be rejected without GitHub"


def test_classify_references_prefixes_unprefixed_refs() -> None:
    """A ref given without ``#`` is recorded in its ``#``-prefixed form."""
    # Arrange
    gh = FakePendingIssueClient(classifications={"9": "issue"})

    # Act
    issues, prs, invalid = _classify(gh, gh_available=True, refs=([], ["9"], []))

    # Assert
    assert issues == {"#9"}, "the unprefixed ref must be recorded as #9"
    assert prs == set(), "no PR ref was supplied"
    assert invalid == set(), "the ref was classified as an issue"
