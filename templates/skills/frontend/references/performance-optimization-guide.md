# Performance Optimization Guide

## Bundle Size Optimization

### Code Splitting

**Route-based splitting**:
```typescript
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// Lazy load route components
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Profile = lazy(() => import('./pages/Profile'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

**Component-based splitting**:
```typescript
import { lazy, Suspense } from 'react';

// Only load heavy components when needed
const HeavyChart = lazy(() => import('./HeavyChart'));
const VideoPlayer = lazy(() => import('./VideoPlayer'));

function Dashboard() {
  const [showChart, setShowChart] = useState(false);

  return (
    <div>
      <button onClick={() => setShowChart(true)}>Show Chart</button>

      {showChart && (
        <Suspense fallback={<div>Loading chart...</div>}>
          <HeavyChart />
        </Suspense>
      )}
    </div>
  );
}
```

### Tree Shaking

```typescript
// ✅ Good - Named imports (tree-shakeable)
import { debounce } from 'lodash-es';

// ❌ Bad - Default import (entire library)
import _ from 'lodash';

// ✅ Good - Individual lodash packages
import debounce from 'lodash.debounce';
```

### Dynamic Imports

```typescript
// Load library only when needed
async function handleExport() {
  const { default: xlsx } from await import('xlsx');

  // Use xlsx library
  const workbook = xlsx.utils.book_new();
  // ...
}

// Load polyfill only for old browsers
async function loadPolyfills() {
  if (!('IntersectionObserver' in window)) {
    await import('intersection-observer');
  }
}
```

### Bundle Analysis

```bash
# Webpack Bundle Analyzer
npm install --save-dev webpack-bundle-analyzer

# In webpack.config.js
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

module.exports = {
  plugins: [
    new BundleAnalyzerPlugin()
  ]
};

# Run build and view report
npm run build
```

## React Performance

### React.memo

```typescript
// ✅ Memoize components that re-render often with same props
const ExpensiveComponent = memo(function ExpensiveComponent({ data }) {
  // Expensive computation or rendering
  return <div>{processData(data)}</div>;
});

// Custom comparison function
const UserCard = memo(
  function UserCard({ user, onEdit }) {
    return <div>{user.name}</div>;
  },
  (prevProps, nextProps) => {
    // Only re-render if user.id changes
    return prevProps.user.id === nextProps.user.id;
  }
);
```

**When NOT to use memo**:
```typescript
// ❌ Don't memo simple components
const Button = memo(({ children, onClick }) => (
  <button onClick={onClick}>{children}</button>
));

// ❌ Don't memo if props always change
const Clock = memo(({ time }) => <div>{time}</div>);
```

### useMemo

```typescript
function SearchResults({ query, items }) {
  // ✅ Memoize expensive computations
  const filteredItems = useMemo(() => {
    console.log('Filtering items...');
    return items
      .filter(item => item.name.toLowerCase().includes(query.toLowerCase()))
      .sort((a, b) => a.score - b.score);
  }, [query, items]);

  return <div>{filteredItems.map(item => <Item key={item.id} {...item} />)}</div>;
}
```

**When NOT to use useMemo**:
```typescript
// ❌ Don't memoize simple operations
const doubled = useMemo(() => value * 2, [value]);

// ✅ Just compute directly
const doubled = value * 2;
```

### useCallback

```typescript
function UserList({ users }) {
  // ✅ Memoize callbacks passed to memoized children
  const handleUserClick = useCallback((userId: string) => {
    console.log('User clicked:', userId);
    // Navigate to user profile
  }, []);

  return (
    <div>
      {users.map(user => (
        <UserCard
          key={user.id}
          user={user}
          onClick={handleUserClick} // Stable reference
        />
      ))}
    </div>
  );
}

const UserCard = memo(function UserCard({ user, onClick }) {
  return (
    <div onClick={() => onClick(user.id)}>
      {user.name}
    </div>
  );
});
```

### Key Prop Optimization

```typescript
// ✅ Good - Stable, unique keys
{items.map(item => (
  <Item key={item.id} {...item} />
))}

// ❌ Bad - Index as key (causes re-renders on reorder)
{items.map((item, index) => (
  <Item key={index} {...item} />
))}

// ❌ Bad - Random keys (forces re-creation)
{items.map(item => (
  <Item key={Math.random()} {...item} />
))}
```

### Virtualization

```typescript
import { FixedSizeList } from 'react-window';

