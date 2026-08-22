# Component Architecture Guide

## Design Patterns

### Composition Pattern

**Principle**: Build complex UIs by composing small, focused components.

```typescript
// ✅ Good - Composition
function Card({ children }) {
  return <div className="card">{children}</div>;
}

function CardHeader({ children }) {
  return <div className="card-header">{children}</div>;
}

function CardBody({ children }) {
  return <div className="card-body">{children}</div>;
}

// Usage
<Card>
  <CardHeader>
    <h2>Title</h2>
  </CardHeader>
  <CardBody>
    <p>Content</p>
  </CardBody>
</Card>
```

```typescript
// ❌ Bad - Monolithic
function Card({ title, content, footer, showFooter }) {
  return (
    <div className="card">
      <div className="card-header">
        <h2>{title}</h2>
      </div>
      <div className="card-body">{content}</div>
      {showFooter && <div className="card-footer">{footer}</div>}
    </div>
  );
}
```

**Benefits**:
- Flexibility - Compose in different ways
- Reusability - Use components independently
- Clarity - Clear component boundaries

### Container/Presentational Pattern

**Principle**: Separate data logic from presentation.

```typescript
// Container (Logic)
function UserListContainer() {
  const { data, loading, error } = useUsers();

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return <UserList users={data} />;
}

// Presentational (UI)
interface UserListProps {
  users: User[];
}

function UserList({ users }: UserListProps) {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

**Benefits**:
- Testability - Test presentation without data logic
- Reusability - Use presentational component with different data sources
- Separation of concerns - Clear responsibilities

### Compound Components Pattern

**Principle**: Components that work together to share implicit state.

```typescript
import { createContext, useContext, useState } from 'react';

// Shared context
const TabsContext = createContext(null);

