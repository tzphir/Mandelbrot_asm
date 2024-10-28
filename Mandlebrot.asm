.data
bitmapDisplay: .space 0x80000 # enough memory for a 512x256 bitmap display
resolution: .word 512 256    # width and height of the bitmap display

windowlrbt: 
#.float -2.5 2.5 -1.25 1.25  					# good window for viewing Julia sets
#.float -3 2 -1.25 1.25  					# good window for viewing full Mandelbrot set
#.float -0.807298 -0.799298 -0.179996 -0.175996 			# double spiral
.float -1.019741354 -1.013877846  -0.325120847 -0.322189093 	# baby Mandelbrot
 
bound: .float 100	# bound for testing for unbounded growth during iteration
maxIter: .word 64	# maximum iteration count to be used by drawJulia and drawMandelbrot
scale: .word 32		# scale parameter used by computeColour

# Julia constants for testing, or likewise for more examples see
# https://en.wikipedia.org/wiki/Julia_set#Quadratic_polynomials  
JuliaC0:  .float 0    0    # should give you a circle, a good test, though boring!
JuliaC1:  .float 0.25 0.5 
JuliaC2:  .float 0    0.7 
JuliaC3:  .float 0    0.8
JuliaC4: .float 0 -0.8

# a demo starting point for iteration tests
z0: .float  0 0

start: .word 0
newLine: .asciiz "\n"
plusSign: .asciiz " + "
i: .asciiz "i"

x: .asciiz "x"
y: .asciiz "y"
equals: .asciiz " = "



########################################################################################
.text
	
	
	
	
	
	
	
	
	#TEST
	
	#lwc1 $f12 JuliaC3
	#lwc1 $f13 JuliaC3+4
	#jal printComplex
	

	
		
				
	#TEST
		
	#lwc1 $f12 JuliaC1 #(a+bi)(c+di)
	#lwc1 $f13 JuliaC1+4
	#lwc1 $f14 JuliaC1
	#lwc1 $f15 JuliaC1+4

	#jal multComplex
	
	#mov.s $f12 $f0
	#mov.s $f13 $f1
	
	#jal printComplex
	
	
	
	
	
	
	
	
	#TEST
	
	#lwc1 $f20 bound #original bound label
	#lw $t9 start #start iteration test from 0 (x0,y0, then x1,y1, etc)
	#li $a0 10 #10 iterations to start with, choose whatever int
	
	#lwc1 $f12 JuliaC1 #a
	#lwc1 $f13 JuliaC1+4 #b
	#lwc1 $f14 JuliaC0
	#lwc1 $f15 JuliaC0
	
	#jal iterateVerbose
	
	
	
	
	
	
	
	
	
	#TEST
	
	#lwc1 $f20 bound #original bound label
	#lw $t9 start #start iteration test from 0 (x0,y0, then x1,y1, etc)
	#li $a0 10 #10 iterations to start with, choose whatever int
	
	#lwc1 $f12 JuliaC1 #a
	#lwc1 $f13 JuliaC1+4 #b
	#lwc1 $f14 JuliaC0
	#lwc1 $f15 JuliaC0
	
	#jal iterate
	
	#li $v0 1
	#syscall
	
	
	
	
	
	
	
	
	
	
	#TEST
	
	#li $a0 10 #col 
	#li $a1 20 #row
	
	#jal pixel2ComplexInWindow
	
	#mov.s $f12 $f0
	#mov.s $f13 $f1
	
	#jal printComplex
	
	
	
	
	
	
	
	
	
	#TEST
	
	#lw $a0 maxIter #16 is the max number of iterations
	#lwc1 $f12 JuliaC4
	#lwc1 $f13 JuliaC4+4
	#lwc1 $f20 bound
	#jal drawJulia
	
	
	
	
	
	
	#MAIN PROGRAM
	
	lw $a0 maxIter
	lwc1 $f12 JuliaC0
	lwc1 $f13 JuliaC0
	lwc1 $f20 bound
	jal drawMandelbrot
	
	
	
	
	
	
	
	
	
		
	li $v0 10 # exit
	syscall



# HELPER 1
printComplex:

	
	addi $sp $sp -12 #allocate memory in stack
	sw $ra 0($sp) #register to jump back to main
	swc1 $f12, 4($sp) #first float
	sw $v0 8($sp)

	
	li $v0 2 #print first float (it's already in $f12)
	syscall
	
	
	
	jal printPlusSign #print ' + '
	
	
	mov.s $f12 $f13 #print second float
	li $v0 2
	syscall
	
	jal printI #print 'i'
	
	jal printNewLine #print new line
	
	
	lwc1 $f12, 4($sp) #get back original $f12 value
	lw $ra, 0($sp) #get register back to main
	lw $v0 8($sp) #get v0 back
	
	addi $sp $sp 12 #popping stack
	
	jr $ra
	
	
