"""Tests for the pure push-down exclusion manifest module.

Covers the root-level manifest path invariant, the manifest grammar and its
malformed-entry set, the exact/directory/glob matcher boundaries, first-match
planning, and five seeded property checks. Property cases use
``random.Random(seed)`` over a fixed seed list; the seed is in every case id and
every assertion message so a failure is reproducible. No test touches the
filesystem.
"""

from __future__ import annotations

import random

import pytest

from scripts.dev_tools.push_down_claude_customizations import ROOT_FOLDERS
from scripts.dev_tools.push_down_exclusion_manifest import (
    EXCLUSION_MANIFEST_RELATIVE_PATH,
    ExclusionManifest,
    ExclusionManifestError,
    assert_manifest_path_is_root_level,
    find_first_match,
    matches_exclusion_entry,
    normalize_exclusion_entry,
    parse_exclusion_manifest,
    plan_exclusions,
)

SEEDS = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
SEED_IDS = [f"seed-{seed}" for seed in SEEDS]
MANIFEST_PATH = EXCLUSION_MANIFEST_RELATIVE_PATH
SEGMENT_ALPHABET = "abcdefxyz"


class PathGenerator:
    """Seeded generator of destination-relative POSIX paths for property tests."""

    def __init__(self, seed: int) -> None:
        """Seed the generator; the same seed always yields the same sequence."""

        # Deterministic test data; S311 authorized in pyproject per-file-ignores.
        self.rng = random.Random(seed)

    def segment(self) -> str:
        """Return a lowercase segment of one to six characters."""

        length = self.rng.randint(1, 6)
        return "".join(self.rng.choice(SEGMENT_ALPHABET) for _ in range(length))

    def path(self, depth: int) -> str:
        """Return a path of ``depth`` segments joined by ``/``."""

        return "/".join(self.segment() for _ in range(depth))

    def depth(self) -> int:
        """Return a path depth between one and four."""

        return self.rng.randint(1, 4)


def _single_entry(text: str) -> ExclusionManifest:
    """Parse ``text`` as a one-line manifest."""

    return parse_exclusion_manifest(text + "\n", MANIFEST_PATH)


def _no_destination(_relative_path: str) -> bool:
    """Destination probe reporting that no destination file exists."""

    return False


def test_manifest_relative_path_is_root_level_outside_root_folders() -> None:
    """The manifest path has no separator and starts with no published root."""

    root_names = tuple(root.as_posix() for root in ROOT_FOLDERS)

    assert "/" not in EXCLUSION_MANIFEST_RELATIVE_PATH
    assert_manifest_path_is_root_level(EXCLUSION_MANIFEST_RELATIVE_PATH, root_names)


@pytest.mark.parametrize("relative_path", ["a/b", ".claude-x"])
def test_assert_manifest_path_rejects_slash_and_root_prefix(
    relative_path: str,
) -> None:
    """A nested path or a root-prefixed name is rejected with ValueError."""

    with pytest.raises(ValueError, match="Exclusion manifest path"):
        assert_manifest_path_is_root_level(relative_path, (".claude", "config"))


def test_parse_valid_manifest_with_comments_blank_lines_crlf_and_bom() -> None:
    """Comments and blanks are skipped, CRLF splits lines, and a BOM is dropped."""

    text = "\ufeff# reason\r\n.claude/rules/a.md\r\n\r\n   \r\n  # note\r\nconfig/b\r\n"

    manifest = parse_exclusion_manifest(text, MANIFEST_PATH)

    assert manifest.path == MANIFEST_PATH
    assert [(e.normalized, e.line) for e in manifest.entries] == [
        (".claude/rules/a.md", 2),
        ("config/b", 6),
    ]


def test_parse_normalizes_backslash_dot_slash_repeated_slash_and_whitespace() -> None:
    """Each normalization step is applied and the raw text is preserved."""

    text = "  .\\config\\\\rules//x.md  \n"

    manifest = parse_exclusion_manifest(text, MANIFEST_PATH)

    assert len(manifest.entries) == 1
    assert manifest.entries[0].normalized == "config/rules/x.md"
    assert manifest.entries[0].raw == "  .\\config\\\\rules//x.md  "


def test_parse_classifies_entry_kind() -> None:
    """Entries are classified as exact, directory, or glob."""

    text = ".claude/a.md\n.claude/memory/\n.claude/**\nconfig/?.json\n"

    manifest = parse_exclusion_manifest(text, MANIFEST_PATH)

    assert [e.kind for e in manifest.entries] == ["exact", "directory", "glob", "glob"]


