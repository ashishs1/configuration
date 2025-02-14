###########################################################################
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

include(SalomeMacros)

IF(NOT Sphinx_FOUND)
   MESSAGE(FATAL_ERROR "Developer error -> UseSphinx file should be included after detection of the sphinx!")
ENDIF()

FUNCTION(SPHINX_CHECK_EXTENSIONS)
  CMAKE_PARSE_ARGUMENTS(CHECK_EXTENSIONS "REQUIRED" "" "" ${ARGN})
  FOREACH(_ext ${CHECK_EXTENSIONS_UNPARSED_ARGUMENTS})
    EXECUTE_PROCESS(COMMAND ${PYTHON_EXECUTABLE} -c "import ${_ext}; print('ok')" OUTPUT_VARIABLE _has_ext ERROR_QUIET)
    IF(_has_ext)
      MESSAGE(STATUS "Required Sphinx extension '${_ext}' has been found!")
    ELSE()
      IF(CHECK_EXTENSIONS_REQUIRED)
        MESSAGE(FATAL_ERROR "Required Sphinx extension '${_ext}' is not found!")
      ELSE()
        MESSAGE(WARNING "Required Sphinx extension '${_ext}' is not found!")
      ENDIF()
    ENDIF()
  ENDFOREACH()
ENDFUNCTION()

function(JOIN OUTPUT GLUE)
    set(_TMP_RESULT "")
    set(_GLUE "") # effective glue is empty at the beginning
    foreach(arg ${ARGN})
        set(_TMP_RESULT "${_TMP_RESULT}${_GLUE}${arg}")
        set(_GLUE "${GLUE}")
    endforeach()
    set(${OUTPUT} "${_TMP_RESULT}" PARENT_SCOPE)
endfunction()

#----------------------------------------------------------------------------
# ADD_MULTI_LANG_DOCUMENTATION is a macro which adds sphinx multi-language 
# documentation.
#
# USAGE: ADD_MULTI_LANG_DOCUMENTATION(TARGET <target_name> MODULE <module_name>
#                                     LANGUAGES <languages_list>)
#
# ARGUMENTS:
# TARGET_NAME : IN : target name for the documentation
# MODULE : IN : SALOME module name
# LANGUAGES : IN : list of the languages
# ADDITIONAL_ENVIRONMENT: IN : list of additional enviromnent variable used 
# for generation of the documentation
#----------------------------------------------------------------------------
MACRO(ADD_MULTI_LANG_DOCUMENTATION)
  # Common options
  SET(PAPEROPT_a4 "-D latex_paper_size=a4")

  # Parse input argument
  PARSE_ARGUMENTS(MULTI_LANG "TARGET_NAME;MODULE;LANGUAGES;ADDITIONAL_ENVIRONMENT" "" ${ARGN})

  # Content of the executable file to generate documentation
  SET(CMDS)

  JOIN(SPHINX_EXE " " ${SPHINX_EXECUTABLE})
  STRING(REPLACE "$$" "$" SPHINX_EXE ${SPHINX_EXE})

  IF(MULTI_LANG_LANGUAGES)
    # 1. Options for generation POT files
    SET(POT_SPHINXOPTS "-c ${CMAKE_CURRENT_BINARY_DIR} -b gettext ${CMAKE_CURRENT_SOURCE_DIR}/input potfiles")
    SET(CMDS "${CMDS} ${SPHINX_EXE} ${POT_SPHINXOPTS}\n")

    # 2. Update PO files options
    SET(LANGS "")
    FOREACH(lang ${MULTI_LANG_LANGUAGES})
      SET(LANGS "${LANGS} -l ${lang}")
    ENDFOREACH()
    SET(PO_SPHINXOPTS "${PO_SPHINXOPTS} update -p potfiles ${LANGS}")
    SET(CMDS "${CMDS} ${SPHINX_INTL_EXECUTABLE} ${PO_SPHINXOPTS}\n")

    # 3. Build MO files
    SET(CMDS "${CMDS} ${SPHINX_INTL_EXECUTABLE} build\n")
  ENDIF()

  # 4. Options for EN documentation
  SET(SPHINXOPTS "-c ${CMAKE_CURRENT_BINARY_DIR} -d doctrees -b html ${PAPEROPT_a4} ${CMAKE_CURRENT_SOURCE_DIR}/input ${MULTI_LANG_MODULE}")
  SET(CMDS "${CMDS} ${SPHINX_EXE} ${SPHINXOPTS}\n")

  # 5. Options for other documentation
  FOREACH(lang ${MULTI_LANG_LANGUAGES})
    SET(${lang}_SPHINXOPTS "-c ${CMAKE_CURRENT_BINARY_DIR} -d doctrees -b html ${PAPEROPT_a4} -D language=${lang} ${CMAKE_CURRENT_SOURCE_DIR}/input ${MULTI_LANG_MODULE}_${lang}")
    SET(CMDS "${CMDS} ${SPHINX_EXE} ${${lang}_SPHINXOPTS}\n")
  ENDFOREACH()

  # 6. Create command file
  SET(_script_wo "build_doc")
  IF(WIN32)
    SET(_ext "bat")
  ELSE()
    SET(_ext "sh")
  ENDIF()
  SET(_script "${_script_wo}.${_ext}")

  SALOME_GENERATE_ENVIRONMENT_SCRIPT(_not_used_output ${_script_wo} "" "" CONTEXT "${MULTI_LANG_TARGET_NAME}" CONTEXT_NAME "DO_GENERATION" ADDITIONAL_VARIABLES ${MULTI_LANG_ADDITIONAL_ENVIRONMENT})

  FILE(APPEND ${_script} "${CMDS}")

  # 7. Create custom target
  ADD_CUSTOM_TARGET(${MULTI_LANG_TARGET_NAME}
		    # 1. Copy existing po files
		    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/locale ${CMAKE_CURRENT_BINARY_DIR}/locale
		    # 2.  Generate documentation
		    COMMAND ${_call_cmd} ${_script}
		    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		   )

  # 8. Update PO files
  FOREACH(lang ${MULTI_LANG_LANGUAGES})
    FILE(GLOB _pfiles ${CMAKE_CURRENT_BINARY_DIR}/locale/${lang}/LC_MESSAGES/*.po)
    ADD_CUSTOM_COMMAND(TARGET ${MULTI_LANG_TARGET_NAME} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_SOURCE_DIR}/locale/${lang}/LC_MESSAGES)
    FOREACH(pofile ${_pfiles})
      GET_FILENAME_COMPONENT(fn_wo_path ${pofile} NAME)
      ADD_CUSTOM_COMMAND(TARGET ${MULTI_LANG_TARGET_NAME} POST_BUILD
                         COMMAND ${CMAKE_COMMAND} -E
                         copy_if_different ${pofile} ${CMAKE_CURRENT_SOURCE_DIR}/locale/${lang}/LC_MESSAGES/${fn_wo_path})
    ENDFOREACH()
  ENDFOREACH()

  # 9. Make clean files/folders
  SET(make_clean_files ${MULTI_LANG_MODULE} doctrees potfiles locale)
  FOREACH(lang ${MULTI_LANG_LANGUAGES})
    SET(make_clean_files ${make_clean_files} ${MULTI_LANG_MODULE}_${lang})
  ENDFOREACH()
  SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${make_clean_files}")

ENDMACRO(ADD_MULTI_LANG_DOCUMENTATION)
