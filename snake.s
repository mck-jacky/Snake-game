########################################################################
# COMP1521 21T2 -- Assignment 1 -- Snake!
# <https://www.cse.unsw.edu.au/~cs1521/21T2/assignments/ass1/index.html>
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# For instructions, see: https://www.cse.unsw.edu.au/~cs1521/21T2/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by Jacky Ma (z5336759)
# on 28-6-2021
#
# Version 1.0 (2021-06-24): Team COMP1521 <cs1521@cse.unsw.edu.au>
#

	# Requires:
	# - [no external symbols]
	#
	# Provides:
	# - Global variables:
	.globl	symbols
	.globl	grid
	.globl	snake_body_row
	.globl	snake_body_col
	.globl	snake_body_len
	.globl	snake_growth
	.globl	snake_tail

	# - Utility global variables:
	.globl	last_direction
	.globl	rand_seed
	.globl  input_direction__buf

	# - Functions for you to implement
	.globl	main
	.globl	init_snake
	.globl	update_apple
	.globl	move_snake_in_grid
	.globl	move_snake_in_array

	# - Utility functions provided for you
	.globl	set_snake
	.globl  set_snake_grid
	.globl	set_snake_array
	.globl  print_grid
	.globl	input_direction
	.globl	get_d_row
	.globl	get_d_col
	.globl	seed_rng
	.globl	rand_value


########################################################################
# Constant definitions.

N_COLS          = 15
N_ROWS          = 15
MAX_SNAKE_LEN   = N_COLS * N_ROWS

EMPTY           = 0
SNAKE_HEAD      = 1
SNAKE_BODY      = 2
APPLE           = 3

NORTH       = 0
EAST        = 1
SOUTH       = 2
WEST        = 3


########################################################################
# .DATA
	.data

# const char symbols[4] = {'.', '#', 'o', '@'};
symbols:
	.byte	'.', '#', 'o', '@'

	.align 2
# int8_t grid[N_ROWS][N_COLS] = { EMPTY };
grid:
	.space	N_ROWS * N_COLS

	.align 2
# int8_t snake_body_row[MAX_SNAKE_LEN] = { EMPTY };
snake_body_row:
	.space	MAX_SNAKE_LEN

	.align 2
# int8_t snake_body_col[MAX_SNAKE_LEN] = { EMPTY };
snake_body_col:
	.space	MAX_SNAKE_LEN

# int snake_body_len = 0;
snake_body_len:
	.word	0

# int snake_growth = 0;
snake_growth:
	.word	0

# int snake_tail = 0;
snake_tail:
	.word	0

# Game over prompt, for your convenience...
main__game_over:
	.asciiz	"Game over! Your score was "


########################################################################
#
# Your journey begins here, intrepid adventurer!
#
# Implement the following 6 functions, and check these boxes as you
# finish implementing each function
#
#  - [x] main
#  - [x] init_snake
#  - [x] update_apple
#  - [x] update_snake
#  - [x] move_snake_in_grid
#  - [x] move_snake_in_array
#



########################################################################
# .TEXT <main>
	.text
main:

	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    $ra
	# Uses:	    $a0, $s0, $s1, $s2, $s8
	# Clobbers: None
	#
	# Locals:
	#   None
	#
	# Structure:
	#   main
	#   -> [prologue]
	#   -> body
	#   -> do_while_loop
	#   -> end_do_while_loop
	#   -> [epilogue]

	# Code:
main__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

main__body:
	li	$s8, 1
	jal 	init_snake			# init_snake();
	jal	update_apple			# update_apple();

do_while_loop:
	jal	print_grid			# print_grid();
	jal 	input_direction
	move	$a0, $v0			# input_direction();
	jal	update_snake
	move	$s0, $v0
	beq	$s0, $s8, do_while_loop		# while (update_snake(direction) == 1);

end_do_while_loop:
	li	$t1, 3
	lw	$s2, snake_body_len
	div	$s2, $s2, $t1			# int score = snake_body_len / 3;

	la	$a0, main__game_over
	li	$v0, 4
	syscall					# printf("Game over! Your score was);
	move	$a0, $s2
	li	$v0, 1
	syscall 				# printf("%d", score);
	li   	$a0, '\n'      			# printf("%c", '\n');
    	li   	$v0, 11
    	syscall

		
