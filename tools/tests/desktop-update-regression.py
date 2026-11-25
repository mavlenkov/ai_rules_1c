#!/usr/bin/env python3
"""Offline old-to-new desktop command update through the real installer.

Pass --baseline pointing to the approved pre-desktop source. HOME and TEMP are
isolated beneath --work; no desktop package, MCP client or service is started.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--work', type=Path, required=True)
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[2]
    work = args.work.resolve()
    work.mkdir(parents=True, exist_ok=False)
    home, temp, target = (work / name for name in ('home', 'temp', 'project with spaces'))
    for path in (home, temp, target):
        path.mkdir()
    env = dict(os.environ, HOME=str(home), USERPROFILE=str(home), TMPDIR=str(temp),
               TMP=str(temp), TEMP=str(temp), XDG_CONFIG_HOME=str(home/'.config'),
               XDG_DATA_HOME=str(home/'.local/share'), XDG_CACHE_HOME=str(home/'.cache'))
    for key in ('BASESAI_MCP_GLOBAL_ROOT', 'MCP_OPERATOR_TOKEN', 'MCP_GLOBAL_ROOT'):
        env.pop(key, None)
    original_env = b'USE_EDT=false\nTOOL_WINDOWS_MCP=required\nTOOL_COGNEE=off\n'
    (target/'.dev.env').write_bytes(original_env)

    def run(name, src, action):
        argv = ['pwsh', '-NoLogo', '-NoProfile', '-File', str(src/'install.ps1'), action,
                '-Source', str(src), '-ProjectRoot', str(target), '-NonInteractive', '-McpMode', 'managed']
        if action == 'init':
            argv += ['-Tools', 'cursor,claude-code,codex,kimi,opencode']
        p = subprocess.run(argv, cwd=target, env=env, stdin=subprocess.DEVNULL,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        (work/(name+'.log')).write_text(p.stdout)
        assert p.returncode == 0, f'{name}: installer exit {p.returncode}; see log'
        return p.stdout

    def receipt():
        return json.loads((target/'.ai-rules.json').read_text())

    run('baseline', args.baseline.resolve(), 'init')
    before = receipt()
    # The baseline may already carry later policy keys: test the legacy-only
    # transition explicitly, without changing a real project setting.
    (target/'.dev.env').write_bytes(original_env)
    edited = target/'.claude/commands/install-windows-mcp.md'
    edited.write_bytes(edited.read_bytes() + b'\nUser-owned command override; retain exact bytes.\n')
    override = edited.read_bytes()
    clean_paths = [target/'.cursor/commands/install-windows-mcp.md',
                   target/'.opencode/command/install-windows-mcp.md',
                   home/'.codex/prompts/install-windows-mcp.md']
    assert all(path.is_file() for path in clean_paths)
    log = run('update', source, 'update')
    after = receipt()
    checks = {
        'new_commands': all(path.is_file() for path in [target/'.cursor/commands/install-agent-desktop.md',
            target/'.claude/commands/install-agent-desktop.md', target/'.opencode/command/install-agent-desktop.md',
            target/'.agents/skills/install-agent-desktop/SKILL.md']),
        'pristine_old_removed': all(not path.exists() for path in clean_paths),
        'override_preserved': edited.read_bytes() == override,
        'override_owned': after['files'].get('.claude/commands/install-windows-mcp.md', {}).get('userModified') is True,
        'tool_selection': before['tools'] == after['tools'],
        'entry_routing': '.cursor/commands/' in (target/'AGENTS.md').read_text()
            and (target/'.cursor/commands/install-agent-desktop.md').is_file(),
        'legacy_required_retained': (target/'.dev.env').read_bytes().startswith(original_env),
        'new_required_migrated': b'TOOL_AGENT_DESKTOP=required\n' in (target/'.dev.env').read_bytes(),
        'new_installer_announced': any('install-agent-desktop.md' in line for line in log.splitlines()
            if 'Добавлены новые установщики инструментов:' in line) and '/installtools' in log,
    }
    (work/'checks-first.json').write_text(json.dumps(checks, indent=2)+'\n')
    assert all(checks.values()), f'Failed checks: {[key for key, value in checks.items() if not value]}'
    payload = {key: hashlib.sha256((Path(key) if Path(key).is_absolute() else target/key).read_bytes()).hexdigest()
               for key in after['files'] if (Path(key) if Path(key).is_absolute() else target/key).is_file()}
    log2 = run('repeat', source, 'update')
    repeated = receipt()
    checks['repeat_bytes'] = all(hashlib.sha256((Path(key) if Path(key).is_absolute() else target/key).read_bytes()).hexdigest() == value
                                for key, value in payload.items())
    checks['repeat_no_install_offer'] = 'Добавлены новые установщики инструментов:' not in log2
    checks['repeat_override_owned'] = repeated['files']['.claude/commands/install-windows-mcp.md']['userModified'] is True
    (work/'checks.json').write_text(json.dumps(checks, indent=2)+'\n')
    assert all(checks.values()), f'Failed checks: {[key for key, value in checks.items() if not value]}'
    print(f'PASS: {len(checks)} desktop update checks, including clean prune, override, policy, routing and repeat')


if __name__ == '__main__':
    main()
