"""
OpenClaw Agent - Minimal Entry Point
Client will install OpenClaw and set up their agent here.
This keeps the container running until client installs their agent.
"""

import sys
import time

def main():
    """Minimal entry point - keeps container running."""
    print("=" * 60)
    print("OpenClaw Agent - Sandbox Environment Ready")
    print("=" * 60)
    print(f"Python version: {sys.version.split()[0]}")
    print(f"Working directory: /app")
    print("")
    print("Tools available:")
    print("  ✓ Python")
    print("  ✓ pip")
    print("  ✓ git")
    print("")
    print("Next steps:")
    print("  1. Install OpenClaw: pip install openclaw")
    print("  2. Set up your agent in /app")
    print("  3. Update this file or docker-compose.yml CMD")
    print("")
    print("Container is running. Install OpenClaw when ready.")
    print("=" * 60)
    
    # Keep container running
    try:
        while True:
            time.sleep(3600)  # Sleep for 1 hour, then print status
            print("Container still running. Ready for OpenClaw installation.")
    except KeyboardInterrupt:
        print("\nContainer stopped by user")
        sys.exit(0)


if __name__ == "__main__":
    main()
