/**
 * Seeded pseudo-random source for property-style push-down tests.
 *
 * Purpose:
 *     Give property cases a reproducible sequence without the ambient global
 *     random source or a new dependency. A 32-bit linear congruential generator (multiplier
 *     1664525, increment 1013904223) yields the same values for the same seed,
 *     so a failing case is reproduced by its seed alone.
 */

/** Fixed seed list shared with the Python property tests. */
export const SEEDS: ReadonlyArray<number> = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89];

/** Alphabet used for generated path segments. */
const SEGMENT_ALPHABET = "abcdefxyz";

/** Deterministic 32-bit linear congruential generator. */
export class SeededRandom {
  private state: number;

  /**
   * @param seed Initial state; the same seed always yields the same sequence.
   */
  constructor(seed: number) {
    this.state = seed >>> 0;
  }

  /**
   * Advance the generator and return the next unsigned 32-bit value.
   *
   * @returns The next state.
   */
  private next(): number {
    this.state = (Math.imul(this.state, 1664525) + 1013904223) >>> 0;
    return this.state;
  }

  /**
   * Return an integer in `[0, maxExclusive)`.
   *
   * @param maxExclusive Exclusive upper bound; must be positive.
   * @returns The generated integer.
   * @throws Error When the bound is not a positive integer.
   */
  nextInt(maxExclusive: number): number {
    if (!Number.isInteger(maxExclusive) || maxExclusive <= 0) {
      throw new Error(
        `maxExclusive must be a positive integer: ${String(maxExclusive)}`,
      );
    }
    return this.next() % maxExclusive;
  }

  /**
   * Return one element of a non-empty array.
   *
   * @param items Candidate items.
   * @returns The chosen item.
   * @throws Error When `items` is empty.
   */
  pick<T>(items: ReadonlyArray<T>): T {
    const item = items[this.nextInt(items.length)];
    if (item === undefined) {
      throw new Error("pick requires a non-empty array");
    }
    return item;
  }

  /**
   * Return a lowercase segment of one to six characters.
   *
   * @returns The generated segment.
   */
  pathSegment(): string {
    const length = 1 + this.nextInt(6);
    let segment = "";
    for (let index = 0; index < length; index += 1) {
      segment += this.pick([...SEGMENT_ALPHABET]);
    }
    return segment;
  }

  /**
   * Return a path of `depth` segments joined by `/`.
   *
   * @param depth Number of segments; at least one.
   * @returns The generated POSIX relative path.
   */
  relativePath(depth: number): string {
    const segments: string[] = [];
    for (let index = 0; index < depth; index += 1) {
      segments.push(this.pathSegment());
    }
    return segments.join("/");
  }
}
