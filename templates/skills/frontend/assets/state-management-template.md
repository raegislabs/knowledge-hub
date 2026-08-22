# State Management Template

## Context API Pattern

```typescript
/**
 * Context-based state management for {FeatureName}
 */

import React, { createContext, useContext, useReducer, ReactNode } from 'react';

// State type
interface FeatureState {
  items: Item[];
  loading: boolean;
  error: Error | null;
}

// Action types
type FeatureAction =
  | { type: 'FETCH_START' }
  | { type: 'FETCH_SUCCESS'; payload: Item[] }
  | { type: 'FETCH_ERROR'; payload: Error }
  | { type: 'ADD_ITEM'; payload: Item }
  | { type: 'UPDATE_ITEM'; payload: { id: string; updates: Partial<Item> } }
  | { type: 'DELETE_ITEM'; payload: string };

// Initial state
const initialState: FeatureState = {
  items: [],
  loading: false,
  error: null,
};

// Reducer
function featureReducer(state: FeatureState, action: FeatureAction): FeatureState {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, loading: true, error: null };

    case 'FETCH_SUCCESS':
      return { ...state, loading: false, items: action.payload };

    case 'FETCH_ERROR':
      return { ...state, loading: false, error: action.payload };

    case 'ADD_ITEM':
      return { ...state, items: [...state.items, action.payload] };

    case 'UPDATE_ITEM':
      return {
        ...state,
        items: state.items.map(item =>
          item.id === action.payload.id
            ? { ...item, ...action.payload.updates }
            : item
        ),
      };

    case 'DELETE_ITEM':
      return {
        ...state,
        items: state.items.filter(item => item.id !== action.payload),
      };

    default:
      return state;
  }
}

// Context
const FeatureContext = createContext<{
  state: FeatureState;
  dispatch: React.Dispatch<FeatureAction>;
} | undefined>(undefined);

// Provider
export function FeatureProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(featureReducer, initialState);

  return (
    <FeatureContext.Provider value={{ state, dispatch }}>
      {children}
    </FeatureContext.Provider>
  );
}

// Hook
export function useFeature() {
  const context = useContext(FeatureContext);

  if (!context) {
    throw new Error('useFeature must be used within FeatureProvider');
  }

  return context;
}

// Convenience hook with actions
export function useFeatureActions() {
  const { dispatch } = useFeature();

  return {
    fetchItems: async () => {
      dispatch({ type: 'FETCH_START' });
      try {
        const items = await apiClient.get('/api/items');
        dispatch({ type: 'FETCH_SUCCESS', payload: items.data });
      } catch (error) {
        dispatch({ type: 'FETCH_ERROR', payload: error as Error });
      }
    },

    addItem: (item: Item) => {
      dispatch({ type: 'ADD_ITEM', payload: item });
    },

    updateItem: (id: string, updates: Partial<Item>) => {
      dispatch({ type: 'UPDATE_ITEM', payload: { id, updates } });
    },

    deleteItem: (id: string) => {
      dispatch({ type: 'DELETE_ITEM', payload: id });
    },
  };
}
```

## Zustand Store Pattern

```typescript
/**
 * Zustand store for {FeatureName}
 */

import create from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface FeatureStore {
  // State
  items: Item[];
  loading: boolean;
  error: Error | null;

  // Actions
  fetchItems: () => Promise<void>;
  addItem: (item: Item) => void;
  updateItem: (id: string, updates: Partial<Item>) => void;
  deleteItem: (id: string) => void;
  clearError: () => void;
}

export const useFeatureStore = create<FeatureStore>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial state
        items: [],
        loading: false,
        error: null,

        // Actions
        fetchItems: async () => {
          set({ loading: true, error: null });
          try {
            const response = await apiClient.get('/api/items');
            set({ items: response.data, loading: false });
          } catch (error) {
            set({ error: error as Error, loading: false });
          }
        },

        addItem: (item) => {
          set((state) => ({
            items: [...state.items, item],
          }));
        },

        updateItem: (id, updates) => {
          set((state) => ({
            items: state.items.map((item) =>
              item.id === id ? { ...item, ...updates } : item
            ),
          }));
        },

        deleteItem: (id) => {
          set((state) => ({
            items: state.items.filter((item) => item.id !== id),
          }));
        },

        clearError: () => {
          set({ error: null });
        },
      }),
      {
        name: 'feature-storage', // localStorage key
        partialize: (state) => ({
          items: state.items, // Only persist items
        }),
      }
    )
  )
);

// Selectors
export const selectItems = (state: FeatureStore) => state.items;
export const selectLoading = (state: FeatureStore) => state.loading;
export const selectError = (state: FeatureStore) => state.error;
```

## Redux Toolkit Slice

