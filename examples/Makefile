# Note, this Makefile includes a commented-out 'example' for an OpenGL
# application. This is to demonstrate how a new application/example could be
# added that required custom flags on particular operating systems.

CC = gcc

# Platform detection (override with make PLATFORM=linux/win32/macos)
ifeq ($(OS),Windows_NT)
    PLATFORM ?= win32
else
    PLATFORM ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
    ifeq ($(PLATFORM),darwin)
        PLATFORM = macos
    endif
endif

# Platform-specific settings
ifeq ($(PLATFORM),linux)
    UI_OS_DEFINE = -D UI_LINUX
    PLATFORM_CFLAGS =
    PLATFORM_LDFLAGS = -lX11
    #PLATFORM_OPENGL_LDFLAGS = -lGL  # Example
    EXE_SUFFIX =
    APP_BUNDLE_SUFFIX =
else ifeq ($(PLATFORM),win32)
    UI_OS_DEFINE = -D UI_WINDOWS
    PLATFORM_CFLAGS =
    PLATFORM_LDFLAGS = -luser32 -lgdi32
    #PLATFORM_OPENGL_LDFLAGS = -lopengl32  # Example
    EXE_SUFFIX = .exe
    APP_BUNDLE_SUFFIX =
else ifeq ($(PLATFORM),macos)
    UI_OS_DEFINE = -D UI_COCOA
    PLATFORM_CFLAGS = -x objective-c
    PLATFORM_LDFLAGS = -framework Cocoa
    #PLATFORM_OPENGL_LDFLAGS = -framework OpenGL  # Example (NOTE: OpenGL is deprecated on macOS)
    EXE_SUFFIX =
    APP_BUNDLE_SUFFIX = .app
else
    $(error Unsupported platform: $(PLATFORM))
endif

LDFLAGS = $(PLATFORM_LDFLAGS)

CONFIGS = base freetype freetype_unicode debug debug_freetype debug_freetype_unicode sse2 sse2_freetype sse2_freetype_unicode debug_sse2 debug_sse2_freetype debug_sse2_freetype_unicode

PROGS = example example_todo_list example_unit_converter #example_opengl  # Example

# Define output targets based on platform
ifeq ($(PLATFORM),macos)
    ALL = $(foreach config,$(CONFIGS),$(addsuffix $(APP_BUNDLE_SUFFIX),$(addsuffix -$(config),$(PROGS))))
else
    ALL = $(foreach config,$(CONFIGS),$(addsuffix $(EXE_SUFFIX),$(addsuffix -$(config),$(PROGS))))
endif

# If 'pkg-config' not availabole, override with e.g.:
#   make FREETYPE_CFLAGS_CFG="-I/path/to/freetype" FREETYPE_LDFLAGS="freetype2"
FREETYPE_CFLAGS_CFG ?= $(shell pkg-config --cflags freetype2 2>/dev/null)
FREETYPE_LDFLAGS ?= $(shell pkg-config --libs freetype2 2>/dev/null)

# Hierarchical CFLAGS components
BASE_CFLAGS = $(UI_OS_DEFINE) $(PLATFORM_CFLAGS)
DEBUG_CFLAGS = -D UI_DEBUG
SSE2_CFLAGS = -D UI_SSE2
FREETYPE_CFLAGS = -D UI_FREETYPE $(FREETYPE_CFLAGS_CFG)
UNICODE_CFLAGS = -D UI_UNICODE

