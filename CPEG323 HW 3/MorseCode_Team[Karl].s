.data
buffer: .space 30
string0: .asciiz "Select Operation Mode [0=ASCII to MC, 1=MC to ASCII]:"
string1: .asciiz "Enter a Character: "
string2: .asciiz "Enter a Pattern: "
string3: .asciiz "Morse Code: "
string4: .asciiz "ASCII: "
string5: .asciiz "End of Program\n"
string6: .asciiz "[Error] no ASCII2MC!\n"
string7: .asciiz "[Error] no MC2ASCII!\n"
string8: .asciiz "[Error] Invalid combination!\n"

endLine: .asciiz "\n"

dict: .word 0x55700030, 0x95700031, 0xA5700032, 0xA9700033, 0xAA700034, 0xAAB00035, 0x6AB00036, 0x5AB00037, 0x56B00038, 0x55B00039, 0x9C000041, 0x6AC00042, 0x66C00043, 0x6B000044, 0xB0000045, 0xA6C00046, 0x5B000047, 0xAAC00048, 0xAC000049, 0x95C0004A, 0x6700004B, 0x9AC0004C, 0x5C00004D, 0x6C00004E, 0x5700004F, 0x96C00050, 0x59C00051, 0x9B000052, 0xAB000053, 0x70000054, 0xA7000055, 0xA9C00056, 0x97000057, 0x69C00058, 0x65C00059, 0x5AC0005A
s_dsh: .byte '-'
s_dot: .byte '.'
s_spc: .byte ' '
 

.text
#--------------------------------------------------------------#
#------------------------By Karl Thimm-------------------------#
#--------------------------------------------------------------#
main:
  
  li $v0, 4                 # print "Select Operation Mode [0=ASCII to MC, 1=MC to ASCII]:"
  la $a0, string0  
  syscall                   # syscall print string0 

  li $v0, 5
  syscall                   # syscall Read int 

  bne $v0, $0, MC2A

A2MC:
  li $v0, 4                 # print "Enter a Letter:" 
  la $a0, string1
  syscall                   # syscall print string1

  li $t0, 1                 # Define length
  li $v0, 12                # Read character
  syscall                   # syscall Read character
  move $t0,$v0              # Transfer the char entered to the temporary value
  
  li $t2, 1                 # Define length
  li $v0, 12                # Read NULL character 
  syscall                   # syscall Read character

  la $t2, dict              # Load address of dir
  li $t3, 0                 # Initialize index
  li $t4, 36                # Initialize boundary

LoopA2MC:
  lb $t5, ($t2)             # Load value to be compared
  beq $t0, $t5, FndA2MC     # Compare values
  addi $t2, $t2, 4          # Next symbol
  addi $t3, $t3, 1          # Next index
  blt $t3, $t4, LoopA2MC    # Evaluate index condition
  j ErrorA2MC

FndA2MC:
  li $v0, 4                 # print "Enter a Letter:" 
  la $a0, string3
  syscall                   # syscall print string3

  lw $t3, ($t2)             # Load value to be printed
  li $t4, 0x80000000        # Load bitmask

snext:
  and $t5, $t3, $t4         # Apply bitmask
  beq $t5, $0, caseZ        # Zero Found

caseO:
  sll $t3, $t3, 1           # Shift Left
  and $t5, $t3, $t4         # Apply bitmask  
  sll $t3, $t3, 1           # Shift Left
  beq $t5, $0, pdot         # 10 Found

caseE:
  li $v0, 4                 # Print string code
  la $a0, endLine           # Print NewLine
  syscall                   # syscall print value
  j EXIT                    # End

caseZ:
  sll $t3, $t3, 1           # Shift Left
  and $t5, $t3, $t4         # Apply bitmask  
  sll $t3, $t3, 1           # Shift Left
  beq $t5, $0, caseN        # 00 Found

pdash:
  li $v0, 11                # Print char
  lb $a0, s_dsh             # Load value to be printed
  syscall                   # Print value
  j snext

pdot:
  li $v0, 11                # Print char
  lb $a0, s_dot             # Load value to be printed
  syscall                   # Print value
  j snext

caseN:
  li $v0, 4                 # print "Error, Invalid combination!" 
  la $a0, string8
  syscall                   # syscall print string
  j EXIT

ErrorA2MC:
  li $v0 , 4                # print "Error no ASCII2MC!" 
  la $a0 , string6
  syscall                   # syscall print string6

  j EXIT

MC2A:
  li $v0 , 4
  la $a0 , string2        
  syscall

#--------------------------------------------------------------#
#-------------------- Write your code Here --------------------#
#--------------------------------------------------------------#

  li $v0, 8       
  
  la $a0, buffer  # load buffer into a0
  li $a1, 20      

  move $t0, $a0   
  syscall 
  
  la $t2, dict              
  li $t3, 0                 
  li $t4, 36   #boundry             
  
  j binaryLoop

  li $v0 , 4               
  la $a0 , endLine          
  syscall                   

LoopMC2A:
  lw $t5, ($t2)             
  and $t1, $t5, 0xFFFF0000  
  beq $t9, $t1, printLetter 
  addi $t2, $t2, 4          
  addi $t3, $t3, 1           
  blt $t3, $t4, LoopMC2A    
  
  j ErrorMC2A #No MC2A value

binaryLoop:
  add $t8, $t0, $t7     
  lb $a0, ($t8)       
  beq $a0, $zero, addtoEnd    
  beq $a0, '-', Dash     
  beq $a0, '.', Dot      
  addi $t7, $t7, 1          
  j binaryLoop
  
Dot:
  sll $t9, $t9, 2   #SL 2 (x4)        
  or $t9, $t9, 2       #update reg t9    
  addi $t7, $t7, 1      #adds 10 to end of binary str   
  j binaryLoop

Dash:
  sll $t9, $t9, 2            
  or $t9, $t9, 1            
  addi $t7, $t7, 1  #adds 01 to end of binary str       
  j binaryLoop
  
addtoEnd:
  sll $t9, $t9, 2           
  or $t9, $t9, 3           
  addi $t7, $t7, 1        
  j SL 
  
SL:                  
  li $t1, 0                
  li $t6, 2
  mul $t1, $t7, $t6        
  li $t6, 18                
  sub $t1, $t6, $t1         
  addi $t1, $t1, 16         
  sll $t9, $t9, $t1         
  li $t1, 0
  j LoopMC2A #jump to MC2A

printLetter:
  li $v0 , 4                
  la $a0 , string4          
  syscall                   
  
  and $t1, $t5, 0x0000FFFF  
  li $v0, 11                
  move $a0, $t1
  syscall 
  
#--------------------------------------------------------------#

  li $v0 , 4                # Print string code
  la $a0 , endLine          # Print NewLine
  syscall                   # syscall print value
  
  j EXIT
  
ErrorMC2A:
  li $v0 , 4                # print "Error no MC2ASCII!" 
  la $a0 , string7
  syscall                   # syscall print string7
  j EXIT

EXIT:    
  li $v0, 4
  la $a0, string5
  syscall

  li $a0, 0
  li $v0, 17              #exit
  syscall