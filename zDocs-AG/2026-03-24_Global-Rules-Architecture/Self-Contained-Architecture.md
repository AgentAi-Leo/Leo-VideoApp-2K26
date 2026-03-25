# 🔥 GLOBAL ARCHITECTURAL DIRECTIVE: 100% SELF-CONTAINED PAYLOADS

## The Core Rule 
Under zero circumstances should an application, codebase, script, or environment rely on logic, assets, or pipelines located outside of its own root project directory. 

Moving forward, **every single project and skill must be architected as a 100% standalone, portable payload.**

## Technical Explanation & Rationale
When building applications on macOS (or any deployment environment), relying on "external dependencies" (e.g., hardcoding absolute paths to `___000-Basics/` or hotlinking audio files from `_001-ElevenLabs/`) breaks sandboxing and guarantees critical pipeline failure if the parent folder is moved, zipped, or deployed to a bare-metal machine.

To completely prevent `FileNotFoundError` pipeline crashes and HTTP 500 mapping errors caused by missing local paths:

1. **Dependency Duplication Over Sharing:** 
   If a new project requires Google Drive APIs, Google Sheets connectors, UI components, image assets, or `.mp3` sound effects that exist in *another* skill folder, **you must physically clone the required directories and files into the new project's filesystem native scope.** Do not "DRY" (Don't Repeat Yourself) components across separate macro project environments.
   
2. **Dynamic Pathing:** 
   In backend Python code, never use global hardcoded absolute paths `BASICS_DIR = "/Users/jb3/.../___000-Basics"`. 
   Instead, copy the `Data-GoogleDrive` logic directly into the project (e.g., `./Google_Backend/Data-GoogleDrive`) and dynamically resolve its path relative to the executing script: 
   `os.path.join(os.path.dirname(os.path.abspath(__file__)), "Google_Backend", "...")`
   
3. **Frontend Assets (Audio/Fonts/Images):**
   Audio clips, SVGs, and fonts must live in a local `./assets` directory inside the project and be referenced relatively via HTTP or simple directory mapping.

4. **CSS Stylesheets & Design Languages:**
   When instructed to "use the styling from Project X" (e.g., matching the UI aesthetics of a previous dashboard), **you must physically extract the raw CSS variables, class declarations, and design tokens from the source project and natively duplicate them into the new project.** Never attempt to externally link to another project's stylesheet (e.g., `<link href="../../other_project/style.css">`).

## Enforcement Protocol
By completely siloing every single AI project with its own independently cloned backend utilities, we guarantee **Flawless Portability Algorithm**. 

The user must always be able to zip the current app folder, drop it onto a completely clean MacBook, double-click the `.command` launcher script, and experience a 100% successful execution without needing to adjust hard drive layouts or recreate external dependencies.
