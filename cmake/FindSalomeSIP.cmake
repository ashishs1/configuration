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

# SIP detection for Salome
#
#  !! Please read the generic detection procedure in SalomeMacros.cmake !!
#
SALOME_FIND_PACKAGE_AND_DETECT_CONFLICTS(SIP SIP_EXECUTABLE 2)
MARK_AS_ADVANCED(SIP_EXECUTABLE SIP_INCLUDE_DIR)

IF(SIP_FOUND) 
  SALOME_ACCUMULATE_ENVIRONMENT(PATH ${SIP_EXECUTABLE})
  SALOME_ACCUMULATE_ENVIRONMENT(LD_LIBRARY_PATH ${SIP_PYTHONPATH})
  SALOME_ACCUMULATE_ENVIRONMENT(PYTHONPATH ${SIP_PYTHONPATH})
ENDIF()