function Tabs({ children, defaultTab }) {
  const [activeTab, setActiveTab] = useState(defaultTab);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

function TabList({ children }) {
  return <div className="tab-list">{children}</div>;
}

function Tab({ id, children }) {
  const { activeTab, setActiveTab } = useContext(TabsContext);

  return (
    <button
      className={activeTab === id ? 'active' : ''}
      onClick={() => setActiveTab(id)}
    >
      {children}
    </button>
  );
}

function TabPanels({ children }) {
  return <div className="tab-panels">{children}</div>;
}

function TabPanel({ id, children }) {
  const { activeTab } = useContext(TabsContext);

  if (activeTab !== id) return null;

  return <div className="tab-panel">{children}</div>;
}

// Namespace
Tabs.List = TabList;
Tabs.Tab = Tab;
Tabs.Panels = TabPanels;
Tabs.Panel = TabPanel;

// Usage
<Tabs defaultTab="tab1">
  <Tabs.List>
    <Tabs.Tab id="tab1">Tab 1</Tabs.Tab>
    <Tabs.Tab id="tab2">Tab 2</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panels>
    <Tabs.Panel id="tab1">Content 1</Tabs.Panel>
    <Tabs.Panel id="tab2">Content 2</Tabs.Panel>
  </Tabs.Panels>
</Tabs>
```

**Benefits**:
- API simplicity - Intuitive, declarative API
- State management - Shared state without prop drilling
- Flexibility - Compose in any order

### Render Props Pattern

**Principle**: Share code using a prop whose value is a function.

```typescript
interface MouseTrackerProps {
  render: (mouse: { x: number; y: number }) => React.ReactNode;
}

function MouseTracker({ render }: MouseTrackerProps) {
  const [mouse, setMouse] = useState({ x: 0, y: 0 });

  const handleMouseMove = (event: React.MouseEvent) => {
    setMouse({ x: event.clientX, y: event.clientY });
  };

  return <div onMouseMove={handleMouseMove}>{render(mouse)}</div>;
}

// Usage
<MouseTracker
  render={({ x, y }) => (
    <div>
      Mouse position: {x}, {y}
    </div>
  )}
/>
```

**Modern Alternative**: Use custom hooks instead.

```typescript
// Better with hooks
function useMousePosition() {
  const [mouse, setMouse] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handleMouseMove = (event: MouseEvent) => {
      setMouse({ x: event.clientX, y: event.clientY });
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return mouse;
}

// Usage
function Component() {
  const { x, y } = useMousePosition();
  return <div>Mouse: {x}, {y}</div>;
}
```

### Higher-Order Components (HOC)

**Principle**: Function that takes a component and returns a new component.

```typescript
function withAuth<P extends object>(
  Component: React.ComponentType<P>
): React.FC<P> {
  return (props: P) => {
    const { isAuthenticated, user } = useAuth();

    if (!isAuthenticated) {
      return <Redirect to="/login" />;
    }

    return <Component {...props} user={user} />;
  };
}

// Usage
const ProtectedDashboard = withAuth(Dashboard);
```

**Modern Alternative**: Use hooks or composition.

```typescript
// Better with composition
function ProtectedRoute({ children }) {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <Redirect to="/login" />;
  }

  return children;
}

// Usage
<ProtectedRoute>
  <Dashboard />
</ProtectedRoute>
```

## Component Organization

### File Structure Options

**Option 1: Co-location (Recommended)**
```
src/components/UserProfile/
├── UserProfile.tsx
├── UserProfile.styles.ts
├── UserProfile.test.tsx
├── UserProfile.stories.tsx
├── components/
│   ├── UserAvatar.tsx
│   └── UserStats.tsx
├── hooks/
│   └── useUserData.ts
└── index.ts
```

**Option 2: Feature-based**
```
src/features/user/
├── components/
│   ├── UserProfile.tsx
│   └── UserSettings.tsx
├── hooks/
│   └── useUserData.ts
├── api/
│   └── userApi.ts
├── types.ts
└── index.ts
```

**Option 3: Atomic Design**
```
src/components/
├── atoms/           # Basic building blocks (Button, Input)
├── molecules/       # Simple combinations (SearchBar)
├── organisms/       # Complex components (Header, UserCard)
├── templates/       # Page layouts
└── pages/          # Full pages
```

### Naming Conventions

```typescript
// ✅ Good - Clear, descriptive names
function UserProfileCard() {}
function useUserData() {}
function UserAvatar() {}

// ❌ Bad - Vague, ambiguous
function Profile() {}  // Too generic
function UC() {}       // Abbreviation unclear
function Component1() {} // Meaningless
```

**Rules**:
1. **Components**: PascalCase, noun-based (`UserCard`, `SearchBar`)
2. **Hooks**: camelCase, start with `use` (`useUserData`, `useAuth`)
3. **Utilities**: camelCase, verb-based (`formatDate`, `validateEmail`)
4. **Constants**: UPPER_SNAKE_CASE (`API_BASE_URL`, `MAX_ITEMS`)

### Props Interface Design

```typescript
// ✅ Good - Clear, typed, documented
interface UserCardProps {
  /** User data to display */
  user: User;

  /** Optional click handler */
  onClick?: (userId: string) => void;

  /** Size variant */
  size?: 'small' | 'medium' | 'large';

  /** Additional CSS class */
  className?: string;

  /** Whether to show all details */
  expanded?: boolean;
}

function UserCard({
  user,
  onClick,
  size = 'medium',
  className,
  expanded = false,
}: UserCardProps) {
  // Implementation
}
```

```typescript
// ❌ Bad - Unclear, untyped
function UserCard(props: any) {
  const { u, fn, s, c, e } = props;
  // What do these mean?
}
```

**Best Practices**:
- Use descriptive prop names
- Provide defaults for optional props
- Document with JSDoc comments
- Group related props in objects if many

### Component Size Guidelines

**Small Component** (50-100 lines):
```typescript
function Button({ children, onClick, variant = 'primary' }) {
  return (
    <button className={`btn btn-${variant}`} onClick={onClick}>
      {children}
    </button>
  );
}
```

**Medium Component** (100-250 lines):
```typescript
function UserCard({ user, onEdit, onDelete }) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className="user-card">
      <UserAvatar src={user.avatar} />
      <UserInfo user={user} expanded={expanded} />
      <UserActions onEdit={onEdit} onDelete={onDelete} />
    </div>
  );
}
```

**Large Component** (>250 lines):
Consider breaking down into smaller components.

```typescript
// ❌ Too large - Hard to maintain
function Dashboard() {
  // 500+ lines of component logic
}

