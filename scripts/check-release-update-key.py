#!/usr/bin/env python3
"""Validate that the release signer is trusted by shipped RegexMate clients.

No production key is needed for --self-test. Only the public SPKI is embedded
in version.rkt; release-private PKCS#8 DER must remain outside source control.
"""
from __future__ import annotations

import base64
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HEADER = bytes.fromhex("302a300506032b6570032100")


def shipped_key() -> bytes:
    source = (ROOT / "version.rkt").read_text(encoding="utf-8")
    key = re.search(
        r'\(define\s+regexmate-update-public-key-b64\s+"([A-Za-z0-9+/=]+)"\)',
        source,
    )
    if not key:
        raise ValueError("missing bundled updater public key")
    try:
        public = base64.b64decode(key.group(1), validate=True)
    except ValueError as err:
        raise ValueError("malformed bundled updater public key") from err
    if len(public) != 44 or not public.startswith(HEADER):
        raise ValueError("bundled updater public key is not Ed25519 SPKI")
    return public


def signer_public_key(private_der: Path) -> bytes:
    try:
        output = subprocess.run(
            ["openssl", "pkey", "-inform", "DER", "-in", str(private_der),
             "-pubout", "-outform", "DER"],
            check=True, capture_output=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError) as err:
        raise ValueError("invalid release private key (expected Ed25519 PKCS#8 DER)") from err
    if len(output) != 44 or not output.startswith(HEADER):
        raise ValueError("release private key is not Ed25519")
    return output


def verify(private_der: Path, expected: bytes) -> None:
    if signer_public_key(private_der) != expected:
        raise ValueError("release key does not match the public key in version.rkt")


def self_test() -> None:
    shipped_key()
    with tempfile.TemporaryDirectory(prefix="regexmate-key-contract-") as root:
        directory = Path(root)
        pem = directory / "throwaway.pem"
        der = directory / "throwaway.der"
        subprocess.run(
            ["openssl", "genpkey", "-algorithm", "ed25519", "-out", str(pem)],
            capture_output=True, check=True,
        )
        subprocess.run(
            ["openssl", "pkey", "-in", str(pem), "-outform", "DER", "-out", str(der)],
            capture_output=True, check=True,
        )
        correct = signer_public_key(der)
        verify(der, correct)
        try:
            verify(der, correct[:-1] + bytes([correct[-1] ^ 1]))
        except ValueError:
            pass
        else:
            raise AssertionError("wrong public trust root was accepted")
        bad = directory / "invalid.der"
        bad.write_bytes(b"not a signing key")
        try:
            verify(bad, correct)
        except ValueError:
            pass
        else:
            raise AssertionError("malformed private key was accepted")
    print("RegexMate Ed25519 release trust preflight: offline tests passed")


def main() -> int:
    try:
        if sys.argv[1:] == ["--self-test"]:
            self_test()
        elif len(sys.argv) == 2:
            verify(Path(sys.argv[1]), shipped_key())
            print("RegexMate release signer matches the embedded updater trust root")
        else:
            print("usage: check-release-update-key.py --self-test | private.der", file=sys.stderr)
            return 2
    except (ValueError, AssertionError, subprocess.CalledProcessError) as err:
        print(f"RegexMate release signing preflight: {err}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