@pytest.mark.parametrize(
    "text", ["./", "/abs", "X:/abs", "a/../b", "!neg", "a[b].md", "a].md", "dir/**/"]
)
def test_parse_rejects_malformed_entry(text: str) -> None:
    """Every malformed entry fails with the manifest path and line 1."""

    with pytest.raises(ExclusionManifestError) as captured:
        parse_exclusion_manifest(text + "\n", MANIFEST_PATH)

    assert captured.value.path == ".push-down-exclusions"
    assert captured.value.line == 1
    assert ".push-down-exclusions" in str(captured.value)
    assert "line 1" in str(captured.value)


def test_parse_error_reports_offending_line_after_comments() -> None:
    """The reported line counts comment and blank lines."""

    with pytest.raises(ExclusionManifestError) as captured:
        parse_exclusion_manifest("# c\n\n.claude/ok.md\n!bad\n", MANIFEST_PATH)

    assert captured.value.line == 4
    assert "line 4" in str(captured.value)


@pytest.mark.parametrize(
    ("entry", "candidate", "expected"),
    [
        (".claude/rules/x", ".claude/rules/xy.md", False),
        (".claude/rules/x", ".claude/rules/x/y.md", True),
        (".claude/rules/*", ".claude/rules/sub/x.md", False),
        (".claude/rules/*", ".claude/rules/x.md", True),
        (".claude/**", ".claude/a/b/c.md", True),
        ("config/?.json", "config/a.json", True),
        ("config/?.json", "config/ab.json", False),
    ],
    ids=[
        "sibling-prefix-nonmatch",
        "directory-prefix-match",
        "star-not-crossing-slash",
        "star-within-segment",
        "doublestar-crossing-slash",
        "question-one-char",
        "question-not-two-chars",
    ],
)
def test_matches_exact_directory_and_glob_boundaries(
    entry: str, candidate: str, expected: bool
) -> None:
    """Matcher boundaries for sibling prefixes, ``*``, ``**``, and ``?``."""

    parsed = _single_entry(entry).entries[0]

    assert matches_exclusion_entry(parsed, candidate) is expected


def test_plan_exclusions_first_match_precedence() -> None:
    """The first matching entry in manifest order is the one recorded."""

    manifest = parse_exclusion_manifest(
        ".claude/rules/quality-tiers.md\n.claude/rules/**\n", MANIFEST_PATH
    )
    payload = [".claude/rules/quality-tiers.md", ".claude/rules/python.md"]

    plan = plan_exclusions(payload, manifest, _no_destination)

    assert plan.kept == ()
    assert [(s.relative_path, s.entry, s.line) for s in plan.skipped] == [
        (".claude/rules/quality-tiers.md", ".claude/rules/quality-tiers.md", 1),
        (".claude/rules/python.md", ".claude/rules/**", 2),
    ]
    assert plan.unmatched_entries == ()


def test_plan_exclusions_reports_shadowed_entry_as_unmatched() -> None:
    """An entry whose paths an earlier entry claimed is reported as unmatched."""

    manifest = parse_exclusion_manifest(
        ".claude/rules/**\n.claude/rules/quality-tiers.md\n", MANIFEST_PATH
    )

    plan = plan_exclusions(
        [".claude/rules/quality-tiers.md"], manifest, _no_destination
    )

    assert [s.entry for s in plan.skipped] == [".claude/rules/**"]
    assert [(e.normalized, e.line) for e in plan.unmatched_entries] == [
        (".claude/rules/quality-tiers.md", 2)
    ]


def test_plan_exclusions_uses_destination_probe_for_status() -> None:
    """The probe decides present versus absent and is asked only for skips."""

    manifest = parse_exclusion_manifest("a.md\nb.md\n", MANIFEST_PATH)
    probed: list[str] = []

    def probe(relative_path: str) -> bool:
        probed.append(relative_path)
        return relative_path == "a.md"

    plan = plan_exclusions(["a.md", "b.md", "c.md"], manifest, probe)

    assert [(s.relative_path, s.destination_status) for s in plan.skipped] == [
        ("a.md", "present"),
        ("b.md", "absent"),
    ]
    assert plan.kept == ("c.md",)
    assert probed == ["a.md", "b.md"]


@pytest.mark.parametrize("seed", SEEDS, ids=SEED_IDS)
def test_property_exact_entry_matches_only_itself(seed: int) -> None:
    """A wildcard-free entry matches itself and its descendants, nothing else."""

    generator = PathGenerator(seed)
    target = generator.path(generator.depth())
    entry = _single_entry(target).entries[0]
    candidates = [target, target + "x", target + "/" + generator.segment()]
    candidates.extend(generator.path(generator.depth()) for _ in range(20))

    for candidate in candidates:
        expected = candidate == target or candidate.startswith(target + "/")
        assert (
            matches_exclusion_entry(entry, candidate) is expected
        ), f"seed={seed} entry={target!r} candidate={candidate!r}"


