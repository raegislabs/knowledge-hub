---
name: frontend-templates
description: Production-ready templates and patterns for building modern, accessible, performant React applications. Use when implementing frontend features, creating new components, or establishing frontend architecture patterns. Provides component templates, API integration hooks, form validation, state management, and comprehensive guides for architecture, accessibility, performance, and styling.
---

# Frontend Templates

## Overview

This skill provides production-ready templates and comprehensive patterns for building modern frontend applications with React, TypeScript, and industry best practices. It complements the @frontend-implementation-specialist agent by providing standardized component structures, architectural patterns, and detailed reference guides for accessibility, performance, and styling.

**When to use this skill:**
- Implementing new React components from scratch
- Integrating with backend APIs
- Building accessible, WCAG 2.1 AA compliant UIs
- Optimizing frontend performance
- Establishing state management patterns
- Creating forms with validation
- Setting up component documentation
- Implementing responsive, mobile-first designs

**Skill Structure:** Reference/Guidelines-based with reusable templates and comprehensive methodologies.

## Available Templates

This skill provides 5 production-ready templates in `assets/`:

### 1. Component Template
**File:** `assets/component-template.md`

Complete React component structure including:
- TypeScript component implementation with props interface
- Styled-components with responsive design
- Accessibility attributes (ARIA labels, roles, keyboard navigation)
- Component documentation with JSDoc
- Usage examples and patterns
- Performance considerations (memoization)
- File structure recommendations

**Use when:** Creating new React components with TypeScript and styled-components.

**Example usage:**
```typescript
// Component implementation
export interface UserCardProps {
  /** User data to display */
  user: User;
  /** Optional click handler */
  onClick?: (userId: string) => void;
  /** Size variant */
  size?: 'small' | 'medium' | 'large';
}

export const UserCard: React.FC<UserCardProps> = ({
  user,
  onClick,
  size = 'medium',
}) => {
  // Implementation following template pattern
};
```

### 2. API Integration Hook Template
**File:** `assets/api-integration-hook-template.md`

Custom React hooks for API integration with:
- Data fetching hook (GET requests)
- Mutation hook (POST/PUT/DELETE requests)
- Polling/real-time updates pattern
- Pagination hook pattern
- Error handling and loading states
- AbortController for cleanup
- Debounced search hook

**Use when:** Creating custom hooks for backend API integration.

**Example usage:**
```typescript
// Data fetching hook
export const useUserData = (id: string): UseUserDataResult => {
  const [data, setData] = useState<UserData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchData();
  }, [id]);

  return { data, loading, error, refetch: fetchData };
};

// Usage in component
function UserProfile({ userId }: { userId: string }) {
  const { data, loading, error, refetch } = useUserData(userId);

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return <div>{data.name}</div>;
}
```

### 3. Component Documentation Template
**File:** `assets/component-documentation-template.md`

Comprehensive component documentation format with:
- Component description and usage examples
- Props table (prop, type, required, default, description)
- Accessibility checklist (keyboard navigation, screen readers, WCAG)
- Component states (default, loading, error, disabled)
- Testing examples (unit tests, accessibility tests)
- Integration examples (with forms, state management)
- Styling and theming guidance
- Performance tips
- Browser support matrix
- Changelog

**Use when:** Documenting components for team collaboration and onboarding.

**Example usage:**
```markdown
# UserCard

Displays user information with avatar, name, and optional actions.

## Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `user` | `User` | Yes | - | User data to display |
| `onClick` | `(userId: string) => void` | No | - | Callback when card is clicked |

## Accessibility

- ✅ Keyboard navigable
- ✅ Screen reader friendly
- ✅ WCAG AA color contrast
```

### 4. Form Validation Template
**File:** `assets/form-validation-template.md`

Form validation patterns and techniques:
- React Hook Form + Zod schema validation
- Custom validation rules (email, password strength, min/max length)
- Field-level validation
- Async validation (username availability)
- Multi-step form validation
- Real-time validation feedback (password strength)
- Accessibility-focused error handling
- Best practices (UX, security, performance)

**Use when:** Building forms with validation logic and error handling.

