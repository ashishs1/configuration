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

# Qwt detection for Salome
#
#  !! Please read the generic detection procedure in SalomeMacros.cmake !!
#
SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS(Qwt QWT_INCLUDE_DIR 1)
MARK_AS_ADVANCED(QWT_INCLUDE_DIR QWT_LIBRARY)

IF(QWT_FOUND)
  SALOME_ACCUMULATE_HEADERS(QWT_INCLUDE_DIR)
  SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH ${QWT_LIBRARY})
ENDIF()