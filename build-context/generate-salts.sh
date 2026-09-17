#!/bin/bash
# Generates random 40-character hex strings for WordPress salts

KEYS=("AUTH_KEY" "SECURE_AUTH_KEY" "LOGGED_IN_KEY" "NONCE_KEY" "AUTH_SALT" "SECURE_AUTH_SALT" "LOGGED_IN_SALT" "NONCE_SALT")

# Generate and store the salts
declare -A SALTS
for key in "${KEYS[@]}"; do
    SALTS[$key]=$(openssl rand -hex 20)
done

echo "================================================================="
echo "1. Add these to your .env file (if passing via docker-compose):"
echo "================================================================="
for key in "${KEYS[@]}"; do
    echo "WORDPRESS_${key}=${SALTS[$key]}"
done

echo ""
echo "================================================================="
echo "2. Add these to your wp-config.php file:"
echo "================================================================="
for key in "${KEYS[@]}"; do
    # Pad the entire string segment instead of the variable name
    printf "%-28s%-45s'%s') );\n" "define( '${key}'," "getenv_docker('WORDPRESS_${key}'," "${SALTS[$key]}"
done
echo ""