**Example usage:**
```typescript
// React Hook Form + Zod
const formSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Must contain uppercase letter'),
});

type FormData = z.infer<typeof formSchema>;

function RegistrationForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(formSchema),
  });

  const onSubmit = async (data: FormData) => {
    await apiClient.post('/api/register', data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('email')}
        aria-invalid={errors.email ? 'true' : 'false'}
      />
      {errors.email && <span role="alert">{errors.email.message}</span>}
    </form>
  );
}
```

### 5. State Management Template
**File:** `assets/state-management-template.md`

State management patterns for different scales:
- Context API pattern (reducer, actions, provider)
- Zustand store pattern (with devtools, persistence)
- Redux Toolkit slice (async thunks, selectors)
- Local component state best practices
- Usage guidelines (when to use each pattern)
- Best practices (immutability, memoization, normalization)

**Use when:** Implementing state management for features or global application state.

**Example usage:**
```typescript
// Zustand store
export const useFeatureStore = create<FeatureStore>()(
  devtools(
    persist(
      (set, get) => ({
        items: [],
        loading: false,
        error: null,

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
          set((state) => ({ items: [...state.items, item] }));
        },
      }),
      { name: 'feature-storage' }
    )
  )
);

// Usage
function FeatureList() {
  const { items, loading, fetchItems } = useFeatureStore();

  useEffect(() => {
    fetchItems();
  }, []);

  if (loading) return <Spinner />;
  return <div>{items.map(item => <Item key={item.id} {...item} />)}</div>;
}
```

## Reference Guides

This skill provides 4 comprehensive reference guides in `references/`:

### 1. Component Architecture Guide
**File:** `references/component-architecture-guide.md`

Design patterns and architectural best practices:

**Design Patterns:**
- **Composition Pattern** - Building complex UIs from small, focused components
- **Container/Presentational Pattern** - Separating data logic from presentation
- **Compound Components Pattern** - Components that work together sharing implicit state
- **Render Props Pattern** - Sharing code using function props (with modern hook alternatives)
- **Higher-Order Components (HOC)** - Component enhancement (with modern alternatives)

**Component Organization:**
- File structure options (co-location, feature-based, atomic design)
- Naming conventions (PascalCase, camelCase, UPPER_SNAKE_CASE)
- Props interface design patterns
- Component size guidelines (small <100, medium <250, large >250 lines)

**Props Management:**
- Props spreading best practices
- Default props (modern vs legacy)
- Conditional props (discriminated unions)

**Performance Optimization:**
- Memoization (React.memo, useMemo, useCallback)
- Code splitting (lazy loading, Suspense)
- Virtual scrolling (react-window)

**Use when:** Need systematic framework for structuring components and making architectural decisions.

### 2. Accessibility Guide
**File:** `references/accessibility-guide.md`

WCAG 2.1 compliance and accessible component patterns:

**WCAG 2.1 Standards:**
- Three levels of conformance (A, AA, AAA)
- Four principles (POUR: Perceivable, Operable, Understandable, Robust)

**Semantic HTML:**
- Proper element usage (header, nav, main, article, section)
- Semantic elements reference table

**ARIA Attributes:**
- When to use ARIA (first rule: use native HTML when possible)
- Common ARIA roles (dialog, tablist, alert, status)
- ARIA states and properties (aria-label, aria-invalid, aria-live)
- ARIA in React components (examples for dialogs, accordions)

**Keyboard Navigation:**
- Focusable elements (naturally focusable vs tabindex)
- Keyboard event handling (Enter, Space, Arrow keys, Escape)
- Keyboard shortcuts reference table

**Focus Management:**
- Focus indicators (visible focus rings)
- Focus trapping for modals (complete implementation)

**Color Contrast:**
- WCAG AA requirements (4.5:1 text, 3:1 UI)
- Testing tools and approaches
- Don't rely on color alone

**Screen Reader Support:**
- ARIA live regions (polite, assertive, status)
- Visually hidden content patterns
- Skip links

**Forms Accessibility:**
- Labels and instructions
- Error handling with aria-describedby
- Error summary focus management

**Testing:**
- Automated testing (jest-axe)
- Manual testing checklist
- Tools (axe DevTools, NVDA, JAWS, VoiceOver)

