"""Render accepted generation data without creating readiness or write authority."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import cast

from drm_copilot_discovery.acceptance_models import (
    AcceptanceGeneration,
    AcceptanceSpecification,
)
from drm_copilot_discovery.acceptance_render_text import (
    AcceptanceTextOutput as _Output,
)
from drm_copilot_discovery.acceptance_render_text import utf8_path_size
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.path_models import check_path_collisions, relative_path
from drm_copilot_discovery.report_models import ReportBudget, ReportLimitError

_MAX_BYTES = 64 * 1024 * 1024
_MAX_FILES = 1_000_000
_TAG = re.compile(r"@[a-z][a-z0-9_.-]*")


@dataclass(frozen=True, kw_only=True)
class AcceptanceRenderedFile:
    """Retain one portable relative path and immutable UTF-8 content.

    path (str) is not a write grant; content (bytes) is only rendered data.
    Construction checks shape, encoding and the public hard byte ceiling before
    decoding. The value is immutable and performs no I/O or readiness assessment.
    """

    path: str
    content: bytes

    def __post_init__(self) -> None:
        """Check fields; return None or raise ValueError/ReportLimitError.

        No arguments, caller mutation or I/O; invalid paths use PathPolicyError.
        """
        if type(self.path) is not str or type(self.content) is not bytes:
            raise ValueError("Rendered files require a string path and bytes")
        if len(self.content) > _MAX_BYTES:
            raise ReportLimitError()
        utf8_path_size(self.path, limit=_MAX_BYTES - len(self.content))
        relative_path(self.path)
        try:
            self.content.decode("utf-8")
        except UnicodeError as error:
            raise ValueError("Rendered content requires valid UTF-8") from error


def _paths(paths: tuple[str, ...], budget: ReportBudget) -> tuple[str, ...]:
    """Return portable sorted paths after reserving their aggregate work.

    paths is a tuple of strings; budget (ReportBudget) reserves prefix,
    normalization and comparison work before allocation. Raises ValueError or
    PathPolicyError for collisions, ReportLimitError for excess. Only budget
    counters mutate; no I/O occurs.
    """
    budget.work(len(paths))
    width = 0
    # Prefix reconstruction is quadratic in path width in the accepted policy.
    for path in paths:
        width += len(path)
        budget.work(8 * (len(path) + 1) ** 2)
    budget.work(4 * width * max(1, len(paths).bit_length()))
    checked = check_path_collisions(paths)
    leaves = set(checked)
    # A file must not also be the parent directory of another emitted file.
    for path in checked:
        parts = path.split("/")
        # Inspect each actual ancestor instead of using a textual prefix test.
        for length in range(1, len(parts)):
            if "/".join(parts[:length]) in leaves:
                raise ValueError("Rendered paths contain a file-directory collision")
    return checked


@dataclass(frozen=True, kw_only=True)
class AcceptanceRenderBundle:
    """Normalize immutable rendered files without publication authority.

    files (tuple[AcceptanceRenderedFile, ...]) is detached by immutable storage,
    checked for portable collisions and sorted by path. Construction enforces
    hard aggregate count/byte bounds; render_acceptance additionally enforces the
    generation's lower limits. No filesystem access or semantic proof occurs.
    """

    files: tuple[AcceptanceRenderedFile, ...]

    def __post_init__(self) -> None:
        """Normalize files; return None or raise ValueError/ReportLimitError.

        Only this frozen instance's initial field changes. No I/O occurs.
        """
        if type(self.files) is not tuple:
            raise ValueError("Rendered bundles require an immutable file tuple")
        if len(self.files) > _MAX_FILES:
            raise ReportLimitError()
        budget = ReportBudget(
            ParseLimits(document_bytes=_MAX_BYTES, artifact_records=_MAX_FILES)
        )
        # Raw file content has no implicit canonical-JSON trailing newline.
        budget.bytes_left = _MAX_BYTES
        budget.work(len(self.files))
        # Check all members and aggregate bytes before building the path index.
        for item in self.files:
            if type(item) is not AcceptanceRenderedFile:
                raise ValueError("Rendered bundles require typed file values")
            budget.spend(len(item.content))
            budget.work(len(item.path))
            budget.spend(utf8_path_size(item.path, limit=budget.bytes_left))
        # Retain one path index only after member/count/byte validation.
        paths = _paths(tuple(item.path for item in self.files), budget)
        # Avoid repeated scans when applying the collision-checked ordering.
        by_path = {item.path: item for item in self.files}
        # Normalize the local immutable field, preserving the supplied file values.
        object.__setattr__(self, "files", tuple(by_path[path] for path in paths))


def _fields(item: AcceptanceSpecification, output: _Output) -> dict[str, object]:
    """Index item (AcceptanceSpecification) once under output's work budget.

    output (_Output) owns local reservations. Returns document field references
    without copying children. Invalid rendering shapes raise ValueError; capacity
    raises ReportLimitError.
    Only the local budget changes; no schema or readiness proof is performed.
    """
    output.budget.work(4 * len(item.document))
    values: dict[str, object] = dict(item.document.members)
    if values.get("readiness") not in ("ready", "pending"):
        raise ValueError("Acceptance rendering requires a declared readiness state")
    tags = values.get("tags")
    if type(tags) is not tuple:
        raise ValueError("Acceptance rendering requires immutable tags")
    tag_values = cast("tuple[object, ...]", tags)
    output.budget.work(len(tag_values))
    width = 0
    # Validate literal tag syntax without reconstructing applicability decisions.
    for tag in tag_values:
        if type(tag) is not str:
            raise ValueError("Acceptance tags require literal strings")
        output.budget.work(4 * len(tag))
        width += len(tag)
        if _TAG.fullmatch(tag) is None:
            raise ValueError("Acceptance tag has unsafe syntax")
    output.budget.work(4 * width * max(1, len(tag_values).bit_length()))
    literal_tags = cast("tuple[str, ...]", tag_values)
    if tuple(sorted(set(literal_tags))) != literal_tags:
        raise ValueError("Acceptance tags must be sorted and unique")
    return values


def _trace(item: AcceptanceSpecification, output: _Output) -> dict[str, object]:
    """Return a trace of item (AcceptanceSpecification) under output (_Output).

    Uses the public identity key and unchanged document/owner. Prospective work
    and remaining bytes bound that key construction. Raises ReportLimitError;
    no provenance recomputation, graph assessment or caller mutation occurs.
    """
    key = item.identity
    coordinates = (
        key.source_repository_id,
        key.feature_id,
        key.criterion_id,
        key.client_id,
        key.platform_id,
        key.mode_id,
        *(key.linked_scenario or ()),
    )
    # The public key factory's bounded copies are charged to this whole operation.
    for coordinate in coordinates:
        output.budget.work(20 * len(coordinate or ""))
    remaining = output.budget.bytes_left
    if remaining < 1:
        raise ReportLimitError()
    limits = ParseLimits(
        document_bytes=remaining,
        artifact_records=output.budget.limits.artifact_records,
        nesting_depth=output.budget.limits.nesting_depth,
    )
    return {
        "identity": key.key(limits=limits),
        "repository": item.repository.to_dict(),
        "specification": item.document,
    }


def _feature(
    values: dict[str, object], trace: dict[str, object], output: _Output
) -> bytes:
    """Render values and trace (dict[str, object]); return ASCII bytes.

    values originate from a ready member; output (_Output) reserves all text.
    Invalid step shapes raise ValueError; capacity raises ReportLimitError.
    No semantic validation or I/O occurs.
    """
    identifier = cast("str", values["scenario_id"])
    given, when, then = values.get("given"), values.get("when"), values.get("then")
    if (
        type(given) is not tuple
        or type(when) is not str
        or type(then) is not tuple
        or not then
    ):
        raise ValueError("Ready acceptance requires complete immutable steps")
    chunks = [
        output.fixed("# "),
        output.json(trace),
        output.fixed("\nFeature: " + identifier + "\n\n"),
    ]
    tags = cast("tuple[str, ...]", values["tags"])
    # Generated tags are emitted exactly, immediately before the scenario.
    for index, tag in enumerate(tags):
        chunks.append(output.fixed("  " if index == 0 else " "))
        chunks.append(output.fixed(tag))
    if tags:
        chunks.append(output.fixed("\n"))
    chunks.append(output.fixed("  Scenario: " + identifier + "\n"))
    # Empty given has no invented setup; authored step order remains unchanged.
    for statements, first in (
        (cast("tuple[object, ...]", given), "Given"),
        ((when,), "When"),
        (cast("tuple[object, ...]", then), "Then"),
    ):
        # Fixed keywords and JSON quoting prevent authored multiline syntax.
        for index, statement in enumerate(statements):
            if type(statement) is not str:
                raise ValueError("Acceptance steps require literal strings")
            chunks.append(output.fixed("    " + (first if index == 0 else "And") + " "))
            chunks.append(output.json(statement))
            chunks.append(output.fixed("\n"))
    return "".join(chunks).encode("ascii")


def render_acceptance(generation: AcceptanceGeneration) -> AcceptanceRenderBundle:
    """Render generation's exact ready subset and complete traceable Markdown.

    generation must be the immutable AcceptanceGeneration returned by the public
    generator. Construction alone is not readiness proof. Returns sorted relative
    files; malformed shape/encoding/collisions raise ValueError/PathPolicyError,
    and aggregate resource excess raises ReportLimitError without partial output.
    No I/O, revalidation, step definitions, grants or acceptance mutation occurs.
    """
    if type(generation) is not AcceptanceGeneration:
        raise ValueError("Acceptance rendering requires a typed generation result")
    output = _Output(generation.limits)
    total = (
        len(generation.specifications)
        + len(generation.ready)
        + len(generation.findings)
    )
    if total + 1 > generation.limits.artifact_records:
        raise ReportLimitError()
    output.budget.work(8 * (total + 1))
    # The model retained canonical instances, so membership never compares documents.
    ready = {id(item) for item in generation.ready}
    files: list[AcceptanceRenderedFile] = []
    ready_blocks: list[str] = []
    other_blocks: list[str] = []
    pending = 0
    # Each candidate is indexed once and retained in exactly one Markdown section.
    for item in generation.specifications:
        values = _fields(item, output)
        selected = id(item) in ready
        status = (
            "ready"
            if selected
            else "pending" if values["readiness"] == "pending" else "withheld"
        )
        trace = _trace(item, output)
        block = output.block({"status": status, **trace})
        (ready_blocks if selected else other_blocks).append(block)
        pending += status == "pending"
        if selected:
            path = output.fixed(
                item.identity.kind
                + "/"
                + cast("str", values["scenario_id"])
                + ".feature"
            )
            files.append(
                AcceptanceRenderedFile(
                    path=path, content=_feature(values, trace, output)
                )
            )
    findings: list[dict[str, object]] = []
    # Reference immutable finding children; never copy unmeasured reference lists.
    for finding in generation.findings:
        findings.append(
            {
                "code": finding.code,
                "severity": finding.severity,
                "message": finding.message,
                "next_action": finding.next_action,
                "artifact_path": finding.artifact_path,
                "pointer": finding.pointer,
                "related_ids": finding.related_ids,
                "related_paths": finding.related_paths,
            }
        )
    markdown = (
        output.fixed("# Acceptance\n\n## Summary\n\n")
        + output.block(
            {
                "candidates": len(generation.specifications),
                "ready": len(ready),
                "pending": pending,
                "withheld": len(other_blocks) - pending,
            }
        )
        + output.fixed("## Findings\n\n")
        + output.block(tuple(findings))
        + output.fixed("## Ready\n\n")
        + "".join(ready_blocks)
        + output.fixed("## Non-executable\n\n")
        + "".join(other_blocks)
    )
    files.append(
        AcceptanceRenderedFile(
            path=output.fixed("acceptance.md"), content=markdown.encode("ascii")
        )
    )
    # Reserve both final ordering and the public bundle's collision recheck.
    _paths(tuple(item.path for item in files), output.budget)
    return AcceptanceRenderBundle(files=tuple(files))
