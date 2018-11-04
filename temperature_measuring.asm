.include "m16def.inc"
.org 0x00
rjmp reset
.def A=r20
.def B=r21
.def C=r22
.def sign=r16
.dseg				;h kai apo pano
_tmp_: .byte 2

.cseg





reset:
ldi r24 , low(RAMEND) ; initialize stack pointer
out SPL , r24
ldi r24 , high(RAMEND)
out SPH , r24

ser r24
out DDRD,r24
ser r24
out ddra,r24

clr r16
out ddrb,r16


ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4) 
; ??te? ?? e??d??? ta 4 MSB
out DDRC ,r24						   
; t?? ???a? PORTC


rcall lcd_init
ldi r24,0x02		; clear lcd display		
rcall lcd_command
clr r26
out porta,r26


start:
rcall lcd_init
ldi r24,0x02
rcall lcd_command       ; clear lcd display
edw1:
ldi r24,5
rcall scan_keypad_rising_edge	
rcall keypad_to_ascii
cpi r24,0
breq edw1
push r24
rcall lcd_data
pop r24
rcall to_hex
mov r29,r24
lsl r29
lsl r29
lsl r29
lsl r29

edw2:
ldi r24,5
rcall scan_keypad_rising_edge	
rcall keypad_to_ascii
cpi r24,0
breq edw2
push r24
rcall lcd_data
pop r24
rcall to_hex	
andi r29, 0xF0
andi r24, 0x0F	
or r29,r24


edw3:
ldi r24,5
rcall scan_keypad_rising_edge	
rcall keypad_to_ascii
cpi r24,0
breq edw3
out porta, r24
push r24
rcall lcd_data
pop r24
rcall to_hex
mov r28,r24
lsl r28
lsl r28
lsl r28
lsl r28

edw4:
ldi r24,5
rcall scan_keypad_rising_edge	
rcall keypad_to_ascii
cpi r24,0
breq edw4
push r24
rcall lcd_data
pop r24
rcall to_hex
andi r28, 0xF0
andi r24, 0x0F	
add r28,r24


ldi r24, '='
rcall lcd_data
ldi r24, '>'
rcall lcd_data
ldi r24, ' '
rcall lcd_data


mov r25,r29
mov r24,r28

cpi r25,0x80
breq checktherest
call show
ldi r24,high(10)
ldi r25,low(10)
rcall wait_msec
jmp start

checktherest:
cpi r24, 0x00
breq do_nothing
call show
ldi r24,high(10)
ldi r25,low(10)
rcall wait_msec
jmp start
do_nothing: ;edo esvisa dio grammes
ldi r24,'N'
rcall lcd_data
ldi r24,'O'
rcall lcd_data
ldi r24,' '
rcall lcd_data
ldi r24,'D'
rcall lcd_data
ldi r24,'e'
rcall lcd_data
ldi r24,'v'
rcall lcd_data
ldi r24,'i'
rcall lcd_data
ldi r24,'c'
rcall lcd_data
ldi r24,'e'
rcall lcd_data
ldi r24,high(10)
ldi r25,low(10)
rcall wait_msec
rcall lcd_init
ldi r24,1
rcall lcd_command

jmp start


show:


sbrs r25,0;koitame to msb pou deixnei to proshmo

jmp thetiko		;an r25=00 einai 8etiko
out porta,r24
mov r27,r24
ldi r24,'-'
rcall lcd_data;emfanizoume to -
ldi sign,0		;1 an exei dekadiko
sbrs r27,0
jmp next3
ldi sign,1




next3:

mov r25,r27
neg r25
ror r25
andi r25,0b01111111





jmp next;proxwra parakatw




thetiko:
ldi sign,0		;1 an exei dekadiko
sbrs r24,0
jmp next4
ldi sign,1

next4:
ror r24
andi r24,0b01111111


mov r25,r24 
cpi r25,0
breq next;an exoume 0 den emfanizoume to +
ldi r24,'+';gia tous ypoloipous 8etikous to emfanizoume

rcall lcd_data
next:
mov A,r25;o r25 exei thn apolyth timh tou ari8mou
ldi B,0xFF	;B=-1
DECA:  ;routina metatrophs     
inc B
subi A,10  
brcc DECA 	;an to carry einai cleared ara 8etiko ksanafairese  
ldi r25,0x0A	;apla gia na kanoume thn epomenh pros8esh
add A,r25	;epanafora tou A sta 8etika
mov C,A 	;o C tr exei ths monades    

mov A,B  	;o A exei tis dekades  
 
ldi B,0xFF

