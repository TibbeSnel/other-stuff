#!/usr/bin/env bash
set -e

FILE="$1"
EXT="${FILE##*.}"
DIR="$(dirname "$FILE")"
BASENAME="$(basename "$FILE" ".$EXT")"

case "$EXT" in
    c)
        BUILD="$DIR/c_build"
        mkdir -p "$BUILD"
        echo "Compiling C with gcc..."
        if gcc "$FILE" -o "$BUILD/$BASENAME.out"; then
            echo -e "Running...\n"
            "$BUILD/$BASENAME.out"
        else
            echo "Error during compilation"
            exit 1
        fi
        ;;
    cpp)
        BUILD="$DIR/cpp_build"
        mkdir -p "$BUILD"
        echo "Compiling C++ with g++..."
        if g++ "$FILE" -o "$BUILD/$BASENAME.out"; then
            echo -e "Running...\n"
            "$BUILD/$BASENAME.out"
        else
            echo "Error during compilation"
            exit 1
        fi
        ;;
    v|sv)
        BUILD="$DIR/v_build"
        mkdir -p "$BUILD"
        shopt -s nullglob
        FILES=("$DIR"/*.v "$DIR"/*.sv)
        if [ ${#FILES[@]} -eq 0 ]; then
            echo "No Verilog/SystemVerilog files found in $DIR"
            exit 1
        fi
        echo -e "Compiling Verilog/SystemVerilog with Icarus Verilog...\n"
        if iverilog -g2012 -o "$BUILD/sim.out" "${FILES[@]}"; then
            echo -e "Running simulation...\n"
            vvp "$BUILD/sim.out"
            echo -e "\nOpening GTKWave..."
            gtkwave dump.vcd
        else
            echo "Error during compilation"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported file type: $EXT"
        exit 1
        ;;
esac
