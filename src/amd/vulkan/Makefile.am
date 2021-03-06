# Copyright © 2015 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice (including the next
# paragraph) shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

include Makefile.sources

vulkan_includedir = $(includedir)/vulkan

vulkan_include_HEADERS = \
	$(top_srcdir)/include/vulkan/vk_platform.h \
	$(top_srcdir)/include/vulkan/vulkan.h

lib_LTLIBRARIES = libvulkan_radeon.la

check_LTLIBRARIES = libvulkan-test.la

PER_GEN_LIBS = \
   libradv-ci.la

noinst_LTLIBRARIES = $(PER_GEN_LIBS)

# The gallium includes are for the util/u_math.h include from main/macros.h

AM_CPPFLAGS = \
	$(AMDGPU_CFLAGS) \
	$(VALGRIND_CFLAGS) \
	$(DEFINES) \
	-I$(top_srcdir)/include \
	-I$(top_builddir)/src \
	-I$(top_srcdir)/src \
	-I$(top_srcdir)/src/amd \
	-I$(top_srcdir)/src/amd/common \
	-I$(top_builddir)/src/compiler \
	-I$(top_builddir)/src/compiler/nir \
	-I$(top_srcdir)/src/compiler \
	-I$(top_srcdir)/src/mapi \
	-I$(top_srcdir)/src/mesa \
	-I$(top_srcdir)/src/mesa/drivers/dri/common \
	-I$(top_srcdir)/src/gallium/auxiliary \
	-I$(top_srcdir)/src/gallium/include \
	-I$(srcdir)/addrlib \
	-I$(srcdir)/addrlib/core \
	-I$(srcdir)/addrlib/inc/chip/r800 \
	-I$(srcdir)/addrlib/r800/chip \
	-DBRAHMA_BUILD=1

AM_CFLAGS = -Wno-override-init -msse2 \
	$(VISIBILITY_FLAGS) \
	$(PTHREAD_CFLAGS) \
	$(LLVM_CFLAGS)

libradv_ci_la_CFLAGS = $(AM_CFLAGS) -DHW_VERSION=CI
libradv_ci_la_SOURCES = $(GEN7_FILES)


VULKAN_SOURCES = \
	$(VULKAN_GENERATED_FILES) \
	$(VULKAN_FILES)

VULKAN_LIB_DEPS = $(AMDGPU_LIBS)


if HAVE_PLATFORM_X11
AM_CPPFLAGS += \
	$(XCB_DRI3_CFLAGS) \
	-DVK_USE_PLATFORM_XCB_KHR \
	-DVK_USE_PLATFORM_XLIB_KHR

VULKAN_SOURCES += $(VULKAN_WSI_X11_FILES)

# FIXME: Use pkg-config for X11-xcb ldflags.
VULKAN_LIB_DEPS += $(XCB_DRI3_LIBS) -lX11-xcb
endif


if HAVE_PLATFORM_WAYLAND
AM_CPPFLAGS += \
	-I$(top_builddir)/src/egl/wayland/wayland-drm \
	-I$(top_srcdir)/src/egl/wayland/wayland-drm \
	$(WAYLAND_CFLAGS) \
	-DVK_USE_PLATFORM_WAYLAND_KHR

VULKAN_SOURCES += $(VULKAN_WSI_WAYLAND_FILES)

VULKAN_LIB_DEPS += \
	$(top_builddir)/src/egl/wayland/wayland-drm/libwayland-drm.la \
	$(WAYLAND_LIBS)
endif

noinst_LTLIBRARIES += libvulkan_common.la
libvulkan_common_la_SOURCES = $(VULKAN_SOURCES)

VULKAN_LIB_DEPS += \
	libvulkan_common.la \
	$(top_builddir)/src/amd/common/libamd_common.la \
	$(top_builddir)/src/compiler/nir/libnir.la \
	$(top_builddir)/src/util/libmesautil.la \
	$(PER_GEN_LIBS) \
	$(LLVM_LIBS) \
	$(LIBELF_LIBS) \
	$(PTHREAD_LIBS) \
	$(LIBDRM_LIBS) \
	$(PTHREAD_LIBS) \
	$(DLOPEN_LIBS) \
	-lm

nodist_EXTRA_libvulkan_radeon_la_SOURCES = dummy.cpp
libvulkan_radeon_la_SOURCES = $(VULKAN_GEM_FILES)

radv_entrypoints.h : radv_entrypoints_gen.py $(vulkan_include_HEADERS)
	$(AM_V_GEN) cat $(vulkan_include_HEADERS) |\
	$(PYTHON2) $(srcdir)/radv_entrypoints_gen.py header > $@

radv_entrypoints.c : radv_entrypoints_gen.py $(vulkan_include_HEADERS)
	$(AM_V_GEN) cat $(vulkan_include_HEADERS) |\
	$(PYTHON2) $(srcdir)/radv_entrypoints_gen.py code > $@

.PHONY: radv_timestamp.h

radv_timestamp.h:
	@echo "Updating radv_timestamp.h"
	$(AM_V_GEN) echo "#define RADV_TIMESTAMP \"$(TIMESTAMP_CMD)\"" > $@

vk_format_table.c: vk_format_table.py \
		   vk_format_parse.py \
                   vk_format_layout.csv
	$(PYTHON2) $(srcdir)/vk_format_table.py $(srcdir)/vk_format_layout.csv > $@

BUILT_SOURCES = $(VULKAN_GENERATED_FILES)
CLEANFILES = $(BUILT_SOURCES) dev_icd.json radv_timestamp.h
EXTRA_DIST = \
	$(top_srcdir)/include/vulkan/vk_icd.h \
	radv_entrypoints_gen.py \
	dev_icd.json.in \
	radeon_icd.json

libvulkan_radeon_la_LIBADD = $(VULKAN_LIB_DEPS) $(top_builddir)/src/amd/addrlib/libamdgpu_addrlib.la

libvulkan_radeon_la_LDFLAGS = \
	-shared \
	-module \
	-no-undefined \
	-avoid-version \
	$(BSYMBOLIC) \
	$(LLVM_LDFLAGS) \
	$(GC_SECTIONS) \
	$(LD_NO_UNDEFINED)


icdconfdir = @VULKAN_ICD_INSTALL_DIR@
icdconf_DATA = radeon_icd.json
# The following is used for development purposes, by setting VK_ICD_FILENAMES.
noinst_DATA = dev_icd.json

dev_icd.json : dev_icd.json.in
	$(AM_V_GEN) $(SED) \
		-e "s#@build_libdir@#${abs_top_builddir}/${LIB_DIR}#" \
		< $(srcdir)/dev_icd.json.in > $@

# Libvulkan with dummy gem. Used for unit tests.
libvulkan_test_la_SOURCES = $(VULKAN_GEM_STUB_FILES)
libvulkan_test_la_LIBADD = $(VULKAN_LIB_DEPS)

include $(top_srcdir)/install-lib-links.mk

noinst_HEADERS =

LDADD = \
	libvulkan-test.la \
	$(PTHREAD_LIBS) -lm -lstdc++