DECA2:		;metatrepoume tis dekades se dekades%10 k ekatontades 
inc B
subi A,0x0A  
brcc DECA2	;an to carry einai cleared ksanafairese  
ldi r25,0x0A	;apla gia na kanoume thn epomenh pros8esh
add A,r25  
;tr o A exei dekades kai o B ekatontades
cpi B,0
breq skip_ek	;an o B einai mhden dn emfanizoume to mhdeniko stis ekatontades
mov r24,B
ldi r25,'0'
add r24,r25
rcall lcd_data	;alliws metatroph se ascii k emfnish tou dekadikou pshfiou
rjmp here

skip_ek:
cpi A,0
breq skip_dek	;an o A einai mhden dn emfanizoume to mhdeniko stis dekades

here:
mov r24,A
ldi r25,'0'
add r24,r25
rcall lcd_data	;alliws metatroph se ascii k emfnish tou dekadikou pshfiou

skip_dek:
mov r24,C	;typwma monadwn
ldi r25,'0'
add r24,r25
rcall lcd_data	;alliws metatroph se ascii k emfnish tou dekadikou pshfiou

cpi sign,1
brne here1
ldi r24,','
rcall lcd_data
ldi r24,'5'
rcall lcd_data



here1:
ldi r24,' '
rcall lcd_data
ldi r24,' '
rcall lcd_data
ldi r24,' '
rcall lcd_data	;typwma triwn kenwn gia na ka8arizoume tyxon prohgoumena pshfia sthn lcd o8onh
ret




to_hex:
cpi r24,'A'
brlo arithmos
subi r24,55
jmp telos_metatropis
arithmos:
subi r24,48
telos_metatropis:
ret


;-----------.-----------.-----------routines-----------.-----------.-----------.-----------

write_2_nibbles:
push r24 ; st???e? ta 4 MSB
in r25 ,PIND ; d?a?????ta? ta 4 LSB ?a? ta ?a?ast?????µe
andi r25 ,0x0f ; ??a ?a µ?? ?a??s??µe t?? ?p??a p??????µe?? 
andi r24 ,0xf0 ; ap?µ??????ta? ta 4 MSB ?a?
add r24 ,r25 ; s??d?????ta? µe ta p???p?????ta 4 LSB
out PORTD ,r24 ; ?a? d????ta? st?? ???d?
sbi PORTD ,PD3 ; d?µ?????e?ta? pa?µ?? ?nable st?? a???d??t? PD3
cbi PORTD ,PD3 ; PD3=1 ?a? µet? PD3=0
pop r24 ; st???e? ta 4 LSB. ??a?t?ta? t? byte.
swap r24 ; e?a???ss??ta? ta 4 MSB µe ta 4 LSB
andi r24 ,0xf0 ; p?? µe t?? se??? t??? ap?st?????ta?
add r24 ,r25
out PORTD ,r24
sbi PORTD ,PD3 ; ???? pa?µ?? ?nable
cbi PORTD ,PD3
ret


lcd_data:
push r25
push r24
sbi PORTD ,PD2 ; ep????? t?? ?ata????t? ded?µ???? (PD2=1)
rcall write_2_nibbles ; ap?st??? t?? byte
ldi r24 ,43 ; a?aµ??? 43µsec µ???? ?a ?????????e? ? ????
ldi r25 ,0 ; t?? ded?µ???? ap? t?? e?e??t? t?? lcd
rcall wait_usec
pop r24
pop r25
ret


lcd_command:
cbi PORTD ,PD2 ; ep????? t?? ?ata????t? e?t???? (PD2=1)
rcall write_2_nibbles ; ap?st??? t?? e?t???? ?a? a?aµ??? 
ldi r24 ,2 ; ??a t?? ????????s? t?? e?t??es?? t?? ap? t?? 
ldi r25 ,0 ; S??.: ?p?????? d?? e?t????, ?? clear display 

rcall wait_msec ; p?? apa?t??? s?µa?t??? µe?a??te?? ??????? 

ret


lcd_init:
ldi r24 ,40 ; ?ta? ? e?e??t?? t?? lcd t??f?d?te?ta? µe
ldi r25 ,0 ; ?e?µa e?te?e? t?? d??? t?? a?????p???s?.
rcall wait_msec ; ??aµ??? 40 msec µ???? a?t? ?a 

ldi r24 ,0x30 ; e?t??? µet??as?? se 8 bit mode
out PORTD ,r24 ; epe?d? de? µp????µe ?a e?µaste ???a???
sbi PORTD ,PD3 ; ??a t? d?aµ??f?s? e?s?d?? t?? e?e??t?
cbi PORTD ,PD3 ; t?? ??????, ? e?t??? ap?st???eta? d?? 

ldi r24 ,39
ldi r25 ,0 ; e?? ? e?e??t?? t?? ?????? ???s?eta? se 8-bit mode
rcall wait_usec ; de? ?a s?µ?e? t?p?ta, a??? a? ? e?e??t?? 

