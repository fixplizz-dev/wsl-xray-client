#!/usr/bin/env bash
# Test setup and common functions for bats tests

# Function to check if bats is installed
check_bats_installation() {
    if ! command -v bats >/dev/null 2>&1; then
        echo "ERROR: bats (Bash Automated Testing System) is not installed"
        echo "Install with:"
        echo "  Ubuntu/Debian: sudo apt install bats"
        echo "  Or from source: https://github.com/bats-core/bats-core"
        exit 1
    fi
}

# Setup function for all tests
setup() {
    # Create temporary directory for test files
    export TEST_TEMP_DIR="$(mktemp -d)"

    # Set project root relative to tests directory
    export PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"

    # Source common functions
    source "$PROJECT_ROOT/lib/common.sh"

    # Disable colors in tests for consistent output
    export XRAY_DISABLE_COLORS=1

    # Enable debug logging in tests
    export XRAY_DEBUG=1
}

# Cleanup function for all tests
teardown() {
    # Clean up temporary directory
    if [[ -n "${TEST_TEMP_DIR:-}" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR" 2>/dev/null || true
    fi
}

# Helper function to create test .env file
create_test_env() {
    local env_file="${1:-$TEST_TEMP_DIR/.env}"
    cat > "$env_file" << 'EOF'
XRAY_PROTOCOL=vless
XRAY_SERVER_HOST=test.example.com
XRAY_SERVER_PORT=443
XRAY_UUID_OR_PASS=12345678-abcd-1234-efgh-123456789012
XRAY_SECURITY=reality
XRAY_SNI=www.cloudflare.com
XRAY_PUBLIC_KEY=SIlMRHOvKi-4lDn6ghtML3uWtsaW4oV9SG5K3YiOEyc
XRAY_SHORT_ID=6ba85179e30d4fc2
XRAY_FINGERPRINT=chrome
XRAY_LOCAL_SOCKS_PORT=1080
XRAY_LOCAL_HTTP_PORT=8080
XRAY_AUTOSTART=off
XRAY_CLIENT_LANG=en
EOF
    chmod 600 "$env_file"
    echo "$env_file"
}

# Helper function to create invalid .env file
create_invalid_env() {
    local env_file="${1:-$TEST_TEMP_DIR/.env}"
    cat > "$env_file" << 'EOF'
# Invalid syntax - missing quotes and invalid variable reference
XRAY_PROTOCOL=vless
INVALID_SYNTAX=${{NOT_A_VARIABLE
XRAY_SERVER_HOST=
EOF
    chmod 600 "$env_file"
    echo "$env_file"
}

# Check if we're in test mode (called by bats)
if [[ "${BATS_TEST_FILENAME:-}" != "" ]]; then
    # We're in a bats test, check installation
    check_bats_installation
fi