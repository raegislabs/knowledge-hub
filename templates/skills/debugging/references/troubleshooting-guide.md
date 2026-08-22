# Troubleshooting Guide Reference

## Overview
Systematic approaches to diagnosing and resolving common system issues. This guide provides decision trees, diagnostic steps, and solutions for frequent problems.

---

## General Troubleshooting Process

### 1. Define the Problem
- What's the observable symptom?
- When did it start?
- Is it consistent or intermittent?
- What changed recently?

### 2. Gather Information
- Error messages
- Logs
- System metrics
- User reports
- Environment details

### 3. Form Hypothesis
- What could cause these symptoms?
- What's most likely?
- How can we test each theory?

### 4. Test & Verify
- Test one hypothesis at a time
- Document results
- Eliminate possibilities systematically

### 5. Implement Solution
- Fix root cause, not symptom
- Test fix thoroughly
- Monitor for recurrence

---

## Network Issues

### Symptom: Cannot Connect to Service

**Decision Tree:**
```
Can't connect to service
  ├─ Is service running?
  │   ├─ No → Start service
  │   └─ Yes → Continue
  ├─ Can you ping the host?
  │   ├─ No → Network/DNS issue
  │   └─ Yes → Continue
  ├─ Is port open?
  │   ├─ No → Firewall/port issue
  │   └─ Yes → Continue
  └─ Is service listening on correct port?
      ├─ No → Configuration issue
      └─ Yes → Application issue
```

**Diagnostic Steps:**

1. **Check if service is running**
   ```bash
   # Linux/Mac
   ps aux | grep service_name
   systemctl status service_name

   # Check specific port
   lsof -i :8080
   netstat -an | grep 8080
   ```

2. **Test connectivity**
   ```bash
   # Ping host
   ping hostname

   # Test port connectivity
   telnet hostname 8080
   nc -zv hostname 8080

   # Check DNS resolution
   nslookup hostname
   dig hostname
   ```

3. **Check firewall**
   ```bash
   # Linux
   sudo iptables -L

   # Mac
   sudo pfctl -sr

   # Check if port is open
   sudo ufw status
   ```

4. **Check service configuration**
   ```bash
   # Verify listening address
   netstat -an | grep LISTEN

   # Check configuration file
   cat /etc/service/config.conf
   ```

**Common Solutions:**

- **Service not running**: `systemctl start service_name`
- **Wrong port**: Update configuration file
- **Firewall blocking**: `sudo ufw allow 8080/tcp`
- **DNS not resolving**: Check `/etc/hosts` or DNS server

### Symptom: Slow Network Performance

**Diagnostic Steps:**

1. **Measure latency**
   ```bash
   # Ping for latency
   ping -c 10 hostname

   # Trace route
   traceroute hostname

   # Check bandwidth
   iperf3 -c hostname
   ```

2. **Check for packet loss**
   ```bash
   ping -c 100 hostname
   # Look for % packet loss
   ```

3. **Monitor network usage**
   ```bash
   # Real-time network monitoring
   iftop
   nethogs

   # Check bandwidth per process
   sudo lsof -i -P
   ```

**Common Causes:**
- High latency: Network congestion, geographic distance
- Packet loss: Network issues, overloaded router
- Slow transfer: Bandwidth limitation, server load

---

## Database Issues

### Symptom: Slow Queries

**Diagnostic Steps:**

1. **Identify slow queries**
   ```sql
   -- PostgreSQL
   SELECT pid, now() - query_start as duration, query
   FROM pg_stat_activity
   WHERE state = 'active'
   ORDER BY duration DESC;

   -- MySQL
   SHOW PROCESSLIST;

   -- Check slow query log
   SELECT * FROM mysql.slow_log LIMIT 10;
   ```

