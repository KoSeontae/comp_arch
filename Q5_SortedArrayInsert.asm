# sorted_array_insert:
# Input:
#   $a0 = new_int (the 32-bit signed integer to insert)
#   $a1 = num_ints (the current number of integers in the sorted array)
#   $a2 = address of array[0] (base address of the sorted array)
#
# Function:
#   Inserts new_int into the sorted array so that the array remains in ascending order.
#   If the correct position is within the array, the elements from that position onward are shifted
#   to the right to make room.
#
# Note: The caller is responsible for incrementing the element count.

sorted_array_insert:
    li   $t0, 0            # $t0 will serve as our index (initially 0)

    # If the array is empty (num_ints == 0), insertion index is 0.
    beq  $a1, $zero, insert_here

find_insertion:
    bge  $t0, $a1, insert_here  # If index >= num_ints, insertion is at the end.
    sll  $t1, $t0, 2        # $t1 = index * 4
    add  $t2, $a2, $t1      # $t2 = address of array[$t0]
    lw   $t3, 0($t2)        # $t3 = array[$t0]
    # If new_int ($a0) is less than the current element, that's our insertion point.
    blt  $a0, $t3, insert_here
    addi $t0, $t0, 1        # Otherwise, move to the next index
    j    find_insertion

insert_here:
    # $t0 now holds the insertion index.
    # Shift elements to the right only if insertion is not at the end.
    beq  $t0, $a1, store_element  # No shifting needed if inserting at the end.
    
    # Set up shift index: $t8 will start at the last element's index.
    move $t8, $a1          # $t8 = current number of elements
    addi $t8, $t8, -1      # $t8 = last valid index in array

shift_loop:
    blt  $t8, $t0, store_element  # When shift index is less than insertion index, finish.
    sll  $t4, $t8, 2       # $t4 = $t8 * 4 (byte offset for current element)
    add  $t5, $a2, $t4     # $t5 = address of array[$t8]
    lw   $t6, 0($t5)       # $t6 = array[$t8]
    # Compute address for array[$t8 + 1]:
    addi $t4, $t4, 4       # $t4 = ($t8 + 1) * 4
    add  $t7, $a2, $t4     # $t7 = address of array[$t8+1]
    sw   $t6, 0($t7)       # Shift the element to the right
    addi $t8, $t8, -1      # Decrement shift index
    j    shift_loop

store_element:
    # Store the new integer at the insertion position.
    sll  $t1, $t0, 2       # $t1 = insertion index * 4
    add  $t2, $a2, $t1     # $t2 = address for array[$t0]
    sw   $a0, 0($t2)       # Write new_int into the array.
    jr   $ra               # Return from function.
