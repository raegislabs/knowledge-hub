# Form Validation Template

## React Hook Form + Zod Validation

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Define validation schema
const formSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
  confirmPassword: z.string(),
  age: z.number().min(18, 'Must be 18 or older').max(120),
  terms: z.boolean().refine(val => val === true, 'You must accept terms'),
}).refine(data => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
});

type FormData = z.infer<typeof formSchema>;

function ValidationForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(formSchema),
  });

  const onSubmit = async (data: FormData) => {
    try {
      await apiClient.post('/api/submit', data);
      // Handle success
    } catch (error) {
      // Handle error
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {/* Email Field */}
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          {...register('email')}
          aria-invalid={errors.email ? 'true' : 'false'}
          aria-describedby={errors.email ? 'email-error' : undefined}
        />
        {errors.email && (
          <span id="email-error" role="alert">
            {errors.email.message}
          </span>
        )}
      </div>

      {/* Password Field */}
      <div>
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          {...register('password')}
          aria-invalid={errors.password ? 'true' : 'false'}
          aria-describedby={errors.password ? 'password-error' : undefined}
        />
        {errors.password && (
          <span id="password-error" role="alert">
            {errors.password.message}
          </span>
        )}
      </div>

      {/* Submit Button */}
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  );
}
```

## Custom Validation Rules

```typescript
// Custom validation functions
const validations = {
  required: (value: string) => value.trim() !== '' || 'This field is required',

  email: (value: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(value) || 'Invalid email address';
  },

  minLength: (min: number) => (value: string) =>
    value.length >= min || `Must be at least ${min} characters`,

  maxLength: (max: number) => (value: string) =>
    value.length <= max || `Must be at most ${max} characters`,

  pattern: (regex: RegExp, message: string) => (value: string) =>
    regex.test(value) || message,

  strongPassword: (value: string) => {
    const hasUpper = /[A-Z]/.test(value);
    const hasLower = /[a-z]/.test(value);
    const hasNumber = /[0-9]/.test(value);
    const hasSpecial = /[!@#$%^&*]/.test(value);

    if (!hasUpper) return 'Must contain uppercase letter';
    if (!hasLower) return 'Must contain lowercase letter';
    if (!hasNumber) return 'Must contain number';
    if (!hasSpecial) return 'Must contain special character';

    return true;
  },
};

// Usage with React Hook Form
const { register } = useForm();

<input
  {...register('username', {
    validate: {
      required: validations.required,
      minLength: validations.minLength(3),
      maxLength: validations.maxLength(20),
    }
  })}
/>
```

## Field-Level Validation

```typescript
import { useState } from 'react';

function FieldWithValidation() {
  const [value, setValue] = useState('');
  const [error, setError] = useState<string | null>(null);

  const validateField = (input: string) => {
    if (input.trim() === '') {
      setError('This field is required');
      return false;
    }

    if (input.length < 3) {
      setError('Must be at least 3 characters');
      return false;
    }

    setError(null);
    return true;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    setValue(newValue);
    validateField(newValue);
  };

  const handleBlur = () => {
    validateField(value);
  };

  return (
    <div>
      <input
        value={value}
        onChange={handleChange}
        onBlur={handleBlur}
        aria-invalid={error ? 'true' : 'false'}
        aria-describedby={error ? 'field-error' : undefined}
      />
      {error && (
        <span id="field-error" role="alert" style={{ color: 'red' }}>
          {error}
        </span>
      )}
    </div>
  );
}
```

## Async Validation (Username Availability)

```typescript
import { useForm } from 'react-hook-form';
import { debounce } from 'lodash';

function AsyncValidationForm() {
  const { register, formState: { errors } } = useForm();

  const checkUsernameAvailability = async (username: string) => {
    if (!username) return true;

    try {
      const response = await apiClient.get(`/api/check-username/${username}`);
      return response.data.available || 'Username already taken';
    } catch (error) {
      return 'Error checking username availability';
    }
  };

  const debouncedValidation = debounce(checkUsernameAvailability, 500);

  return (
    <form>
      <input
        {...register('username', {
          required: 'Username is required',
          validate: debouncedValidation,
        })}
      />
      {errors.username && <span>{errors.username.message}</span>}
    </form>
  );
}
```

## Multi-Step Form Validation

```typescript
import { useState } from 'react';
import { useForm } from 'react-hook-form';

interface Step1Data {
  firstName: string;
  lastName: string;
}

interface Step2Data {
  email: string;
  phone: string;
}

function MultiStepForm() {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({});

  const step1Form = useForm<Step1Data>();
  const step2Form = useForm<Step2Data>();

  const onStep1Submit = (data: Step1Data) => {
    setFormData(prev => ({ ...prev, ...data }));
    setStep(2);
  };

  const onStep2Submit = (data: Step2Data) => {
    const completeData = { ...formData, ...data };
    // Submit complete form
    console.log('Complete form data:', completeData);
  };

  return (
    <div>
      {step === 1 && (
        <form onSubmit={step1Form.handleSubmit(onStep1Submit)}>
          <input
            {...step1Form.register('firstName', {
              required: 'First name is required'
            })}
            placeholder="First Name"
          />
          {step1Form.formState.errors.firstName && (
            <span>{step1Form.formState.errors.firstName.message}</span>
          )}

          <button type="submit">Next</button>
        </form>
      )}

      {step === 2 && (
        <form onSubmit={step2Form.handleSubmit(onStep2Submit)}>
          <input
            {...step2Form.register('email', {
              required: 'Email is required',
              pattern: {
                value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
                message: 'Invalid email'
              }
            })}
            placeholder="Email"
          />
          {step2Form.formState.errors.email && (
            <span>{step2Form.formState.errors.email.message}</span>
          )}

          <button type="button" onClick={() => setStep(1)}>Back</button>
          <button type="submit">Submit</button>
        </form>
      )}
    </div>
  );
}
```

## Real-Time Validation Feedback

```typescript
import { useForm, useWatch } from 'react-hook-form';

function PasswordStrengthForm() {
  const { register, control } = useForm();
  const password = useWatch({ control, name: 'password' });

  const getPasswordStrength = (pwd: string): 'weak' | 'medium' | 'strong' => {
    if (!pwd) return 'weak';

    let strength = 0;
    if (pwd.length >= 8) strength++;
    if (/[A-Z]/.test(pwd)) strength++;
    if (/[a-z]/.test(pwd)) strength++;
    if (/[0-9]/.test(pwd)) strength++;
    if (/[!@#$%^&*]/.test(pwd)) strength++;

    if (strength <= 2) return 'weak';
    if (strength <= 4) return 'medium';
    return 'strong';
  };

  const strength = getPasswordStrength(password || '');

  return (
    <div>
      <input
        type="password"
        {...register('password')}
        placeholder="Password"
      />

      <div>
        Password Strength:
        <span style={{
          color: strength === 'weak' ? 'red' :
                 strength === 'medium' ? 'orange' : 'green'
        }}>
          {strength.toUpperCase()}
        </span>
      </div>

      <ul>
        <li style={{ color: password?.length >= 8 ? 'green' : 'gray' }}>
          ✓ At least 8 characters
        </li>
        <li style={{ color: /[A-Z]/.test(password || '') ? 'green' : 'gray' }}>
          ✓ Contains uppercase letter
        </li>
        <li style={{ color: /[0-9]/.test(password || '') ? 'green' : 'gray' }}>
          ✓ Contains number
        </li>
      </ul>
    </div>
  );
}
```

## Best Practices

### 1. Accessibility
- Use `aria-invalid` on invalid fields
- Use `aria-describedby` to link error messages
- Use `role="alert"` for error messages
- Ensure keyboard navigation works

### 2. User Experience
- Validate on blur, not on every keystroke
- Show success states for valid fields
- Provide helpful error messages
- Don't block submission with client-side validation alone

### 3. Security
- Always validate on server-side
- Sanitize inputs before submission
- Use HTTPS for sensitive data
- Implement rate limiting for form submissions

### 4. Performance
- Debounce async validations
- Memoize validation functions
- Use field-level validation for complex forms
- Lazy load validation schemas if large

### 5. Error Messages
- Be specific and actionable
- Avoid technical jargon
- Suggest corrections when possible
- Use consistent tone and language
