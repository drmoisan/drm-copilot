"""Deterministic property tests for the T2 pure helpers that had example tests only.

Each property draws its inputs from a digest-driven generator seeded by the
test id, so a failure is reproducible from the seed and no pseudo-random module
is involved, and asserts an invariant that holds for every drawn value rather
than a single example: identity on strings and ``None`` elsewhere, whitespace
insensitivity, member-order and extension independence of the environment
identity, field reflection of input findings, and rejection of every operation
name outside the fixed service matrix.
"""

from __future__ import annotations

import string
from hashlib import sha256

import pytest
from drm_copilot_discovery.reference_links import string_value
from drm_copilot_discovery.runtime_claim_rules import environment_identity, has_text
from drm_copilot_discovery.service_request_rules import check_combinations
from drm_copilot_discovery.validation_inputs import input_problem

from tests.discovery_runtime.test_references import immutable

SEEDS = (11, 23, 47, 101, 211)
CORE_KEYS = ("id", "platform", "operating_mode")
TEXT_ALPHABET = string.ascii_letters + string.digits + " "
BLANK_ALPHABET = " \t\n"


class Draw:
    """Digest-driven deterministic value source for one seed.

    Every call hashes the seed and a running counter, so the sequence of drawn
    values is a pure function of the seed and the call order. No randomness
    module is used, which keeps the tests reproducible and free of S311.
    """

    def __init__(self, seed: int) -> None:
        self.seed = seed
        self.counter = 0

    def integer(self, upper: int) -> int:
        """Return an integer in [0, upper) derived from the next digest."""
        self.counter += 1
        digest = sha256(f"{self.seed}:{self.counter}".encode()).digest()
        return int.from_bytes(digest[:4], "big") % upper

    def choice(self, options: list[object]) -> object:
        """Return one of options chosen by the next digest."""
        return options[self.integer(len(options))]

    def text(self, *, blank: bool = False) -> str:
        """Return a short string, whitespace-only when blank is requested."""
        alphabet = BLANK_ALPHABET if blank else TEXT_ALPHABET
        length = 1 + self.integer(12)
        return "".join(alphabet[self.integer(len(alphabet))] for _ in range(length))

    def shuffled(self, items: list[tuple[str, object]]) -> list[tuple[str, object]]:
        """Return the items in a digest-driven permutation."""
        remaining = list(items)
        ordered: list[tuple[str, object]] = []
        # Pull one remaining item per draw until the permutation is complete.
        while remaining:
            ordered.append(remaining.pop(self.integer(len(remaining))))
        return ordered


def _json_value(draw: Draw) -> object:
    """Return a drawn non-string JSON scalar or empty container."""
    return draw.choice([None, True, False, draw.integer(11) - 5, 0.5, [], {}])


@pytest.mark.parametrize("seed", SEEDS)
def test_string_value_is_identity_on_strings_and_none_elsewhere(seed: int) -> None:
    """string_value never coerces: strings pass through, other values are None."""
    draw = Draw(seed)
    # Every drawn string round-trips unchanged and every non-string collapses.
    for _ in range(25):
        text = draw.text()
        assert string_value(text) == text
        assert string_value(string_value(text)) == text
        assert string_value(immutable({"v": _json_value(draw)})["v"]) is None


@pytest.mark.parametrize("seed", SEEDS)
def test_has_text_ignores_surrounding_whitespace_and_rejects_blank_values(
    seed: int,
) -> None:
    """has_text is true exactly when a string carries a non-whitespace character."""
    draw = Draw(seed)
    # Padding a non-blank string never changes the verdict; blanks are false.
    for _ in range(25):
        core = draw.text().strip() or "x"
        padded = draw.text(blank=True) + core + draw.text(blank=True)
        assert has_text(core) is True
        assert has_text(padded) is True
        assert has_text(draw.text(blank=True)) is False
        assert has_text(immutable({"v": _json_value(draw)})["v"]) is False


@pytest.mark.parametrize("seed", SEEDS)
def test_environment_identity_is_order_and_extension_independent(seed: int) -> None:
    """The identity depends on the four core fields only, in a fixed order."""
    draw = Draw(seed)
    for _ in range(10):
        core = {key: draw.text().strip() or "v" for key in CORE_KEYS}
        client = draw.choice([None, draw.text().strip() or "client"])
        base: dict[str, object] = {**core, "client_id": client}
        extended: dict[str, object] = {
            **base,
            "extra": draw.text(),
            "n": draw.integer(10),
        }
        shuffled = dict(draw.shuffled(list(extended.items())))

        expected = (core["id"], core["platform"], core["operating_mode"], client)
        assert environment_identity(immutable(base)) == expected
        assert environment_identity(immutable(shuffled)) == expected
        # Dropping any core key, or a blank client, removes the identity entirely.
        dropped = draw.choice(list(CORE_KEYS))
        without_core = {key: value for key, value in base.items() if key != dropped}
        assert environment_identity(immutable(without_core)) is None
        assert environment_identity(immutable({**core})) is None
        assert environment_identity(immutable({**core, "client_id": "   "})) is None


@pytest.mark.parametrize("seed", SEEDS)
def test_input_problem_reflects_its_arguments_as_an_error_finding(
    seed: int,
) -> None:
    """Every input problem carries the supplied code, message and path unchanged."""
    draw = Draw(seed)
    for _ in range(25):
        code = "INPUT_" + draw.text().strip().upper().replace(" ", "_")
        message = draw.text()
        candidate = "docs/" + draw.text().strip().replace(" ", "-")
        path = candidate if draw.integer(2) == 1 else None
        finding = input_problem(code, message, path)
        assert (finding.code, finding.message, finding.artifact_path) == (
            code,
            message,
            path,
        )
        assert finding.severity == "error"
        assert finding.next_action


@pytest.mark.parametrize("seed", SEEDS)
def test_check_combinations_rejects_every_operation_outside_the_matrix(
    seed: int,
) -> None:
    """An operation name outside the fixed matrix is refused before field checks."""
    draw = Draw(seed)
    for _ in range(25):
        operation = "op-" + draw.text().strip().lower().replace(" ", "-")
        fields: dict[str, object] = {
            "operation": operation,
            "mode": draw.choice(["structural", "agent-output", "planning"]),
            "inputs": immutable({}),
            "invocation_ref": None,
            "format": draw.choice(["json", "markdown", "both"]),
            "dry_run": draw.choice([True, False]),
            "write": draw.choice([True, False]),
        }
        with pytest.raises(ValueError, match="Service operation is unsupported"):
            check_combinations(fields)
