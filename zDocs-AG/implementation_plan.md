# Phase 3: Horizontal Layout Architecture (vers-P)

## Core Objective
The user has requested the `CREATE UI` be drastically minimized by transitioning from the `vers-O` Vertical Stack pattern into a **Horizontally Stacked** paradigm. This means laying out the `Intro Workspace`, `Main Workspace`, and `Outro Workspace` side-by-side rather than top-to-bottom.

## User Review Required
> [!NOTE]
> Ensure the user signs off on the layout mechanics before execution.

## Proposed Changes

### CSS Layout Shifts
- Apply `display: grid` or `display: flex` with wrap support to the `#create-sub-playlist` container.
- Establish a responsive threshold (e.g. `minmax(320px, 1fr)`) so that the cards scale down into a vertical stack safely on mobile devices but display perfectly 3-wide horizontally on desktop monitors.
- **Badge Layout Pivot:** Isolate numerical step badges on their own row above card headers using `flex-direction: column` to maximize clarity.

## Verification Plan
### Automated Tests
- N/A
### Manual Verification
- Visual inspection of column wrapping and resize behavior.

## Verification Plan
### Automated Tests
- DOM layout consistency parsing for responsiveness.

### Manual Verification
- Visual inspection of the Create Layout UI tab after user specifications are merged.
