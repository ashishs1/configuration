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
# Author: Adrien Bruneton
#

# HDF5 detection for Salome
#
#  !! Please read the generic detection procedure in SalomeMacros.cmake !!
#
# --- HDF5 specificities ----
#  MPI root directory used for HDF5 compilation is exposed into MPI_ROOT_DIR_EXP
#

SET(HDF5_ROOT_DIR $ENV{HDF5_ROOT_DIR} CACHE PATH "Path to the HDF5.")

IF(HDF5_ROOT_DIR)
  SET (HDF5_ROOT ${HDF5_ROOT_DIR})
  IF(WIN32)
    SET(HDF5_DIR ${HDF5_ROOT_DIR}/cmake/hdf5)
  ENDIF()
ENDIF()

FIND_PACKAGE(HDF5)
MARK_AS_ADVANCED(FORCE HDF5_INCLUDE_DIR HDF5_LIB HDF5_DIR)

# Stupidly enough, CONFIG mode and MODULE mode for HDF5 do not return the same thing ...!
SET(HDF5_INCLUDE_DIRS "${HDF5_INCLUDE_DIRS};${HDF5_INCLUDE_DIR}")
# Same story with libraries - if in CONFIG mode, HDF5_LIBRARIES is not defined:
IF(NOT DEFINED HDF5_LIBRARIES)
    IF(TARGET hdf5)
      SET(HDF5_C_LIBRARIES hdf5)
    ELSEIF(TARGET hdf5::hdf5-shared)
      SET(HDF5_C_LIBRARIES hdf5::hdf5-shared)
    ENDIF()
    IF(TARGET hdf5_cpp)
      SET(HDF5_CXX_LIBRARIES hdf5_cpp)
    ELSEIF(TARGET hdf5::hdf5_cpp-shared)
      SET(HDF5_CXX_LIBRARIES hdf5::hdf5_cpp-shared)
    ENDIF()
    IF(TARGET hdf5_hl)
      SET(HDF5_C_HL_LIBRARIES hdf5_hl)
    ELSEIF(TARGET hdf5::hdf5_hl-shared)
      SET(HDF5_C_HL_LIBRARIES hdf5::hdf5_hl-shared)
    ENDIF()
    IF(TARGET hdf5_hl_cpp)
      SET(HDF5_CXX_HL_LIBRARIES hdf5_hl_cpp)
    ELSEIF(TARGET hdf5::hdf5_hl_cpp-shared)
      SET(HDF5_CXX_HL_LIBRARIES hdf5::hdf5_hl_cpp-shared)
    ENDIF()
    # Note: now we only set HDF5_LIBRARIES to CXX libraries as it's enough for SALOME.
    # In future, we probably must list all libraries from requested components.
    SET(HDF5_LIBRARIES ${HDF5_CXX_LIBRARIES})
ENDIF()

##
## 7. Specific to HDF5 only:
## Expose MPI configuration to the rest of the world
##
IF(HDF5_ENABLE_PARALLEL OR HDF5_IS_PARALLEL)
  # Set only one reference boolean variable:
  # (unfortunately what is found in /usr/share/cmake/Modules/FindHDF5.cmake
  #  and in the native HDF5-config.cmake differ!)
  SET(HDF5_IS_PARALLEL TRUE)

  # HDF5 was compiled with MPI support
  # Unfortunately HDF5 doesn't expose its MPI configuration easily ...
  # We sniff the properties of the HDF5 target which should also be there:
  IF(NOT DEFINED HDF5_LIBRARIES)
    SET(HDF5_LIBRARIES "hdf5")
    IF(NOT TARGET hdf5 AND NOT TARGET hdf5-static AND NOT TARGET hdf5-shared)
      # Some HDF5 versions (e.g. 1.8.18) used hdf5::hdf5 etc
      SET(_target_prefix "hdf5::")
    ENDIF()
    SET(_suffix "-shared")
    SET(HDF5_LIBRARIES "${_target_prefix}hdf5${_suffix}")
  ENDIF()
   #Loop over HDF5_LIBRARIES, because GET_PROPERTY can have only 1 source at a time
  FOREACH(_h5lib ${HDF5_LIBRARIES})
    GET_PROPERTY(_lib_lst SOURCE _h5lib PROPERTY IMPORTED_LINK_INTERFACE_LIBRARIES_NOCONFIG)
    FOREACH(s ${_lib_lst})
      STRING(FIND "${s}" "mpi." _res)   # should cover WIN(?) and LINUX
      IF(_res GREATER -1)
        GET_FILENAME_COMPONENT(_tmp "${s}" PATH)     # go up to levels
        GET_FILENAME_COMPONENT(MPI_ROOT_DIR_EXP "${_tmp}" PATH)
        BREAK()
      ENDIF()
    ENDFOREACH()
  ENDFOREACH()
  IF(NOT SalomeHDF5_FIND_QUIETLY)
    MESSAGE(STATUS "HDF5 was compiled with MPI: ${MPI_ROOT_DIR_EXP}")
  ENDIF()
ENDIF()

## Add definitions
ADD_DEFINITIONS(-DH5_USE_16_API)
IF(WIN32)
  ADD_DEFINITIONS(-D_HDF5USEDLL_)
ENDIF()

## Ensure SALOME uses MPI if HDF5 was parallel:
IF(HDF5_IS_PARALLEL AND NOT SALOME_USE_MPI)
   MESSAGE(FATAL_ERROR "HDF5 is compiled with MPI, you have to set SALOME_USE_MPI to ON")
ENDIF()

IF(HDF5_FOUND)
  SALOME_ACCUMULATE_HEADERS(HDF5_INCLUDE_DIRS)
  SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH ${HDF5_LIBRARIES})
ENDIF()