// ✅ Better - Split into smaller components
function Dashboard() {
  return (
    <>
      <DashboardHeader />
      <DashboardSidebar />
      <DashboardContent />
      <DashboardFooter />
    </>
  );
}
```

## Props Management

### Props Spreading

```typescript
// ✅ Good - Explicit props + rest
function Input({ label, error, ...inputProps }: InputProps) {
  return (
    <div>
      <label>{label}</label>
      <input {...inputProps} aria-invalid={!!error} />
      {error && <span>{error}</span>}
    </div>
  );
}
```

```typescript
// ❌ Bad - Unclear what's being passed
function Input(props) {
  return <input {...props} />;
}
```

### Default Props

```typescript
// ✅ Modern - Default parameters
function Button({
  variant = 'primary',
  size = 'medium',
  children
}: ButtonProps) {
  return <button className={`btn-${variant} btn-${size}`}>{children}</button>;
}

// ❌ Legacy - defaultProps (deprecated)
Button.defaultProps = {
  variant: 'primary',
  size: 'medium',
};
```

### Conditional Props (Discriminated Unions)

```typescript
// ✅ Type-safe conditional props
type ButtonProps =
  | {
      variant: 'link';
      href: string;
      onClick?: never;
    }
  | {
      variant: 'button';
      href?: never;
      onClick: () => void;
    };

function Button(props: ButtonProps) {
  if (props.variant === 'link') {
    return <a href={props.href}>Link</a>;
  }

  return <button onClick={props.onClick}>Button</button>;
}
```

## Performance Optimization

### Memoization

```typescript
import { memo, useMemo, useCallback } from 'react';

// Component memoization
const UserCard = memo(function UserCard({ user }: UserCardProps) {
  return <div>{user.name}</div>;
});

// Value memoization
function UserList({ users }: UserListProps) {
  const sortedUsers = useMemo(
    () => [...users].sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  );

  return <div>{sortedUsers.map(user => <UserCard key={user.id} user={user} />)}</div>;
}

// Callback memoization
function UserList({ users }: UserListProps) {
  const handleUserClick = useCallback((userId: string) => {
    console.log('User clicked:', userId);
  }, []);

  return (
    <div>
      {users.map(user => (
        <UserCard key={user.id} user={user} onClick={handleUserClick} />
      ))}
    </div>
  );
}
```

**When to Memoize**:
- ✅ Expensive calculations
- ✅ Large lists
- ✅ Components that re-render often
- ❌ Simple components
- ❌ Premature optimization

### Code Splitting

```typescript
import { lazy, Suspense } from 'react';

// Lazy load component
const Dashboard = lazy(() => import('./Dashboard'));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <Dashboard />
    </Suspense>
  );
}
```

### Virtual Scrolling

```typescript
import { FixedSizeList } from 'react-window';

function VirtualizedList({ items }: { items: Item[] }) {
  const Row = ({ index, style }) => (
    <div style={style}>
      {items[index].name}
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
```

## Best Practices Summary

### Component Design
1. **Single Responsibility** - One component, one job
2. **Composition Over Inheritance** - Build complex UIs from simple components
3. **Props Over State** - Prefer controlled components
4. **TypeScript Always** - Type all props and state
5. **Accessibility First** - WCAG 2.1 AA minimum

### Code Quality
1. **Small Components** - Keep under 250 lines
2. **Clear Naming** - Self-documenting code
3. **Extract Logic** - Move complex logic to hooks/utils
4. **Avoid Duplication** - DRY principle
5. **Test Coverage** - Unit test presentational logic

### Performance
1. **Memoize Wisely** - Only when needed
2. **Code Split** - Lazy load heavy components
3. **Virtualize Lists** - For long lists (>100 items)
4. **Optimize Renders** - Use React DevTools Profiler
5. **Bundle Size** - Monitor with webpack-bundle-analyzer
