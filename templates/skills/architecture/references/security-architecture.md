# Security Architecture Reference

Essential security patterns and best practices for building secure systems.

## Defense in Depth

**Principle:** Multiple layers of security controls throughout the system.

```
┌─────────────────────────────────┐
│  Network Security (Firewall)    │
├─────────────────────────────────┤
│  Authentication & Authorization │
├─────────────────────────────────┤
│  Input Validation               │
├─────────────────────────────────┤
│  Encryption (TLS/At Rest)       │
├─────────────────────────────────┤
│  Audit Logging                  │
└─────────────────────────────────┘
```

## Authentication Patterns

### 1. JWT (JSON Web Tokens)

```python
import jwt
from datetime import datetime, timedelta

def create_token(user_id: str) -> str:
    payload = {
        "user_id": user_id,
        "exp": datetime.utcnow() + timedelta(hours=24),
        "iat": datetime.utcnow()
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")

def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise AuthenticationError("Token expired")
    except jwt.InvalidTokenError:
        raise AuthenticationError("Invalid token")
```

**Best Practices:**
- Short expiration times (15-60 minutes)
- Use refresh tokens for long sessions
- Store securely (httpOnly cookies)
- Rotate secrets regularly

---

### 2. OAuth 2.0

**Authorization Code Flow:**
```
1. User → Click "Login with Google"
2. App → Redirect to Google OAuth
3. User → Grants permissions
4. Google → Redirects with auth code
5. App → Exchanges code for access token
6. App → Uses token to access Google APIs
```

**Implementation:**
```python
from authlib.integrations.flask_client import OAuth

oauth = OAuth(app)

google = oauth.register(
    name='google',
    client_id=GOOGLE_CLIENT_ID,
    client_secret=GOOGLE_CLIENT_SECRET,
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'}
)

@app.route('/login/google')
def google_login():
    redirect_uri = url_for('google_callback', _external=True)
    return google.authorize_redirect(redirect_uri)

@app.route('/login/google/callback')
def google_callback():
    token = google.authorize_access_token()
    user_info = google.parse_id_token(token)
    # Create session for user
    return redirect('/dashboard')
```

---

## Authorization Patterns

### 3. Role-Based Access Control (RBAC)

```python
from enum import Enum

class Role(Enum):
    ADMIN = "admin"
    EDITOR = "editor"
    VIEWER = "viewer"

class User:
    def __init__(self, id, roles):
        self.id = id
        self.roles = roles

    def has_role(self, role: Role) -> bool:
        return role in self.roles

def require_role(role: Role):
    def decorator(func):
        def wrapper(*args, **kwargs):
            user = get_current_user()
            if not user.has_role(role):
                raise PermissionError("Insufficient permissions")
            return func(*args, **kwargs)
        return wrapper
    return decorator

@app.delete("/users/{user_id}")
@require_role(Role.ADMIN)
def delete_user(user_id: str):
    # Only admins can delete users
    pass
```

---

### 4. Attribute-Based Access Control (ABAC)

```python
class Policy:
    def can_access(self, user, resource, action) -> bool:
        # Example: Users can only edit their own posts
        if action == "edit" and resource.type == "post":
            return user.id == resource.owner_id

        # Admins can do anything
        if user.has_role(Role.ADMIN):
            return True

        return False

policy = Policy()

@app.put("/posts/{post_id}")
def update_post(post_id: str, data: dict):
    user = get_current_user()
    post = db.get_post(post_id)

    if not policy.can_access(user, post, "edit"):
        raise PermissionError("Cannot edit this post")

    # Update post
```

---

## Data Protection

### 5. Encryption at Rest

```python
from cryptography.fernet import Fernet

class DataEncryption:
    def __init__(self, key: bytes):
        self.cipher = Fernet(key)

    def encrypt(self, data: str) -> bytes:
        return self.cipher.encrypt(data.encode())

    def decrypt(self, encrypted_data: bytes) -> str:
        return self.cipher.decrypt(encrypted_data).decode()

# Usage
cipher = DataEncryption(ENCRYPTION_KEY)

# Store encrypted
user.ssn = cipher.encrypt("123-45-6789")
db.save(user)

# Retrieve and decrypt
encrypted_ssn = db.get_user(user_id).ssn
ssn = cipher.decrypt(encrypted_ssn)
```

**Best Practices:**
- Encrypt PII (Social Security Numbers, credit cards)
- Use strong algorithms (AES-256)
- Store keys in secure vault (AWS KMS, HashiCorp Vault)
- Rotate keys regularly

---

### 6. Encryption in Transit (TLS)

**Force HTTPS:**
```python
from flask import redirect, request

@app.before_request
def force_https():
    if not request.is_secure and app.env == "production":
        return redirect(request.url.replace("http://", "https://"))
```