2. **Analyze query plan**
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM users WHERE email = 'test@example.com';
   ```

3. **Check for missing indexes**
   ```sql
   -- Look for sequential scans
   -- Should see "Index Scan" not "Seq Scan"
   ```

4. **Check database stats**
   ```sql
   -- PostgreSQL
   SELECT * FROM pg_stat_database;
   SELECT * FROM pg_stat_user_tables;

   -- MySQL
   SHOW STATUS;
   SHOW VARIABLES;
   ```

**Common Solutions:**

- **Missing index**: `CREATE INDEX idx_users_email ON users(email);`
- **Inefficient query**: Rewrite to avoid full table scan
- **Too many joins**: Denormalize or add caching
- **No query limit**: Add `LIMIT` clause

### Symptom: Connection Pool Exhausted

**Diagnostic Steps:**

1. **Check active connections**
   ```sql
   -- PostgreSQL
   SELECT count(*) FROM pg_stat_activity;

   -- MySQL
   SHOW STATUS WHERE Variable_name = 'Threads_connected';
   ```

2. **Find long-running connections**
   ```sql
   -- PostgreSQL
   SELECT pid, query_start, state, query
   FROM pg_stat_activity
   WHERE state != 'idle'
   ORDER BY query_start;
   ```

3. **Check connection pool settings**
   ```python
   # Application code
   print(f"Pool size: {pool.size}")
   print(f"Active connections: {pool.active_count}")
   print(f"Idle connections: {pool.idle_count}")
   ```

**Common Solutions:**

- **Connections not released**: Add `finally` blocks to close connections
- **Pool too small**: Increase max pool size
- **Long-running queries**: Add query timeouts
- **Connection leaks**: Use connection pooling context managers

```python
# Fix connection leak
def query_database():
    conn = None
    try:
        conn = pool.get_connection()
        result = conn.execute(query)
        return result
    finally:
        if conn:
            conn.close()  # Always release connection
```

---

## Memory Issues

### Symptom: Out of Memory

**Diagnostic Steps:**

1. **Check memory usage**
   ```bash
   # Overall memory
   free -h
   top
   htop

   # Per-process memory
   ps aux --sort=-%mem | head

   # Python memory profiling
   python -m memory_profiler script.py
   ```

2. **Check for memory leaks**
   ```python
   import tracemalloc

   tracemalloc.start()

   # Run code
   process_data()

   # Check memory usage
   current, peak = tracemalloc.get_traced_memory()
   print(f"Current memory: {current / 10**6}MB")
   print(f"Peak memory: {peak / 10**6}MB")

   tracemalloc.stop()
   ```

3. **Profile memory allocation**
   ```python
   from memory_profiler import profile

   @profile
   def memory_intensive_function():
       # Your code
       pass
   ```

**Common Causes:**

- **Memory leak**: Objects not freed, circular references
- **Large data structures**: Loading entire dataset into memory
- **Inefficient algorithms**: Creating too many temporary objects
- **No limits**: Unbounded caches or queues

**Solutions:**

```python
# Fix 1: Limit cache size
from functools import lru_cache

@lru_cache(maxsize=1000)  # Limit to 1000 entries
def expensive_function(arg):
    return compute(arg)

# Fix 2: Process in chunks
def process_large_file(filename):
    with open(filename) as f:
        while chunk := f.read(1024 * 1024):  # 1MB chunks
            process_chunk(chunk)

# Fix 3: Use generators
def get_all_users():
    # Bad: Loads all users into memory
    return User.query.all()

def get_all_users():
    # Good: Yields users one at a time
    for user in User.query.yield_per(100):
        yield user
```

### Symptom: Memory Growing Over Time

**Diagnostic Steps:**

1. **Monitor memory over time**
   ```bash
   # Watch memory usage
   watch -n 1 'ps aux | grep python'

   # Log memory usage
   while true; do
       date >> memory.log
       ps aux | grep python >> memory.log
       sleep 60
   done
   ```

2. **Find memory leaks**
   ```python
   import objgraph

   # Take snapshot before
   objgraph.show_growth()

   # Run code
   process_data()

   # Show what grew
   objgraph.show_growth()
   ```

**Common Leaks:**

- **Global caches**: `cache = {}` that grows forever
- **Event listeners**: Not removed after use
- **Circular references**: Parent-child references
- **Database connections**: Not closed

---

## Performance Issues

### Symptom: Application Slow

**Decision Tree:**
```
Application slow
  ├─ Is CPU high?
  │   ├─ Yes → CPU-bound issue
  │   │   ├─ Profile CPU usage
  │   │   └─ Optimize hot paths
  │   └─ No → Continue
  ├─ Is memory high?
  │   ├─ Yes → Memory issue
  │   │   ├─ Check for leaks
  │   │   └─ Reduce memory usage
  │   └─ No → Continue
  ├─ Is I/O wait high?
  │   ├─ Yes → I/O-bound issue
  │   │   ├─ Database slow?
  │   │   ├─ Disk slow?
  │   │   └─ Network slow?
  │   └─ No → Continue
  └─ Is load high?
      ├─ Yes → Too many requests
      │   ├─ Scale horizontally
      │   └─ Add caching
      └─ No → Application logic issue
