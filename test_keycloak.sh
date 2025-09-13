#!/bin/bash

# Test Keycloak server configuration
echo "Testing Keycloak server configuration..."

# Check if Keycloak is running
echo "1. Checking if Keycloak is running..."
if curl -s http://localhost:8080/realms/lewens > /dev/null; then
    echo "✅ Keycloak server is running"
else
    echo "❌ Keycloak server is not running"
    echo "   Please start Keycloak with: bin/kc.sh start-dev"
    exit 1
fi

# Check realm configuration
echo "2. Checking realm configuration..."
if curl -s http://localhost:8080/realms/lewens/.well-known/openid_configuration > /dev/null; then
    echo "✅ Realm 'lewens' is configured"
else
    echo "❌ Realm 'lewens' is not found"
    echo "   Please create realm 'lewens' in Keycloak admin console"
    exit 1
fi

# Check client configuration
echo "3. Checking client configuration..."
if curl -s "http://localhost:8080/realms/lewens/protocol/openid-connect/auth?client_id=lewens-ios&response_type=code&redirect_uri=lewens://auth&scope=openid" > /dev/null; then
    echo "✅ Client 'lewens-ios' is configured"
else
    echo "❌ Client 'lewens-ios' is not found or misconfigured"
    echo "   Please create client 'lewens-ios' with redirect URI 'lewens://auth'"
    exit 1
fi

# Check endpoints
echo "4. Checking OAuth endpoints..."
AUTH_URL="http://localhost:8080/realms/lewens/protocol/openid-connect/auth"
TOKEN_URL="http://localhost:8080/realms/lewens/protocol/openid-connect/token"
USERINFO_URL="http://localhost:8080/realms/lewens/protocol/openid-connect/userinfo"

if curl -s "$AUTH_URL" > /dev/null; then
    echo "✅ Authorization endpoint is accessible"
else
    echo "❌ Authorization endpoint is not accessible"
fi

if curl -s "$TOKEN_URL" > /dev/null; then
    echo "✅ Token endpoint is accessible"
else
    echo "❌ Token endpoint is not accessible"
fi

if curl -s "$USERINFO_URL" > /dev/null; then
    echo "✅ User info endpoint is accessible"
else
    echo "❌ User info endpoint is not accessible"
fi

echo ""
echo "🎉 Keycloak configuration test completed!"
echo "   If all checks passed, you can test the iOS app integration."
echo "   Run the iOS app and tap 'Sign In' to test OAuth flow."
