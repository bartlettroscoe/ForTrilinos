INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})

SET(EXTRA_SOURCE
  solver_handle.cpp
  fortran_operator.cpp
  handle_helpers.cpp
  )

IF (${PACKAGE_NAME}_ENABLE_Anasazi)
  LIST(APPEND EXTRA_SOURCE eigen_handle.cpp)
ENDIF()

IF (ForTrilinos_ENABLE_DeveloperMode)
  # Generate wrapper and proxy files
  SET(CMAKE_SWIG_OUTDIR "${CMAKE_CURRENT_SOURCE_DIR}")

  MAKE_SWIG(MODULE fortrilinos
    SOURCE fortrilinos.i
    EXTRASRC ${EXTRA_SOURCE}
    )

ELSE()
  # Use pre-generated files
  SET(GEN_SOURCE
    fortrilinos.f90
    fortrilinosFORTRAN_wrap.cxx)

  TRIBITS_ADD_LIBRARY(
    fortrilinos
    SOURCES ${GEN_SOURCE} ${EXTRA_SOURCE})
ENDIF()

INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/fortrilinos.mod DESTINATION include)