**Common Accessible Patterns:**
- Modal, Tabs, Dropdown implementations

**Use when:** Building accessible components or need WCAG compliance guidance.

### 3. Performance Optimization Guide
**File:** `references/performance-optimization-guide.md`

Comprehensive performance optimization strategies:

**Bundle Size Optimization:**
- Code splitting (route-based, component-based)
- Tree shaking (named imports vs default)
- Dynamic imports (load on demand)
- Bundle analysis (webpack-bundle-analyzer)

**React Performance:**
- React.memo (when to use, custom comparison)
- useMemo (expensive computations)
- useCallback (stable callbacks)
- Key prop optimization
- Virtualization (FixedSizeList, VariableSizeList)

**Image Optimization:**
- Lazy loading (native loading="lazy", Intersection Observer)
- Responsive images (picture, srcset)
- Image compression (next/image)

**Network Optimization:**
- Request deduplication (React Query)
- Debouncing and throttling
- Prefetching (likely next pages, on hover)

**Rendering Optimization:**
- Avoid inline functions
- Avoid inline objects/arrays
- Conditional rendering efficiency
- Fragment usage

**State Management Performance:**
- State colocation (local vs global)
- Lazy initial state
- Batched updates

**Profiling and Monitoring:**
- React DevTools Profiler
- Performance monitoring (onRender callback)

**Performance Budget:**
- Core Web Vitals targets (FCP, LCP, TTI, TBT, CLS)
- Bundle size budget
- Checklist for initial load, runtime, network performance

**Use when:** Optimizing performance or need to meet performance budget targets.

### 4. Styling Patterns Guide
**File:** `references/styling-patterns-guide.md`

Modern CSS patterns and styling approaches:

**CSS-in-JS (styled-components):**
- Basic usage
- Props-based styling
- Theming (light/dark themes)
- Global styles

**CSS Modules:**
- Basic usage
- Composition pattern

**Tailwind CSS:**
- Basic usage with variants
- Using classnames/clsx utility
- Custom configuration

**Responsive Design:**
- Mobile-first approach
- Container queries (modern)

**Design Systems:**
- Component variants pattern
- Design tokens (colors, spacing, typography, shadows)

**Animation and Transitions:**
- CSS transitions
- Framer Motion (declarative animations, stagger effects)

**Dark Mode:**
- CSS variables approach
- Tailwind dark mode

**Best Practices:**
- Consistency (design tokens, naming conventions)
- Performance (avoid inline styles, purge unused CSS)
- Accessibility (color contrast, reduced motion)
- Maintainability (colocation, TypeScript)
- Responsive design (mobile-first, relative units)

**Use when:** Need styling patterns or establishing design system standards.

## Usage Patterns

### Pattern 1: New Component from Scratch

**Scenario:** Build a new UserCard component with TypeScript, accessibility, and responsive design.

**Process:**
1. Read `component-template.md` for structure
2. Read `accessibility-guide.md` → Semantic HTML and ARIA sections
3. Read `styling-patterns-guide.md` → Responsive Design section
4. Implement component following template
5. Use `component-documentation-template.md` to document

**Time:** 1-2 hours

### Pattern 2: API Integration

**Scenario:** Create hooks for fetching and mutating user data from backend API.

**Process:**
1. Read `api-integration-hook-template.md`
2. Implement data fetching hook (useUserData)
3. Implement mutation hook (useUpdateUser)
4. Add error handling and loading states
5. Test with React Query for caching (optional)

**Time:** 30 minutes - 1 hour

### Pattern 3: Complex Form with Validation

**Scenario:** Build registration form with email, password, and real-time validation.

**Process:**
1. Read `form-validation-template.md` → React Hook Form + Zod section
2. Read `accessibility-guide.md` → Forms Accessibility section
3. Define Zod schema for validation
4. Implement form with react-hook-form
5. Add real-time password strength feedback
6. Ensure ARIA attributes for error messages

**Time:** 2-3 hours

### Pattern 4: Performance Optimization

**Scenario:** Optimize slow dashboard with heavy components and large data lists.

