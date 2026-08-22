# Styling Patterns Guide

## CSS-in-JS (styled-components)

### Basic Usage

```typescript
import styled from 'styled-components';

// Basic styled component
const Button = styled.button`
  padding: 0.75rem 1.5rem;
  background-color: #0066cc;
  color: white;
  border: none;
  border-radius: 0.375rem;
  font-size: 1rem;
  cursor: pointer;

  &:hover {
    background-color: #0052a3;
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
`;

// Usage
<Button onClick={handleClick}>Click Me</Button>
```

### Props-based Styling

```typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'small' | 'medium' | 'large';
}

const Button = styled.button<ButtonProps>`
  padding: ${props => {
    switch (props.size) {
      case 'small': return '0.5rem 1rem';
      case 'large': return '1rem 2rem';
      default: return '0.75rem 1.5rem';
    }
  }};

  background-color: ${props => {
    switch (props.variant) {
      case 'secondary': return '#6c757d';
      case 'danger': return '#dc3545';
      default: return '#0066cc';
    }
  }};

  font-size: ${props => props.size === 'small' ? '0.875rem' : '1rem'};
`;

// Usage
<Button variant="danger" size="large">Delete</Button>
```

### Theming

```typescript
// theme.ts
export const lightTheme = {
  colors: {
    primary: '#0066cc',
    secondary: '#6c757d',
    background: '#ffffff',
    text: '#212121',
    border: '#dee2e6',
  },
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
  },
  breakpoints: {
    mobile: '480px',
    tablet: '768px',
    desktop: '1024px',
  },
};

export const darkTheme = {
  ...lightTheme,
  colors: {
    ...lightTheme.colors,
    background: '#1a1a1a',
    text: '#f5f5f5',
  },
};

// App.tsx
import { ThemeProvider } from 'styled-components';

function App() {
  const [theme, setTheme] = useState('light');

  return (
    <ThemeProvider theme={theme === 'light' ? lightTheme : darkTheme}>
      <AppContent />
    </ThemeProvider>
  );
}

// Component using theme
const Card = styled.div`
  background-color: ${({ theme }) => theme.colors.background};
  color: ${({ theme }) => theme.colors.text};
  padding: ${({ theme }) => theme.spacing.md};
  border: 1px solid ${({ theme }) => theme.colors.border};

  @media (max-width: ${({ theme }) => theme.breakpoints.tablet}) {
    padding: ${({ theme }) => theme.spacing.sm};
  }
`;
```

### Global Styles

```typescript
import { createGlobalStyle } from 'styled-components';

const GlobalStyle = createGlobalStyle`
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
    color: ${({ theme }) => theme.colors.text};
    background-color: ${({ theme }) => theme.colors.background};
    line-height: 1.6;
  }

  a {
    color: ${({ theme }) => theme.colors.primary};
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }
`;

function App() {
  return (
    <ThemeProvider theme={lightTheme}>
      <GlobalStyle />
      <AppContent />
    </ThemeProvider>
  );
}
```

## CSS Modules

### Basic Usage

```css
/* Button.module.css */
.button {
  padding: 0.75rem 1.5rem;
  background-color: #0066cc;
  color: white;
  border: none;
  border-radius: 0.375rem;
  cursor: pointer;
}

.button:hover {
  background-color: #0052a3;
}

.button.primary {
  background-color: #0066cc;
}

.button.secondary {
  background-color: #6c757d;
}
```

```typescript
// Button.tsx
import styles from './Button.module.css';
import classNames from 'classnames';

interface ButtonProps {
  variant?: 'primary' | 'secondary';
  children: React.ReactNode;
}

function Button({ variant = 'primary', children }: ButtonProps) {
  return (
    <button className={classNames(styles.button, styles[variant])}>
      {children}
    </button>
  );
}
```

### Composition

```css
/* Base styles */
.base {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 0.375rem;
  cursor: pointer;
}

/* Variant styles */
.primary {
  composes: base;
  background-color: #0066cc;
  color: white;
}

.secondary {
  composes: base;
  background-color: #6c757d;
  color: white;
}
```

