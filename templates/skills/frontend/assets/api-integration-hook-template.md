# API Integration Hook Template

## Custom Hook Implementation

```typescript
/**
 * Custom hook for {feature} API integration
 */

import { useState, useEffect } from 'react';
import { apiClient } from '@/lib/api';

interface UseFeatureDataResult {
  data: FeatureData | null;
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

export const useFeatureData = (id: string): UseFeatureDataResult => {
  const [data, setData] = useState<FeatureData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await apiClient.get(`/api/feature/${id}`);
      setData(response.data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [id]);

  return { data, loading, error, refetch: fetchData };
};
```

## Mutation Hook (POST/PUT/DELETE)

```typescript
/**
 * Custom hook for {feature} mutations
 */

import { useState } from 'react';
import { apiClient } from '@/lib/api';

interface UseMutateFeatureResult {
  mutate: (payload: FeaturePayload) => Promise<FeatureData>;
  loading: boolean;
  error: Error | null;
  data: FeatureData | null;
}

export const useMutateFeature = (): UseMutateFeatureResult => {
  const [data, setData] = useState<FeatureData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const mutate = async (payload: FeaturePayload) => {
    try {
      setLoading(true);
      setError(null);
      const response = await apiClient.post('/api/feature', payload);
      setData(response.data);
      return response.data;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error');
      setError(error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  return { mutate, loading, error, data };
};
```

## Usage Instructions

### Basic Data Fetching

```typescript
import { useFeatureData } from '@/hooks/useFeatureData';

function MyComponent({ featureId }: { featureId: string }) {
  const { data, loading, error, refetch } = useFeatureData(featureId);

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!data) return <EmptyState />;

  return (
    <div>
      <h1>{data.title}</h1>
      <button onClick={refetch}>Refresh</button>
    </div>
  );
}
```

### Mutation with Optimistic Updates

```typescript
import { useMutateFeature } from '@/hooks/useMutateFeature';
import { useQueryClient } from '@tanstack/react-query'; // If using React Query

function CreateFeatureForm() {
  const { mutate, loading, error } = useMutateFeature();
  const queryClient = useQueryClient();

  const handleSubmit = async (payload: FeaturePayload) => {
    try {
      const newFeature = await mutate(payload);

      // Invalidate and refetch queries
      queryClient.invalidateQueries(['features']);

      // Or optimistically update cache
      queryClient.setQueryData(['features'], (old: FeatureData[]) =>
        [...old, newFeature]
      );
    } catch (err) {
      // Error already handled in hook
      console.error('Failed to create feature:', err);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {error && <ErrorAlert error={error} />}
      <button type="submit" disabled={loading}>
        {loading ? 'Creating...' : 'Create Feature'}
      </button>
    </form>
  );
}
```

### Polling/Real-time Updates

```typescript
/**
 * Hook with polling for real-time updates
 */
export const useFeatureDataPolling = (
  id: string,
  interval: number = 5000
): UseFeatureDataResult => {
  const [data, setData] = useState<FeatureData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = async () => {
    try {
      const response = await apiClient.get(`/api/feature/${id}`);
      setData(response.data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData(); // Initial fetch

    const intervalId = setInterval(fetchData, interval);

    return () => clearInterval(intervalId); // Cleanup
  }, [id, interval]);

  return { data, loading, error, refetch: fetchData };
};
```

### Pagination Hook

```typescript
/**
 * Hook for paginated data fetching
 */
interface UsePaginatedDataResult {
  data: FeatureData[];
  loading: boolean;
  error: Error | null;
  page: number;
  totalPages: number;
  nextPage: () => void;
  prevPage: () => void;
  goToPage: (page: number) => void;
}

export const usePaginatedFeatureData = (
  pageSize: number = 20
): UsePaginatedDataResult => {
  const [data, setData] = useState<FeatureData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    const fetchPage = async () => {
      try {
        setLoading(true);
        const response = await apiClient.get('/api/features', {
          params: { page, limit: pageSize }
        });
        setData(response.data.items);
        setTotalPages(response.data.totalPages);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
      } finally {
        setLoading(false);
      }
    };

    fetchPage();
  }, [page, pageSize]);

  return {
    data,
    loading,
    error,
    page,
    totalPages,
    nextPage: () => setPage(p => Math.min(p + 1, totalPages)),
    prevPage: () => setPage(p => Math.max(p - 1, 1)),
    goToPage: (newPage: number) => setPage(Math.max(1, Math.min(newPage, totalPages))),
  };
};
```

## Best Practices

### 1. Error Handling

- Always catch and set errors
- Return errors to caller for UI handling
- Consider error retry logic for transient failures

### 2. Loading States

- Set loading before async operation
- Always set loading to false in finally block
- Consider skeleton screens for better UX

### 3. TypeScript Types

- Define clear interfaces for data, payloads, and results
- Use generics for reusable hooks
- Avoid `any` types

### 4. Cleanup

- Cancel in-flight requests on unmount (use AbortController)
- Clear intervals/timeouts in useEffect cleanup
- Avoid state updates on unmounted components

### 5. Caching

- Consider React Query or SWR for built-in caching
- Implement cache invalidation strategy
- Use optimistic updates for better UX

### 6. Dependency Arrays

- Always specify all dependencies in useEffect
- Use useCallback for stable function references
- Consider exhaustive-deps ESLint rule

## Advanced Patterns

### Abort Controller for Cleanup

```typescript
export const useFeatureData = (id: string): UseFeatureDataResult => {
  const [data, setData] = useState<FeatureData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const abortController = new AbortController();

    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await apiClient.get(`/api/feature/${id}`, {
          signal: abortController.signal
        });
        setData(response.data);
      } catch (err) {
        if (err.name !== 'AbortError') {
          setError(err instanceof Error ? err : new Error('Unknown error'));
        }
      } finally {
        setLoading(false);
      }
    };

    fetchData();

    return () => abortController.abort(); // Cleanup
  }, [id]);

  return { data, loading, error, refetch: () => {} };
};
```

### Debounced Search Hook

```typescript
import { useState, useEffect } from 'react';
import { debounce } from 'lodash';

export const useSearchFeatures = (query: string, delay: number = 300) => {
  const [results, setResults] = useState<FeatureData[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!query) {
      setResults([]);
      return;
    }

    const debouncedSearch = debounce(async () => {
      setLoading(true);
      try {
        const response = await apiClient.get('/api/features/search', {
          params: { q: query }
        });
        setResults(response.data);
      } catch (err) {
        console.error('Search failed:', err);
      } finally {
        setLoading(false);
      }
    }, delay);

    debouncedSearch();

    return () => debouncedSearch.cancel();
  }, [query, delay]);

  return { results, loading };
};
```
