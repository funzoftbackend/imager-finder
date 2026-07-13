# Image Finder — First Full Scan Timing Report

**Device:** SM A715W (wireless)  
**Photos scanned:** 3606  
**Exact duplicate groups:** 478 (958 photos)  
**Similar groups:** 149  
**Result:** Scan completed successfully (`failed=0` on similar hashing)

---

## Summary

| Category | Duration |
| --- | ---: |
| **Duplicates (exact)** | **8.9s** (8,933 ms) |
| **Similar** | **4m 26s** (265,964 ms) |
| **FULL SCAN** | **5m 25s** (324,856 ms) |

Similar work is ~**82%** of total wall time. Catalog (gallery index) is the next largest cost at ~**14%**.

---

## Step-by-step

| Step | Duration | Detail |
| --- | ---: | --- |
| permission | 2.8s (2,773 ms) | `state=authorized` |
| catalog | 45.8s (45,785 ms) | `photos=3606` |
| diff | 590 ms | `new=3606 changed=0 removed=0 unchanged=0` |
| exact_hash | 6.5s (6,495 ms) | `candidates=999 hashed≈999` |
| exact_group | 2.4s (2,438 ms) | `groups=478 photos=958` |
| similar_hash | 4m 25s (264,720 ms) | `photos=3606 failed=0 rate≈13.6/s` |
| similar_group_prepare | 17 ms | `fingerprints=3606` |
| similar_group | 1.2s (1,227 ms) | `fingerprints=3606 groups=149` |
| persist | 696 ms | `exactGroups=478 similarGroups=149` |

---

## Rollups

### Duplicates (exact) — 8.9s

| Sub-step | Duration |
| --- | ---: |
| exact_hash | 6.5s |
| exact_group | 2.4s |
| **Total** | **8.9s** |

### Similar — 4m 26s

| Sub-step | Duration |
| --- | ---: |
| similar_hash | 4m 25s |
| similar_group_prepare | 17 ms |
| similar_group | 1.2s |
| **Total** | **4m 26s** |

### Other overhead (outside exact/similar rollups)

| Step | Duration | Notes |
| --- | ---: | --- |
| permission | 2.8s | User/system permission grant |
| catalog | 45.8s | MediaStore inventory (metadata + sizes) |
| diff | 590 ms | First scan: all 3606 treated as new |
| persist | 696 ms | Save groups + scan meta |

---

## Similar hash milestones

Rate stayed roughly **13.4–14.2 photos/s** throughout.

| Progress | Step elapsed | Wall total | Rate |
| --- | ---: | ---: | ---: |
| 520 / 3606 | 38.9s | 1m 37s | 13.4/s |
| 1000 / 3606 | 1m 11s | 2m 9s | 14.1/s |
| 1520 / 3606 | 1m 47s | 2m 45s | 14.2/s |
| 2000 / 3606 | 2m 24s | 3m 22s | 13.9/s |
| 2520 / 3606 | 3m 0s | 3m 58s | 14.0/s |
| 3000 / 3606 | 3m 35s | 4m 33s | 14.0/s |
| 3520 / 3606 | 4m 15s | 5m 13s | 13.8/s |
| 3606 / 3606 | 4m 25s | 5m 23s | 13.6/s |

---

## Takeaways

1. **Bottleneck:** `similar_hash` (~4m 25s) — thumbnail fetch + dHash for every photo.
2. **Second cost:** `catalog` (~46s) — MediaStore paging + per-photo `fileSize`.
3. **Exact path is fast:** ~9s for 999 hash candidates → 478 groups.
4. **Grouping is no longer the stall:** `similar_group` finished in ~1.2s for 3606 fingerprints (149 groups).
5. **Rescans should be faster** on catalog/diff/exact when most photos are unchanged (this run was a cold first scan: `new=3606`).

---

*Generated from `ImageFinder.Scan` console output on SM A715W.*