ldi r24 ,0x30
out PORTD ,r24
sbi PORTD ,PD3
cbi PORTD ,PD3
ldi r24 ,39
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x20 ; a??a?? se 4-bit mode
out PORTD ,r24
sbi PORTD ,PD3
cbi PORTD ,PD3
ldi r24 ,39
ldi r25 ,0
rcall wait_usec

ldi r24 ,0x28 ; ep????? ?a?a?t???? µe?????? 5x8 ?????d??
rcall lcd_command ; ?a? eµf???s? d?? ??aµµ?? st?? ?????
ldi r24 ,0x0c ; e?e???p???s? t?? ??????, ap?????? t?? 

rcall lcd_command
ldi r24 ,0x01 ; ?a?a??sµ?? t?? ??????
rcall lcd_command
ldi r24 ,low(1530)
ldi r25 ,high(1530)
rcall wait_usec

ldi r24 ,0x06 ; e?e???p???s? a?t?µat?? a???s?? ?at? 1 t?? 

rcall lcd_command ;p?? e??a? ap????e?µ??? st?? µet??t? 

ret

one_wire_receive_byte:
ldi r27 ,8
clr r26
loop_:
rcall one_wire_receive_bit
lsr r26
sbrc r24 ,0
ldi r24 ,0x80
or r26 ,r24
dec r27
brne loop_
mov r24 ,r26
ret

one_wire_receive_bit:
sbi DDRA ,PA4
cbi PORTA ,PA4 ; generate time slot
ldi r24 ,0x02
ldi r25 ,0x00
rcall wait_usec
cbi DDRA ,PA4 ; release the line
cbi PORTA ,PA4
ldi r24 ,10
; wait 10 µs
ldi r25 ,0
rcall wait_usec
clr r24
; sample the line
sbic PINA ,PA4
ldi r24 ,1
push r24
ldi r24 ,49
; delay 49 µs to meet the standards
ldi r25 ,0
; for a minimum of 60 µsec time slot
rcall wait_usec ; and a minimum of 1 µsec recovery time
pop r24
ret

one_wire_transmit_byte:
mov r26 ,r24
ldi r27 ,8
_one_more_:
clr r24
sbrc r26 ,0
ldi r24 ,0x01
rcall one_wire_transmit_bit
lsr r26
dec r27
brne _one_more_
ret

one_wire_transmit_bit:
push r24
; save r24
sbi DDRA ,PA4
cbi PORTA ,PA4 ; generate time slot
ldi r24 ,0x02
ldi r25 ,0x00
rcall wait_usec
pop r24
; output bit
sbrc r24 ,0
sbi PORTA ,PA4
sbrs r24 ,0
cbi PORTA ,PA4
ldi r24 ,58
; wait 58 µsec for the
ldi r25 ,0
; device to sample the line
rcall wait_usec
cbi DDRA ,PA4 ; recovery time
cbi PORTA ,PA4
ldi r24 ,0x01
ldi r25 ,0x00
rcall wait_usec
ret

one_wire_reset:
sbi DDRA ,PA4 ; PA4 configured for output
cbi PORTA ,PA4 ; 480 µsec reset pulse
ldi r24 ,low(480)
ldi r25 ,high(480)
rcall wait_usec
cbi DDRA ,PA4 ; PA4 configured for input
cbi PORTA ,PA4
ldi r24 ,100
; wait 100 µsec for devices
ldi r25 ,0
; to transmit the presence pulse
rcall wait_usec
in r24 ,PINA ; sample the line
push r24
ldi r24 ,low(380) ; wait for 380 µsec
ldi r25 ,high(380)
rcall wait_usec
pop r25
clr r24
sbrs r25 ,PA4
ldi r24 ,0x01
ret

scan_row:
ldi r25 ,0x08			; a?????p???s? ?µe ?‘0000 

back_: lsl r25		; a??ste?? ???s??s? t?? ?‘1?’ t?se? 

dec r24				; ?s?? e??a? ? a????µ?? t?? 

brne back_
out PORTC ,r25		; ? a?t?st???? ??a?µ?µ? t??eta? st? 

nop
nop					 ; ?a??st???s? ??a 

in r24 ,PINC		; ep?st??f??? ?? ??se?? (st??e?) 

andi r24 ,0x0f		; ap??µ??????ta? ta 4 LSB ?p?? ta 

ret					; ?? d?a??pte?.

scan_keypad:
ldi r24 ,0x01 ; ??e??e t?? p??t? ??a?µ?µ? t?? p???t????????
rcall scan_row
swap r24 ; ap????e?se t? ap?t??es?µa
mov r27 ,r24 ; sta 4 msb t?? r27
ldi r24 ,0x02 ; ??e??e t? de?te?? ??a?µ?µ? t?? 