main__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <init_snake>
	.text
init_snake:

	# Args:     void
	# Returns:  void
	#
	# Frame:    $ra
	# Uses:     $a0, $a1, $a2
	# Clobbers: None
	#
	# Locals:
	#   None
	#
	# Structure:
	#   init_snake
	#   -> [prologue]
	#   -> body
	#   -> [epilogue]

	# Code:
init_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

init_snake__body:

	li	$a0, 7
	li	$a1, 7
	li	$a2, 1
	jal	set_snake			# set_snake(7, 7, SNAKE_HEAD);

	li	$a0, 7
	li	$a1, 6
	li	$a2, 2
	jal	set_snake			# set_snake(7, 6, SNAKE_BODY);

	li	$a0, 7
	li	$a1, 5
	li	$a2, 2
	jal	set_snake			# set_snake(7, 5, SNAKE_BODY);

	li	$a0, 7
	li	$a1, 4
	li	$a2, 2
	jal	set_snake			# set_snake(7, 4, SNAKE_BODY);

init_snake__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra				# return;



########################################################################
# .TEXT <update_apple>
	.text
update_apple:

	# Args:     void
	# Returns:  void
	#
	# Frame:    $ra
	# Uses:     $a0, $s0, $s1, $t2, $t3, $t4, $t5, $t9
	# Clobbers: $t2
	#
	# Locals:
	#   - `int apple_row` in $s0
	#   - `int apple_col` in $s1
	#
	# Structure:
	#   update_apple
	#   -> [prologue]
	#   -> body
	#   -> apple_loop
	#   -> apple_end
	#   -> [epilogue]

	# Code:
update_apple__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

update_apple__body:

apple_loop:
	
	li	$t5, EMPTY
	
	li	$a0, N_ROWS
	jal	rand_value
	move	$s0, $v0			# apple_row = rand_value(N_ROWS)
	
	li	$a0, N_COLS
	jal	rand_value
	move	$s1, $v0			# apple_col = rand_value(N_COLS)


	li	$t2, N_COLS
	mul	$t2, $t2, $s0			# 15 * apple_row
	add	$t2, $t2, $s1			# (15) * apple_row + apple_col
	move	$t9, $t2

	lb	$t3, grid($t2)			# grid[apple_row][apple_col]
	bne	$t3, $t5, apple_loop		# if (grid[apple_row][apple_col] != EMPTY) go to apple_loop
	
	j	apple_end

apple_end:	
	li	$t4, APPLE
	sb	$t4, grid($t2)			# grid[row][col] = apple;




update_apple__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra				# return;



########################################################################
# .TEXT <update_snake>
	.text
update_snake:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: bool
	#
	# Frame:    $ra
	# Uses:     $a0, $a1, $t0, $t1, $t2, $t3, $t4, $t7, $t8, $t9
	#           $s0, $s1, $s2, $s3, $s4, $s5
	# Clobbers: $t3, $t8
	#
	# Locals:
	#   - `int d_row` in $s0
	#   - `int d_col` in $s1
	#   - `int head_row` in $s2
	#   - `int head_col` in $s3
	#   - `int new_head_row` in $s4
	#   - `int new_head_col` in $s5
	#
	# Structure:
	#   update_snake
	#   -> [prologue]
	#   -> body
	#   -> apple_true
	#   -> return_false
	#   -> [epilogue]

	# Code:
update_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

