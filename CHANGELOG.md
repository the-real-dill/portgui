PortGUI CHANGES
===============

0.6.0 | "You always remember your first time"
---------------------------------------------

This is the initial release of PortGUI, a lightweight
cross-platform single-header GUI library forked from
[nakst/luigi](https://github.com/nakst/luigi).

This release can be viewed as a significantly restructured and
slightly polished version of the excellent luigi2 library.

This was forked from the version of luigi2 in the
[nakst/gf](https://github.com/nakst/gf) repository, which has had
the most recent development and the most use in a complex
application. Some features missing from that version of the library
but available in others have been imported.

The changes so far have been focused on improving the code
structure, portability, modularity, and logging, while maintaining
total compatibility with the luigi2 API. Build tooling has been
added, along with a GitHub CI pipeline, and several fixes.

#### New features:

  - `UI_TEXTBOX_HIDE_CHARACTERS` flag for masking textbox input
    (e.g., passwords). (Ported from other edition of luigi.)

  - Enhanced `UIGauge` and `UISlider` elements, vertical layout and
    basic internal position clamping. (Ported from other edition of
    luigi.)

  - `UI_LUIGI_COMPATIBLE` mode for drop-in luigi compatibility,
    enabled by default, opt-out via `UI_NO_LUIGI_COMPATIBILITY`.

  - Flexible logging system: `UI_LOG(...)` macro (zero-cost when not
    compiled), with levels (DEBUG, INFO, WARNING, ERROR), a user
    callback, and `UIInspector` integration.

  - Shell script to generate basic macOS '.app bundles'.

  - Makefile for building examples in any/all variants (base, debug,
    SSE2, FreeType, Unicode, etc.). Uses shell script to create
    '.app bundles' on macOS.

  - GitHub CI workflow: builds examples on Linux/macOS/Windows in
    all variants, as well as nakst/gf and extensions, to validate
    changes with existing applications.

#### Changes:

  - Rebranded to PortGUI: renamed files (luigi2.h -> portgui.h),
    reorganized repository, removed old files.

  - Refactoring: significant and large-scale reorganization of code
    within the library; moved platform-specific and internal code
    (UTF-8, asserts, memory, clock, includes) to `UI_IMPLEMENTATION`
    unit, reducing namespace pollution and improving compilation
    time; used opaque struct for `UIWindow` platform-specifics;
    generalized `UI_CLOCK_T`.

  - Documentation: Revised README.md with additional details and
    more complete technical details / API description.

  - License: Switched to MIT-only, updated copyrights, added
    Unlicense headers to examples.

#### Bug fixes:

  - Fixed heap overflow in `UICodeInsertContent`.
  - Fixed segfault in early `UIInspectorLog` calls.
  - Removed unnecessary `ui.assertionFailure` on Windows.
  - Replaced printf in `UIFontCreate` with UI_LOG for consistency.

  - Platform fixes: SSE2 guard/fallback for non-x86; typedef for
    `_UIPostedMessage` struct on macOS/Cocoa.

  - Examples: Fixed "category" display in unit_converter; updated
    entrypoints to be cross-platform.

#### Known issues:

  - macOS/Cocoa backend "inconsistencies".

For full details, read the commit log.
