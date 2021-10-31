#!/usr/bin/env bash
# Notes on using arrays in bash.

## Declaration
# Declare an array explicitly.
declare -a array_name=()

# Declare an array with elements.
declare -a array_name=(elm1 elm2 elm3)

# Declare and associative array.
declare -A assoc_array_name=()


## Adding Elements
# Append elements.
array_name=("${array_name[@]}" elm4 elm5)

# In short hand.
array_name+=(elm6 elm7)

# Prepend an element.
array_name=(elm0 "${array_name[@]}")

# Add an element by index number.
array_name[8]=elm8

# Use single quotes around multi-word elements.
# Ex) array_name[9]='elm 9'

# Add elements to an associative array.
assoc_array_name[name]=John

# Add multiple elements to an associative array.
assoc_array_name+=([age]=26 [height]=5.10)


## Addressing Arrays
# Get the entire array.
echo Entire array:
echo "${array_name[@]}"
echo

# Get a particular element.
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

# Get associative array element.
echo Associative array value for the key name:
echo "${assoc_array_name[name]}"
echo

## Get range of elements.
# Prints every element from position two to the end of the array.
echo Values from index to end of array:
echo "${array_name[@]:2}"
echo

# Prints from the beginning to position two.
echo Values from index zero to index two:
echo "${array_name[@]:0:2}"
echo

# Prints the three elements from position two onwards.
echo Three values from index two to index four inclusive:
echo "${array_name[@]:2:3}"
echo

# Check if element is in array
echo "Checks to see if 'elm7' is in array:"
value="elm7"
if [[ "${array_name[*]}" =~ ${value} ]] ; then
	echo "The value: $value is in array!"
fi

echo

# Check if element is in array (short hand)
echo "Checks to see if 'elm4' is in array:"
[[ "${array_name[*]}" =~ "elm4" ]] &&
	echo "The value: elm4 is in array!"

echo

## Iterating over arrays.
# Print array elements one by one.
echo Print array elements one by one:
for elm in "${array_name[@]}"
do
	echo $elm
done

echo

# Check if element is in array (long hand)
echo "Checks to see if 'elm6' is in array (the long way):"
value="elm6"
for elm in "${array_name[@]}"
do
	if [[ $elm = "$value" ]] ; then
		echo "The value: $value is in array!"
	fi
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
	if [[ "${array_name[$index]}" = "$value" ]]
	then
		echo $index
	fi
done

echo

# Print all keys and values for an associative array.
echo All keys and values for the associative array:

for key in "${!assoc_array_name[@]}"
do
	value=${assoc_array_name[$key]}
	echo "$key : $value"
done

echo

# Read lines from a file into an array (easy way).
# Puts dummy data into file
for x in {1..5} ; do echo $x >> /tmp/blah.txt ; done

# Uses builtin bash readarray function to read in array from file.
readarray -t file_contents_array < /tmp/blah.txt

rm /tmp/blah.txt

echo "Array of file contents: ${file_contents_array[*]}"

echo

# Read lines from a file into an array (hard way).
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
	echo "$line"
done

echo

## Deleting elements
# Delete an element via its index.
echo "Delete an element via its index:"
array_name=( blah fart foo bar )
echo "Before: ${array_name[*]}"
unset "array_name[2]"
echo "After: ${array_name[*]}"

echo

# Deleting an element using its value.
echo "Delete an element using its value:"
array_name=( blah fart foo bar )
echo "Before: ${array_name[*]}"

for x in "${array_name[@]}" ; do
	if [[ "$x" = "blah" ]] ; then
		unset "array_name[$x]"
	fi
done

echo "After: ${array_name[*]}"

echo 

# Hacky / Shorthand way to remove element.
echo "Hacky / Shorthand way to remove element:"
array_name=( blah fart fartfoo bar )

echo "Before: ${array_name[*]}"

array_name=( ${array_name[@]/"fart"} )

echo "After: ${array_name[*]}"

echo "Downside is this works by removing the prefix." 
echo "So 'fartfoo' is reduced to just 'foo' using this method."

echo 

# Subtract array2 from array1 (short way)
echo "Subtract array2 from array1"
array1=( blah fart foo bar plop snark )
array2=( blah plop snark )
echo "Array 1: ${array1[*]}"
echo "Array 2: ${array2[*]}"

array1_minus_array2=( $(echo "${array1[@]}" "${array2[@]}" | tr ' ' '\n' | sort | uniq -u) )
echo "Array 2 minus Array 2: ${array1_minus_array2[*]}"
unset array1_minus_array2
echo "Notice how they're alphabetical now."

echo

# Subtract array2 from array1 (long way)
echo "Subtract array2 from array1"
array1=( blah fart foo bar plop snark )
array2=( blah plop snark )
echo "Array 1: ${array1[*]}"
echo "Array 2: ${array2[*]}"

for x in "${array1[@]}" ; do
	if ! [[ "${array2[*]}" =~ ${x} ]] ; then
		array1_minus_array2+=( "$x" )
	fi
done
echo "Array 2 minus Array 2: ${array1_minus_array2[*]}"