printI:

	li $v0 4
	la $a0 i
	syscall 
	jr $ra

	
printPlusSign:

	li $v0 4
	la $a0 plusSign
	syscall
	jr $ra
	
printNewLine:

	li $v0 4
	la $a0 newLine
	syscall
	jr $ra
	
##################################################################

#HELPER 2

multComplex:

mul.s $f4 $f12 $f14 #compute ac
mul.s $f5 $f13 $f15 #compute bd
mul.s $f6 $f12 $f15 #compute ad
mul.s $f7 $f13 $f14 #compute bc

sub.s $f0 $f4 $f5 #ac-bd
add.s $f1 $f6 $f7 #ad+bc

jr $ra



####################################################################



#TEST 3

iterateVerbose: #print the iterations

addi $sp $sp -24
sw $a0 0($sp) #save a0 register
sw $v0 4($sp) #always have v0 in stack
swc1 $f12 8($sp) #save a constant
swc1 $f13 12($sp) #save b constant
sw $ra 16($sp) #register to go back to main

li $v0 4
la $a0 x
syscall #print x

li $v0 1 
move $a0 $t9
syscall #print current number of iteration

jal printPlusSign #print '+'

la $a0 y
syscall #print y

li $v0 1 
move $a0 $t9
syscall #print current number of iteration

jal printI

la $a0 equals
syscall #print '='

mov.s $f12 $f14 #$f14 contains real part (x)
mov.s $f13 $f15 #$f15 contains imaginary part (y)

jal printComplex
jal computeFunction




#END OF LOOP

li $v0 1 #print last iteration
move $a0 $t9
syscall


move $v0 $t9
move $t9 $zero

lw $ra -8($sp)
jr $ra


computeFunction: #f(z) = z^2 + c, z = x+yi, c = a+bi

sw $ra 20($sp) #'get back to end of loop' address
mov.s $f12 $f14 #--> x=$f12 y=$f13 x=$f14 y=$f15
mov.s $f13 $f15


jal multComplex #compute (x+yi)(x+yi) 


lwc1 $f7 8($sp) #get 'a' back into temp register
lwc1 $f8 12($sp) #get 'b' back into temp register


add.s $f0 $f0 $f7 #add real part with a ($f0 = real part from (x+yi)^2)
add.s $f1 $f1 $f8 #add imaginary part with b ($f1 = imaginary part from (x+yi)^2

mov.s $f12 $f0 #real part to print (final)
mov.s $f13 $f1 #imaginary part to print (final)

mov.s $f14 $f12 #new x for next iteration
mov.s $f15 $f13 #new y for next iteration




mul.s $f4 $f14 $f14 #x^2 to $f4
mul.s $f5 $f15 $f15 #y^2 to $f5

add.s $f6 $f4 $f5 #x^2 + y^2 in $f6 (to calculate bound)

addi $t9 $t9 1 #iteration = iteration + 1

lwc1 $f12 8($sp) #get back a
lwc1 $f13 12($sp) #get back b
lw $a0 0($sp) #get back $a0
lw $v0 4($sp) #get back $v0
lw $ra 16($sp) #'get back to main' register
addi $sp $sp 24

c.le.s $f6 $f20 #if bound <= x^2 + y^2, also check if we didn't excede the number of iterations
bc1t otherCompare
lw $ra -4($sp)
jr $ra

otherCompare:

bne $t9 $a0 iterateVerbose
lw $ra -4($sp)
jr $ra







#TSET 4 (really same principle as TEST 3, but don't print anything)

iterate:

addi $sp $sp -24
sw $a0 0($sp) #save a0 register
sw $v0 4($sp) #always have v0 in stack
swc1 $f12 8($sp) #save a constant
swc1 $f13 12($sp) #save b constant
sw $ra 16($sp) #register to go back to main

mov.s $f12 $f14 #$f14 contains real part (x)
mov.s $f13 $f15 #$f15 contains imaginary part (y)

jal computeFunction2

#END OF LOOP

move $v0 $t9
move $t9 $zero

lw $ra -8($sp)
jr $ra



computeFunction2:

sw $ra 20($sp) #'get back to end of loop' address
mov.s $f12 $f14 #--> x=$f12 y=$f13 x=$f14 y=$f15
mov.s $f13 $f15