```

**Diagnostic Steps:**

1. **Check system resources**
   ```bash
   # CPU, memory, load
   top
   htop

   # I/O wait
   iostat -x 1

   # Disk usage
   df -h
   du -sh /*
   ```

2. **Profile application**
   ```python
   import cProfile
   import pstats

   # CPU profiling
   cProfile.run('main()', 'stats')
   stats = pstats.Stats('stats')
   stats.sort_stats('cumulative')
   stats.print_stats(20)
   ```

3. **Check for bottlenecks**
   ```python
   import time

   def profile_section(name):
       start = time.time()
       yield
       duration = (time.time() - start) * 1000
       print(f"{name}: {duration:.2f}ms")

   # Usage
   with profile_section("Database query"):
       results = db.query(...)

   with profile_section("Processing"):
       process(results)
   ```

**Common Solutions:**

- **N+1 queries**: Use eager loading
- **No caching**: Add Redis/Memcached
- **Synchronous I/O**: Use async/await
- **Inefficient algorithm**: Optimize (O(n²) → O(n log n))
- **No indexing**: Add database indexes

---

## Application Crashes

### Symptom: Application Crashes Randomly

**Diagnostic Steps:**

1. **Check logs**
   ```bash
   # Application logs
   tail -f /var/log/application.log
   grep ERROR /var/log/application.log

   # System logs
   sudo journalctl -u service_name -f
   dmesg | tail
   ```

2. **Check for core dumps**
   ```bash
   # Enable core dumps
   ulimit -c unlimited

   # Find core dumps
   ls -lh /var/crash/
   ls -lh core.*
   ```

3. **Check for out of memory**
   ```bash
   # OOM killer logs
   dmesg | grep -i "out of memory"
   grep -i "killed process" /var/log/syslog
   ```

4. **Check for segfaults**
   ```bash
   # System logs for segfaults
   dmesg | grep segfault
   journalctl | grep segfault
   ```

**Common Causes:**

- **Uncaught exception**: Add error handling
- **Out of memory**: Reduce memory usage or increase limits
- **Segmentation fault**: Memory corruption (C extensions)
- **Resource exhaustion**: File descriptors, threads, connections

**Solutions:**

```python
# Add global exception handler
def handle_exception(exc_type, exc_value, exc_traceback):
    logger.error(
        "Uncaught exception",
        exc_info=(exc_type, exc_value, exc_traceback)
    )

sys.excepthook = handle_exception

# Add signal handlers
import signal

def handle_signal(signum, frame):
    logger.info(f"Received signal {signum}, shutting down gracefully")
    cleanup()
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_signal)
signal.signal(signal.SIGINT, handle_signal)
```

---

## Deployment Issues

### Symptom: Works Locally, Fails in Production

**Checklist:**

1. **Environment variables**
   ```bash
   # Compare env vars
   env | sort > local_env.txt
   ssh prod 'env | sort' > prod_env.txt
   diff local_env.txt prod_env.txt
   ```

2. **Dependencies**
   ```bash
   # Python
   pip freeze > local_requirements.txt
   ssh prod 'pip freeze' > prod_requirements.txt
   diff local_requirements.txt prod_requirements.txt

   # Node.js
   npm list > local_packages.txt
   ssh prod 'npm list' > prod_packages.txt
   diff local_packages.txt prod_packages.txt
   ```

3. **Configuration**
   ```bash
   # Compare config files
   diff config/local.yml config/production.yml
   ```

4. **Permissions**
   ```bash
   # Check file permissions
   ls -la /app/
   ls -la /var/log/app/

   # Check user/group
   whoami
   groups
   ```

5. **Resources**
   ```bash
   # Check available resources
   free -h  # Memory
   df -h    # Disk
   nproc    # CPU cores
   ```

**Common Differences:**

- **DEBUG mode**: On locally, off in production
- **Database**: Different databases (SQLite vs PostgreSQL)
- **Secrets**: Different credentials
- **Paths**: Absolute vs relative paths
- **Timezone**: Different timezone settings

---

## API Issues

### Symptom: API Returns 500 Error

**Diagnostic Steps:**

1. **Check application logs**
   ```bash
   tail -f /var/log/application.log
   ```

2. **Check request details**
   ```bash
   # Verbose request with curl
   curl -v -X POST https://api.example.com/endpoint \
     -H "Content-Type: application/json" \
     -d '{"key": "value"}'
   ```

3. **Test locally**
   ```bash
   # Same request to local server
   curl -v -X POST http://localhost:8000/endpoint \
     -H "Content-Type: application/json" \
     -d '{"key": "value"}'
   ```

**Common Causes:**

- **Uncaught exception**: Add try/except
- **Invalid input**: Add validation
- **Database error**: Check database connection
- **Missing dependency**: Check imports

### Symptom: API Returns 404

**Checklist:**

- [ ] Is route registered correctly?
- [ ] Is URL correct (trailing slash, casing)?
- [ ] Is method correct (GET vs POST)?
- [ ] Is middleware interfering?

```python
# Debug route registration
from flask import Flask
app = Flask(__name__)

# List all registered routes
for rule in app.url_map.iter_rules():
    print(f"{rule.endpoint}: {rule.methods} {rule.rule}")
```

---

## Docker Issues

### Symptom: Container Won't Start

**Diagnostic Steps:**

1. **Check container logs**
   ```bash
   docker logs container_name
   docker logs -f container_name  # Follow logs
   ```

2. **Check container status**
   ```bash
   docker ps -a  # Show all containers including stopped
   docker inspect container_name
   ```

3. **Try running interactively**
   ```bash
   docker run -it image_name /bin/bash
   # Debug inside container
   ```

**Common Causes:**

- **Missing environment variables**: Set in docker-compose.yml
- **Port already in use**: Change port mapping
- **Volume mount issues**: Check paths and permissions
- **Insufficient resources**: Increase Docker memory/CPU limits

### Symptom: Container Keeps Restarting

**Check restart reason:**
```bash
docker inspect container_name | grep -A 5 State
```

**Common Causes:**

- **Application crashes**: Check application logs
- **Health check failing**: Review health check endpoint
- **Out of memory**: Increase memory limit
- **Startup timeout**: Increase timeout or optimize startup

---

## Quick Troubleshooting Commands

### System
```bash
top                    # CPU and memory usage
htop                   # Better top
df -h                  # Disk usage
free -h                # Memory usage
uptime                 # System load
dmesg                  # Kernel messages
journalctl -f          # System logs
```

### Network
```bash
ping hostname          # Test connectivity
traceroute hostname    # Trace network path
netstat -an            # Network connections
lsof -i :port          # What's using port
tcpdump -i any         # Capture network traffic
```

### Process
```bash
ps aux                 # All processes
ps aux | grep name     # Find process
kill -9 pid            # Kill process
strace -p pid          # Trace system calls
lsof -p pid            # Files opened by process
```

### Disk
```bash
df -h                  # Disk space
du -sh *               # Directory sizes
lsof | grep deleted    # Deleted but open files
iostat -x 1            # Disk I/O stats
```

---

## Troubleshooting Mindset

### Ask These Questions

1. **What changed?** Most issues follow a change
2. **Can you reproduce it?** Consistent vs intermittent
3. **When did it start?** Correlate with deployments/changes
4. **Does it happen everywhere?** One server or all?
5. **What does the data say?** Logs, metrics, traces

### Remember

- **Start with logs** - They usually have the answer
- **Change one thing** - Test after each change
- **Document steps** - You'll need them later
- **Ask for help** - Fresh eyes help
- **Take breaks** - Stuck? Walk away briefly
