# Image Finder — Scan Timing Report

## Latest measured (native + dark/blur) — **source of truth**

**Device:** SM A715W · **Photos:** 3604 · **Full scan:** **37.2 s**  
**Log:** `SCAN COMPLETE photos=3604 exact=474 similar=212 dark=281 blurry=47`


| Stage                    | Duration        | Detail                                      |
| ------------------------ | --------------- | ------------------------------------------- |
| permission               | 1.9 s           | authorized                                  |
| catalog                  | 386 ms          | native                                      |
| diff                     | 595 ms          | new=3604                                    |
| exact_hash               | 6.8 s           | candidates=991                              |
| exact_group              | 2.1 s           | groups=474 photos=950                       |
| similar_hash             | **22.5 s**      | 160.9/s · failed=0 · includes dark+blur     |
| similar_group_prepare    | 59 ms           | fingerprints=3604                           |
| similar_group            | 1.6 s           | groups=212                                  |
| persist                  | 1.1 s           | dark=281 blurry=47                          |
| **Duplicates (exact)**   | **8.8 s**       | roll-up                                     |
| **Similar**              | **24.2 s**      | roll-up                                     |
| **FULL SCAN**            | **37.2 s**      |                                             |


| Category   | Count                                              |
| ---------- | -------------------------------------------------- |
| Duplicate  | 474 groups · 950 photos · 476 selected (keep 474)  |
| Similar    | 212 groups · 597 photos · 385 selected (keep 212)  |
| Dark       | 281 photos · 281 selected                          |
| Blurry     | 47 photos · 47 selected                            |


## Historical baseline (before native pipeline)

**Device:** SM A715W · **Photos:** 3606 · **Full scan:** **5m 25s**


| Category           | Duration       |
| ------------------ | -------------- |
| Catalog            | 45.8s          |
| Duplicates (exact) | 8.9s           |
| Similar hash       | 4m 25s (~14/s) |
| Similar group      | 1.2s           |
| **FULL SCAN**      | **5m 25s**     |


**Speedup vs old baseline:** ~8.7× wall clock (5m25s → 37.2s); catalog ~119×; fingerprint ~12× (~14/s → ~161/s).

## Architecture (current)

- **Native bulk MediaStore catalog** (`catalogImages`) — SIZE + metadata in one cursor
- **Native** `computeDHashBatch` — system `loadThumbnail(64×64)` + thread pool (4–8) → dHash + mean luminance + Laplacian blur
- **Delta fingerprints** — only photos missing `dHash` / `meanLuminance` on rescan
- Exact path: size collision → xxHash

## How to re-verify

1. Full restart (`flutter run` — native Kotlin changed; hot restart is not enough)
2. Clear app data or Rescan so fingerprints recompute
3. Watch `[ImageFinder.Scan]` for the final summary block
4. Paste into this file / `new.md` if numbers change