@pytest.mark.parametrize("seed", SEEDS, ids=SEED_IDS)
def test_property_directory_entry_trailing_slash_equivalence(seed: int) -> None:
    """``foo/bar`` and ``foo/bar/`` match exactly the same candidates."""

    generator = PathGenerator(seed)
    base = generator.path(generator.depth())
    without_slash = _single_entry(base).entries[0]
    with_slash = _single_entry(base + "/").entries[0]
    candidates = [base, base + "/" + generator.path(2), base + "z"]
    candidates.extend(generator.path(generator.depth()) for _ in range(20))

    for candidate in candidates:
        assert matches_exclusion_entry(without_slash, candidate) is (
            matches_exclusion_entry(with_slash, candidate)
        ), f"seed={seed} base={base!r} candidate={candidate!r}"


@pytest.mark.parametrize("seed", SEEDS, ids=SEED_IDS)
def test_property_star_never_crosses_separator(seed: int) -> None:
    """A single ``*`` segment matches one segment and never a deeper path."""

    generator = PathGenerator(seed)
    prefix = generator.path(generator.depth())
    entry = _single_entry(prefix + "/*").entries[0]

    for _ in range(10):
        one = prefix + "/" + generator.segment()
        deeper = one + "/" + generator.path(generator.depth())
        assert matches_exclusion_entry(entry, one), f"seed={seed} candidate={one!r}"
        assert not matches_exclusion_entry(
            entry, deeper
        ), f"seed={seed} candidate={deeper!r}"


@pytest.mark.parametrize("seed", SEEDS, ids=SEED_IDS)
def test_property_normalization_is_idempotent(seed: int) -> None:
    """Normalizing twice equals normalizing once and leaves no ``\\`` or ``//``."""

    generator = PathGenerator(seed)
    for _ in range(20):
        separators = [
            generator.rng.choice(["/", "\\", "//", "\\\\", "/\\"]) for _ in range(3)
        ]
        segments = [generator.segment() for _ in range(4)]
        body = segments[0] + "".join(
            separator + segment
            for separator, segment in zip(separators, segments[1:], strict=True)
        )
        prefix = generator.rng.choice(["", "./", ".\\"])
        padding = " " * generator.rng.randint(0, 3)
        raw = padding + prefix + body + padding

        once = normalize_exclusion_entry(raw)

        assert normalize_exclusion_entry(once) == once, f"seed={seed} raw={raw!r}"
        assert "\\" not in once, f"seed={seed} raw={raw!r}"
        assert "//" not in once, f"seed={seed} raw={raw!r}"


@pytest.mark.parametrize("seed", SEEDS, ids=SEED_IDS)
def test_property_plan_exclusions_partitions_payload(seed: int) -> None:
    """Kept and skipped partition the payload; first match and probe decide."""

    generator = PathGenerator(seed)
    payload = list(
        dict.fromkeys(generator.path(generator.depth()) + ".md" for _ in range(15))
    )
    entry_lines: list[str] = []
    for _ in range(generator.rng.randint(1, 5)):
        source = generator.rng.choice(payload).split("/")
        form = generator.rng.randint(0, 3)
        if form == 0:
            entry_lines.append("/".join(source))
        elif form == 1:
            entry_lines.append(source[0] + "/")
        elif form == 2:
            entry_lines.append(source[0] + "/**")
        else:
            entry_lines.append(generator.path(2) + "/nomatch.md")
    manifest = parse_exclusion_manifest("\n".join(entry_lines) + "\n", MANIFEST_PATH)
    present = {path for path in payload if generator.rng.random() < 0.5}

    plan = plan_exclusions(payload, manifest, lambda path: path in present)

    skipped_paths = [skip.relative_path for skip in plan.skipped]
    message = f"seed={seed} manifest={entry_lines!r}"
    assert sorted(list(plan.kept) + skipped_paths) == sorted(payload), message
    assert not set(plan.kept) & set(skipped_paths), message
    assert list(plan.kept) == [p for p in payload if p in set(plan.kept)], message
    for skip in plan.skipped:
        first = find_first_match(manifest, skip.relative_path)
        assert first is not None, message
        assert (skip.entry, skip.line) == (first.normalized, first.line), message
        expected_status = "present" if skip.relative_path in present else "absent"
        assert skip.destination_status == expected_status, message
    for kept in plan.kept:
        assert find_first_match(manifest, kept) is None, message
    claimed = {(skip.entry, skip.line) for skip in plan.skipped}
    unmatched = {(e.normalized, e.line) for e in plan.unmatched_entries}
    all_entries = {(e.normalized, e.line) for e in manifest.entries}
    assert claimed | unmatched == all_entries, message
    assert not claimed & unmatched, message