# CFLAGS for each configuration
CFLAGS_base = $(BASE_CFLAGS)
CFLAGS_freetype = $(BASE_CFLAGS) $(FREETYPE_CFLAGS)
CFLAGS_freetype_unicode = $(BASE_CFLAGS) $(FREETYPE_CFLAGS) $(UNICODE_CFLAGS)
CFLAGS_debug = $(BASE_CFLAGS) $(DEBUG_CFLAGS)
CFLAGS_debug_freetype = $(BASE_CFLAGS) $(DEBUG_CFLAGS) $(FREETYPE_CFLAGS)
CFLAGS_debug_freetype_unicode = $(BASE_CFLAGS) $(DEBUG_CFLAGS) $(FREETYPE_CFLAGS) $(UNICODE_CFLAGS)
CFLAGS_sse2 = $(BASE_CFLAGS) $(SSE2_CFLAGS)
CFLAGS_sse2_freetype = $(BASE_CFLAGS) $(SSE2_CFLAGS) $(FREETYPE_CFLAGS)
CFLAGS_sse2_freetype_unicode = $(BASE_CFLAGS) $(SSE2_CFLAGS) $(FREETYPE_CFLAGS) $(UNICODE_CFLAGS)
CFLAGS_debug_sse2 = $(BASE_CFLAGS) $(DEBUG_CFLAGS) $(SSE2_CFLAGS)
CFLAGS_debug_sse2_freetype = $(BASE_CFLAGS) $(DEBUG_CFLAGS) $(SSE2_CFLAGS) $(FREETYPE_CFLAGS)
CFLAGS_debug_sse2_freetype_unicode = $(BASE_CFLAGS) $(DEBUG_CFLAGS) $(SSE2_CFLAGS) $(FREETYPE_CFLAGS) $(UNICODE_CFLAGS)

# EXTRA_LDFLAGS for each configuration
EXTRA_LDFLAGS_base =
EXTRA_LDFLAGS_debug =
EXTRA_LDFLAGS_sse2 =
EXTRA_LDFLAGS_debug_sse2 =
EXTRA_LDFLAGS_freetype = $(FREETYPE_LDFLAGS)
EXTRA_LDFLAGS_freetype_unicode = $(FREETYPE_LDFLAGS)
EXTRA_LDFLAGS_debug_freetype = $(FREETYPE_LDFLAGS)
EXTRA_LDFLAGS_debug_freetype_unicode = $(FREETYPE_LDFLAGS)
EXTRA_LDFLAGS_sse2_freetype = $(FREETYPE_LDFLAGS)
EXTRA_LDFLAGS_sse2_freetype_unicode = $(FREETYPE_LDFLAGS)
EXTRA_LDFLAGS_debug_sse2_freetype = $(FREETYPE_LDFLAGS)
EXTRA_LDFLAGS_debug_sse2_freetype_unicode = $(FREETYPE_LDFLAGS)

# Per-program customizations (INCLUDES, EXTRA_CFLAGS, EXTRA_LDFLAGS)
# For programs with no extra flags, leave empty
PROG_example_INCLUDES =
PROG_example_EXTRA_CFLAGS =
PROG_example_EXTRA_LDFLAGS =

PROG_example_todo_list_INCLUDES =
PROG_example_todo_list_EXTRA_CFLAGS =
PROG_example_todo_list_EXTRA_LDFLAGS =

PROG_example_unit_converter_INCLUDES =
PROG_example_unit_converter_EXTRA_CFLAGS =
PROG_example_unit_converter_EXTRA_LDFLAGS =

# Example for 'OpenGL application':
# Add includes if needed (usually standard), and platform-specific OpenGL libs
#PROG_example_opengl_INCLUDES =  # e.g., -I/path/to/opengl/headers if non-standard
#PROG_example_opengl_EXTRA_CFLAGS =  # e.g., any extra defines or flags
#PROG_example_opengl_EXTRA_LDFLAGS = $(OPENGL_LDFLAGS)

all: $(ALL)

# Generate compilation rules for each program/config combo
# NOTE: For the `makefile_macos_bundle.sh` bundling, remove "|| exit 1" to continue on bundle failure
define MAKE_RULES
$(1)-$(2)$(APP_BUNDLE_SUFFIX)$(EXE_SUFFIX): $(1).c
	@echo "🔧 Building $(1)-$(2) ..."
	$(CC) $(CFLAGS_$(2)) $(PROG_$(1)_INCLUDES) $(PROG_$(1)_EXTRA_CFLAGS) $$< $(LDFLAGS) $(EXTRA_LDFLAGS_$(2)) $(PROG_$(1)_EXTRA_LDFLAGS) -o $(1)-$(2)
	@if [ "$(PLATFORM)" = "macos" ]; then \
		chmod +x ./makefile_macos_bundle.sh; \
		./makefile_macos_bundle.sh "$(1)-$(2)" "$(1)-$(2).app" "$(1)-$(2)" || exit 1; \
	fi
endef

$(foreach prog,$(PROGS), \
	$(foreach config,$(CONFIGS), \
		$(eval $(call MAKE_RULES,$(prog),$(config))) \
	) \
)

clean:
	rm -f $(ALL)
