# Copyright (C) 2007-2025  CEA, EDF, OPEN CASCADE
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

# PARAVIS detection for Salome - this is typically called by dependent modules
# (PARAVIS, etc ...)
#
# The detection is simpler than for other prerequisites.
# See explanation in FindSalomeKERNEL.cmake.
#

IF(NOT SalomePARAVIS_FIND_QUIETLY)
  MESSAGE(STATUS "Looking for Salome PARAVIS ...")
ENDIF()

SET(CMAKE_PREFIX_PATH "${PARAVIS_ROOT_DIR}")
SALOME_FIND_PACKAGE(SalomePARAVIS SalomePARAVIS CONFIG)

IF(NOT SalomePARAVIS_FIND_QUIETLY)
  MESSAGE(STATUS "Found Salome PARAVIS: ${PARAVIS_ROOT_DIR}")
ENDIF()

FOREACH(_res ${SalomePARAVIS_EXTRA_ENV})
  SALOME_ACCUMULATE_ENVIRONMENT(${_res} "${SalomePARAVIS_EXTRA_ENV_${_res}}")
ENDFOREACH()