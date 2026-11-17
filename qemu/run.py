#!/usr/bin/env python3
"""Run original regression main on QEMU; keep its output and exit code."""
import argparse
from pathlib import Path
import subprocess
import sys
p = argparse.ArgumentParser()
p.add_argument('--qemu', default='qemu-system-arm')
p.add_argument('--scheme', required=True, choices=['chacha20','poly1305','ecdh25519','asm_example'])
p.add_argument('--elf', required=True, type=Path)
p.add_argument('--timeout', type=float, default=60)
a = p.parse_args()
cmd = [a.qemu, '-M', 'mps2-an386', '-cpu', 'cortex-m4',
       '-display', 'none', '-monitor', 'none', '-serial', 'none', '-net', 'none',
       '-semihosting-config', 'enable=on,target=native', '-kernel', str(a.elf)]
try:
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True, timeout=a.timeout)
    output = result.stdout
except subprocess.TimeoutExpired as e:
    output = e.stdout or b''
    if isinstance(output, bytes): output = output.decode(errors='replace')
    output += '\nQEMU timed out: FAIL\n'
    a.elf.with_suffix('.log').write_text(output)
    print(output, end='')
    sys.exit(124)
a.elf.with_suffix('.log').write_text(output)
print(output, end='' if output.endswith('\n') else '\n')
expected = 'Output 243' if a.scheme == 'asm_example' else 'Test successful!'
if result.returncode != 0 or expected not in output or 'Test failed!' in output:
    print(f'{a.scheme}: FAIL (QEMU exit {result.returncode})')
    sys.exit(1)
print(f'{a.scheme}: PASS (original reference test; no timing claim)')
