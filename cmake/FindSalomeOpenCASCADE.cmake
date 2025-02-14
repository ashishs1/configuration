# Copyright (C) 2013-2025  CEA, EDF, OPEN CASCADE
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
# Author: Roman NIKOLAEV
#

# OpenCASCADE detection for Salome
#
#  !! Please read the generic detection procedure in SalomeMacros.cmake !!
#

# TODO: RNV: Check different OCCT layouts !!!
IF(WIN32)
  SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS(OpenCASCADE OpenCASCADE_INCLUDE_DIR 1)
ELSE()
  SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS(OpenCASCADE OpenCASCADE_INCLUDE_DIR 2)
ENDIF()

SET(OpenCASCADE_SP_VERSION 0)
IF(OpenCASCADE_FOUND)

  FIND_FILE(CAS_VERSION_FILE Standard_Version.hxx PATHS ${OpenCASCADE_INCLUDE_DIR})
  FILE(STRINGS ${CAS_VERSION_FILE} _tmp REGEX "^ *#define OCC_VERSION_SERVICEPACK")
  IF(_tmp)
      STRING(REGEX MATCHALL "[0-9]+" _spComponents "${_tmp}")
      LIST(LENGTH _spComponents _len)
      IF(${_len} GREATER 0)
          LIST(GET _spComponents 0 OpenCASCADE_SP_VERSION)
      ENDIF()
  ENDIF(_tmp)
  
  IF(NOT CAS_FIND_QUIETLY)
      IF(${OpenCASCADE_SP_VERSION})
          MESSAGE(STATUS "Found OpenCASCADE version: ${OpenCASCADE_VERSION}p${OpenCASCADE_SP_VERSION}")
      ELSE()
          MESSAGE(STATUS "Found OpenCASCADE version: ${OpenCASCADE_VERSION}")
      ENDIF()
  ENDIF()

  # OPENCASCADE definitions
  SET(OpenCASCADE_DEFINITIONS ${OpenCASCADE_C_FLAGS} ${OpenCASCADE_CXX_FLAGS})
  SET(OpenCASCADE_LDFLAGS ${OpenCASCADE_LINKER_FLAGS})

  SALOME_ACCUMULATE_HEADERS(OpenCASCADE_INCLUDE_DIR)
  SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH ${OpenCASCADE_LIBRARY_DIR})
  IF(WIN32)
    # RNV: Fix bug with OCCT CMake build procedure:
    #      In Debug ${OpenCASCADE_BINARY_DIR} and ${OpenCASCADE_LIBRARY_DIR} are stored in the
    #      config file w/o "d" suffix. To be checked with latest version of OCCT.
    SET(SUFF "")
    IF(${OpenCASCADE_BUILD_WITH_DEBUG})
      SET(SUFF "d")
    ENDIF()
    SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH ${OpenCASCADE_BINARY_DIR}${SUFF})
  ENDIF()

ELSE()
  # TODO: Detect OpenCASCADE if it is distributed without CMake configuration.
  IF(NOT CAS_FIND_QUIETLY)
    MESSAGE(STATUS "Could not find OpenCASCADE ...")
  ENDIF()
ENDIF()