**Process:**
1. Read `performance-optimization-guide.md` → React Performance section
2. Profile with React DevTools Profiler
3. Memoize expensive components with React.memo
4. Virtualize large lists with react-window
5. Code split dashboard route
6. Measure improvement and verify budget met

**Time:** 2-4 hours

### Pattern 5: Accessibility Audit

**Scenario:** Ensure existing component library meets WCAG 2.1 AA standards.

**Process:**
1. Read `accessibility-guide.md` completely
2. Run automated testing with axe DevTools
3. Test keyboard navigation manually
4. Test with screen reader (VoiceOver/NVDA)
5. Check color contrast with WebAIM checker
6. Fix violations and re-test
7. Document accessibility features in component docs

**Time:** 4-8 hours (depending on library size)

### Pattern 6: State Management Setup

**Scenario:** Set up global state management for e-commerce cart feature.

**Process:**
1. Read `state-management-template.md` → Usage guidelines
2. Choose appropriate pattern (Context API for small, Zustand for medium, Redux for large)
3. Implement store with actions (addItem, updateQuantity, removeItem)
4. Add persistence (localStorage)
5. Test with React DevTools

**Time:** 1-2 hours

### Pattern 7: Design System Foundation

**Scenario:** Establish design system with tokens, variants, and theming.

**Process:**
1. Read `styling-patterns-guide.md` → Design Systems section
2. Read `component-architecture-guide.md` → Component Organization
3. Define design tokens (colors, spacing, typography)
4. Create variant patterns for buttons, inputs, cards
5. Implement theming (light/dark mode)
6. Document in Storybook

**Time:** 4-6 hours

## Integration with @frontend-implementation-specialist

This skill is designed to complement the @frontend-implementation-specialist agent:

**Agent's Role:**
- Implements features based on specifications
- Makes judgment calls on component structure
- Writes production-ready code
- Handles integration and testing

**Skill's Role:**
- Provides standardized templates for consistency
- Offers architectural patterns and best practices
- Ensures accessibility and performance standards
- Documents implementation approaches

**Workflow:**
```markdown
User: "@frontend-implementation-specialist, build a user profile card with edit functionality"

Agent:
1. Loads frontend-templates skill
2. Reads component-template.md for structure
3. Reads accessibility-guide.md for WCAG compliance
4. Reads component-architecture-guide.md for patterns
5. Implements UserProfileCard component following templates
6. Uses component-documentation-template.md to document
7. Delivers production-ready component with tests
```

## Best Practices

### 1. Start with Templates
Always read relevant template files before implementation to ensure consistency with established patterns.

### 2. Accessibility First
Read `accessibility-guide.md` for every user-facing component. WCAG 2.1 AA is minimum standard.

### 3. TypeScript Always
Use TypeScript for all components and hooks. Define clear interfaces with JSDoc comments.

### 4. Mobile-First Responsive
Use mobile-first responsive design patterns from `styling-patterns-guide.md`.

### 5. Performance Budget
Refer to `performance-optimization-guide.md` for performance targets. Monitor bundle size and Core Web Vitals.

### 6. Document Components
Use `component-documentation-template.md` for all reusable components to improve team onboarding.

### 7. Test Accessibility
Always run automated accessibility tests (jest-axe) and manual keyboard navigation tests.

### 8. Choose Right State Management
Use state management usage guidelines to select appropriate pattern (local, Context, Zustand, Redux).

### 9. Optimize Wisely
Don't prematurely optimize. Profile first, then apply memoization and code splitting where needed.

### 10. Follow Design Tokens
Use design tokens from `styling-patterns-guide.md` for consistency across application.

## Resources

### assets/
Template files designed to be copied and customized:

- **component-template.md** - Complete React component structure with TypeScript, styled-components, accessibility
- **api-integration-hook-template.md** - Custom hooks for data fetching, mutations, polling, pagination
- **component-documentation-template.md** - Comprehensive component documentation format
- **form-validation-template.md** - Form validation with React Hook Form, Zod, async validation
- **state-management-template.md** - Context API, Zustand, Redux Toolkit patterns

**Usage:** Copy template, fill in with implementation, customize as needed for specific use case.