jal multComplex #compute (x+yi)(x+yi) 


lwc1 $f7 8($sp) #get 'a' back into temp register
lwc1 $f8 12($sp) #get 'b' back into temp register


add.s $f0 $f0 $f7 #add real part with a ($f0 = real part from (x+yi)^2)
add.s $f1 $f1 $f8 #add imaginary part with b ($f1 = imaginary part from (x+yi)^2

mov.s $f12 $f0 #real part to print (final)
mov.s $f13 $f1 #imaginary part to print (final)

mov.s $f14 $f12 #new x for next iteration
mov.s $f15 $f13 #new y for next iteration

mul.s $f4 $f14 $f14 #x^2 to $f4
mul.s $f5 $f15 $f15 #y^2 to $f5

add.s $f6 $f4 $f5 #x^2 + y^2 in $f6 (to calculate bound)

addi $t9 $t9 1 #iteration = iteration + 1

lwc1 $f12 8($sp) #get back a
lwc1 $f13 12($sp) #get back b
lw $a0 0($sp) #get back $a0
lw $v0 4($sp) #get back $v0
lw $ra 16($sp) #'get back to main' register
addi $sp $sp 24

c.le.s $f6 $f20 #if bound <= x^2 + y^2, also check if we didn't excede the number of iterations
bc1t otherCompare2
lw $ra -4($sp)
jr $ra

otherCompare2:

bne $t9 $a0 iterate
lw $ra -4($sp)
jr $ra





#TEST 5

pixel2ComplexInWindow:

addi $sp $sp -16
sw $t0 0($sp)
sw $t1 4($sp)
sw $t2 8($sp)
sw $t3 12($sp)

lw $t0 resolution #width
lw $t1 resolution+4 #height
lw $t2 windowlrbt #left pixel
lw $t3 windowlrbt+4 #right pixel
lw $t4 windowlrbt+8 #bottom pixel
lw $t5 windowlrbt+12 #top pixel

mtc1 $a0 $f4 #move col as float
mtc1 $a1 $f5 #move row as float
mtc1 $t0 $f6 #move width to float
mtc1 $t1 $f7 #move height
mtc1 $t2 $f8 #move left
mtc1 $t3 $f9 #move right
mtc1 $t4 $f10 #move bottom
mtc1 $t5 $f11 #move top


##computations


div.s $f16 $f4 $f6 #col/w
sub.s $f17 $f9 $f8 #r-l
mul.s $f18 $f16 $f17 #(col/w)(r-l)

add.s $f0 $f18 $f8 #(col/w)(r-l) + l (x value computed)


div.s $f16 $f5 $f7 #row/h
sub.s $f17 $f11 $f10 #t-b
mul.s $f18 $f16 $f17 #(row/h)(t-b)

add.s $f1 $f18 $f10 #(row/h)(t-b) + b (y value computed)


lw $t0 0($sp)
lw $t1 4($sp)
lw $t2 8($sp)
lw $t3 12($sp)

addi $sp $sp 16

jr $ra
  
	

#TEST 6

drawJulia:

addi $sp $sp -8
sw $ra 0($sp) #save go back to main register
sw $a0 4($sp) #a0 for iterate function (assume max iter is loaded in $a0)

lw $s0 resolution #save width
lw $s1 resolution+4 #save height




li $t2, 0 #initialize counter for width (cols)

Outer: # Inner loop

li $t3, 0 # initialize counter for height (rows)

Inner:

move $a0 $t2 #a0 -> current col
move $a1 $t3 #a1 -> current row



jal pixel2ComplexInWindow #get starting point for each (col,row)

mov.s $f14 $f0 #x for iterate
mov.s $f15 $f1 #y for iterate


lw $a0 4($sp) #get max number of iterations back

jal iterate #get number of iterations before it grows out of bounds, or get 16 if it doesn't grow out of bounds

lw $a0 4($sp) #max number of iter is in $a0, real number of iter is in $v0

bne $v0 $a0 putJuliaDot #out of bounds
beq $v0 $a0 putJuliaDot2 #in bounds (black)


check:

addi $t3, $t3, 1     # increment counter for inner loop
bne $t3, $s1, Inner  # branch to Inner if counter is not equal to limit




addi $t2, $t2, 1     # increment counter for outer loop
bne $t2, $s0, Outer  # branch to Outer if counter is not equal to limit



lw $ra 0($sp) #end of loops
lw $a0 4($sp)
addi $sp $sp 8


