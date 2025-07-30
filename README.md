```
    ____             __  ________  ______
   / __ \____  _____/ /_/ ____/ / / /  _/
  / /_/ / __ \/ ___/ __/ / __/ / / // /
 / ____/ /_/ / /  / /_/ /_/ / /_/ // /
/_/    \____/_/   \__/\____/\____/___/

```

PortGUI
=======

PortGUI is a lightweight cross-platform GUI library, designed for
building simple utility tools and advanced desktop applications.
Written in C as a single-header library.

Inspired by GUI toolkits from the 1980s to the present, PortGUI
combines simplicity, performance, and modern aesthetics with
compatibility for older systems and a tiny footprint.

Key features include:
 - Cross-platform window, layout, widget and event management:
    - Windows
    - Linux/Unix/Posix/*BSD (X11)
    - macOS (Cocoa) *\[under development/testing]*
    - [Essence](https://gitlab.com/nakst/essence)
 - Software rendering, easy porting to any platform.
    - Optional hardware-accelerated rendering under development.
 - Optional support for FreeType and UTF-8/Unicode text rendering.
 - Easily customizable themes.
 - Lightweight footprint.
 - No extra dependencies.

This library is a fork of the excellent
[nakst/luigi](https://github.com/nakst/luigi), and maintains drop-in
compatibility with that library.

Projects made with PortGUI (or nakst/luigi)
-------------------------------------------

Various utility applications:

![Utilities, font editor, directory size viewer, image viewer, configuration editor, and a unit converter](https://the-real-dill.github.io/portgui/images/example-nakst-utils.jpg)

GDB frontend, [nakst/gf](https://github.com/nakst/gf/):

![GF Interface, showing the debugger's interface, source view, breakpoints list, call stack, command prompt](https://the-real-dill.github.io/portgui/images/example-nakst-gf.png)
![GF Profiler](https://the-real-dill.github.io/portgui/images/example-nakst-gf-flame-graph.png)

[Essence Element Designer](https://gitlab.com/nakst/essence/-/blob/master/util/designer2.cpp):

![Essence Element Designer, showing a list of layers, sequences, keyframes, properties, preview settings, and a preview of a checkbox being edited](https://the-real-dill.github.io/portgui/images/example-nakst-designer.png)

Building the examples
---------------------

To build the examples (or any PortGUI project), you need define the
platform being built for. This can be done in two ways:

 - add a platform definition before including the `portgui.h` header,
   for example `#define UI_LINUX`, or
 - pass the definition on the command line when building, generally by
   writing, for example `-D UI_LINUX`.

For simplicty, the below examples use the second method.

##### Linux

```
gcc -O2 -D UI_LINUX example.c -lX11 -o example
```

##### Windows

In a Visual Studio command prompt:

```
cl /O2 -D UI_WINDOWS example.c user32.lib gdi32.lib
```

Or in MSYS/Mingw:

```
gcc -O2 -D UI_WINDOWS example.c -luser32 -lgdi32 -o example.exe
```

##### macOS

```
clang -x objective-c -O2 -D UI_COCOA example.c -framework Cocoa -o example
```

**NOTE:** On macOS, applications need to be in an '.app bundle' to
function correctly. This repository contains a script
`makefile_macos_bundle.sh` to create basic .app bundles.

##### Essence

Compilation depends on the Essence environment setup; refer to
Essence documentation for building applications, but it would be
similar to the above.

#### Using the Makefile

A Makefile is included in this repository to help build all of the
examples for the platform being built on. You can compile different
build configurations with the following commands:

```
make base
make debug
make freetype
make freetype_unicode
make sse2
make all
make clean
```

On macOS, this will automatically generate the '.app bundles' using
the included script.

FreeType and UTF8/Unicode Support
---------------------------------

If you want to use FreeType for font rendering (recommendeded for
better text quality and required for UTF-8/Unicode), pass the
additional arguments to your compiler:

```
-D UI_FREETYPE -lfreetype -I <path to freetype headers>
```

Then add in the code, after the call to `UIInitialise`,

```c
UIFontActivate(UIFontCreate("font_path.ttf", 11 /* font size */));
```

#### UTF-8/Unicode Support

For UTF-8/Unicode support, pass these additional arguments to your
compiler:

```
-D UI_FREETYPE -D UI_UNICODE -lfreetype -I <path to freetype headers>
```

Debug Features
--------------

To enable debugging features, define `UI_DEBUG` when compiling. This
will create a built-in "inspector window" showing element hierarchy
and logging output.

Use `UI_LOG(...)` within code to log messages, like below:

```c
UI_LOG(UI_LOG_ERROR, "Unable to load file %s", fileName);
```

 - `UI_LOG_*` levels are `DEBUG`, `INFO`, `WARNING`, `ERROR`.

This code is zero-cost (not compiled) when built in release mode
(not defining `UI_DEBUG` or `UI_LOGGING`).

Documentation
-------------

### Introduction

As with other single-header libraries, to use it in your project
define `UI_IMPLEMENTATION` in _exactly one_ translation unit where
you include the header. Every time you include the header, you must
define the target platform (`UI_WINDOWS`, `UI_LINUX`, `UI_COCOA`, or
`UI_ESSENCE`).

#### Initialization and Element Creation

To initialize the library, call `UIInitialise`.

You can then create one or more windows using `UIWindowCreate` and
populate them with elements using the `UI...Create` functions.

Once you're ready, call `UIMessageLoop`, and input messages will
start being processed.

Windows are built up of *elements* (or widgets), which are allocated
and initialized by `UI...Create` functions. These functions all
return a pointer to the allocated element. At the start of every
element is a common header of type `UIElement`, contained in the
field `e`. When you create an element, you must specify its parent
element and its flags. Each element determines the position of its
children, and every element is clipped to its parent (i.e., it
cannot draw outside the bounds of the parent).

#### Message Handling

The library uses a message-based system to allow elements to respond
to events and requests.

The enumeration `UIMessage` specifies the different messages that
can be sent to an element using the `UIElementMessage` function. A
message is passed with two parameters, an integer `di` and a pointer
`dp`, and the element receiving the message must return an integer
in response. If the meaning of the return value is not specified, or
the element does not handle the message, it should return `0`.

After ensuring the element has not been marked for deletion,
`UIElementMessage` will first try sending the message to the
`messageUser` function pointer in the `UIElement` header. If this
returns `0`, then the message will also be sent to the
`messageClass` function pointer.

The `UI...Create` functions will set the `messageClass` function
pointer, and the user may optionally set the `messageUser` to also
receive messages sent to the element. For example, the
`messageClass` function set by `UIButtonCreate` will handle drawing
the button when it receives the `UI_MSG_PAINT` message. The user
will likely want to set `messageUser` so that they can receive the
`UI_MSG_CLICKED` message, which indicates that the button has been
clicked.

#### Themes

PortGUI supports customizable themes via the `UITheme` struct.
Two predefined themes are available:

 - `uiThemeClassic`: Light theme with gray tones.
 - `uiThemeDark`: Dark theme for modern aesthetics.

Set the global theme after `UIInitialise`:

```c
ui.theme = uiThemeDark; // Or uiThemeClassic
```

You can customize colors for panels, text, buttons, textboxes,
accents, and code highlighting (when using the `UICode` element).

#### Fonts

PortGUI uses a built-in fixed-width font by default. For better text
rendering, enable FreeType (see above). Create and activate fonts
with:

```c
UIFont *font = UIFontCreate("path/to/font.ttf", 14); // Size in points
UIFontActivate(font);
```

Multiple fonts can be created and switched as needed.

### Basic Example

**NOTE:** This example tutorial includes a `UIColorPicker` element,
which is currently unavailable (it will be added soon), however
the tutorial can still be followed. Also see the example files.

The following code demonstrates how to create an empty window:

```c
// Define your platform: UI_WINDOWS, UI_LINUX, UI_COCOA, or UI_ESSENCE
#define UI_WINDOWS  // Example for Windows

