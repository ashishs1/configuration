# Copyright (C) 2013-2024  CEA, EDF, OPEN CASCADE
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
#
# Looking for an installation of BasicIterativeStatistics, and if found the following variable is set
#   BASICITERATIVESTATISTICS_FOUND
#

if(SALOMEPYTHONINTERP_FOUND)
  execute_process(COMMAND ${PYTHON_EXECUTABLE} -c "import iterative_stats"
                  RESULT_VARIABLE _BASICITERATIVESTATISTICS_STATUS ERROR_QUIET)
  if(NOT _BASICITERATIVESTATISTICS_STATUS)
    set(BASICITERATIVESTATISTICS_FOUND TRUE)
  endif()
  if(BASICITERATIVESTATISTICS_FOUND)
    message(STATUS "BasicIterativeStatistics found")
  else()
    message(STATUS "BasicIterativeStatistics not found.")
  endif()
endif()