function VirtualizedList({ items }) {
  const Row = ({ index, style }) => (
    <div style={style}>
      <Item item={items[index]} />
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={80}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}

// For variable-size items
import { VariableSizeList } from 'react-window';

function VariableSizeVirtualizedList({ items }) {
  const getItemSize = (index) => {
    // Calculate height based on content
    return items[index].expanded ? 200 : 80;
  };

  const Row = ({ index, style }) => (
    <div style={style}>
      <Item item={items[index]} />
    </div>
  );

  return (
    <VariableSizeList
      height={600}
      itemCount={items.length}
      itemSize={getItemSize}
      width="100%"
    >
      {Row}
    </VariableSizeList>
  );
}
```

## Image Optimization

### Lazy Loading

```typescript
// Native lazy loading
function ImageGallery({ images }) {
  return (
    <div>
      {images.map(img => (
        <img
          key={img.id}
          src={img.url}
          alt={img.alt}
          loading="lazy"
          width={img.width}
          height={img.height}
        />
      ))}
    </div>
  );
}

// Intersection Observer for more control
function LazyImage({ src, alt }) {
  const [isLoaded, setIsLoaded] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          setIsLoaded(true);
          observer.disconnect();
        }
      },
      { rootMargin: '100px' }
    );

    if (imgRef.current) {
      observer.observe(imgRef.current);
    }

    return () => observer.disconnect();
  }, []);

  return (
    <img
      ref={imgRef}
      src={isLoaded ? src : '/placeholder.jpg'}
      alt={alt}
    />
  );
}
```

### Responsive Images

```typescript
function ResponsiveImage({ src, alt }) {
  return (
    <picture>
      <source
        media="(min-width: 1024px)"
        srcSet={`${src}-large.webp`}
        type="image/webp"
      />
      <source
        media="(min-width: 768px)"
        srcSet={`${src}-medium.webp`}
        type="image/webp"
      />
      <source
        srcSet={`${src}-small.webp`}
        type="image/webp"
      />
      <img src={`${src}.jpg`} alt={alt} />
    </picture>
  );
}
```

### Image Compression

```typescript
// Use next/image (Next.js)
import Image from 'next/image';

function OptimizedImage() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero image"
      width={1200}
      height={600}
      quality={80}
      placeholder="blur"
      blurDataURL="/hero-blur.jpg"
    />
  );
}
```

## Network Optimization

### Request Deduplication

```typescript
// Cache and deduplicate requests
const requestCache = new Map();

async function fetchWithCache(url: string) {
  if (requestCache.has(url)) {
    return requestCache.get(url);
  }

  const promise = fetch(url).then(res => res.json());
  requestCache.set(url, promise);

  return promise;
}

// Use React Query for automatic deduplication
import { useQuery } from '@tanstack/react-query';

function UserProfile({ userId }) {
  const { data, isLoading } = useQuery(
    ['user', userId],
    () => fetchUser(userId),
    {
      staleTime: 5 * 60 * 1000, // 5 minutes
    }
  );

  if (isLoading) return <Spinner />;
  return <div>{data.name}</div>;
}
```

### Debouncing and Throttling

```typescript
import { useMemo } from 'react';
import { debounce, throttle } from 'lodash';

function SearchInput() {
  const [query, setQuery] = useState('');

  // Debounce search requests
  const debouncedSearch = useMemo(
    () => debounce((value: string) => {
      apiClient.get(`/search?q=${value}`);
    }, 300),
    []
  );

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setQuery(value);
    debouncedSearch(value);
  };

  return <input value={query} onChange={handleChange} />;
}

function ScrollTracker() {
  // Throttle scroll events
  const handleScroll = useMemo(
    () => throttle(() => {
      console.log('Scroll position:', window.scrollY);
    }, 100),
    []
  );

  useEffect(() => {
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [handleScroll]);

  return null;
}
```

### Prefetching

```typescript
import { useEffect } from 'react';

function PrefetchLinks() {
  useEffect(() => {
    // Prefetch likely next page
    const link = document.createElement('link');
    link.rel = 'prefetch';
    link.href = '/next-page';
    document.head.appendChild(link);

    return () => {
      document.head.removeChild(link);
    };
  }, []);

  return null;
}

// Prefetch on hover
function NavigationLink({ to, children }) {
  const [prefetched, setPrefetched] = useState(false);

  const handleMouseEnter = () => {
    if (!prefetched) {
      const link = document.createElement('link');
      link.rel = 'prefetch';
      link.href = to;
      document.head.appendChild(link);
      setPrefetched(true);
    }
  };

  return (
    <a href={to} onMouseEnter={handleMouseEnter}>
      {children}
    </a>
  );
}
```

## Rendering Optimization

### Avoid Inline Functions

```typescript
// ❌ Bad - Creates new function on every render
function List({ items }) {
  return (
    <div>
      {items.map(item => (
        <Item
          key={item.id}
          onClick={() => console.log(item.id)}
        />
      ))}
    </div>
  );
}

// ✅ Good - Stable callback
function List({ items }) {
  const handleClick = useCallback((id: string) => {
    console.log(id);
  }, []);

  return (
    <div>
      {items.map(item => (
        <Item
          key={item.id}
          onClick={() => handleClick(item.id)}
        />
      ))}
    </div>
  );
}
```

### Avoid Inline Objects/Arrays

```typescript
// ❌ Bad - Creates new object on every render
function Component() {
  return <Child style={{ margin: 10 }} />;
}

// ✅ Good - Stable object reference
const style = { margin: 10 };

function Component() {
  return <Child style={style} />;
}

// Or use useMemo for dynamic values
function Component({ value }) {
  const style = useMemo(() => ({ margin: value }), [value]);
  return <Child style={style} />;
}
```

### Conditional Rendering

```typescript
// ✅ Efficient - Only renders when needed
function ConditionalComponent({ show, data }) {
  if (!show) return null;

  return <ExpensiveComponent data={data} />;
}

// ❌ Inefficient - Always renders, hides with CSS
function ConditionalComponent({ show, data }) {
  return (
    <div style={{ display: show ? 'block' : 'none' }}>
      <ExpensiveComponent data={data} />
    </div>
  );
}
```

### Fragment Usage

```typescript
// ✅ Good - No extra DOM nodes
function List({ items }) {
  return (
    <>
      {items.map(item => (
        <div key={item.id}>{item.name}</div>
      ))}
    </>
  );
}

// ❌ Bad - Extra wrapper div
function List({ items }) {
  return (
    <div>
      {items.map(item => (
        <div key={item.id}>{item.name}</div>
      ))}
    </div>
  );
}
```

## State Management Performance

### State Colocation

```typescript
// ✅ Good - State close to where it's used
function UserCard({ user }) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div>
      <button onClick={() => setExpanded(!expanded)}>
        {expanded ? 'Collapse' : 'Expand'}
      </button>
      {expanded && <UserDetails user={user} />}
    </div>
  );
}