## Tailwind CSS

### Basic Usage

```typescript
function Button({ children, variant = 'primary' }) {
  const baseClasses = 'px-6 py-3 rounded-md font-medium transition-colors';

  const variantClasses = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700',
    secondary: 'bg-gray-600 text-white hover:bg-gray-700',
    outline: 'border-2 border-blue-600 text-blue-600 hover:bg-blue-50',
  };

  return (
    <button className={`${baseClasses} ${variantClasses[variant]}`}>
      {children}
    </button>
  );
}
```

### Using classnames/clsx

```typescript
import clsx from 'clsx';

function Button({ variant = 'primary', size = 'medium', disabled = false }) {
  return (
    <button
      className={clsx(
        // Base styles
        'font-medium rounded-md transition-colors',

        // Size variants
        {
          'px-3 py-1.5 text-sm': size === 'small',
          'px-6 py-3 text-base': size === 'medium',
          'px-8 py-4 text-lg': size === 'large',
        },

        // Color variants
        {
          'bg-blue-600 text-white hover:bg-blue-700': variant === 'primary',
          'bg-gray-600 text-white hover:bg-gray-700': variant === 'secondary',
        },

        // Disabled state
        {
          'opacity-50 cursor-not-allowed': disabled,
        }
      )}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

### Custom Configuration

```javascript
// tailwind.config.js
module.exports = {
  content: [
    './src/**/*.{js,jsx,ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
      },
      spacing: {
        '128': '32rem',
        '144': '36rem',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
};
```

## Responsive Design

### Mobile-First Approach

```typescript
// styled-components
const Container = styled.div`
  /* Mobile (default) */
  padding: 1rem;
  font-size: 0.875rem;

  /* Tablet */
  @media (min-width: 768px) {
    padding: 1.5rem;
    font-size: 1rem;
  }

  /* Desktop */
  @media (min-width: 1024px) {
    padding: 2rem;
    font-size: 1.125rem;
  }
`;

// Tailwind CSS
<div className="p-4 text-sm md:p-6 md:text-base lg:p-8 lg:text-lg">
  Content
</div>
```

### Container Queries (Modern)

```css
/* Container queries for component-level responsiveness */
.card-container {
  container-type: inline-size;
  container-name: card;
}

.card {
  display: flex;
  flex-direction: column;
}

@container card (min-width: 400px) {
  .card {
    flex-direction: row;
  }
}
```

## Design Systems

### Component Variants Pattern

```typescript
// variants.ts
export const buttonVariants = {
  base: 'px-6 py-3 rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2',

  variants: {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-gray-600 text-white hover:bg-gray-700 focus:ring-gray-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500',
    outline: 'border-2 border-blue-600 text-blue-600 hover:bg-blue-50 focus:ring-blue-500',
  },

  sizes: {
    small: 'px-3 py-1.5 text-sm',
    medium: 'px-6 py-3 text-base',
    large: 'px-8 py-4 text-lg',
  },
};

// Button.tsx
import { buttonVariants } from './variants';
import clsx from 'clsx';

interface ButtonProps {
  variant?: keyof typeof buttonVariants.variants;
  size?: keyof typeof buttonVariants.sizes;
  children: React.ReactNode;
}

function Button({ variant = 'primary', size = 'medium', children }: ButtonProps) {
  return (
    <button
      className={clsx(
        buttonVariants.base,
        buttonVariants.variants[variant],
        buttonVariants.sizes[size]
      )}
    >
      {children}
    </button>
  );
}
```

### Design Tokens

```typescript
// tokens.ts
export const tokens = {
  colors: {
    primary: {
      50: '#eff6ff',
      100: '#dbeafe',
      500: '#3b82f6',
      600: '#2563eb',
      700: '#1d4ed8',
      900: '#1e3a8a',
    },
    gray: {
      50: '#f9fafb',
      100: '#f3f4f6',
      500: '#6b7280',
      900: '#111827',
    },
  },

  spacing: {
    0: '0',
    1: '0.25rem',
    2: '0.5rem',
    3: '0.75rem',
    4: '1rem',
    6: '1.5rem',
    8: '2rem',
    12: '3rem',
  },

  fontSize: {
    xs: '0.75rem',
    sm: '0.875rem',
    base: '1rem',
    lg: '1.125rem',
    xl: '1.25rem',
    '2xl': '1.5rem',
    '3xl': '1.875rem',
  },

  fontWeight: {
    normal: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
  },

  borderRadius: {
    none: '0',
    sm: '0.125rem',
    base: '0.25rem',
    md: '0.375rem',
    lg: '0.5rem',
    full: '9999px',
  },

  shadows: {
    sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
    base: '0 1px 3px 0 rgba(0, 0, 0, 0.1)',
    md: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
    lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
  },
};

// Usage with styled-components
import { tokens } from './tokens';

const Button = styled.button`
  padding: ${tokens.spacing[3]} ${tokens.spacing[6]};
  font-size: ${tokens.fontSize.base};
  font-weight: ${tokens.fontWeight.medium};
  color: white;
  background-color: ${tokens.colors.primary[600]};
  border-radius: ${tokens.borderRadius.md};
  box-shadow: ${tokens.shadows.sm};

  &:hover {
    background-color: ${tokens.colors.primary[700]};
  }
`;
```

## Animation and Transitions

### CSS Transitions

```typescript
const Button = styled.button`
  background-color: #0066cc;
  transform: scale(1);
  transition: all 0.2s ease;

  &:hover {
    background-color: #0052a3;
    transform: scale(1.05);
  }

  &:active {
    transform: scale(0.95);
  }
`;
```

### Framer Motion

```typescript
import { motion } from 'framer-motion';

function AnimatedCard({ children }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      transition={{ duration: 0.3 }}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
    >
      {children}
    </motion.div>
  );
}