**Security Headers:**
```python
@app.after_request
def set_security_headers(response):
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    return response
```

---

## Input Validation

### 7. SQL Injection Prevention

**❌ Vulnerable:**
```python
user_id = request.args.get('id')
query = f"SELECT * FROM users WHERE id = {user_id}"  # NEVER DO THIS
db.execute(query)
```

**✅ Safe (Parameterized Queries):**
```python
user_id = request.args.get('id')
query = "SELECT * FROM users WHERE id = :id"
db.execute(query, {"id": user_id})
```

**Using ORM:**
```python
# Safe by default
user = db.query(User).filter_by(id=user_id).first()
```

---

### 8. XSS Prevention

**Escape Output:**
```python
from markupsafe import escape

@app.route('/user/<username>')
def user_profile(username):
    # Escape user-provided content
    safe_username = escape(username)
    return f"<h1>Profile: {safe_username}</h1>"
```

**Content Security Policy:**
```python
response.headers['Content-Security-Policy'] = (
    "default-src 'self'; "
    "script-src 'self' https://trusted-cdn.com; "
    "style-src 'self' 'unsafe-inline'"
)
```

---

### 9. CSRF Protection

```python
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect(app)

# Forms automatically protected
@app.route('/transfer', methods=['POST'])
def transfer_money():
    # CSRF token validated automatically
    amount = request.form['amount']
    # Process transfer
```

**API CSRF Protection:**
```python
# Use custom header instead of cookie
@app.before_request
def check_csrf_token():
    if request.method in ['POST', 'PUT', 'DELETE']:
        token = request.headers.get('X-CSRF-Token')
        if not validate_csrf_token(token):
            abort(403)
```

---

## Secrets Management

### 10. Environment Variables

```python
import os

# ✅ Good: From environment
DATABASE_URL = os.getenv("DATABASE_URL")
API_KEY = os.getenv("API_KEY")

# ❌ Bad: Hardcoded
DATABASE_URL = "postgresql://user:pass@localhost/db"  # NEVER!
```

**Docker:**
```dockerfile
# Use secrets, not ENV for sensitive data
RUN --mount=type=secret,id=api_key \
    API_KEY=$(cat /run/secrets/api_key) python setup.py
```

---

### 11. Secrets Vault

```python
import hvac  # HashiCorp Vault client

client = hvac.Client(url='http://vault:8200')
client.token = os.getenv('VAULT_TOKEN')

# Read secret
secret = client.secrets.kv.v2.read_secret_version(path='myapp/database')
db_password = secret['data']['data']['password']
```

---

## Audit & Compliance

### 12. Audit Logging

```python
import logging

audit_logger = logging.getLogger('audit')

def audit_log(user_id, action, resource, result):
    audit_logger.info({
        'timestamp': datetime.utcnow().isoformat(),
        'user_id': user_id,
        'action': action,
        'resource': resource,
        'result': result,
        'ip_address': request.remote_addr
    })

@app.delete('/users/{user_id}')
def delete_user(user_id: str):
    current_user = get_current_user()

    try:
        db.delete_user(user_id)
        audit_log(current_user.id, 'DELETE_USER', user_id, 'SUCCESS')
    except Exception as e:
        audit_log(current_user.id, 'DELETE_USER', user_id, 'FAILURE')
        raise
```

**What to Log:**
- ✅ Authentication attempts (success/failure)
- ✅ Authorization failures
- ✅ Data access (especially PII)
- ✅ Data modifications
- ✅ Admin actions
- ❌ Passwords, tokens, PII in logs

---

## Security Best Practices Checklist

### Authentication & Authorization
- [ ] Strong password requirements (length, complexity)
- [ ] Multi-factor authentication (MFA) for sensitive operations
- [ ] Account lockout after failed attempts
- [ ] Secure password storage (bcrypt, Argon2)
- [ ] JWT/session expiration enforced
- [ ] Principle of least privilege

### Data Protection
- [ ] PII encrypted at rest
- [ ] TLS/HTTPS enforced
- [ ] Database credentials encrypted
- [ ] Secrets in vault (not code/env vars in repo)
- [ ] Regular key rotation

### Input Validation
- [ ] Parameterized queries (SQL injection prevention)
- [ ] Output encoding (XSS prevention)
- [ ] CSRF tokens
- [ ] File upload validation
- [ ] API rate limiting

### Dependency Management
- [ ] Regular security updates
- [ ] Vulnerability scanning (Snyk, Dependabot)
- [ ] Minimal dependencies
- [ ] Pin dependency versions

### Monitoring & Incident Response
- [ ] Audit logging enabled
- [ ] Security alerts configured
- [ ] Incident response plan
- [ ] Regular security reviews

---

**Related References:**
- [Design Principles](design-principles.md)
- [Architectural Patterns](architectural-patterns.md)
