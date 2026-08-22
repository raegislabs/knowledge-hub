#!/usr/bin/env python3
"""
Ralph Watch - Rich TUI for monitoring Ralph sessions.

Usage:
    python scripts/ralph-watch.py [refresh_rate]

    refresh_rate: seconds between updates (default: 2)

Requires: pip install rich
"""

import json
import sys
import time
from pathlib import Path
from datetime import datetime

try:
    from rich.console import Console
    from rich.live import Live
    from rich.table import Table
    from rich.panel import Panel
    from rich.progress import Progress, BarColumn, TextColumn, TaskProgressColumn
    from rich.layout import Layout
    from rich.text import Text
    from rich import box
except ImportError:
    print("This script requires the 'rich' library.")
    print("Install with: pip install rich")
    sys.exit(1)


RALPH_DIR = Path("_bmad/ralph")
console = Console()


def get_session_info() -> dict:
    """Load session.json."""
    session_file = RALPH_DIR / "session.json"
    if session_file.exists():
        try:
            return json.loads(session_file.read_text())
        except json.JSONDecodeError:
            return {}
    return {}


def get_cost_tracker() -> dict:
    """Load cost-tracker.json."""
    cost_file = RALPH_DIR / "cost-tracker.json"
    if cost_file.exists():
        try:
            return json.loads(cost_file.read_text())
        except json.JSONDecodeError:
            return {}
    return {}


def get_task_counts() -> tuple[int, int, int]:
    """Parse PLAN.md for task counts."""
    plan_file = RALPH_DIR / "PLAN.md"
    completed = pending = blocked = 0

    if plan_file.exists():
        content = plan_file.read_text()
        for line in content.split('\n'):
            line = line.strip()
            if line.startswith('- [x]') or line.startswith('- [X]'):
                completed += 1
            elif line.startswith('- [ ]'):
                pending += 1
            elif line.startswith('- [~]'):
                blocked += 1

    return completed, pending, blocked


def get_current_task() -> str:
    """Get the first unchecked task from PLAN.md."""
    plan_file = RALPH_DIR / "PLAN.md"
    if plan_file.exists():
        for line in plan_file.read_text().split('\n'):
            line = line.strip()
            if line.startswith('- [ ]'):
                task = line[5:].strip()
                # Truncate long tasks
                if len(task) > 60:
                    task = task[:57] + "..."
                return task
    return "No active task"