### references/
Comprehensive reference guides loaded into context:

- **component-architecture-guide.md** - Design patterns (composition, container/presentational), component organization, props management, performance optimization
- **accessibility-guide.md** - WCAG 2.1 standards, semantic HTML, ARIA attributes, keyboard navigation, focus management, screen readers, testing
- **performance-optimization-guide.md** - Bundle size, React performance (memo, useMemo, useCallback), image optimization, network optimization, profiling
- **styling-patterns-guide.md** - CSS-in-JS, CSS Modules, Tailwind, responsive design, design systems, animation, dark mode

**Usage:** Read relevant sections to inform implementation decisions and ensure best practices.

## Examples

### Example 1: Accessible Modal Component

```markdown
User: "Build an accessible modal dialog for confirming delete actions"

Process:
1. Read component-template.md for structure
2. Read accessibility-guide.md → Common Patterns → Accessible Modal
3. Implement modal with:
   - role="dialog", aria-modal="true"
   - aria-labelledby pointing to title
   - Focus trap (Tab cycles through modal only)
   - Escape key to close
   - Focus restoration when closed
4. Use component-documentation-template.md to document
5. Test with jest-axe and manual keyboard navigation

Output:
- Fully accessible modal component
- WCAG 2.1 AA compliant
- Keyboard navigable
- Screen reader friendly
- Complete documentation
```

### Example 2: Paginated Data Table

```markdown
User: "Create a data table with pagination, sorting, and search"

Process:
1. Read api-integration-hook-template.md → Pagination Hook
2. Read component-architecture-guide.md → Component Organization
3. Read performance-optimization-guide.md → Virtualization (if >100 rows)
4. Implement:
   - usePaginatedData hook for API calls
   - Table component with sorting state
   - Debounced search input
   - Virtualization if needed
5. Read accessibility-guide.md → Ensure table has proper roles
6. Document with component-documentation-template.md

Output:
- Performant paginated table
- Accessible table markup
- Debounced search
- Documented API
```

### Example 3: Theme-Aware Design System

```markdown
User: "Set up design system with light/dark theme support"

Process:
1. Read styling-patterns-guide.md → Design Systems + Dark Mode sections
2. Read component-architecture-guide.md → Props Management
3. Define design tokens (colors, spacing, typography)
4. Implement CSS variables approach for theming
5. Create variant patterns for common components
6. Set up theme toggle with localStorage persistence
7. Document theme usage

Output:
- Complete design token system
- Light/dark theme support
- Reusable component variants
- Theme persistence
- Documentation for team
```

## Tips & Tricks

### Tip 1: Template Customization
Templates are starting points. Adapt to your project's needs - remove irrelevant sections, add project-specific patterns.

### Tip 2: Progressive Enhancement
Start with semantic HTML, add ARIA only when needed. Native HTML is always preferred over custom ARIA implementations.

### Tip 3: Performance First, Optimize Second
Don't prematurely optimize. Build correctly first, profile with React DevTools, then optimize bottlenecks.

### Tip 4: Component Library Documentation
Store completed component documentation in `docs/components/` for team reference and onboarding.

### Tip 5: Accessibility Testing Workflow
Automated tests catch 30-40% of issues. Always supplement with manual keyboard navigation and screen reader testing.

### Tip 6: State Colocation
Keep state as local as possible. Only lift to global state when multiple components need access.

### Tip 7: Design Token Versioning
Version your design tokens. Breaking changes (color values, spacing) should be communicated to team.

### Tip 8: Bundle Size Monitoring
Add bundle size checks to CI/CD pipeline. Prevent regressions by failing builds that exceed budget.

### Tip 9: Accessibility Checklist
Create project-specific accessibility checklist based on `accessibility-guide.md` testing section.

### Tip 10: Component Variants
Use TypeScript discriminated unions for component variants to ensure type safety.

---

**Related Skills:**
- research-templates - Systematic research methodologies (for evaluating frontend libraries/frameworks)

**Related Agents:**
- @frontend-implementation-specialist - Primary consumer of this skill's templates and patterns
- @architect - May use architectural patterns from component-architecture-guide.md
