#!/usr/bin/env python3
"""Verify service account details from private key"""

import os
import json
import base64
from dotenv import load_dotenv
from pathlib import Path

# Load .env
parent_dir = Path(__file__).parent.parent
env_path = parent_dir / '.env'
load_dotenv(env_path)

def decode_jwt_payload(private_key):
    """Extract service account info from private key"""
    try:
        # The private key itself doesn't contain the email
        # But we can verify it's a valid RSA key
        if '-----BEGIN PRIVATE KEY-----' in private_key and '-----END PRIVATE KEY-----' in private_key:
            print("✅ Private key format is valid (PEM format)")
            
            # Count the lines
            lines = private_key.strip().split('\n')
            print(f"✅ Private key has {len(lines)} lines")
            
            # Check if it's properly formatted
            if lines[0].strip() == '-----BEGIN PRIVATE KEY-----':
                print("✅ Private key starts correctly")
            if lines[-1].strip() == '-----END PRIVATE KEY-----':
                print("✅ Private key ends correctly")
                
            return True
        else:
            print("❌ Private key format is invalid")
            return False
    except Exception as e:
        print(f"❌ Error validating private key: {e}")
        return False

def main():
    print("=" * 60)
    print("SERVICE ACCOUNT VERIFICATION")
    print("=" * 60)
    
    # Get credentials
    service_account_email = os.getenv('GOOGLE_SERVICE_ACCOUNT_EMAIL')
    private_key_raw = os.getenv('GOOGLE_PRIVATE_KEY')
    property_id = os.getenv('GA4_PROPERTY_ID')
    
    print(f"\n📧 Service Account Email:")
    print(f"   {service_account_email}")
    
    print(f"\n🔑 GA4 Property ID:")
    print(f"   {property_id}")
    
    # Clean up private key
    private_key = private_key_raw.strip()
    if private_key.startswith('"') and private_key.endswith('"'):
        private_key = private_key[1:-1]
    private_key = private_key.replace('\\n', '\n')
    
    print(f"\n🔐 Private Key Validation:")
    is_valid = decode_jwt_payload(private_key)
    
    if is_valid:
        print("\n" + "=" * 60)
        print("NEXT STEPS:")
        print("=" * 60)
        print("\n1. Verify in Google Cloud Console:")
        print("   https://console.cloud.google.com/iam-admin/serviceaccounts")
        print(f"   - Look for: {service_account_email}")
        print("   - Check if this service account exists")
        print("   - If not, the private key is from a different account")
        
        print("\n2. Verify in Google Analytics:")
        print("   https://analytics.google.com/")
        print(f"   - Select property ID: {property_id}")
        print("   - Go to: Admin > Property Access Management")
        print(f"   - Check if {service_account_email} is listed")
        print("   - If not, add it with 'Viewer' role")
        
        print("\n3. If the service account doesn't exist:")
        print("   - The private key might be from a deleted service account")
        print("   - Create a new service account in Google Cloud Console")
        print("   - Download a new JSON key")
        print("   - Update your .env file with the new credentials")
        
        print("\n4. Wait 1-2 minutes after adding permissions")
        print("   - Google's permission changes can take time to propagate")
        
    else:
        print("\n❌ Private key is invalid. Please:")
        print("   1. Go to Google Cloud Console")
        print("   2. Create a new service account or use existing one")
        print("   3. Download JSON key")
        print("   4. Copy the 'private_key' value to .env")

if __name__ == '__main__':
    main()