jr $ra


putJuliaDot: #out of bounds 

addi $sp $sp -4
sw $a0 0($sp)
move $a0 $v0 #get real number of iterations to $a0 (real number of iterations is in $v0)

jal computeColour

mul $t8 $s0 $t3 #width * row
add $t8 $t8 $t2 #width * row + col
sll $t8 $t8 2 # 4(width * row + col)

la $s3 bitmapDisplay #load address

add $s3 $s3 $t8
sw $v0 0($s3)
 
lw $a0 0($sp)
addi $sp $sp 4

j check



putJuliaDot2:



move $v0 $zero #colour is black

mul $t8 $s0 $t3 #width * row
add $t8 $t8 $t2 #width * row + col
sll $t8 $t8 2 # 4(width * row + col)

la $s3 bitmapDisplay #load address

add $s3 $s3 $t8
sw $v0 0($s3)


j check








drawMandelbrot:

addi $sp $sp -8
sw $ra 0($sp) #save go back to main register
sw $a0 4($sp) #a0 for iterate function (assume max iter is loaded in $a0)

lw $s0 resolution #save width
lw $s1 resolution+4 #save height




li $t2, 0 #initialize counter for width (cols)

Outer2: # Inner loop

li $t3, 0 # initialize counter for height (rows)

Inner2:

move $a0 $t2 #a0 -> current col
move $a1 $t3 #a1 -> current row


jal pixel2ComplexInWindow #$f0 is now constant a, $f1 is now constant b


mov.s $f12 $f0 #a
mov.s $f13 $f1 #b
lwc1 $f14 z0 #x = 0
lwc1 $f15 z0 #y = 0


lw $a0 4($sp) #get max number of iterations back

jal iterate #get number of iterations before it grows out of bounds, or get 16 if it doesn't grow out of bounds

lw $a0 4($sp) #max number of iter is in $a0, real number of iter is in $v0

bne $v0 $a0 putMandelDot #out of bounds
beq $v0 $a0 putMandelDot2 #in bounds (black)


check2:

addi $t3, $t3, 1     # increment counter for inner loop
bne $t3, $s1, Inner2  # branch to Inner if counter is not equal to limit




addi $t2, $t2, 1     # increment counter for outer loop
bne $t2, $s0, Outer2  # branch to Outer if counter is not equal to limit



lw $ra 0($sp) #end of loops
lw $a0 4($sp)
addi $sp $sp 8


jr $ra


putMandelDot: #out of bounds 

addi $sp $sp -4
sw $a0 0($sp)
move $a0 $v0 #get real number of iterations to $a0 (real number of iterations is in $v0)

jal computeColour

mul $t8 $s0 $t3 #width * row
add $t8 $t8 $t2 #width * row + col
sll $t8 $t8 2 # 4(width * row + col)

la $s3 bitmapDisplay #load address

add $s3 $s3 $t8
sw $v0 0($s3)
 
lw $a0 0($sp)
addi $sp $sp 4

j check2



putMandelDot2:



move $v0 $zero #colour is black

mul $t8 $s0 $t3 #width * row
add $t8 $t8 $t2 #width * row + col
sll $t8 $t8 2 # 4(width * row + col)

la $s3 bitmapDisplay #load address

add $s3 $s3 $t8
sw $v0 0($s3)


j check2







########################################################################################
# Computes a colour corresponding to a given iteration count in $a0
# The colours cycle smoothly through green blue and red, with a speed adjustable 
# by a scale parametre defined in the static .data segment
computeColour:
	la $t0 scale
	lw $t0 ($t0)
	mult $a0 $t0
	mflo $a0
ccLoop:
	slti $t0 $a0 256
	beq $t0 $0 ccSkip1
	li $t1 255
	sub $t1 $t1 $a0
	sll $t1 $t1 8
	add $v0 $t1 $a0
	jr $ra
ccSkip1:
  	slti $t0 $a0 512
	beq $t0 $0 ccSkip2
	addi $v0 $a0 -256
	li $t1 255
	sub $t1 $t1 $v0
	sll $v0 $v0 16
	or $v0 $v0 $t1
	jr $ra
ccSkip2:
	slti $t0 $a0 768
	beq $t0 $0 ccSkip3
	addi $v0 $a0 -512
	li $t1 255
	sub $t1 $t1 $v0
	sll $t1 $t1 16
	sll $v0 $v0 8
	or $v0 $v0 $t1
	jr $ra
ccSkip3:
 	addi $a0 $a0 -768
 	j ccLoop
