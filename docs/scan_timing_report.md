# Image Finder — Scan Timing Report

## Baseline (before native pipeline)

**Device:** SM A715W · **Photos:** 3606 · **Full scan:** **5m 25s**


| Category           | Duration       |
| ------------------ | -------------- |
| Catalog            | 45.8s          |
| Duplicates (exact) | 8.9s           |
| Similar hash       | 4m 25s (~14/s) |
| Similar group      | 1.2s           |
| **FULL SCAN**      | **5m 25s**     |


## Target architecture (implemented)

- **Native bulk MediaStore catalog** (`catalogImages`) — SIZE + metadata in one cursor
- **Native** `computeDHashBatch` — system `loadThumbnail(32×32)` + thread pool (4–8) dHash
- **Delta similar** — only photos missing `dHash` on rescan
- Exact path unchanged (size collision → xxHash)

**Expected first full scan:** ~45–90s on mid-range (verify on device after a **full rebuild**).

## How to verify

1. Full restart (`flutter run` — native Kotlin changed; hot restart is not enough)
2. Clear app data or Rescan so similar hashes recompute
3. Watch `[ImageFinder.Scan]` for catalog / similar_hash rates
4. Paste the final report block to refresh numbers below



### Checklist

- [ ] Catalog much less than 46s (aim under 5s)
- [ ] similar_hash rate much greater than 14/s (aim 80+/s)
- [ ] FULL SCAN in about 1–2 minutes
- [ ] Exact ~478 groups / similar groups still useful
- [ ] No isolate / MethodChannel errors