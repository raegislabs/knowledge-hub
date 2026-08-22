# Security Patterns

Comprehensive guide to authentication, authorization, input validation, and common security vulnerabilities in backend systems.

## Table of Contents
1. [Authentication](#authentication)
2. [Authorization](#authorization)
3. [Input Validation](#input-validation)
4. [Password Security](#password-security)
5. [SQL Injection Prevention](#sql-injection-prevention)
6. [XSS Prevention](#xss-prevention)
7. [CSRF Protection](#csrf-protection)
8. [Rate Limiting](#rate-limiting)
9. [Secure Configuration](#secure-configuration)
10. [Common Vulnerabilities](#common-vulnerabilities)

---

## Authentication

### JWT Token-Based Authentication

**Implementation Pattern:**
```python
from datetime import datetime, timedelta
import jwt
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 7

security = HTTPBearer()


def create_access_token(data: dict) -> str:
    """Create a JWT access token."""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(data: dict) -> str:
    """Create a JWT refresh token."""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> dict:
    """
    Validate JWT token and return current user.

    Raises:
        HTTPException: If token is invalid or expired
    """
    token = credentials.credentials

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

        # Verify token type
        if payload.get("type") != "access":
            raise HTTPException(
                status_code=401,
                detail="Invalid token type"
            )

        # Extract user info
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=401,
                detail="Invalid token payload"
            )

        # Fetch user from database
        user = await get_user_by_id(int(user_id))
        if not user or not user.is_active:
            raise HTTPException(
                status_code=401,
                detail="User not found or inactive"
            )

        return user

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=401,
            detail="Token has expired"
        )
    except jwt.JWTError:
        raise HTTPException(
            status_code=401,
            detail="Invalid token"
        )
```

**Login Endpoint:**
```python
from fastapi import APIRouter, Depends
from pydantic import BaseModel

router = APIRouter()


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


@router.post("/login", response_model=TokenResponse)
async def login(credentials: LoginRequest):
    """
    Authenticate user and return tokens.

    Rate limit: 5 requests per minute per IP
    """
    # Verify credentials
    user = await authenticate_user(credentials.email, credentials.password)

    if not user:
        # Don't reveal whether email or password was wrong
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials"
        )

    if not user.is_active:
        raise HTTPException(
            status_code=403,
            detail="Account is disabled"
        )

    # Create tokens
    token_data = {"sub": str(user.id), "email": user.email}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    # Log successful login
    await log_security_event("login_success", user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token
    )
```

**Refresh Token Endpoint:**
```python
@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    credentials: HTTPAuthorizationCredentials = Security(security)
):
    """
    Refresh access token using refresh token.
    """
    token = credentials.credentials

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

        # Verify token type
        if payload.get("type") != "refresh":
            raise HTTPException(
                status_code=401,
                detail="Invalid token type"
            )

        user_id = payload.get("sub")
        user = await get_user_by_id(int(user_id))

        if not user or not user.is_active:
            raise HTTPException(status_code=401, detail="Invalid user")

        # Create new tokens
        token_data = {"sub": str(user.id), "email": user.email}
        new_access_token = create_access_token(token_data)
        new_refresh_token = create_refresh_token(token_data)

        return TokenResponse(
            access_token=new_access_token,
            refresh_token=new_refresh_token
        )

    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Refresh token expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
```

### Session-Based Authentication

```python
from starlette.middleware.sessions import SessionMiddleware

# Add session middleware
app.add_middleware(
    SessionMiddleware,
    secret_key=os.getenv("SESSION_SECRET"),
    max_age=3600,  # 1 hour
    same_site="lax",
    https_only=True  # Production only
)


@router.post("/login")
async def login(credentials: LoginRequest, request: Request):
    """Login with session."""
    user = await authenticate_user(credentials.email, credentials.password)

    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    # Create session
    request.session["user_id"] = user.id
    request.session["email"] = user.email

    return {"message": "Login successful"}


async def get_current_user_from_session(request: Request) -> dict:
    """Get user from session."""
    user_id = request.session.get("user_id")

    if not user_id:
        raise HTTPException(status_code=401, detail="Not authenticated")

    user = await get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid session")

    return user
```

### Best Practices

1. **Short Token Expiration**
   - Access tokens: 15-60 minutes
   - Refresh tokens: 7-30 days

2. **Secure Token Storage**
   - ✅ Store in httpOnly cookies (web)
   - ✅ Secure storage (mobile/desktop)
   - ❌ Never in localStorage (XSS vulnerable)

3. **Token Revocation**
   ```python
   # Maintain blacklist of revoked tokens
   revoked_tokens = set()  # Use Redis in production

   async def revoke_token(token: str):
       """Add token to blacklist."""
       revoked_tokens.add(token)
       # Set expiration in Redis
       redis.setex(f"revoked:{token}", 86400, "1")

   async def is_token_revoked(token: str) -> bool:
       """Check if token is blacklisted."""
       return token in revoked_tokens
   ```

4. **Logout**
   ```python
   @router.post("/logout")
   async def logout(
       credentials: HTTPAuthorizationCredentials = Security(security)
   ):
       """Logout user by revoking token."""
       await revoke_token(credentials.credentials)
       return {"message": "Logout successful"}
   ```

---

## Authorization

### Role-Based Access Control (RBAC)

**Database Schema:**
```sql
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    resource VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL
);

CREATE TABLE role_permissions (
    role_id INTEGER REFERENCES roles(id),
    permission_id INTEGER REFERENCES permissions(id),
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE user_roles (
    user_id INTEGER REFERENCES users(id),
    role_id INTEGER REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
);

-- Sample data
INSERT INTO roles (name) VALUES ('admin'), ('editor'), ('viewer');

INSERT INTO permissions (name, resource, action) VALUES
    ('users:read', 'users', 'read'),
    ('users:write', 'users', 'write'),
    ('users:delete', 'users', 'delete'),
    ('posts:read', 'posts', 'read'),
    ('posts:write', 'posts', 'write');

-- Admin has all permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p WHERE r.name = 'admin';

-- Editor can read/write posts
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'editor' AND p.name IN ('posts:read', 'posts:write');

-- Viewer can only read
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p
WHERE r.name = 'viewer' AND p.action = 'read';
```

**Permission Checker:**
```python
from functools import wraps
from typing import List

async def get_user_permissions(user_id: int) -> List[str]:
    """Get all permissions for a user."""
    query = """
        SELECT DISTINCT p.name
        FROM permissions p
        JOIN role_permissions rp ON p.id = rp.permission_id
        JOIN user_roles ur ON rp.role_id = ur.role_id
        WHERE ur.user_id = $1
    """
    permissions = await db.fetch(query, user_id)
    return [p["name"] for p in permissions]


async def has_permission(user: dict, permission: str) -> bool:
    """Check if user has a specific permission."""
    user_permissions = await get_user_permissions(user["id"])
    return permission in user_permissions


async def has_role(user: dict, role: str) -> bool:
    """Check if user has a specific role."""
    query = """
        SELECT EXISTS(
            SELECT 1 FROM user_roles ur
            JOIN roles r ON ur.role_id = r.id
            WHERE ur.user_id = $1 AND r.name = $2
        )
    """
    result = await db.fetchval(query, user["id"], role)
    return result


def require_permission(permission: str):
    """Decorator to require specific permission."""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, current_user: dict = None, **kwargs):
            if not current_user:
                raise HTTPException(status_code=401, detail="Not authenticated")

            if not await has_permission(current_user, permission):
                raise HTTPException(
                    status_code=403,
                    detail=f"Permission denied: {permission} required"
                )

            return await func(*args, current_user=current_user, **kwargs)
        return wrapper
    return decorator


def require_role(role: str):
    """Decorator to require specific role."""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, current_user: dict = None, **kwargs):
            if not current_user:
                raise HTTPException(status_code=401, detail="Not authenticated")

            if not await has_role(current_user, role):
                raise HTTPException(
                    status_code=403,
                    detail=f"Role required: {role}"
                )

            return await func(*args, current_user=current_user, **kwargs)
        return wrapper
    return decorator
```

**Using Permission Decorators:**
```python
@router.delete("/users/{user_id}")
@require_permission("users:delete")
async def delete_user(
    user_id: int,
    current_user: dict = Depends(get_current_user)
):
    """Delete user (requires users:delete permission)."""
    await user_service.delete(user_id)
    return Response(status_code=204)


@router.get("/admin/dashboard")
@require_role("admin")
async def admin_dashboard(current_user: dict = Depends(get_current_user)):
    """Admin dashboard (requires admin role)."""
    return await get_admin_stats()
```

### Resource-Based Authorization

```python
async def check_resource_access(
    user: dict,
    resource_id: int,
    resource_type: str,
    action: str
) -> bool:
    """
    Check if user can perform action on resource.

    Rules:
    - Owner can do anything
    - Admin can do anything
    - Editor can read/write
    - Viewer can only read
    """
    # Get resource
    resource = await get_resource(resource_type, resource_id)

    if not resource:
        return False

    # Owner check
    if resource.owner_id == user["id"]:
        return True

    # Admin check
    if await has_role(user, "admin"):
        return True

    # Permission check
    permission = f"{resource_type}:{action}"
    return await has_permission(user, permission)


@router.patch("/posts/{post_id}")
async def update_post(
    post_id: int,
    update_data: PostUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Update post (requires ownership or permission)."""
    if not await check_resource_access(current_user, post_id, "posts", "write"):
        raise HTTPException(status_code=403, detail="Permission denied")

    return await post_service.update(post_id, update_data)
```

---

## Input Validation

### Using Pydantic Validators

```python
from pydantic import BaseModel, Field, validator, root_validator
from typing import Optional
import re


class UserCreate(BaseModel):
    """Schema for user creation with validation."""

    email: str = Field(..., max_length=255)
    password: str = Field(..., min_length=8, max_length=128)
    name: str = Field(..., min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=13, le=120)
    website: Optional[str] = Field(None, max_length=255)

    @validator('email')
    def validate_email(cls, v):
        """Validate email format."""
        email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_regex, v):
            raise ValueError('Invalid email format')
        return v.lower()  # Normalize to lowercase

    @validator('password')
    def validate_password(cls, v):
        """Validate password strength."""
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain lowercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain digit')
        if not re.search(r'[!@#$%^&*]', v):
            raise ValueError('Password must contain special character')
        return v

    @validator('name')
    def validate_name(cls, v):
        """Validate name contains no special characters."""
        if not re.match(r'^[a-zA-Z\s]+$', v):
            raise ValueError('Name can only contain letters and spaces')
        return v.strip()

    @validator('website')
    def validate_website(cls, v):
        """Validate website URL."""
        if v is None:
            return v

        url_regex = r'^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$'
        if not re.match(url_regex, v):
            raise ValueError('Invalid URL format')
        return v

    @root_validator
    def validate_user(cls, values):
        """Cross-field validation."""
        # Example: Check if email domain matches company domain
        email = values.get('email')
        if email and 'example.com' not in email:
            # Custom business rule
            pass
        return values


class PostCreate(BaseModel):
    """Schema for post creation."""

    title: str = Field(..., min_length=1, max_length=200)
    content: str = Field(..., min_length=1, max_length=10000)
    tags: List[str] = Field(default_factory=list, max_items=10)
    published: bool = False

    @validator('title', 'content')
    def sanitize_html(cls, v):
        """Strip HTML tags from text fields."""
        return re.sub(r'<[^>]+>', '', v)

    @validator('tags')
    def validate_tags(cls, v):
        """Validate tags."""
        if len(v) != len(set(v)):
            raise ValueError('Duplicate tags not allowed')

        for tag in v:
            if len(tag) > 20:
                raise ValueError('Tag too long (max 20 characters)')
            if not re.match(r'^[a-z0-9-]+$', tag):
                raise ValueError('Tags must be lowercase alphanumeric with hyphens')

        return v
```

### SQL Injection Prevention

```python
# ✅ SAFE - Parameterized query
async def get_user_safe(user_id: int):
    query = "SELECT * FROM users WHERE id = $1"
    return await db.fetchrow(query, user_id)


# ❌ DANGEROUS - String interpolation
async def get_user_unsafe(user_id: str):
    query = f"SELECT * FROM users WHERE id = {user_id}"  # SQL injection!
    return await db.fetchrow(query)


# ✅ SAFE - Using ORM
async def get_user_orm(user_id: int):
    return await User.query.filter_by(id=user_id).first()


# ✅ SAFE - Parameterized IN clause
async def get_users_by_ids(user_ids: List[int]):
    placeholders = ','.join(f'${i+1}' for i in range(len(user_ids)))
    query = f"SELECT * FROM users WHERE id IN ({placeholders})"
    return await db.fetch(query, *user_ids)
```

---

## Password Security

### Password Hashing

```python
from passlib.context import CryptContext

# Use bcrypt for password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)


async def authenticate_user(email: str, password: str) -> Optional[dict]:
    """
    Authenticate user by email and password.

    Returns user if credentials valid, None otherwise.
    """
    user = await get_user_by_email(email)

    if not user:
        # Always hash even if user not found (timing attack prevention)
        pwd_context.hash("dummy_password")
        return None

    if not verify_password(password, user.password_hash):
        return None

    return user
```

### Password Reset Flow

```python
import secrets
from datetime import datetime, timedelta


async def request_password_reset(email: str):
    """
    Request password reset.

    Sends email with reset token.
    """
    user = await get_user_by_email(email)

    if not user:
        # Don't reveal if email exists
        logger.info(f"Password reset requested for non-existent email: {email}")
        return {"message": "If email exists, reset link sent"}

    # Generate secure random token
    reset_token = secrets.token_urlsafe(32)
    reset_expires = datetime.utcnow() + timedelta(hours=1)

    # Store token (hash it!)
    token_hash = hash_password(reset_token)
    await store_reset_token(user.id, token_hash, reset_expires)

    # Send email (don't wait for it)
    await send_reset_email(user.email, reset_token)

    return {"message": "If email exists, reset link sent"}


async def reset_password(token: str, new_password: str):
    """Reset password using token."""
    # Find token
    stored_token = await get_reset_token(token_hash=hash_password(token))

    if not stored_token:
        raise HTTPException(status_code=400, detail="Invalid or expired token")

    if stored_token.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Token expired")

    if stored_token.used:
        raise HTTPException(status_code=400, detail="Token already used")

    # Update password
    password_hash = hash_password(new_password)
    await update_user_password(stored_token.user_id, password_hash)

    # Mark token as used
    await mark_token_used(stored_token.id)

    # Invalidate all sessions
    await revoke_all_user_tokens(stored_token.user_id)

    return {"message": "Password reset successful"}
```

---

## Rate Limiting

### Using slowapi

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)


@router.post("/login")
@limiter.limit("5/minute")  # 5 requests per minute
async def login(request: Request, credentials: LoginRequest):
    """Login endpoint with rate limiting."""
    # ... login logic


@router.post("/api/expensive-operation")
@limiter.limit("10/hour")  # 10 requests per hour
async def expensive_operation(request: Request):
    """Expensive operation with strict rate limit."""
    # ... operation logic


# Custom rate limit per user
@limiter.limit("100/minute", key_func=lambda: get_current_user().id)
async def user_specific_limit(request: Request):
    """Rate limit per authenticated user."""
    pass
```

### Custom Rate Limiter with Redis

```python
import redis
from datetime import datetime

redis_client = redis.Redis(host='localhost', port=6379, db=0)


async def check_rate_limit(
    key: str,
    limit: int,
    window_seconds: int
) -> bool:
    """
    Check if rate limit exceeded.

    Args:
        key: Identifier (user_id, IP, etc.)
        limit: Max requests
        window_seconds: Time window

    Returns:
        True if allowed, False if rate limited
    """
    now = datetime.utcnow().timestamp()
    window_start = now - window_seconds

    # Remove old requests
    redis_client.zremrangebyscore(key, 0, window_start)

    # Count requests in window
    request_count = redis_client.zcard(key)

    if request_count >= limit:
        return False

    # Add new request
    redis_client.zadd(key, {str(now): now})
    redis_client.expire(key, window_seconds)

    return True


@router.post("/login")
async def login(request: Request, credentials: LoginRequest):
    """Login with custom rate limiting."""
    client_ip = request.client.host
    key = f"login:{client_ip}"

    if not await check_rate_limit(key, limit=5, window_seconds=60):
        raise HTTPException(
            status_code=429,
            detail="Too many login attempts. Try again later."
        )

    # ... login logic
```

---

## Secure Configuration

### Environment Variables

```python
from pydantic import BaseSettings, Field, validator


class Settings(BaseSettings):
    """Application settings from environment variables."""

    # Database
    DATABASE_URL: str
    DATABASE_POOL_SIZE: int = 10

    # Security
    JWT_SECRET_KEY: str = Field(..., min_length=32)
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15

    # API
    API_V1_PREFIX: str = "/api/v1"
    CORS_ORIGINS: List[str] = ["http://localhost:3000"]

    # Email
    SMTP_HOST: str
    SMTP_PORT: int = 587
    SMTP_USER: str
    SMTP_PASSWORD: str

    @validator('CORS_ORIGINS', pre=True)
    def parse_cors_origins(cls, v):
        """Parse CORS origins from comma-separated string."""
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(',')]
        return v

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()

# Never hardcode secrets
❌ JWT_SECRET_KEY = "my-secret-key"
✅ JWT_SECRET_KEY = settings.JWT_SECRET_KEY
```

### Secrets Management

```bash
# .env file (never commit!)
DATABASE_URL=postgresql://user:pass@localhost/db
JWT_SECRET_KEY=generated-with-secrets-token-urlsafe-32

# .env.example (commit this)
DATABASE_URL=postgresql://user:pass@localhost/db
JWT_SECRET_KEY=your-secret-key-here
```

**Generate secure secrets:**
```python
import secrets

# Generate JWT secret
print(secrets.token_urlsafe(32))
```

---

## Common Vulnerabilities

### OWASP Top 10 Prevention

**1. Broken Access Control**
```python
# ❌ BAD - No permission check
@router.delete("/users/{user_id}")
async def delete_user(user_id: int):
    await user_service.delete(user_id)

# ✅ GOOD - Check permissions
@router.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    current_user: dict = Depends(get_current_user)
):
    if user_id != current_user["id"] and not current_user["is_admin"]:
        raise HTTPException(status_code=403)
    await user_service.delete(user_id)
```

**2. Cryptographic Failures**
```python
# ❌ BAD - Storing passwords in plain text
user.password = request.password

# ✅ GOOD - Hash passwords
user.password_hash = hash_password(request.password)

# ❌ BAD - Using MD5/SHA1 for passwords
hashlib.md5(password.encode()).hexdigest()

# ✅ GOOD - Using bcrypt
pwd_context.hash(password)
```

**3. Injection**
```python
# ❌ BAD - SQL injection
db.execute(f"SELECT * FROM users WHERE email = '{email}'")

# ✅ GOOD - Parameterized query
db.execute("SELECT * FROM users WHERE email = $1", email)
```

**4. Insecure Design**
- Implement principle of least privilege
- Fail securely (default deny)
- Don't trust client-side validation

**5. Security Misconfiguration**
```python
# ❌ BAD - Debug mode in production
app = FastAPI(debug=True)

# ✅ GOOD - Debug only in development
app = FastAPI(debug=settings.DEBUG)

# ❌ BAD - Exposing error details
return {"error": str(exception)}

# ✅ GOOD - Generic error messages
logger.error(f"Error: {exception}")
return {"error": "An error occurred"}
```

**6. Vulnerable Components**
```bash
# Keep dependencies updated
pip install --upgrade pip
pip install --upgrade -r requirements.txt

# Check for vulnerabilities
pip install safety
safety check
```

**7. Authentication Failures**
- Implement MFA
- Rate limit login attempts
- Use secure session management
- Implement account lockout

**8. Software and Data Integrity Failures**
- Verify dependencies (checksums)
- Use signed commits
- Implement CI/CD security

**9. Logging Failures**
```python
# ❌ BAD - Not logging security events
user_login(email, password)

# ✅ GOOD - Log security events
logger.info(f"Login attempt: {email} from {ip}")
if success:
    logger.info(f"Login successful: {email}")
else:
    logger.warning(f"Login failed: {email}")
```

**10. Server-Side Request Forgery (SSRF)**
```python
# ❌ BAD - Unrestricted URL fetch
@router.post("/fetch")
async def fetch_url(url: str):
    response = requests.get(url)  # SSRF vulnerability!

# ✅ GOOD - Whitelist allowed domains
ALLOWED_DOMAINS = ["api.example.com", "cdn.example.com"]

@router.post("/fetch")
async def fetch_url(url: str):
    parsed = urlparse(url)
    if parsed.netloc not in ALLOWED_DOMAINS:
        raise HTTPException(status_code=400, detail="Invalid domain")
    response = requests.get(url, timeout=5)
```

### Security Checklist

- [ ] HTTPS enforced (no HTTP)
- [ ] Passwords hashed with bcrypt
- [ ] JWT tokens properly validated
- [ ] Authorization checks on all endpoints
- [ ] Input validation with Pydantic
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitize output)
- [ ] CSRF protection (for cookie-based auth)
- [ ] Rate limiting implemented
- [ ] Secrets in environment variables
- [ ] Debug mode disabled in production
- [ ] Error messages don't leak details
- [ ] Security events logged
- [ ] Dependencies kept updated
- [ ] CORS properly configured