update_snake__body:
	jal	get_d_row
	move	$s0, $v0			# d_row = get_d_row(direction)
	jal	get_d_col
	move	$s1, $v0			# d_col = get_d_col(direction)

	li	$t0, 0
	lb	$s2, snake_body_row($t0)	# head_row = snake_body_row[0]
	lb	$s3, snake_body_col($t0)  	# head_col = snake_body_col[0]

	li	$t2, SNAKE_BODY
	li	$t1, N_COLS			
	mul	$t1, $t1, $s2			# 15 * head_row
	add	$t1, $t1, $s3			# 15 * head_row + head_col 
	sb	$t2, grid($t1)			# grid[head_row][head_col] = SNAKE_BODY;

	add	$s4, $s2, $s0			# new_head_row = head_row + d_row
	add     $s5, $s3, $s1			# new_head_col = head_col + d_col

	bltz	$s4, return_false		# if (new_head_row < 0)       return false;
	li	$t2, N_ROWS			
	bge	$s4, $t2, return_false		# if (new_head_row >= N_ROWS) return false;
	bltz	$s5, return_false		# if (new_head_col < 0)       return false;
	li	$t2, N_COLS
	bge	$s5, $t2, return_false		# if (new_head_col >= N_COLS) return false;

	lw	$t3, snake_body_len
	addiu	$t3, $t3, -1
	sw	$t3, snake_tail			# snake_tail = snake_body_len - 1;

	move	$a0, $s4
	move	$a1, $s5
	jal	move_snake_in_grid
	move	$t4, $v0
	beqz	$t4, return_false		# if (! move_snake_in_grid(new_head_row, new_head_col)) return false
	
	
	jal	move_snake_in_array		# move_snake_in_array(new_head_row, new_head_col);

	li	$t1, N_COLS
	mul	$t1, $t1, $s4			# 15 * new_head_row
	add	$t1, $t1, $s5			# 15 * new_head_row + new_head_col
	li	$t7, APPLE
	beq	$t9, $t1, apple_true		# if (apple is true)

	j	update_snake__epilogue

apple_true:
	lw	$t8, snake_growth
	addiu	$t8, $t8, 3
	sw	$t8, snake_growth		# snake_growth += 3;
	jal	update_apple			# update_apple()
	j	update_snake__epilogue

return_false:
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra				# return false;		


update_snake__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 1
	jr	$ra				# return true;



########################################################################
# .TEXT <move_snake_in_grid>
	.text
move_snake_in_grid:

	# Args:
	#   - $a0: new_head_row
	#   - $a1: new_head_col
	# Returns:
	#   - $v0: bool
	#
	# Frame:    $ra
	# Uses:     $a0, $a1, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $s0, $s1, $s2, $s3
	# Clobbers: $t0, $t2, $t4
	#
	# Locals:
	#   - `int tail_row` in $s1
	#   - `int tail_col` in $s2
	#
	# Structure:
	#   move_snake_in_grid
	#   -> [prologue]
	#   -> body
	#   -> else
	#   -> if_grid_is_snake_body
	#   -> returnfalse
	#   -> [epilogue]

	# Code:
move_snake_in_grid__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

move_snake_in_grid__body:
	lw	$s0, snake_growth		# int i = snake_tail
	li	$t1, 0	

	ble	$s0, $t1, else			# if snake_growth <= 0, goto else
	lw	$t0, snake_tail
	addiu	$t0, $t0, 1
	sw	$t0, snake_tail			# snake_tail++;

	lw	$t0, snake_body_len
	addiu	$t0, $t0, 1
	sw	$t0, snake_body_len		# snake_body_len++;

	lw	$t0, snake_growth
	addiu	$t0, $t0, -1
	sw	$t0, snake_growth		# snake_growth--;

else:
	lw	$t0, snake_tail			# int tail = snake_tail;

	lb	$s1, snake_body_row($t0)	# int tail_row = snake_body_row[tail];
	lb	$s2, snake_body_col($t0)	# int tail_col = snake_body_col[tail];

	li	$t2, N_COLS
	mul	$t2, $t2, $s1			# 15 * tail_row
	add	$t2, $t2, $s2			# (15) * tail_row + tail_col
	li	$t3, EMPTY
	sb	$t3, grid($t2)			# grid[row][col] = EMPTY;

if_grid_is_snake_body:
	li	$t4, N_COLS
	mul	$t4, $t4, $a0			# 15 * new_head_row 
	add	$t4, $t4, $a1			# 15 * new_head_row + new_head_col
	lb	$s3, grid($t4)			# grid[new_head_row][new_head_col] == SNAKE_BODY
	li	$t5, SNAKE_BODY
	
	beq	$t5, $s3, returnfalse		# if (grid[new_head_row][new_head_col] == SNAKE_BODY)

	li	$t6, SNAKE_HEAD
	sb	$t6, grid($t4)			# grid[new_head_row][new_head_col] = SNAKE_HEAD
	j	move_snake_in_grid__epilogue

