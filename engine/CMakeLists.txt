cmake_minimum_required(VERSION 3.16)

project(ventus_cv_engine VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Options
option(BUILD_TESTS "Build test suite" ON)
option(BUILD_BENCHMARKS "Build performance benchmarks" OFF)

# Find dependencies
find_package(OpenCV REQUIRED)
find_package(Protobuf REQUIRED)
find_package(gRPC CONFIG REQUIRED)
find_package(absl CONFIG REQUIRED)

# TensorFlow Lite
find_library(TFLITE_LIB tensorflowlite HINTS /usr/local/lib)
find_path(TFLITE_INCLUDE tensorflow/lite HINTS /usr/local/include)

# Proto generation
set(PROTO_DIR ${CMAKE_CURRENT_SOURCE_DIR}/proto)
set(GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)
file(MAKE_DIRECTORY ${GENERATED_DIR})

# Generate protobuf and gRPC sources
set(PROTO_FILES ${PROTO_DIR}/verification.proto)

add_custom_command(
    OUTPUT 
        ${GENERATED_DIR}/verification.pb.cc
        ${GENERATED_DIR}/verification.pb.h
        ${GENERATED_DIR}/verification.grpc.pb.cc
        ${GENERATED_DIR}/verification.grpc.pb.h
    COMMAND protobuf::protoc
        --cpp_out=${GENERATED_DIR}
        --grpc_out=${GENERATED_DIR}
        --plugin=protoc-gen-grpc=$<TARGET_FILE:gRPC::grpc_cpp_plugin>
        -I${PROTO_DIR}
        ${PROTO_FILES}
    DEPENDS ${PROTO_FILES}
    COMMENT "Generating protobuf and gRPC sources"
)

# Engine library
add_library(ventus_cv_core STATIC
    src/scene_classifier.cpp
    src/preprocessing.cpp
    src/inference_engine.cpp
    ${GENERATED_DIR}/verification.pb.cc
    ${GENERATED_DIR}/verification.grpc.pb.cc
)

target_include_directories(ventus_cv_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${GENERATED_DIR}
    ${OpenCV_INCLUDE_DIRS}
    ${TFLITE_INCLUDE}
)

target_link_libraries(ventus_cv_core PUBLIC
    ${OpenCV_LIBS}
    ${TFLITE_LIB}
    gRPC::grpc++
    protobuf::libprotobuf
)

# gRPC server executable
add_executable(ventus_server
    src/server.cpp
)

target_link_libraries(ventus_server PRIVATE
    ventus_cv_core
)

# Tests
if(BUILD_TESTS)
    enable_testing()
    find_package(GTest REQUIRED)
    
    add_executable(ventus_tests
        tests/test_preprocessing.cpp
        tests/test_classifier.cpp
    )
    
    target_link_libraries(ventus_tests PRIVATE
        ventus_cv_core
        GTest::gtest_main
    )
    
    include(GoogleTest)
    gtest_discover_tests(ventus_tests)
endif()

# Install targets
install(TARGETS ventus_server ventus_cv_core
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY include/ DESTINATION include)
