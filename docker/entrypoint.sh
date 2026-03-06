#!/bin/bash
set -e

echo "=== LySmart Chat Server Entrypoint ==="

# Default values
LYSMART_CONTEXT_SOURCE="${LYSMART_CONTEXT_SOURCE:-local}"
LYSMART_DEFAULT_PROJECT_PATH="${LYSMART_DEFAULT_PROJECT_PATH:-/app/context}"

echo "Context source: $LYSMART_CONTEXT_SOURCE"
echo "Target path: $LYSMART_DEFAULT_PROJECT_PATH"

# Initialize context based on source type
if [ "$LYSMART_CONTEXT_SOURCE" = "git" ]; then
    echo ""
    echo "=== Initializing Git Context ==="
    
    if [ -z "$LYSMART_CONTEXT_GIT_URL" ]; then
        echo "ERROR: LYSMART_CONTEXT_GIT_URL is required when LYSMART_CONTEXT_SOURCE=git"
        exit 1
    fi
    
    LYSMART_CONTEXT_GIT_BRANCH="${LYSMART_CONTEXT_GIT_BRANCH:-main}"
    
    # Build auth URL if token provided
    GIT_URL="$LYSMART_CONTEXT_GIT_URL"
    if [ -n "$LYSMART_CONTEXT_GIT_TOKEN" ]; then
        # Inject token into HTTPS URL
        GIT_URL=$(echo "$LYSMART_CONTEXT_GIT_URL" | sed "s|https://|https://${LYSMART_CONTEXT_GIT_TOKEN}@|")
        echo "Using authenticated git URL"
    fi
    
    # Clone or pull
    if [ -d "$LYSMART_DEFAULT_PROJECT_PATH/.git" ]; then
        echo "Repository exists, pulling latest..."
        cd "$LYSMART_DEFAULT_PROJECT_PATH"
        git fetch "$GIT_URL" "$LYSMART_CONTEXT_GIT_BRANCH" --depth=1
        git reset --hard FETCH_HEAD
        echo "✓ Context updated"
    else
        echo "Cloning repository..."
        # Ensure parent directory exists
        mkdir -p "$(dirname "$LYSMART_DEFAULT_PROJECT_PATH")"
        
        # Remove target if it exists but isn't a git repo
        if [ -d "$LYSMART_DEFAULT_PROJECT_PATH" ]; then
            rm -rf "$LYSMART_DEFAULT_PROJECT_PATH"
        fi
        
        git clone --branch "$LYSMART_CONTEXT_GIT_BRANCH" --depth 1 --single-branch "$GIT_URL" "$LYSMART_DEFAULT_PROJECT_PATH"
        echo "✓ Context cloned"
    fi
    
    # Validate context
    if [ ! -f "$LYSMART_DEFAULT_PROJECT_PATH/lysmart_config.yaml" ]; then
        echo "ERROR: lysmart_config.yaml not found in cloned repository"
        exit 1
    fi
    
    echo "✓ Context validated"

elif [ "$LYSMART_CONTEXT_SOURCE" = "local" ]; then
    echo ""
    echo "=== Validating Local Context ==="
    
    if [ ! -d "$LYSMART_DEFAULT_PROJECT_PATH" ]; then
        echo "ERROR: Context path does not exist: $LYSMART_DEFAULT_PROJECT_PATH"
        echo "For local mode, ensure the path is mounted as a Docker volume"
        echo "or use LYSMART_CONTEXT_SOURCE=git for git-based context."
        exit 1
    fi
    
    if [ ! -f "$LYSMART_DEFAULT_PROJECT_PATH/lysmart_config.yaml" ]; then
        echo "ERROR: lysmart_config.yaml not found in $LYSMART_DEFAULT_PROJECT_PATH"
        echo "Ensure the context path contains a valid LySmart project."
        exit 1
    fi
    
    echo "✓ Local context validated"

else
    echo "ERROR: Unknown LYSMART_CONTEXT_SOURCE: $LYSMART_CONTEXT_SOURCE"
    echo "Must be 'local' or 'git'"
    exit 1
fi

echo ""
echo "=== Starting Services ==="

# Grant the LySmart user access to /dev/kvm if it exists (needed for Boxlite sandboxing)
if [ -e /dev/kvm ]; then
    KVM_GID=$(stat -c '%g' /dev/kvm)
    if ! getent group kvm > /dev/null 2>&1; then
        groupadd -g "$KVM_GID" kvm
    fi
    usermod -aG kvm lysmart
    echo "✓ Added LySmart user to kvm group (GID $KVM_GID)"
fi

# Generate BETTER_AUTH_SECRET if not provided
if [ -z "$BETTER_AUTH_SECRET" ]; then
    export BETTER_AUTH_SECRET=$(openssl rand -hex 32)
    echo "⚠ BETTER_AUTH_SECRET not set — generated a random one."
    echo "  Sessions will not persist across restarts. Set BETTER_AUTH_SECRET for persistence."
fi

# Export the path for child processes
export LYSMART_DEFAULT_PROJECT_PATH

# Start supervisord (which manages FastAPI and Chat Server)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/lysmart.conf
