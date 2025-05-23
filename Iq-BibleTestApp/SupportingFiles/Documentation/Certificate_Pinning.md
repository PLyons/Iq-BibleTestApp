# Certificate Pinning Implementation

## Overview

Certificate pinning is a security technique that validates server SSL/TLS certificates against known, pre-defined certificates or public key hashes. This technique provides protection against man-in-the-middle attacks, even if an attacker has compromised a certificate authority.

## Implementation Details

In this app, we've implemented certificate pinning using the `CertificatePinningManager` class, which:

1. Stores trusted public key hashes for our API endpoints
2. Creates custom URLSessions that validate server certificates
3. Rejects connections to servers presenting untrusted certificates

## Key Components

- **CertificatePinningManager**: Core class that validates certificates against known hashes
- **Certificate Validation**: Performed using SHA-256 hashing of public keys
- **Error Handling**: Custom errors for certificate validation failures

## SSL Error Resolution

The certificate pinning implementation directly addresses the SSL errors we encountered:


