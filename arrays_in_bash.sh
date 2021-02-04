#!/usr/bin/env bash
# Notes on using arrays in bash.

## Declaration
# Declare an array explicitly.
declare -a array_name=()

# Declare an array with elements.
declare -a array_name=(elm1 elm2 elm3)


## Adding Elements
# Append elements.
array_name=(${array_name[@]} elm4 elm5)

# In short hand.
array_name+=(elm6 elm7)

# Prepend an element.
array_name=(elm0 ${array_name[@]})

# Add an element by index number.
array_name[8]=elm8

# Use single quotes around multi-word elements.
# Ex) array_name[9]='elm 9'


## 
# Get the entire array.
echo Entire array:
echo "${array_name[@]}"
echo

# Get particular element.
echo Fifth element:
echo "${array_name[5]}"
echo

# Get array length with #.
echo Array length:
echo "${#array_name[@]}"
echo

# Get array indexes with !.
echo Indexes of array:
echo "${!array_name[@]}"
echo

# Get last element with negative index.
echo Last element via negative indexing:
echo "${array_name[-1]}"
echo


## Get range of elements.
# Prints every element after position two to the end of the array.
echo Values from index to end of array:
echo "${array_name[@]:2}"
echo

# Prints from the beginning to position two.
echo Values from index zero to index two:
echo "${array_name[@]:0:2}"
echo

# Prints the three elements after position two.
echo Three values from index two to index four inclusive:
echo "${array_name[@]:2:3}"
echo


## Iterating over arrays.
# Print array elements one by one.
echo Print array elements one by one:
for elm in "${array_name[@]}"
do
	echo $elm
done

echo

# Putting values into an array.
echo Values put into the_teens array:
declare -a the_teens=()
index=0
for num in {13..19}
do
	the_teens[$index]=$num
	((index++))
done

echo "${the_teens[@]}"
echo

# Find the index of a particular value in an array.
echo The index value of elm4 is:
value="elm4"

for index in "${!array_name[@]}"
do
	if [[ "${array_name[$index]}" = $value ]]
	then
		echo $index
	fi
done

echo

# Read lines from a file into an array.
echo Putting lines from a file into an array and printing them:
declare -a file_lines=()

index=0

while IFS= read -r line
do
	file_lines[$index]="$line"
	((index++))
done << EOF
Pretend this is a file.
and these are the file lines.
This would work the same
if you put a file name here
instead of this heredoc.
For example,
done < file.txt 
instead of,
done << EOF
EOF

# Print the lines again.

for line in "${file_lines[@]}"
do
	echo $line
done

echo
