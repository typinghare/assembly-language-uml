# Copyright 2024, James Chen

# Data section
.data
	x: .word 0, 0, 0							    # int* x[3] = {0, 0, 0};
	message: .asciiz "The sum of x is:  "			# char* message = "The sum of x is: ";
	error_msg: .asciiz "The number should between 1 and 20!"
	
# Code section
.text
	.globl main
	
	main:											# int main() {
		la $a0, x									#
													#
		# Read a whole number and save it in x[0]	#
		li $v0, 5									#   int $v0;
		syscall										#   scanf("%d", &$v0);
		# Here I am using base addressing mode		#
		sw $v0, 0($a0)								# 	x[0] = $v0;
													#
		# Read a whole number and save it in x[1]	#
		li $v0, 5									#   
		syscall										#	scanf("%d", &$v0);
		# Here I am using immediate addressing mode	#
		addi $t0, $a0, 4							#	int $t0 = x + 4;
		sw $v0, 0($t0)								#	*$t0 = $v0;
													#
		# Read a whole number and save it in x[2]	#
		li $v0, 5									#
		syscall										#   scanf("%d", &$v0);
		# Here I am using resgister addressing mode	#
		li $t0, 8									#   int $t0 = 8;
		add	$t1, $a0, $t0							#   int $t1 = x + $t0;
		sw $v0, 0($t1)								#   *$t1 = $v0;
													#
		# Initialize register $s0 to 0				#
		li $s0, 0									#	int $s0 = 0;
													#
		# Fetch x[0] into register $t8, and add it to $s0
		lw $t8, x									#   $t8 = x[0]
		add $s0, $s0, $t8							#	$s0 = $s0 + $t8;
													#
		# Fetch the value from x[1] into register $t8, and add it to $s0
		lw $t8, x + 4								#   $t8 = x[1]
		add $s0, $s0, $t8							#	$s0 = $s0 + $t8;
													#
		# Fetch the value from x[2] into register $t8, and add it to $s0
		lw $t8, x + 8								#   $t8 = x[2]
		add $s0, $s0, $t8							#   $s0 = $s0 + $t8;
													#
		# Print message								#
		li $v0, 4									#	
		la $a0, message								#	char* $a0 = message;
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