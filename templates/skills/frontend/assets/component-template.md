# React Component Template

## Component Implementation

```typescript
/**
 * {ComponentName} - {Brief description}
 *
 * @example
 * ```tsx
 * <ComponentName
 *   prop1="value"
 *   onAction={handleAction}
 * />
 * ```
 */

import React, { useState, useCallback } from 'react';
import { ComponentContainer, Title, Button } from './ComponentName.styles';

export interface ComponentNameProps {
  /** Description of prop1 */
  prop1: string;
  /** Description of prop2 */
  prop2?: number;
  /** Callback fired when action occurs */
  onAction?: (value: string) => void;
  /** Additional CSS class */
  className?: string;
}

export const ComponentName: React.FC<ComponentNameProps> = ({
  prop1,
  prop2 = 0,
  onAction,
  className,
}) => {
  const [state, setState] = useState<string>('');

  const handleClick = useCallback(() => {
    // Handle interaction
    onAction?.(state);
  }, [state, onAction]);

  return (
    <ComponentContainer
      className={className}
      role="region"
      aria-label={prop1}
    >
      <Title>{prop1}</Title>
      <Button
        onClick={handleClick}
        aria-label="Submit action"
      >
        Submit
      </Button>
    </ComponentContainer>
  );
};

ComponentName.displayName = 'ComponentName';
```

## Component Styles

```typescript
/**
 * Styles for {ComponentName}
 */

import styled from 'styled-components';

export const ComponentContainer = styled.div`
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.5rem;
  border-radius: 0.5rem;
  background-color: ${({ theme }) => theme.colors.background};

  /* Responsive design */
  @media (max-width: ${({ theme }) => theme.breakpoints.tablet}) {
    padding: 1rem;
  }

  /* Focus visible for accessibility */
  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.primary};
    outline-offset: 2px;
  }
`;

export const Title = styled.h2`
  font-size: 1.5rem;
  font-weight: 600;
  color: ${({ theme }) => theme.colors.text};
  margin: 0;

  @media (max-width: ${({ theme }) => theme.breakpoints.mobile}) {
    font-size: 1.25rem;
  }
`;

export const Button = styled.button`
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 0.375rem;
  background-color: ${({ theme }) => theme.colors.primary};
  color: white;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover:not(:disabled) {
    background-color: ${({ theme }) => theme.colors.primaryHover};
    transform: translateY(-1px);
  }

  &:active:not(:disabled) {
    transform: translateY(0);
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.focus};
    outline-offset: 2px;
  }
`;
```

## Usage Instructions

### Basic Setup

1. **Copy Template**: Copy this template as a starting point for new components
2. **Rename Component**: Replace `ComponentName` with your component name (PascalCase)
3. **Update Props**: Define appropriate props interface with JSDoc comments
4. **Implement Logic**: Add state management and event handlers
5. **Style Component**: Create styled components with responsive design
6. **Add Accessibility**: Ensure proper ARIA labels and keyboard navigation

### File Structure

```
src/components/ComponentName/
├── ComponentName.tsx          # Component logic
├── ComponentName.styles.ts    # Styled components
├── ComponentName.test.tsx     # Unit tests
├── ComponentName.stories.tsx  # Storybook stories
└── index.ts                   # Public exports
```

### Key Patterns

1. **TypeScript Interfaces**: Always define prop types with JSDoc
2. **React.FC**: Use functional components with typed props
3. **useCallback**: Memoize event handlers to prevent re-renders
4. **Semantic HTML**: Use appropriate HTML elements (article, nav, section, etc.)
5. **ARIA Attributes**: Include role, aria-label, aria-describedby where needed
6. **Focus Management**: Style :focus-visible for keyboard navigation
7. **Responsive Design**: Mobile-first with breakpoint media queries

### Accessibility Checklist

- [ ] Semantic HTML elements used
- [ ] ARIA roles and labels added
- [ ] Keyboard navigation tested
- [ ] Focus indicators visible
- [ ] Color contrast meets WCAG AA (4.5:1 for text)
- [ ] Screen reader tested (optional but recommended)

### Performance Considerations

- [ ] Heavy computations memoized with useMemo
- [ ] Event handlers wrapped in useCallback
- [ ] Large lists virtualized (react-window)
- [ ] Images lazy loaded
- [ ] Code split with React.lazy() if component is large