rcall scan_row
add r27 ,r24 ; ap????e?se t? ap?t??es?µa sta 4 lsb t?? r27
ldi r24 ,0x03 ; ??e??e t?? t??t? ??a?µ?µ? t?? p???t????????
rcall scan_row
swap r24 ; ap????e?se t? ap?t??es?µa
mov r26 ,r24 ; sta 4 msb t?? r26
ldi r24 ,0x04 ; ??e??e t?? t?ta?t? ??a?µ?µ? t?? 

rcall scan_row
add r26 ,r24 ; ap????e?se t? ap?t??es?µa sta 4 lsb t?? r26
movw r24 ,r26 ; ?µet?fe?e t? ap?t??es?µa st??? ?ata????t?? r25:r24
ret

  

scan_keypad_rising_edge:
mov r22 ,r24 ; ap????e?se t? ????? sp??????s?µ?? st?? r22
rcall scan_keypad ; ??e??e t? p???t??????? ??a p?es?µ????? 

push r24 ; ?a? ap????e?se t? ap?t??es?µa
push r25
mov r24 ,r22 ; ?a??st???se r22 ms (t?p???? t??µ?? 10-20 

ldi r25 ,0 ; ?atas?e?ast? t?? p???t???????? ?– 

rcall wait_msec
rcall scan_keypad ; ??e??e t? p???t??????? ?a?? ?a?
pop r23 ; ap?????e ?sa p???t?a e?µfa??????
pop r22 ; sp??????s?µ?
and r24 ,r22
and r25 ,r23
ldi r26 ,low(_tmp_) ; f??t?se t?? ?at?stas? t?? d?a??pt?? 
ldi r27 ,high(_tmp_) ; p???????µe?? ???s? t?? ???t??a? 

ld r23 ,X+
ld r22 ,X
st X ,r24 ; ap????e?se st? RAM t? ??a ?at?stas?
st -X ,r25 ; t?? d?a??pt??
com r23
com r22 ; G??e? t??? d?a??pte? p?? ????? ?«?µ?????» pat??e?
and r24 ,r22
and r25 ,r23
ret

keypad_to_ascii: ; ?????? ?‘1?’ st?? ??se?? t?? ?ata????t? 

movw r26 ,r24 ; ta pa?a??t? s??µG???a ?a? a????µ???
ldi r24 ,'E'
sbrc r26 ,0
ret
ldi r24 ,'0'
sbrc r26 ,1
ret
ldi r24 ,'F'
sbrc r26 ,2
ret
ldi r24 ,'D'
sbrc r26 ,3 ; a? de? e??a? ?‘1?’pa?a???µpte? t?? ret, 
ret

ldi r24 ,'7'
sbrc r26 ,4
ret
ldi r24 ,'8'
sbrc r26 ,5
ret
ldi r24 ,'9'
sbrc r26 ,6
ret
ldi r24 ,'C'
sbrc r26 ,7
ret
ldi r24 ,'4' ; ?????? ?‘1?’ st?? ??se?? t?? ?ata????t? r27 
sbrc r27 ,0 ; ta pa?a??t? s??µG???a ?a? a????µ???
ret
ldi r24 ,'5'
sbrc r27 ,1
ret
ldi r24 ,'6'
sbrc r27 ,2
ret
ldi r24 ,'B'
sbrc r27 ,3
ret
ldi r24 ,'1'
sbrc r27 ,4
ret
ldi r24 ,'2'
sbrc r27 ,5
ret
ldi r24 ,'3'
sbrc r27 ,6
ret
ldi r24 ,'A'
sbrc r27 ,7
ret
clr r24
ret


wait_usec:
	sbiw r24 ,1		; 2 cycles (0.250 micro sec)
	nop				; 1 cycles (0.125 micro sec)
	nop				; 1 cycles (0.125 micro sec)
	nop				; 1 cycles (0.125 micro sec)
	nop				; 1 cycles (0.125 micro sec)
	brne wait_usec	; 1 or 2 cycles (0.125 or 0.250 micro sec)
	ret				; 4 cycles (0.500 micro sec)

wait_msec:
	push r24		; 2 cycles (0.250 micro sec)
	push r25		; 2 cycles
	ldi r24 , 0xe6	; load register r25:r24 with 998 (1 cycles - 0.125 micro sec)
	ldi r25 , 0x03	; 1 cycles (0.125 micro sec)
	rcall wait_usec	; 3 cycles (0.375 micro sec), total delay 998.375 micro sec
	pop r25			; 2 cycles (0.250 micro sec)
	pop r24			; 2 cycles
	sbiw r24 , 1	; 2 cycles
	brne wait_msec	; 1 or 2 cycles (0.125 or 0.250 micro sec)
	ret