// ❌ Bad - Global state for local UI
function UserCard({ user, expanded, setExpanded }) {
  // Causes entire app to re-render when toggled
  return <div>...</div>;
}
```

### Lazy Initial State

```typescript
// ✅ Good - Expensive computation only once
function Component() {
  const [data, setData] = useState(() => {
    return expensiveComputation();
  });

  return <div>{data}</div>;
}

// ❌ Bad - Runs on every render
function Component() {
  const [data, setData] = useState(expensiveComputation());
  return <div>{data}</div>;
}
```

### Batched Updates

```typescript
import { unstable_batchedUpdates } from 'react-dom';

// React 18 automatically batches updates
function handleClick() {
  setCount(c => c + 1);
  setFlag(f => !f);
  // Only one re-render
}

// React 17 - Manual batching for async updates
async function handleAsyncUpdate() {
  const data = await fetchData();

  unstable_batchedUpdates(() => {
    setData(data);
    setLoading(false);
  });
}
```

## Profiling and Monitoring

### React DevTools Profiler

```typescript
import { Profiler } from 'react';

function App() {
  const onRenderCallback = (
    id: string,
    phase: 'mount' | 'update',
    actualDuration: number,
    baseDuration: number,
    startTime: number,
    commitTime: number
  ) => {
    console.log(`${id} (${phase}) took ${actualDuration}ms`);
  };

  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <Dashboard />
    </Profiler>
  );
}
```

### Performance Monitoring

```typescript
// Measure component render time
function measureRenderTime(componentName: string) {
  return {
    onRender: (
      id: string,
      phase: 'mount' | 'update',
      actualDuration: number
    ) => {
      // Send to analytics
      analytics.track('component_render', {
        component: componentName,
        phase,
        duration: actualDuration,
      });
    },
  };
}

<Profiler {...measureRenderTime('Dashboard')}>
  <Dashboard />
</Profiler>
```

## Performance Budget

### Metrics to Track

| Metric | Target | Tool |
|--------|--------|------|
| First Contentful Paint (FCP) | < 1.8s | Lighthouse |
| Largest Contentful Paint (LCP) | < 2.5s | Lighthouse |
| Time to Interactive (TTI) | < 3.8s | Lighthouse |
| Total Blocking Time (TBT) | < 200ms | Lighthouse |
| Cumulative Layout Shift (CLS) | < 0.1 | Lighthouse |
| Bundle Size | < 200KB (gzipped) | webpack-bundle-analyzer |

### Bundle Size Budget

```json
// package.json
{
  "bundlesize": [
    {
      "path": "./dist/main.*.js",
      "maxSize": "200 KB"
    },
    {
      "path": "./dist/vendor.*.js",
      "maxSize": "300 KB"
    }
  ]
}
```

## Checklist

### Initial Load Performance
- [ ] Code splitting implemented
- [ ] Route-based lazy loading
- [ ] Tree shaking enabled
- [ ] Images optimized and lazy loaded
- [ ] Critical CSS inlined
- [ ] Unused dependencies removed
- [ ] Bundle size analyzed

### Runtime Performance
- [ ] Expensive components memoized
- [ ] Callbacks memoized with useCallback
- [ ] Expensive computations memoized with useMemo
- [ ] Large lists virtualized
- [ ] State colocated
- [ ] Unnecessary re-renders eliminated

### Network Performance
- [ ] API requests deduplicated
- [ ] Search/scroll debounced or throttled
- [ ] Data cached appropriately
- [ ] Prefetching for likely navigation
- [ ] Compression enabled (gzip/brotli)

### Monitoring
- [ ] Performance profiling in CI
- [ ] Bundle size tracked
- [ ] Core Web Vitals monitored
- [ ] Performance budget enforced