function ListWithStagger({ items }) {
  return (
    <motion.ul
      initial="hidden"
      animate="visible"
      variants={{
        visible: {
          transition: {
            staggerChildren: 0.1,
          },
        },
      }}
    >
      {items.map(item => (
        <motion.li
          key={item.id}
          variants={{
            hidden: { opacity: 0, x: -20 },
            visible: { opacity: 1, x: 0 },
          }}
        >
          {item.name}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

## Dark Mode

### CSS Variables Approach

```css
/* Global styles */
:root {
  --color-background: #ffffff;
  --color-text: #212121;
  --color-primary: #0066cc;
}

[data-theme='dark'] {
  --color-background: #1a1a1a;
  --color-text: #f5f5f5;
  --color-primary: #3b82f6;
}

.card {
  background-color: var(--color-background);
  color: var(--color-text);
}
```

```typescript
function ThemeToggle() {
  const [theme, setTheme] = useState('light');

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  return (
    <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
      Toggle Theme
    </button>
  );
}
```

### Tailwind Dark Mode

```typescript
// tailwind.config.js
module.exports = {
  darkMode: 'class', // or 'media'
  // ...
};

// Usage
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
  Content
</div>

// Toggle
function ThemeToggle() {
  const [darkMode, setDarkMode] = useState(false);

  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [darkMode]);

  return (
    <button onClick={() => setDarkMode(!darkMode)}>
      {darkMode ? '☀️' : '🌙'}
    </button>
  );
}
```

## Best Practices

### 1. Consistency
- Use design tokens for spacing, colors, typography
- Follow a naming convention
- Reuse component variants

### 2. Performance
- Avoid inline styles (creates new objects)
- Use CSS-in-JS with caution (runtime cost)
- Purge unused CSS in production

### 3. Accessibility
- Ensure sufficient color contrast (4.5:1 minimum)
- Don't rely on color alone
- Support reduced motion preferences

### 4. Maintainability
- Colocate styles with components
- Use TypeScript for type-safe props
- Document design decisions

### 5. Responsive Design
- Mobile-first approach
- Test on real devices
- Use relative units (rem, em)
