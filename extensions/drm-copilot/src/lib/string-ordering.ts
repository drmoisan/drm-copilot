/**
 * Ordinal string ordering shared by every subsystem of the extension.
 *
 * Responsibilities:
 *     - Provide `compareCodePoint`, the single ordinal string comparator for
 *       the extension (issue #796). It orders strings by Unicode code point so
 *       that TypeScript output matches Python `str` comparison.
 *
 * Boundary:
 *     This module has no imports, so any subsystem (pr-context, push-down,
 *     codex-native-converter, subagent-tree) may depend on it without adding a
 *     cross-subsystem dependency edge or a cycle.
 */

/**
 * Map a UTF-16 code unit to its rank for code-point ordering.
 *
 * Surrogates (U+D800..U+DFFF) are moved above U+E000..U+FFFF, and
 * U+E000..U+FFFF are moved down into the gap the surrogates leave. The
 * mapping is injective and keeps the relative order inside each range.
 *
 * @param unit A UTF-16 code unit (0..0xFFFF).
 * @returns The rank of the code unit.
 */
function rankCodeUnit(unit: number): number {
  if (unit >= 0xd800 && unit <= 0xdfff) {
    return unit + 0x2000;
  }
  if (unit >= 0xe000) {
    return unit - 0x800;
  }
  return unit;
}

/**
 * Compare two strings by Unicode code point, matching Python `str` comparison.
 *
 * This differs from the JavaScript `<` operator, which compares UTF-16 code
 * units: a supplementary character (a surrogate pair) sorts before a BMP
 * character in U+E000..U+FFFF under `<`, but after it here.
 *
 * At the first differing UTF-16 code unit, each unit is ranked with a
 * surrogate fix-up: code units U+D800..U+DFFF rank above U+E000..U+FFFF, and
 * all other units keep their numeric order. A proper prefix sorts first.
 *
 * The result is a strict total order over every JavaScript string, including
 * strings that contain unpaired surrogates, so it is a consistent comparator
 * for `Array.prototype.sort`. For well-formed strings it equals Unicode
 * code-point order.
 *
 * @returns Exactly -1, 0, or 1.
 */
export function compareCodePoint(left: string, right: string): number {
  const sharedLength = Math.min(left.length, right.length);
  for (let index = 0; index < sharedLength; index += 1) {
    const leftUnit = left.charCodeAt(index);
    const rightUnit = right.charCodeAt(index);
    if (leftUnit !== rightUnit) {
      return rankCodeUnit(leftUnit) < rankCodeUnit(rightUnit) ? -1 : 1;
    }
  }
  if (left.length === right.length) {
    return 0;
  }
  return left.length < right.length ? -1 : 1;
}
