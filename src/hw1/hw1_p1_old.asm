# Copyright 2024, James Chen

# Data section
.data
	x: .word 0, 0, 0							    # int* x[3] = {0, 0, 0};
	message: .asciiz "The sum of x is:  "			# char* message = "The sum of x is: ";
	
# Code section
.text
	.globl main
	
	main:											# int main() {
		# Read a whole number and save it in x[0]	#
		li $v0, 5									#   int $v0;
		syscall										#   scanf("%d", &$v0);
		sw $v0, x									# 	x[0] = $v0;
													#
		# Read a whole number and save it in x[1]	#
		li $v0, 5									#   
		syscall										#	scanf("%d", &$v0);
		sw $v0, x + 4								#	x[1] = $v0;
													#
		# Read a whole number and save it in x[2]	#
		li $v0, 5									#
		syscall										#   scanf("%d", &$v0);
		sw $v0, x + 8								#   x[2] = $v0;
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
													# }
		