// Put the library implementation in this translation unit.
#define UI_IMPLEMENTATION 
#include "portgui.h"

#ifdef UI_WINDOWS
int WinMain(HINSTANCE instance, HINSTANCE previousInstance, LPSTR commandLine, int showCommand) {
#else
int main(int argc, char **argv) {
#endif
	// Initialise the library.
	UIInitialise(); 
	
	// Create a window.
	UIWindow *window = UIWindowCreate(0, 0, "My First Application", 640, 480);
	
	// Process input messages from the operating system.
	return UIMessageLoop();
}
```

Since we haven't added anything to the window, its contents will be
uninitialized, so don't worry if you see some random pixels.

To start adding elements to the window, we first need to add a panel which
will be responsible for laying out the other elements in the window.

```c
UIInitialise(); 
UIWindow *window = UIWindowCreate(0, 0, "My First Application", 640, 480);

// Create a panel, filling the window, with medium spacing.
// By default, a panel places its children from top to bottom.
// You can additionally specify the UI_PANEL_HORIZONTAL flag if you want a left-to-right layout.
// If you want to customize the spacing between child elements, modify panel->gap.
// If you want to customize the border between the panel and its children, modify panel->border.
UIPanel *panel = UIPanelCreate(&window->e, UI_PANEL_COLOR_1 | UI_PANEL_MEDIUM_SPACING);

return UIMessageLoop();
```

![An empty window with a dark gray background](https://the-real-dill.github.io/portgui/images/tutorial-1.png)

We can now add some elements to the panel.

```c
// Global variables for elements (example):
UIButton *button;
UIColorPicker *colorPicker;
UIGauge *gauge;
UISlider *slider;
UISpacer *spacer;
UILabel *label;
UITextbox *textbox;

...

UIPanel *panel = UIPanelCreate(&window->e, UI_PANEL_COLOR_1 | UI_PANEL_MEDIUM_SPACING);
button = UIButtonCreate(&panel->e, 0, "Push", -1);
colorPicker = UIColorPickerCreate(&panel->e, 0);
gauge = UIGaugeCreate(&panel->e, 0);
slider = UISliderCreate(&panel->e, 0);
spacer = UISpacerCreate(&panel->e, 0, 0 /* width */, 20 /* height */);
label = UILabelCreate(&panel->e, 0, "Label", -1);
textbox = UITextboxCreate(&panel->e, 0);
```

![A window showing the added elements, arranged from top to bottom and horizontally centered.](https://the-real-dill.github.io/portgui/images/tutorial-2.png)

Let's add some interactivity to the interface. Set the message
callbacks for the button, slider and textbox. We can process input
messages in these callbacks, and respond to them however we want.

```c
button->e.messageUser = ButtonMessage;
slider->e.messageUser = SliderMessage;
textbox->e.messageUser = TextboxMessage;
```

In the button's callback, we'll change the color in the color picker
to white when the button is clicked.

```c
int ButtonMessage(UIElement *element, UIMessage message, int di, void *dp) {
	if (message == UI_MSG_CLICKED) {
		colorPicker->saturation = 0;
		colorPicker->value = 1;
		UIElementRefresh(&colorPicker->e); // Update and repaint the color picker.
	}
	
	return 0;
}
```

In the slider's callback, we'll make the gauge match the slider's
position.

```c
int SliderMessage(UIElement *element, UIMessage message, int di, void *dp) {
	if (message == UI_MSG_VALUE_CHANGED) {
		gauge->position = slider->position;
		UIElementRefresh(&gauge->e);
	}
	
	return 0;
}
```

Finally, in the textbox's callback, we'll make the label match the
textbox's contents.

```c
int TextboxMessage(UIElement *element, UIMessage message, int di, void *dp) {
	if (message == UI_MSG_VALUE_CHANGED) {
		UILabelSetContent(label, textbox->string, textbox->bytes);
		UIElementRefresh(&label->e);
		
		// The label's size might have changed, 
		// so we need to refresh the parent panel, to update its layout.
		UIElementRefresh(label->e.parent); 
	}
	
	return 0;
}
```

![A window showing the elements having been interacted with. The label and textbox both show the text "hello, world!", and the gauge and slider have the same position. A shade of green has been selected in the color picker.](https://the-real-dill.github.io/portgui/images/tutorial-3.png)

Technical Details and API
-------------------------

### UIRectangle

This contains 4 integers, `l`, `r`, `t` and `b` which represent the
left, right, top and bottom edges of a rectangle. Usually, the
coordinates are in pixels relative to the top-left corner of the
relevant window.

### UIElement

The common header for all elements.

```c
typedef struct UIElement {
	uint32_t flags; // First 16 bits are element specific.
	uint32_t id;
	uint32_t childCount;
	uint32_t _unused0;

	struct UIElement *parent;
	struct UIElement **children;
	struct UIWindow *window;

	UIRectangle bounds, clip;

	void *cp; // Context pointer (for user).

	int (*messageClass)(struct UIElement *element, UIMessage message, int di /* data integer */, void *dp /* data pointer */);
	int (*messageUser)(struct UIElement *element, UIMessage message, int di, void *dp);

	const char *cClassName;
} UIElement;
```

`flags` contains a bitset of flags for the element. The first
16-bits are specific to each type of element. The upper 16-bits are
common to all elements.

Here are the common flags available:

 - `UI_ELEMENT_V_FILL` hints to the parent element that this element
    should take up all available vertical space.
 - `UI_ELEMENT_H_FILL` hint to the parent element that this element
    should take up all available horizontal space.
 - `UI_ELEMENT_WINDOW` marks top-level windows.
 - `UI_ELEMENT_PARENT_PUSH` automatically adds the element to the
    parent stack. See `UIParentPush`.
 - `UI_ELEMENT_TAB_STOP` marks the element as a tab stop. The user
    may focus it using the tab key.
 - `UI_ELEMENT_NON_CLIENT` indicates the element behaves less like a
    child of its parent, but rather is integral to the existence of
    its parent. For example, scrollbars in a table will be marked as
    non-client. This flag has several effects:
        `UIElementDestroyDescendents` will not destroy non-client
        elements; the `UI_MSG_CLIENT_PARENT` message will not be
        sent to the parent during its creation; and panels will
        not include it in their layout. This flag affects
        destruction, layout, and more.
 - `UI_ELEMENT_DISABLED` marks the element as disabled. It will not
    receive input events.
 - `UI_ELEMENT_BORDER` adds a border (specific usage).
 - `UI_ELEMENT_HIDE` marks the element as hidden. It will not
    receive input events, be drawn, or take up space in the
    parent's layout.
 - `UI_ELEMENT_RELAYOUT` / `UI_ELEMENT_RELAYOUT_DESCENDENT` /
   `UI_ELEMENT_DESTROY`  / `UI_ELEMENT_DESTROY_DESCENDENT` are
    internal flags for updates.

`id` is an optional user-set identifier.  
`childCount` tracks the number of children.  
`parent` contains a pointer to the element's parent.  
`children` is an array of pointers to child elements.  
`window` contains a pointer to the window that contains the element.

`bounds` contains the element's bounds, expressed in pixels relative
to the top-left corner of the containing window.  
`clip` gives the clip region in a similar fashion.  

 - Do not set either of these directly; instead, use `UIElementMove`.

`cp` is a context pointer available for the user.

`messageClass` and `messageUser` contain function pointers to the
element's message handlers.

 - `messageClass` is set when the element is first created, and has
    lower priority than `messageUser` when receiving messages.
 - `messageUser` can be optionally set by the user of the element
   to inspect and handle its messages.
     - If `messageUser` returns a non-zero value, then `messageClass`
       will not receive the message.
     - If `messageUser` is `NULL`, then `messageClass` will always
       receive the message.

 - Do not call these directly; see `UIElementMessage`.

`cClassName` is a debug string for the element type (e.g.,
"Button").

### UIMessage Enumerations

```c
// -- General event messages
UI_MSG_PAINT, // dp = pointer to UIPainter
UI_MSG_PAINT_FOREGROUND, // after children have painted
UI_MSG_LAYOUT,
UI_MSG_DESTROY,
UI_MSG_DEALLOCATE,
UI_MSG_UPDATE, // di = UI_UPDATE_... constant
UI_MSG_ANIMATE,
UI_MSG_SCROLLED,
UI_MSG_GET_WIDTH, // di = height (if known); return width
UI_MSG_GET_HEIGHT, // di = width (if known); return height
UI_MSG_GET_CHILD_STABILITY, // dp = child element; return stable axes, 1 (width) | 2 (height)

// -- Input events
UI_MSG_INPUT_EVENTS_START, // not sent to disabled elements
UI_MSG_LEFT_DOWN,
UI_MSG_LEFT_UP,
UI_MSG_MIDDLE_DOWN,
UI_MSG_MIDDLE_UP,
UI_MSG_RIGHT_DOWN,
UI_MSG_RIGHT_UP,
UI_MSG_KEY_TYPED, // dp = pointer to UIKeyTyped; return 1 if handled
UI_MSG_KEY_RELEASED, // dp = pointer to UIKeyTyped; return 1 if handled
UI_MSG_MOUSE_MOVE,
UI_MSG_MOUSE_DRAG,
UI_MSG_MOUSE_WHEEL, // di = delta; return 1 if handled
UI_MSG_CLICKED,
UI_MSG_GET_CURSOR, // return cursor code
UI_MSG_PRESSED_DESCENDENT, // dp = pointer to child that is/contains pressed element
UI_MSG_INPUT_EVENTS_END,

// -- Specific elements
UI_MSG_VALUE_CHANGED, // sent to notify that the element's value has changed
UI_MSG_TABLE_GET_ITEM, // dp = pointer to UITableGetItem; return string length
UI_MSG_CODE_GET_MARGIN_COLOR, // di = line index (starts at 1); return color
UI_MSG_CODE_DECORATE_LINE, // dp = pointer to UICodeDecorateLine
UI_MSG_TAB_SELECTED, // sent to the tab that was selected (not the tab pane itself)

// -- Windows
UI_MSG_WINDOW_DROP_FILES, // di = count, dp = char ** of paths
UI_MSG_WINDOW_ACTIVATE,
UI_MSG_WINDOW_CLOSE, // return 1 to prevent default (process exit for UIWindow; close for UIMDIChild)
UI_MSG_WINDOW_UPDATE_START,
UI_MSG_WINDOW_UPDATE_BEFORE_DESTROY,
UI_MSG_WINDOW_UPDATE_BEFORE_LAYOUT,
UI_MSG_WINDOW_UPDATE_BEFORE_PAINT,
UI_MSG_WINDOW_UPDATE_END,

// -- User-defined messages
UI_MSG_USER,
```

### API

```c
// -- General

void            UIInitialise();
int             UIMessageLoop();
UI_CLOCK_T      UIAnimateClock(); // In ms.

// -- Debugging

void           UILogSetCallback(UILogCallback callback, void *userData);
typedef void (*UILogCallback)(UILogLevel level, const char *cMessage, void *userData);

// -- Elements
// These are used internally, for writing new elements/widgets, and for advanced applications.
// General users of this library can largely ignore these functions.

UIElement*      UIElementCreate(size_t bytes, UIElement *parent, uint32_t flags, int (*messageClass)(UIElement *, UIMessage, int, void *), const char *cClassName);
int             UIElementMessage(UIElement *element, UIMessage message, int di, void *dp);

UIElement*      UIElementChangeParent(UIElement *element, UIElement *newParent, UIElement *insertBefore); // Set insertBefore to null to insert at the end. Returns the element it was before in its previous parent, or NULL.
UIElement*      UIParentPush(UIElement *element);
UIElement*      UIParentPop();
UIElement*      UIElementFindByPoint(UIElement *element, int x, int y);
UIRectangle     UIElementScreenBounds(UIElement *element); // Returns bounds of element in same coordinate system as used by UIWindowCreate.

bool            UIElementAnimate(UIElement *element, bool stop);
void            UIElementDestroy(UIElement *element);
void            UIElementDestroyDescendents(UIElement *element);
void            UIElementFocus(UIElement *element);
void            UIElementMeasurementsChanged(UIElement *element, int which);
void            UIElementMove(UIElement *element, UIRectangle bounds, bool alwaysLayout);
void            UIElementRefresh(UIElement *element);
void            UIElementRelayout(UIElement *element);
void            UIElementRepaint(UIElement *element, UIRectangle *region);

// -- Windows

UIWindow*       UIWindowCreate(UIWindow *owner, uint32_t flags, const char *cTitle, int width, int height);
void            UIWindowPostMessage(UIWindow *window, UIMessage message, void *dp); // Thread-safe.
void            UIWindowPack(UIWindow *window, int width); // Change the size of the window to best match its contents.
void            UIWindowRegisterShortcut(UIWindow *window, UIShortcut shortcut);

typedef void  (*UIDialogUserCallback)(UIElement *);
const char*     UIDialogShow(UIWindow *window, uint32_t flags, const char *format, ...);

// -- Layout

// Panes
UIExpandPane*   UIExpandPaneCreate(UIElement *parent, uint32_t flags, const char *label, ptrdiff_t labelBytes, uint32_t panelFlags);
UISplitPane*    UISplitPaneCreate(UIElement *parent, uint32_t flags, float weight);
UITabPane*      UITabPaneCreate(UIElement *parent, uint32_t flags, const char *tabs /* separate with \t, terminate with \0 */);
// Panels
UIPanel*        UIPanelCreate(UIElement *parent, uint32_t flags);
UIWrapPanel*    UIWrapPanelCreate(UIElement *parent, uint32_t flags);
// Spacer
UISpacer*       UISpacerCreate(UIElement *parent, uint32_t flags, int width, int height);
// Switcher
UISwitcher*     UISwitcherCreate(UIElement *parent, uint32_t flags);
void            UISwitcherSwitchTo(UISwitcher *switcher, UIElement *child);
// MDI
UIMDIClient*    UIMDIClientCreate(UIElement *parent, uint32_t flags);
UIMDIChild*     UIMDIChildCreate(UIElement *parent, uint32_t flags, UIRectangle initialBounds, const char *title, ptrdiff_t titleBytes);

// -- Basic Widgets

// Button
UIButton*       UIButtonCreate(UIElement *parent, uint32_t flags, const char *label, ptrdiff_t labelBytes);
void            UIButtonSetLabel(UIButton *button, const char *string, ptrdiff_t stringBytes);
// Checkbox
UICheckbox*     UICheckboxCreate(UIElement *parent, uint32_t flags, const char *label, ptrdiff_t labelBytes);
// Guage
UIGauge*        UIGaugeCreate(UIElement *parent, uint32_t flags);
void            UIGaugeSetPosition(UIGauge *gauge, double value);
// Image Display
UIImageDisplay* UIImageDisplayCreate(UIElement *parent, uint32_t flags, uint32_t *bits, size_t width, size_t height, size_t stride);
void            UIImageDisplaySetContent(UIImageDisplay *display, uint32_t *bits, size_t width, size_t height, size_t stride);
// Label
UILabel*        UILabelCreate(UIElement *parent, uint32_t flags, const char *label, ptrdiff_t labelBytes);
void            UILabelSetContent(UILabel *label, const char *content, ptrdiff_t byteCount);
// Scrollbar
UIScrollBar*    UIScrollBarCreate(UIElement *parent, uint32_t flags);
// Slider
UISlider*       UISliderCreate(UIElement *parent, uint32_t flags);
void            UISliderSetPosition(UISlider *slider, double value, bool sendChangedMessage);
// Textbox
UITextbox*      UITextboxCreate(UIElement *parent, uint32_t flags);
void            UITextboxClear(UITextbox *textbox, bool sendChangedMessage);
void            UITextboxMoveCaret(UITextbox *textbox, bool backward, bool word);
void            UITextboxReplace(UITextbox *textbox, const char *text, ptrdiff_t bytes, bool sendChangedMessage);
char*           UITextboxToCString(UITextbox *textbox); // Free with UI_FREE.

// -- Compound/Advanced Widgets

// Code/Text Viewer
UICode*         UICodeCreate(UIElement *parent, uint32_t flags);
void            UICodeFocusLine(UICode *code, int index); // Line numbers are 1-indexed!!
void            UICodeInsertContent(UICode *code, const char *content, ptrdiff_t byteCount, bool replace);
void            UICodeMoveCaret(UICode *code, bool backward, bool word);
void            UICodePositionToByte(UICode *code, int x, int y, int *line, int *byte);
int             UICodeHitTest(UICode *code, int x, int y); // Returns line number; negates if in margin. Returns 0 if not on a line.
// Menu
UIMenu*         UIMenuCreate(UIElement *parent, uint32_t flags);
void            UIMenuAddItem(UIMenu *menu, uint32_t flags, const char *label, ptrdiff_t labelBytes, void (*invoke)(void *cp), void *cp);
void            UIMenuShow(UIMenu *menu);
bool            UIMenusOpen();
// Table
UITable*        UITableCreate(UIElement *parent, uint32_t flags, const char *columns /* separate with \t, terminate with \0 */);
bool            UITableEnsureVisible(UITable *table, int index); // Returns false if the item was already visible.
void            UITableResizeColumns(UITable *table);
int             UITableHitTest(UITable *table, int x, int y); // Returns item index. Returns -1 if not on an item.
int             UITableHeaderHitTest(UITable *table, int x, int y); // Returns column index or -1.

// -- Fonts

UIFont*         UIFontCreate(const char *cPath, uint32_t size);
UIFont*         UIFontActivate(UIFont *font); // Returns the previously active font.

// -- Strings

int             UIMeasureStringWidth(const char *string, ptrdiff_t bytes);
int             UIMeasureStringHeight();
char*           UIStringCopy(const char *in, ptrdiff_t inBytes);

// -- Geometry, Maths and Color Space

UIRectangle     UIRectangleAdd(UIRectangle a, UIRectangle b);
UIRectangle     UIRectangleBounding(UIRectangle a, UIRectangle b);
UIRectangle     UIRectangleCenter(UIRectangle parent, UIRectangle child);
UIRectangle     UIRectangleFit(UIRectangle parent, UIRectangle child, bool allowScalingUp);
UIRectangle     UIRectangleIntersection(UIRectangle a, UIRectangle b);
UIRectangle     UIRectangleTranslate(UIRectangle a, UIRectangle b);

bool            UIRectangleEquals(UIRectangle a, UIRectangle b);
bool            UIRectangleContains(UIRectangle a, int x, int y);

bool            UIColorToHSV(uint32_t rgb, float *hue, float *saturation, float *value);
void            UIColorToRGB(float hue, float saturation, float value, uint32_t *rgb);

// -- Drawing
// These are used internally, for writing new elements/widgets, and for advanced applications.
// General users of this library can largely ignore these functions.

void            UIDrawBlock(UIPainter *painter, UIRectangle rectangle, uint32_t color);
void            UIDrawBorder(UIPainter *painter, UIRectangle r, uint32_t borderColor, UIRectangle borderSize);
void            UIDrawCircle(UIPainter *painter, int centerX, int centerY, int radius, uint32_t fillColor, uint32_t outlineColor, bool hollow);
void            UIDrawInvert(UIPainter *painter, UIRectangle rectangle);
bool            UIDrawLine(UIPainter *painter, int x0, int y0, int x1, int y1, uint32_t color); // Returns false if the line was not visible.
void            UIDrawRectangle(UIPainter *painter, UIRectangle r, uint32_t mainColor, uint32_t borderColor, UIRectangle borderSize);
void            UIDrawTriangle(UIPainter *painter, int x0, int y0, int x1, int y1, int x2, int y2, uint32_t color);
void            UIDrawTriangleOutline(UIPainter *painter, int x0, int y0, int x1, int y1, int x2, int y2, uint32_t color);

void            UIDrawGlyph(UIPainter *painter, int x, int y, int c, uint32_t color);
void            UIDrawString(UIPainter *painter, UIRectangle r, const char *string, ptrdiff_t bytes, uint32_t color, int align, UIStringSelection *selection);
int             UIDrawStringHighlighted(UIPainter *painter, UIRectangle r, const char *string, ptrdiff_t bytes, int tabSize, UIStringSelection *selection); // Returns final x position.

void            UIDrawControl(UIPainter *painter, UIRectangle bounds, uint32_t mode /* UI_DRAW_CONTROL_* */, const char *label, ptrdiff_t labelBytes, double position, float scale);
void            UIDrawControlDefault(UIPainter *painter, UIRectangle bounds, uint32_t mode, const char *label, ptrdiff_t labelBytes, double position, float scale);
```

Is it lightweight and blazing fast?
-----------------------------------

The port to Javascript is underway, it will be once that is done.