returnfalse:
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra				# return false;

move_snake_in_grid__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 1
	jr	$ra				# return true;



########################################################################
# .TEXT <move_snake_in_array>
	.text
move_snake_in_array:

	# Arguments:
	#   - $a0: int new_head_row
	#   - $a1: int new_head_col
	# Returns:  void
	#
	# Frame:    $ra
	# Uses:     $a0, $a1, $a2, $t0, $t1, $t2, $s0, $s1
	# Clobbers: $t2
	#
	# Locals:
	#   None
	#
	# Structure:
	#   move_snake_in_array
	#   -> [prologue]
	#   -> body
	#   -> move_snake_loop
	#   -> move_snake_loop_end
	#   -> [epilogue]

	# Code:
move_snake_in_array__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

move_snake_in_array__body:
	lw	$t0, snake_tail			# int i = snake_tail
	li	$t1, 1
	move	$s0, $a0
	move	$s1, $a1

move_snake_loop:
	blt	$t0, $t1, move_snake_loop_end	# if i < 1 goto move_snake_loop_end
	move	$a2, $t0			# nth_body_piece = i

	sub	$t2, $t0, $t1
	lb	$a0, snake_body_row($t2)	# snake_body_row[i - 1]
	lb	$a1, snake_body_col($t2)	# snake_body_col[i - 1]

	jal	set_snake_array			# set_snake_array(snake_body_row[i - 1], snake_body_col[i - 1], i);

	sub	$t0, $t0, 1			# i--
	j	move_snake_loop

move_snake_loop_end:
	move	$a0, $s0
	move	$a1, $s1
	li	$a2, 0				# nth_body_piece = 0
	jal	set_snake_array


move_snake_in_array__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra				# return;


########################################################################
####                                                                ####
####        STOP HERE ... YOU HAVE COMPLETED THE ASSIGNMENT!        ####
####                                                                ####
########################################################################

##
## The following is various utility functions provided for you.
##
## You don't need to modify any of the following.  But you may find it
## useful to read through --- you'll be calling some of these functions
## from your code.
##

	.data

last_direction:
	.word	EAST

rand_seed:
	.word	0

input_direction__invalid_direction:
	.asciiz	"invalid direction: "

input_direction__bonk:
	.asciiz	"bonk! cannot turn around 180 degrees\n"

	.align	2
input_direction__buf:
	.space	2



########################################################################
# .TEXT <set_snake>
	.text
set_snake:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int body_piece
	# Returns:  void
	#
	# Frame:    $ra, $s0, $s1
	# Uses:     $a0, $a1, $a2, $t0, $s0, $s1
	# Clobbers: $t0
	#
	# Locals:
	#   - `int row` in $s0
	#   - `int col` in $s1
	#
	# Structure:
	#   set_snake
	#   -> [prologue]
	#   -> body
	#   -> [epilogue]

	# Code:
set_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1,  ($sp)

set_snake__body:
	move	$s0, $a0		# $s0 = row
	move	$s1, $a1		# $s1 = col

	jal	set_snake_grid		# set_snake_grid(row, col, body_piece);

	move	$a0, $s0
	move	$a1, $s1
	lw	$a2, snake_body_len
	jal	set_snake_array		# set_snake_array(row, col, snake_body_len);

	lw	$t0, snake_body_len
	addiu	$t0, $t0, 1
	sw	$t0, snake_body_len	# snake_body_len++;