def get_recent_activity() -> list[str]:
    """Get recent lines from latest iteration log."""
    iterations_dir = RALPH_DIR / "iterations"
    if not iterations_dir.exists():
        return ["No iteration logs yet"]

    logs = sorted(iterations_dir.glob("*.log"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not logs:
        return ["No iteration logs yet"]

    try:
        lines = logs[0].read_text().strip().split('\n')[-5:]
        return [line[:70] for line in lines if line.strip()]
    except Exception:
        return ["Error reading logs"]


def create_status_display() -> Panel:
    """Create the main status display."""
    session = get_session_info()
    costs = get_cost_tracker()
    completed, pending, blocked = get_task_counts()
    total = completed + pending + blocked

    # Session info
    session_id = session.get('session_id', 'No session')
    status = session.get('status', 'unknown')
    mode = session.get('mode', 'unknown')
    iteration = session.get('current_iteration', 0)
    max_iter = session.get('limits', {}).get('max_iterations', 50)

    # Status styling
    status_styles = {
        'running': '[bold green]● RUNNING[/]',
        'completed': '[bold green]✓ COMPLETED[/]',
        'paused': '[bold yellow]⏸ PAUSED[/]',
        'failed': '[bold red]✗ FAILED[/]',
    }
    status_text = status_styles.get(status, f'[yellow]? {status}[/]')

    # Build layout
    layout = Layout()

    # Header
    header_text = Text()
    header_text.append("🤖 RALPH WIGGUM - LIVE MONITOR\n", style="bold cyan")
    header_text.append(f"Session: {session_id}\n")
    header_text.append(f"Status:  ")
    header_text.append(status_text.replace('[bold green]', '').replace('[bold yellow]', '').replace('[bold red]', '').replace('[/]', ''),
                       style="green" if "RUNNING" in status_text or "COMPLETED" in status_text else "yellow" if "PAUSED" in status_text else "red")
    header_text.append(f"\nMode:    {mode}")

    # Task Progress Table
    task_table = Table(show_header=False, box=box.SIMPLE, padding=(0, 1))
    task_table.add_column("Label", style="bold")
    task_table.add_column("Bar", width=35)
    task_table.add_column("Stats")

    # Task progress bar
    task_pct = (completed / total * 100) if total > 0 else 0
    task_bar_filled = int(task_pct / 100 * 30)
    task_bar = f"[green]{'█' * task_bar_filled}[/][dim]{'░' * (30 - task_bar_filled)}[/]"
    task_table.add_row("Tasks", task_bar, f"{task_pct:.0f}% ({completed}/{total})")

    # Iteration progress bar
    iter_pct = (iteration / max_iter * 100) if max_iter > 0 else 0
    iter_bar_filled = int(iter_pct / 100 * 30)
    iter_bar = f"[blue]{'█' * iter_bar_filled}[/][dim]{'░' * (30 - iter_bar_filled)}[/]"
    task_table.add_row("Iterations", iter_bar, f"{iteration}/{max_iter}")

    # Token usage table
    token_table = Table(title="Token Usage", box=box.ROUNDED, show_header=True, header_style="bold cyan")
    token_table.add_column("Provider", style="bold")
    token_table.add_column("Calls", justify="right")
    token_table.add_column("Input", justify="right", style="green")
    token_table.add_column("Output", justify="right", style="yellow")

    providers = costs.get('providers', {})
    total_in = total_out = total_calls = 0
    for provider, data in providers.items():
        calls = data.get('calls', 0)
        inp = data.get('input_tokens', 0)
        out = data.get('output_tokens', 0)
        if calls > 0 or inp > 0 or out > 0:
            token_table.add_row(
                provider,
                str(calls),
                f"{inp:,}",
                f"{out:,}"
            )
            total_in += inp
            total_out += out
            total_calls += calls

    if total_calls > 0:
        token_table.add_row("─" * 8, "─" * 5, "─" * 10, "─" * 10, style="dim")
        token_table.add_row("TOTAL", str(total_calls), f"{total_in:,}", f"{total_out:,}", style="bold")

    # Current task
    current_task = get_current_task()
    task_panel = Panel(
        f"[cyan]{current_task}[/]",
        title="Current Task",
        box=box.ROUNDED
    )

    # Recent activity
    activity = get_recent_activity()
    activity_text = "\n".join(f"[dim]{line}[/]" for line in activity)
    activity_panel = Panel(
        activity_text or "[dim]No recent activity[/]",
        title="Recent Activity",
        box=box.ROUNDED
    )

    # Task counts
    counts_text = f"[green]✓ Completed: {completed}[/]  [yellow]○ Pending: {pending}[/]  [red]~ Blocked: {blocked}[/]"

    # Combine everything
    output = Table.grid(padding=1)
    output.add_column()
    output.add_row(header_text)
    output.add_row("")
    output.add_row(task_table)
    output.add_row(counts_text)
    output.add_row("")
    output.add_row(token_table)
    output.add_row("")
    output.add_row(task_panel)
    output.add_row(activity_panel)
    output.add_row(f"[dim]Updated: {datetime.now().strftime('%H:%M:%S')} | Ctrl+C to exit[/]")

    return Panel(output, title="[bold]Ralph Monitor[/]", box=box.DOUBLE)


def main():
    refresh_rate = float(sys.argv[1]) if len(sys.argv) > 1 else 2.0

    console.print("[bold cyan]Starting Ralph Watch...[/]")
    console.print(f"[dim]Monitoring: {RALPH_DIR.absolute()}[/]")
    console.print(f"[dim]Refresh rate: {refresh_rate}s[/]")
    console.print()

    try:
        with Live(create_status_display(), console=console, refresh_per_second=1/refresh_rate) as live:
            while True:
                time.sleep(refresh_rate)
                live.update(create_status_display())
    except KeyboardInterrupt:
        console.print("\n[yellow]Ralph Watch stopped.[/]")


if __name__ == "__main__":
    main()
