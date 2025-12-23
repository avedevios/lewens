# Keycloak Server Setup Guide

## Prerequisites
- Java 11 or later
- Keycloak server (download from https://www.keycloak.org/downloads)

## Step 1: Start Keycloak Server

### Development Mode (Quick Start)
```bash
# Download and extract Keycloak
wget https://github.com/keycloak/keycloak/releases/download/22.0.0/keycloak-22.0.0.zip
unzip keycloak-22.0.0.zip
cd keycloak-22.0.0

# Start in development mode
bin/kc.sh start-dev
```

### Production Mode
```bash
# Start in production mode
bin/kc.sh start
```

## Step 2: Access Admin Console
1. Open browser: http://localhost:8080
2. Click "Administration Console"
3. Create admin user (first time only)

## Step 3: Create Realm
1. In admin console, click "Create Realm"
2. Name: `lewens`
3. Click "Create"

## Step 4: Create Client
1. Go to "Clients" → "Create"
2. Client ID: `lewens-ios`
3. Client Protocol: `openid-connect`
4. Click "Save"

## Step 5: Configure Client
1. **Access Type**: `public`
2. **Valid Redirect URIs**: `lewens://auth`
3. **Web Origins**: `+` (allow all)
4. **Standard Flow Enabled**: `ON`
5. **Direct Access Grants Enabled**: `ON`
6. Click "Save"

## Step 6: Create Test User
1. Go to "Users" → "Add user"
2. Username: `testuser`
3. Email: `test@example.com`
4. First Name: `Test`
5. Last Name: `User`
6. Click "Save"
7. Go to "Credentials" tab → "Set password"
8. Password: `password123`
9. Click "Save"

## Step 7: Test Configuration
1. Go to "Clients" → "lewens-ios"
2. Click "Test" tab
3. Verify endpoints are accessible:
   - Authorization URL: http://localhost:8080/realms/lewens/protocol/openid-connect/auth
   - Token URL: http://localhost:8080/realms/lewens/protocol/openid-connect/token
   - User Info URL: http://localhost:8080/realms/lewens/protocol/openid-connect/userinfo

## Step 8: Update iOS App Configuration
Update `KeycloakConfig.swift` if needed:
```swift
static let serverURL = "http://localhost:8080"
static let realm = "lewens"
static let clientId = "lewens-ios"
static let redirectURI = "lewens://auth"
```

## Testing the Integration
1. Run iOS app
2. Tap "Sign In"
3. Browser should open with Keycloak login
4. Enter test user credentials
5. Should redirect back to app with user profile

## Troubleshooting
- **Connection refused**: Check if Keycloak is running
- **Invalid redirect URI**: Verify redirect URI in client settings
- **Token errors**: Check client configuration and scopes
- **User not found**: Verify user exists and is enabled

## Production Considerations
- Use HTTPS in production
- Configure proper CORS settings
- Set up proper SSL certificates
- Use environment-specific configurations
- Implement proper logging and monitoring