set_snake__epilogue:
	# tear down stack frame
	lw	$s1,  ($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu 	$sp, $sp, 12

	jr	$ra			# return;



########################################################################
# .TEXT <set_snake_grid>
	.text
set_snake_grid:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int body_piece
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0, $a1, $a2, $t0
	# Clobbers: $t0
	#
	# Locals:   None
	#
	# Structure:
	#   set_snake
	#   -> body

	# Code:
	li	$t0, N_COLS
	mul	$t0, $t0, $a0		#  15 * row
	add	$t0, $t0, $a1		# (15 * row) + col
	sb	$a2, grid($t0)		# grid[row][col] = body_piece;

	jr	$ra			# return;



########################################################################
# .TEXT <set_snake_array>
	.text
set_snake_array:

	# Args:
	#   - $a0: int row
	#   - $a1: int col
	#   - $a2: int nth_body_piece
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0, $a1, $a2
	# Clobbers: None
	#
	# Locals:   None
	#
	# Structure:
	#   set_snake_array
	#   -> body

	# Code:
	sb	$a0, snake_body_row($a2)	# snake_body_row[nth_body_piece] = row;
	sb	$a1, snake_body_col($a2)	# snake_body_col[nth_body_piece] = col;

	jr	$ra				# return;



########################################################################
# .TEXT <print_grid>
	.text
print_grid:

	# Args:     void
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $v0, $a0, $t0, $t1, $t2
	# Clobbers: $v0, $a0, $t0, $t1, $t2
	#
	# Locals:
	#   - `int i` in $t0
	#   - `int j` in $t1
	#   - `char symbol` in $t2
	#
	# Structure:
	#   print_grid
	#   -> for_i_cond
	#     -> for_j_cond
	#     -> for_j_end
	#   -> for_i_end

	# Code:
	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	li	$t0, 0			# int i = 0;

print_grid__for_i_cond:
	bge	$t0, N_ROWS, print_grid__for_i_end	# while (i < N_ROWS)

	li	$t1, 0			# int j = 0;

print_grid__for_j_cond:
	bge	$t1, N_COLS, print_grid__for_j_end	# while (j < N_COLS)

	li	$t2, N_COLS
	mul	$t2, $t2, $t0		#                             15 * i
	add	$t2, $t2, $t1		#                            (15 * i) + j
	lb	$t2, grid($t2)		#                       grid[(15 * i) + j]
	lb	$t2, symbols($t2)	# char symbol = symbols[grid[(15 * i) + j]]

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t2
	syscall				# putchar(symbol);

	addiu	$t1, $t1, 1		# j++;

	j	print_grid__for_j_cond

print_grid__for_j_end:

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	addiu	$t0, $t0, 1		# i++;

	j	print_grid__for_i_cond

print_grid__for_i_end:
	jr	$ra			# return;



########################################################################
# .TEXT <input_direction>
	.text
input_direction:

	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0, $a1, $t0, $t1
	# Clobbers: $v0, $a0, $a1, $t0, $t1
	#
	# Locals:
	#   - `int direction` in $t0
	#
	# Structure:
	#   input_direction
	#   -> input_direction__do
	#     -> input_direction__switch
	#       -> input_direction__switch_w
	#       -> input_direction__switch_a
	#       -> input_direction__switch_s
	#       -> input_direction__switch_d
	#       -> input_direction__switch_newline
	#       -> input_direction__switch_null
	#       -> input_direction__switch_eot
	#       -> input_direction__switch_default
	#     -> input_direction__switch_post
	#     -> input_direction__bonk_branch
	#   -> input_direction__while

	# Code:
input_direction__do:
	li	$v0, 8			# syscall 8: read_string
	la	$a0, input_direction__buf
	li	$a1, 2
	syscall				# direction = getchar()

	lb	$t0, input_direction__buf

input_direction__switch:
	beq	$t0, 'w',  input_direction__switch_w	# case 'w':
	beq	$t0, 'a',  input_direction__switch_a	# case 'a':
	beq	$t0, 's',  input_direction__switch_s	# case 's':
	beq	$t0, 'd',  input_direction__switch_d	# case 'd':
	beq	$t0, '\n', input_direction__switch_newline	# case '\n':
	beq	$t0, 0,    input_direction__switch_null	# case '\0':
	beq	$t0, 4,    input_direction__switch_eot	# case '\004':
	j	input_direction__switch_default		# default:

input_direction__switch_w:
	li	$t0, NORTH			# direction = NORTH;
	j	input_direction__switch_post	# break;

input_direction__switch_a:
	li	$t0, WEST			# direction = WEST;
	j	input_direction__switch_post	# break;

input_direction__switch_s:
	li	$t0, SOUTH			# direction = SOUTH;
	j	input_direction__switch_post	# break;

input_direction__switch_d:
	li	$t0, EAST			# direction = EAST;
	j	input_direction__switch_post	# break;

input_direction__switch_newline:
	j	input_direction__do		# continue;

input_direction__switch_null:
input_direction__switch_eot:
	li	$v0, 17			# syscall 17: exit2
	li	$a0, 0
	syscall				# exit(0);

input_direction__switch_default:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__invalid_direction
	syscall				# printf("invalid direction: ");

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t0
	syscall				# printf("%c", direction);

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# printf("\n");

	j	input_direction__do	# continue;

input_direction__switch_post:
	blt	$t0, 0, input_direction__bonk_branch	# if (0 <= direction ...
	bgt	$t0, 3, input_direction__bonk_branch	# ... && direction <= 3 ...

	lw	$t1, last_direction	#     last_direction
	sub	$t1, $t1, $t0		#     last_direction - direction
	abs	$t1, $t1		# abs(last_direction - direction)
	beq	$t1, 2, input_direction__bonk_branch	# ... && abs(last_direction - direction) != 2)

	sw	$t0, last_direction	# last_direction = direction;

	move	$v0, $t0
	jr	$ra			# return direction;

input_direction__bonk_branch:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__bonk
	syscall				# printf("bonk! cannot turn around 180 degrees\n");

input_direction__while:
	j	input_direction__do	# while (true);



########################################################################
# .TEXT <get_d_row>
	.text
get_d_row:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0
	# Clobbers: $v0
	#
	# Locals:   None
	#
	# Structure:
	#   get_d_row
	#   -> get_d_row__south:
	#   -> get_d_row__north:
	#   -> get_d_row__else:

	# Code:
	beq	$a0, SOUTH, get_d_row__south	# if (direction == SOUTH)
	beq	$a0, NORTH, get_d_row__north	# else if (direction == NORTH)
	j	get_d_row__else			# else

get_d_row__south:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_row__north:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_row__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <get_d_col>
	.text
get_d_col:

	# Args:
	#   - $a0: int direction
	# Returns:
	#   - $v0: int
	#
	# Frame:    None
	# Uses:     $v0, $a0
	# Clobbers: $v0
	#
	# Locals:   None
	#
	# Structure:
	#   get_d_col
	#   -> get_d_col__east:
	#   -> get_d_col__west:
	#   -> get_d_col__else:

	# Code:
	beq	$a0, EAST, get_d_col__east	# if (direction == EAST)
	beq	$a0, WEST, get_d_col__west	# else if (direction == WEST)
	j	get_d_col__else			# else

get_d_col__east:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_col__west:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_col__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <seed_rng>
	.text
seed_rng:

	# Args:
	#   - $a0: unsigned int seed
	# Returns:  void
	#
	# Frame:    None
	# Uses:     $a0
	# Clobbers: None
	#
	# Locals:   None
	#
	# Structure:
	#   seed_rng
	#   -> body

	# Code:
	sw	$a0, rand_seed		# rand_seed = seed;

	jr	$ra			# return;



########################################################################
# .TEXT <rand_value>
	.text
rand_value:

	# Args:
	#   - $a0: unsigned int n
	# Returns:
	#   - $v0: unsigned int
	#
	# Frame:    None
	# Uses:     $v0, $a0, $t0, $t1
	# Clobbers: $v0, $t0, $t1
	#
	# Locals:
	#   - `unsigned int rand_seed` cached in $t0
	#
	# Structure:
	#   rand_value
	#   -> body

	# Code:
	lw	$t0, rand_seed		#  rand_seed

	li	$t1, 1103515245
	mul	$t0, $t0, $t1		#  rand_seed * 1103515245

	addiu	$t0, $t0, 12345		#  rand_seed * 1103515245 + 12345

	li	$t1, 0x7FFFFFFF
	and	$t0, $t0, $t1		# (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF

	sw	$t0, rand_seed		# rand_seed = (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF;

	rem	$v0, $t0, $a0
	jr	$ra			# return rand_seed % n;

