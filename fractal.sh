#!/usr/bin/env bash
# This script is my attempt at an answer to the HackerRank.com `Functions and
# Fractals - Recursive Trees` bash challange.
# https://www.hackerrank.com/challenges/fractal-trees-all
# Written by John R., March 2023

ROWS=63
COLUMNS=100
HALF_COL=$(( $COLUMNS / 2 ))

function buildUnderscores(){
    local num_underscores=$1
    for underscore in $(seq 1 $num_underscores); do
        row+='_'
    done
}

# Get's the iter for a given row_num.
function iterAtRowNum(){
    local row_num=$1
    i=1
    for height in ${heights_per_iter[@]}; do
        if [[ $row_num -gt $height ]]; then
            i=$(( $i + 1 ))
        fi
    done
    echo $i
}

function buildYs(){
    cur_iter=$(iterAtRowNum $row_num)

#    echo "Row Num: $row_num"
#    echo "Cur Iter: $cur_iter"

    # -1 bc arrays are zero-base indexed.
    index=$(( $cur_iter - 1 )) 

    len=${lengths[$index]}
    num_forks=${cutlery_set[$index]}
    iter_ceiling=${heights_per_iter[$index]}
    if [[ $cur_iter -eq 1 ]]; then
        iter_floor=0
    else
        # Previous iters ceiling.
        iter_floor=${heights_per_iter[ $(( $index - 1 )) ]}
    fi
    v_base_indent=${indents_per_iter[$index]}

#    echo "Num Forks: $num_forks"
#    echo "Iter Ceiling: $iter_ceiling"
#    echo "Iter Floor: $iter_floor"

    v_base_height=$(( $iter_floor + $len ))

    # Constucting the Vs.
    if [[ $row_num -le $iter_ceiling ]] && [[ $row_num -gt $v_base_height ]]; then
        v_center_offset=$(( $row_num % $len ))
        if [[ $v_center_offset -eq 0 ]] && [[ $row_num -ne $v_base_height ]]; then
            v_center_offset=$len
        fi

        # With multiple forks left refers to the fartherst left underscores and
        # right refers to the fartherist right underscores. The center value is
        # the space between the V, where as middle is the space between two Vs.
        left=$(( $v_base_indent - $v_center_offset ))
        center=$(( $(( $v_center_offset * 2 )) - 1 ))
        right=$(( $left + 1 ))
        total_center=$(( $num_forks * $center ))
        num_1s=$(( $num_forks * 2 ))
        total_counted=$(( $left + $right + $total_center + $num_1s ))
        num_middles=$(( $num_forks - 1 ))
        # To avoid divide by zero. Middle value does not exist anyways when
        # num_middles is zero.
        [[ $num_middles -eq 0 ]] && num_middles=1
        total_remaining=$(( $COLUMNS - $total_counted ))
        middle=$(( $total_remaining / $num_middles ))
        
#        echo "Left: $left"
#        echo "Center: $center"
#        echo "Middle: $middle"
#        echo "Right: $right"

        buildUnderscores $left

        if [[ $num_forks -eq 1 ]]; then
            row+='1'
            buildUnderscores $center
            row+='1'
        else
            for v in $(seq 1 $(( $num_forks - 1 )) ); do
                row+='1'
                buildUnderscores $center
                row+='1'
                buildUnderscores $middle
            done
            row+='1'
            buildUnderscores $center
            row+='1'
        fi

        buildUnderscores $right
        echo $row

    # Consturct the sticks |.
    elif [[ $row_num -le $v_base_height ]]; then
        left=$v_base_indent
        right=$(( $v_base_indent + 1 ))
        total_counted=$(( $left + $right + $num_forks ))
        num_middles=$(( $num_forks - 1 ))
        total_remaining=$(( $COLUMNS - $total_counted ))
        [[ $num_middles -eq 0 ]] && num_middles=1
        middle=$(( $total_remaining / $num_middles ))

        buildUnderscores $left

        if [[ $num_forks -gt 1 ]]; then
            for v in $(seq 1 $(( $num_forks - 1 )) ); do
                row+='1'
                buildUnderscores $middle
            done
        fi

        row+='1'
        buildUnderscores $right
        echo $row
    fi
}

# Kindly does the needful.
function main(){
    declare -a lengths=( "16" "8" "4" "2" "1" )
    declare -a cutlery_set=( "1" "2" "4" "8" "16" )
    declare -a heights_per_iter=()
    declare -a indents_per_iter=()

    # The heights_per_iter array is filled with the values of the row numbers
    # that are at the top of the Y for a given iteration.
    height=0
    indent=49
    for length in ${lengths[@]}; do
        height=$(( $height + $(( 2 * $length )) ))
        heights_per_iter+=( $height )

        indents_per_iter+=( $indent )
        indent=$(( $indent - $length ))
    done 

    echo -n "Enter number of iterations (N <= 5): "
    read N

    if [[ $N -gt 5 ]]; then
        echo "N must be less 5!!"
        exit
    fi

    iter=$N

    # ceiling_row is the height of the max iter (-1 bc index array is zero based).
    ceiling_row=${heights_per_iter[ $(( $iter - 1 )) ]}

    # Count down from rows to 1.
    for row_num in $(seq $ROWS -1 1); do
        row=""

        if [[ $row_num -gt $ceiling_row ]]; then
            buildUnderscores $COLUMNS
            echo $row
            continue
        fi
        buildYs 
    done
}

main