```typescript
/**
 * Redux Toolkit slice for {FeatureName}
 */

import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import type { RootState } from '@/store';

// State type
interface FeatureState {
  items: Item[];
  loading: boolean;
  error: string | null;
}

// Initial state
const initialState: FeatureState = {
  items: [],
  loading: false,
  error: null,
};

// Async thunks
export const fetchItems = createAsyncThunk(
  'feature/fetchItems',
  async (_, { rejectWithValue }) => {
    try {
      const response = await apiClient.get('/api/items');
      return response.data;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const addItem = createAsyncThunk(
  'feature/addItem',
  async (item: Omit<Item, 'id'>, { rejectWithValue }) => {
    try {
      const response = await apiClient.post('/api/items', item);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Slice
const featureSlice = createSlice({
  name: 'feature',
  initialState,
  reducers: {
    updateItemLocal: (
      state,
      action: PayloadAction<{ id: string; updates: Partial<Item> }>
    ) => {
      const item = state.items.find((i) => i.id === action.payload.id);
      if (item) {
        Object.assign(item, action.payload.updates);
      }
    },

    deleteItemLocal: (state, action: PayloadAction<string>) => {
      state.items = state.items.filter((item) => item.id !== action.payload);
    },

    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch items
      .addCase(fetchItems.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchItems.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload;
      })
      .addCase(fetchItems.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })

      // Add item
      .addCase(addItem.pending, (state) => {
        state.loading = true;
      })
      .addCase(addItem.fulfilled, (state, action) => {
        state.loading = false;
        state.items.push(action.payload);
      })
      .addCase(addItem.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { updateItemLocal, deleteItemLocal, clearError } = featureSlice.actions;

// Selectors
export const selectAllItems = (state: RootState) => state.feature.items;
export const selectLoading = (state: RootState) => state.feature.loading;
export const selectError = (state: RootState) => state.feature.error;
export const selectItemById = (state: RootState, itemId: string) =>
  state.feature.items.find((item) => item.id === itemId);

export default featureSlice.reducer;
```

## Local Component State

```typescript
/**
 * Component with local state management
 */

import { useState, useCallback } from 'react';

function ComponentWithLocalState() {
  // Simple state
  const [count, setCount] = useState(0);

  // Object state
  const [form, setForm] = useState({
    name: '',
    email: '',
  });

  // Array state
  const [items, setItems] = useState<Item[]>([]);

  // Update object state
  const handleFormChange = useCallback((field: string, value: string) => {
    setForm((prev) => ({
      ...prev,
      [field]: value,
    }));
  }, []);

  // Add to array
  const addItem = useCallback((item: Item) => {
    setItems((prev) => [...prev, item]);
  }, []);

  // Update array item
  const updateItem = useCallback((id: string, updates: Partial<Item>) => {
    setItems((prev) =>
      prev.map((item) => (item.id === id ? { ...item, ...updates } : item))
    );
  }, []);

  // Remove from array
  const removeItem = useCallback((id: string) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }, []);

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>
        Count: {count}
      </button>

      <input
        value={form.name}
        onChange={(e) => handleFormChange('name', e.target.value)}
      />
    </div>
  );
}
```

## Usage Guidelines

### When to Use Context API
- **Small to medium apps** - Not too much state
- **Avoid prop drilling** - Pass data deep in tree
- **Theme/Auth/Locale** - Global configuration
- **Infrequent updates** - State doesn't change often

### When to Use Zustand
- **Medium to large apps** - More complex state
- **Performance critical** - Selective re-renders
- **Persistence needed** - localStorage integration
- **Simpler than Redux** - Less boilerplate

### When to Use Redux Toolkit
- **Large enterprise apps** - Complex state interactions
- **Time travel debugging** - Redux DevTools
- **Middleware needed** - Logging, analytics
- **Team familiarity** - Team knows Redux

### When to Use Local State
- **Component-only state** - Not shared with others
- **Simple UI state** - Toggle, form inputs
- **Temporary data** - Search queries, filters
- **Performance** - Avoid context re-renders

## Best Practices

### 1. Immutability
Always return new objects/arrays, never mutate:

```typescript
// ✅ Good
setItems([...items, newItem]);
setUser({ ...user, name: 'John' });

// ❌ Bad
items.push(newItem);
user.name = 'John';
```

### 2. Selector Memoization
Use memoized selectors for derived state:

```typescript
import { useMemo } from 'react';

const completedItems = useMemo(
  () => items.filter(item => item.completed),
  [items]
);
```

### 3. Action Creators
Keep actions and logic separate from components:

```typescript
// ✅ Good - Actions in store/context
const { addItem } = useFeatureActions();

// ❌ Bad - Logic in component
const addItem = () => {
  // Complex logic here
};
```

### 4. Async Patterns
Handle loading and error states:

```typescript
const [data, setData] = useState(null);
const [loading, setLoading] = useState(false);
const [error, setError] = useState(null);
```

### 5. State Normalization
Normalize nested data for easier updates:

```typescript
// ✅ Good - Normalized
{
  items: { '1': { id: '1', name: 'Item 1' } },
  itemIds: ['1']
}

// ❌ Bad - Nested
{
  items: [{ id: '1', name: 'Item 1', children: [...] }]
}
```
