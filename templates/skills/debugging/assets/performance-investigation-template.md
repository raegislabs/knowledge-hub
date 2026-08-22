# Performance Investigation: {Issue Title}

## Overview
**Date**: {YYYY-MM-DD}
**Investigator**: {Your name}
**System/Component**: {What's being investigated}
**Performance Goal**: {Target metric - e.g., <200ms response time}

## Problem Statement
**Symptom**: {Observable performance issue}
**Current Performance**: {Measured value}
**Target Performance**: {Desired value}
**Gap**: {Difference between current and target}

## Performance Baseline

### Current Metrics
| Metric | Current | Target | Gap |
|--------|---------|--------|-----|
| Response Time (p50) | {value}ms | {target}ms | {delta}ms |
| Response Time (p95) | {value}ms | {target}ms | {delta}ms |
| Response Time (p99) | {value}ms | {target}ms | {delta}ms |
| Throughput | {value} req/s | {target} req/s | {delta} |
| CPU Usage | {value}% | {target}% | {delta}% |
| Memory Usage | {value}MB | {target}MB | {delta}MB |
| Database Queries | {value} queries | {target} | {delta} |
| Database Time | {value}ms | {target}ms | {delta}ms |

### Test Conditions
- **Load**: {Number of concurrent users/requests}
- **Data volume**: {Size of test dataset}
- **Environment**: {Development, staging, production}
- **Time period**: {When measurements taken}

## Initial Hypotheses

### Hypothesis 1: {Description}
**Likelihood**: High | Medium | Low
**Impact if true**: High | Medium | Low
**How to test**: {Testing approach}

### Hypothesis 2: {Description}
**Likelihood**: High | Medium | Low
**Impact if true**: High | Medium | Low
**How to test**: {Testing approach}

### Hypothesis 3: {Description}
**Likelihood**: High | Medium | Low
**Impact if true**: High | Medium | Low
**How to test**: {Testing approach}

## Profiling Results

### CPU Profiling

**Tool used**: {cProfile, py-spy, perf, Chrome DevTools, etc.}

**Top 10 Functions by Time**:
```
ncalls  tottime  percall  cumname  Function
------  -------  -------  -------  --------
  1000  2.453    0.002    process_data (data.py:42)
   500  1.876    0.004    fetch_from_db (db.py:123)
  5000  1.234    0.000    validate_input (validators.py:56)
```

**Hotspots identified**:
1. **{Function/module 1}**: {X}% of total time
   - Location: {File:line}
   - Reason: {Why it's slow}

2. **{Function/module 2}**: {Y}% of total time
   - Location: {File:line}
   - Reason: {Why it's slow}

### Memory Profiling

**Tool used**: {memory_profiler, tracemalloc, heapy, etc.}

**Memory usage over time**:
```
Line    Mem usage    Increment   Occurrences   Line Contents
====    =========    =========   ===========   =============
42      100.5 MiB    0.0 MiB     1             def process_data(items):
43      150.2 MiB    49.7 MiB    1                 cache = [item.copy() for item in items]
44      175.8 MiB    25.6 MiB    1                 results = process_all(cache)
```

**Memory issues identified**:
1. **{Issue 1}**: {Description}
   - Peak memory: {value}MB
   - Cause: {Explanation}

2. **{Issue 2}**: {Description}
   - Leak rate: {X}MB per request
   - Cause: {Explanation}

### Database Profiling

**Tool used**: {EXPLAIN ANALYZE, slow query log, APM tool}

**Slow queries identified**:

#### Query 1
```sql
-- Execution time: 2.3s
SELECT u.*, p.*
FROM users u
LEFT JOIN preferences p ON u.id = p.user_id
WHERE u.created_at > '2024-01-01'
ORDER BY u.name;
```

**EXPLAIN analysis**:
```
Seq Scan on users  (cost=0.00..10000.00 rows=50000)
  Filter: (created_at > '2024-01-01')
  -> Index Scan on preferences (cost=0.29..8.31 rows=1)
```

**Issues**:
- ❌ Sequential scan on large table
- ❌ No index on `created_at`
- ❌ ORDER BY requires sort

**Impact**: {X} queries per request, {Y}ms each = {total}ms

#### Query 2
{Another slow query}

### Network Profiling

**Tool used**: {Chrome DevTools, curl, tcpdump, etc.}

**Network waterfall**:
```
Request 1: GET /api/data     200ms ████████████████
Request 2: GET /api/users     150ms ████████████
Request 3: GET /api/settings  100ms ████████
Total serial time: 450ms
```

**Issues identified**:
- ❌ {Number} sequential requests (should be parallel)
- ❌ No caching on {endpoint}
- ❌ Large payload: {size}MB (could compress)

## Bottleneck Analysis

### Primary Bottleneck
**Component**: {Database, API call, computation, etc.}
**Time consumed**: {X}ms ({Y}% of total)
**Impact**: {How it affects overall performance}

**Evidence**:
- {Profiling data}
- {Metrics}
- {Logs}

### Secondary Bottlenecks
1. **{Bottleneck 1}**: {X}ms ({Y}% of total)
2. **{Bottleneck 2}**: {X}ms ({Y}% of total)
3. **{Bottleneck 3}**: {X}ms ({Y}% of total)

### Bottleneck Dependencies
{Map how bottlenecks interact}

```
User Request (1000ms total)
  ├─ Database Query (600ms) ← PRIMARY BOTTLENECK
  │   ├─ Query parsing (10ms)
  │   ├─ Sequential scan (500ms) ← ROOT CAUSE
  │   └─ Result marshalling (90ms)
  ├─ Business logic (300ms) ← SECONDARY
  │   └─ Inefficient algorithm (280ms)
  └─ Response formatting (100ms)
```

## Root Cause Analysis

### Technical Root Cause
{Detailed explanation of why performance is poor}

**Mechanism**: {How the slowness manifests}
**Location**: {File, function, component}
**Why it's slow**: {Technical explanation}

### Contributing Factors
1. **{Factor 1}**: {How it contributes}
   - Impact: {Percentage or time}

2. **{Factor 2}**: {How it contributes}
   - Impact: {Percentage or time}

### Performance Anti-patterns Identified
- [ ] N+1 query problem
- [ ] Missing database indexes
- [ ] Inefficient algorithm (O(n²) instead of O(n))
- [ ] No caching (computing same thing repeatedly)
- [ ] Synchronous when could be async
- [ ] Loading entire dataset into memory
- [ ] No pagination on large lists
- [ ] Serialization/deserialization overhead
- [ ] Resource leaks (connections, file handles)
- [ ] Blocking I/O on critical path

## Optimization Solutions

### Solution 1: {Description}
**Type**: Algorithm | Database | Caching | Architecture | Infrastructure

**Implementation**:
```python
# Before (slow)
def process_items(items):
    results = []
    for item in items:
        user = db.query(User).filter_by(id=item.user_id).first()  # N+1!
        results.append(process(item, user))
    return results

# After (fast)
def process_items(items):
    # Batch load users
    user_ids = {item.user_id for item in items}
    users = {u.id: u for u in db.query(User).filter(User.id.in_(user_ids))}

    # Process with cached users
    results = [process(item, users[item.user_id]) for item in items]
    return results
```

**Expected improvement**: {X}ms → {Y}ms ({Z}% faster)
**Implementation effort**: {Hours/days}
**Risk**: Low | Medium | High

### Solution 2: {Description}
**Type**: Algorithm | Database | Caching | Architecture | Infrastructure

**Implementation**:
```sql
-- Before (slow)
SELECT * FROM users WHERE created_at > '2024-01-01' ORDER BY name;

-- After (fast)
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_name ON users(name);

SELECT * FROM users WHERE created_at > '2024-01-01' ORDER BY name;
```

**Expected improvement**: {X}ms → {Y}ms ({Z}% faster)
**Implementation effort**: {Hours/days}
**Risk**: Low | Medium | High

### Solution 3: {Description}
{Additional solutions...}

## Optimization Plan

### Phase 1: Quick Wins (Low effort, high impact)
1. **{Optimization 1}**
   - Effort: {X hours}
   - Expected improvement: {Y}%
   - Risk: Low

2. **{Optimization 2}**
   - Effort: {X hours}
   - Expected improvement: {Y}%
   - Risk: Low

**Phase 1 Total Impact**: {Expected total improvement}

### Phase 2: Medium-term (Medium effort, medium impact)
1. **{Optimization 3}**
   - Effort: {X days}
   - Expected improvement: {Y}%
   - Risk: Medium

### Phase 3: Long-term (High effort, transformative)
1. **{Optimization 4}**
   - Effort: {X weeks}
   - Expected improvement: {Y}%
   - Risk: High
   - Note: {Requires architecture change, etc.}

## Testing & Validation

### Performance Tests
```python
import pytest
import time

def test_performance_process_items():
    """Process 1000 items should complete in <500ms"""
    items = generate_test_items(1000)

    start = time.time()
    result = process_items(items)
    duration = (time.time() - start) * 1000

    assert duration < 500, f"Too slow: {duration}ms"
    assert len(result) == 1000
```

### Benchmark Results

**Before optimization**:
```
Benchmark: process_items (1000 items)
  Min:     1250ms
  Median:  1453ms
  P95:     1678ms
  Max:     2103ms
```

**After optimization**:
```
Benchmark: process_items (1000 items)
  Min:     142ms  (8.8x faster)
  Median:  168ms  (8.6x faster)
  P95:     203ms  (8.3x faster)
  Max:     287ms  (7.3x faster)
```

**Goals met**: ✅ Yes | ❌ No | ⚠️ Partial

### Load Testing

**Tool used**: {Locust, JMeter, k6, etc.}

**Test scenario**:
- Users: {Number of concurrent users}
- Duration: {Test duration}
- Ramp-up: {How quickly users added}

**Results**:
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| RPS | {value} | {value} | {delta} |
| p50 | {value}ms | {value}ms | {delta}ms |
| p95 | {value}ms | {value}ms | {delta}ms |
| Error rate | {value}% | {value}% | {delta}% |

## Monitoring & Alerts

### Metrics to Track
- {Metric 1}: {Why important}
- {Metric 2}: {Why important}
- {Metric 3}: {Why important}

### Alert Thresholds
```yaml
alerts:
  - name: "Slow API Response"
    metric: response_time_p95
    threshold: 500ms
    severity: warning

  - name: "High Database Load"
    metric: db_query_time_p95
    threshold: 200ms
    severity: critical
```

### Dashboard
{Link to monitoring dashboard or description of metrics to visualize}

## Follow-up

### Immediate Actions
- [ ] {Action 1}
- [ ] {Action 2}

### Future Optimizations
- {Optimization to consider later}
- {Area to investigate further}

### Review Schedule
- **1 week**: Check if performance improvements sustained
- **1 month**: Review for regression
- **Quarterly**: Re-benchmark and identify new opportunities

## Appendix

### Tools Used
- **Profiling**: {Tools}
- **Benchmarking**: {Tools}
- **Monitoring**: {Tools}

### Environment Details
- **Hardware**: {CPU, RAM, disk}
- **Software**: {OS, runtime versions}
- **Configuration**: {Relevant settings}

### References
- {Link to profiling reports}
- {Link to benchmark data}
- {Link to related performance investigations}
