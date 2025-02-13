/*
 * asm_func.s
 *
 *  Created on: 7/2/2025
 *      Author: Hou Linxin
 */
   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global asm_func

@ Start of executable code
.section .text

@ CG/[T]EE2028 Assignment 1, Sem 2, AY 2024/25
@ (c) ECE NUS, 2025

@ Write Student 1’s Name here:
@ Write Student 2’s Name here:

@ R0: building array pointer
@ R1: entry array pointer
@ R2: exit array pointer
@ R3: result array pointer

@ R4: Number of entry handled
@ R5: Current number of car entry
@ R6: Number of cars in current section after adding the current entry
@ R7: Total number of sections
@ R8: Number of loops completed in EXIT_LOOP
@ R9: Floor num
@ R10: Section num
@ R11: Copy of the initial start position of the result array
@ R12: Current number of car exit

.equ SECTION_MAX, 12 			@ maximum no. of cars in each section
.equ NUM_ENTRY, 5				@ Number of entries into the car park

PUSH {LR} 						@Push LR onto stack

MOV R11, R3						@ Create a copy of the starting address of result array
LDR R9, [R3]					@ Load F no.floor
LDR R10, [R3, #4]				@ Load S no.section per floor
MUL R7, R9, R10 				@ Calculate number of times needed for EXIT_LOOP: F x S
MOV R4, #0 						@ Record number of entry
MOV R8, #0						@ Record the number of loops completed for EXIT_LOOP

LDR R5, [R1], #4 				@ Load first entry

ENTRY_LOOP:
	BL PARK_CAR					@ Call the PARK_CAR function
	ADD R4, #1					@ Each call of PARK_CAR function should handle one entry
	CMP R4, #NUM_ENTRY			@ Check if all entry has been parked
	BLT ENTRY_LOOP				@ If not all entry parked loop back
		
	B EXIT_LOOP					@ Handle the exit


PARK_CAR: 						@ Handle an entry into the car park
	LDR R6, [R0] 				@ Load the no.car of current section
	ADD R6, R5 					@ Add the no.car unparked into current section
	CMP R6, #SECTION_MAX		@ Compare if exceeded max no.section
	BGT HANDLE_OVERFLOW			@ If the no.car exceed max, handle overflow

	STR R6, [R3] 				@ No overflow, Update result for current section
	STR R6, [R0]				@ And update the current section
	BX LR						@ Return to the ENTRY_LOOP


HANDLE_OVERFLOW:
	SUB R5, R6, #SECTION_MAX 	@ Store unparked remainder back to R5
	MOV R6, #SECTION_MAX
	STR R6, [R3]				@ Update result for current section to be max.
	ADD R0, #4					@ Move to next section for current array
	ADD R3, #4					@ Move to next section for result array
	B PARK_CAR


EXIT_LOOP:
	LDR R6, [R11]				@ Load the current section result
	LDR R12, [R2]				@ Load the current section exit number of car
	SUB R6, R12					@ Subtract the current section number with the exit number
	STR R6, [R11]				@ Store the updated result back to result array

	ADD R11, #4					@ Move to next section for result array
	ADD R2, #4					@ Move to next section for exit array
	ADD R8, #1					@ Increment the count for the number of loops completed
	CMP R8, R7					@ Compare current number of loop completed

	BNE EXIT_LOOP				@ If not equal, restart from beginning
	
POP {LR} 						@ Return to C program
BX LR
