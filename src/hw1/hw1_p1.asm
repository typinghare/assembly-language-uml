# Copyright 2024, James Chen
#
# On Jan 31, a TA told me that I'd better use loop structures to read numbers and find the summation. 
# However, Professor Hendrickson didn't cover conditional and loop structures until tonight (Jan 31) class. 
# Just in case, I refactored my code, but I also submitted the old version (hw1_p1_old.asm).
#
# I implemented the input validation checking if the input numbers are between 1 and 20 in this program, to 
# showcase that I understood how to do this part. Therefore, I didn't implement it in the part 2 program.
# 
# Thank you for your understanding!

# Data section
.data
	N: .word 3										# constexpr int N = 3;
	x: .word 0, 0, 0							    # int* x[N] = {0, 0, 0};
	msg: .asciiz "The sum of x is:  "				# char* msg = "The sum of x is: ";
	error_msg: .asciiz "The number should between 1 and 20!"

# Code section
.text
	.globl main
	
	main:											# int main() {
		la $a0, x									#   int* $a0 = x;
		li $t0, 0									#   int $t0 = 0;
		la $t8, N
		lw $t1, ($t8)
		# lw $t1, N									#   int $t1 = N;
		li $t2, 1									#	int $t2 = 1;
		li $t3, 20									#	int $t3 = 20;
													#
		# Read three whole numbers, and add them	#
		# to the array x							#
		read_loop:									#	while (true) {
			bge	$t0, $t1, read_done 				#		if ($t0 >= N) break;
			li $v0, 5								#   	int $v0;
			syscall									# 		scanf("%d", &$v0);
			blt $v0, $t2, invalid_input				#		if ($v0 < $t1) invalid_input();
			bgt $v0, $t3, invalid_input				#		if ($v0 > $t2) invalid_input();
			sw $v0, 0($a0)							#   	*$a0 = $v0;
			addi $a0, $a0, 4						#   	$a0 = $a0 + 4
			addi $t0, $t0, 1						# 		$t0 = $t0 + 1
			b read_loop								#	}
		read_done:									#   
													#
		# Initialize register $s0 to 0				#
		li $s0, 0									#	int $s0 = 0;
													#
		la $a0, x									#   $a0 = x;
		li $t0, 0									#   t0 = 0
		sum_loop:									#	while (true) {
			bge	$t0, $t1, sum_end					#		if ($t0 >= N) break;
			lw $t8, 0($a0)							#		int $t8 = *$a0
			add $s0, $s0, $t8						#		$s0 = $s0 + $t8
			addi $a0, $a0, 4						#   	$a0 = $a0 + 4
			addi $t0, $t0, 1						# 		$t0 = $t0 + 1
			b sum_loop								#   }
		sum_end:									#
													#
		# Print message								#
		li $v0, 4									#	
		la $a0, msg									#	char* $a0 = msg;
		syscall										#	printf($a0);
													#
		# Print the summation ($s0)					#
		la $v0, 1									#	
		move $a0, $s0								#	int $a0 = $s0;
		syscall										#	printf("%d", $a0);
													#
		# Exit the program							#
		la $v0, 10									#	return 0;
		syscall										# }
													#
	# @brief Prints the error message and exit the	#
	# program.										#
	invalid_input:									# void invalid_input() {
		# Print the error message					#
		li $v0, 4									#	
		la $a0, error_msg							#	char* $a0 = error_msg;
		syscall										#	printf($a0);
													#
		# Exit the program							# 
		la $v0, 10									#	return 0;
		syscall										# }
