# Phase 2: Create UI Cleanup Plan (vers-O)

## Core Objective
Now that the three-tiered sequence (Intro -> Main -> Outro) is fully synchronized and operational, the secondary workspace structure needs to be cleaned up for long-term scalability. The current Create navigation tab hosts multiple separate input and list cards linearly stacked. The goal of this phase is to refine the styling, spacing, grouping, and interaction models of the `#panel-create` layout to modernize the user experience.

## User Review Required
> [!NOTE]
> **Pending User Direction**
> The user stated: "CLEAN UP CREATE UI". I am officially awaiting clarification on exactly what the user intends for this cleanup before generating the detailed changes. Specifically:
> 1. Which visual paradigms (collapsibles, spacing, merging input panels with list displays) does the user favor?
> 2. Are there specific style references or UX layouts the user wants to mimic?

## Proposed Changes

### Workspace Aggregation
- **Merge Component Cards:** The 6 separated DOM cards (3 Add blocks + 3 List blocks) will be structurally condensed into exactly 3 universal workspace cards. 
- The `#add-[target]-card` HTML elements will be stripped of their outer container and injected directly above the `<ul>` inside their `#target-playlist-card`. 
- This reduces the visual footprint of the Create tab by 50% and localizes the contextual focus per playlist type.

## Verification Plan
### Automated Tests
- DOM layout consistency parsing for responsiveness.

### Manual Verification
- Visual inspection of the Create Layout UI tab after user specifications are merged.
