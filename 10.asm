;�������������������ַ���Сдת���������ͳ���ַ����� ,ʮ������ת��Ϊʮ����
;���ӹ����ڴ��������

data segment
  message db 50 DUP()  ;�洢��Ϣ
  remessage db 50 dup()  ;�洢������Ϣ
  b_message db 50 dup();�洢��дӢ���ַ�
  s_message db 50 dup() ;�洢СдӢ���ַ�
  
  enter db 'message: ',24h  ;��ʾ������Ϣ
  m_output db 'zhengxu: ',24h   ;��ʾ���������Ϣ
  r_output db 'nixu:    ',24h     ;��ʾ���������Ϣ
  b_output db 'daxie:   ',24h  ;�ַ���д���
  s_output db 'xiaoxie: ',24h ;�ַ�Сд��� 
  error db 13,10,'error! yichu!',13,10,24h  ;��ʾ����
  countbchar db 'daxiezifu:' ,24h  ;��ʾ��д�ַ�����
  countschar db 'xiaoxiezifu:',24h  ;��ʾСд�ַ�����
  countnum db 'shuzi: '  ,24h      ;��ʾ���ָ���
  addnum db 'addnum: ',24h     ;�����ۼ����
  allcount db 'allcount: ',24h     ; �ַ�����

 count dw 0,2424h ,0,2424h,0,2424h,0,2424h, 0,2424h    ;����
 ;count[0]ͳ���ַ�����    count[4]ͳ�ƴ�д�ַ�  
 ;count[8]ͳ��Сд�ַ�    count[12]ͳ�����ָ���
 ;count[16]�洢�����ۼ�ֵ
 ;����ͳ�Ƶ��ַ����������س�

  cr db 13,10,24h  ;����
data ends

stack segment stack
   db 400 dup(0)
stack ends

code segment
  assume cs:code,ds:data,ss:stack
  
start :
   mov ax,data
   mov ds,ax
  ; mov es,ax
   call input  ;����
   call output ;���
   lea dx,cr     ;����
   mov ah,9
   int 21h     
   call reoutput  ;�������
   call bsoutput  ; ��Сд���
   call num_count ;  ͳ���ַ����
    
   mov ah,4ch
   int 21h

;����
input proc near
 lea dx,enter  ;��ʾ����
 mov ah,9
 int 21h

 mov si,0
 mov count,0  ;��ʼ��

 _enter:
 inc count 
mov ah,1
int 21h
mov bl,al

 cmp al,0dH        ;��س����Ƚϣ��س����������
  je  _endenter   
  jne _store

_store:   ;�洢��Ϣ
 mov message[si],bl
 add si,1
 jmp _enter

_error:
 lea dx,error
 mov ah,9
 int 21h
 mov ah,4ch
 int 21h

_endenter:
 
 mov message[si+1],al
 mov al,24h
 mov message[si],al
 cmp count[0],32h
 ja _error
 ret
input  endp

;���
output proc near
 

 lea dx,m_output     ;��ʾ�������
 mov ah,9
 int 21h
 lea dx,message 
 mov ah,9
 int 21h

 
 ret
output endp

;�������
reoutput proc near
 lea dx,r_output    ;��ʾ�������
 mov ah,9
 int 21h

 mov cx,count[0]
 dec cx
 mov si,0
s:
 push message[si]      ;��ջ
 inc si
 loop s

mov cx,count[0]
dec cx
mov si,0
o:
 pop remessage[si]    ;��ջ
 inc si
 loop o

 mov al,24h
 mov remessage[si],al  ;����'$��

 lea dx,remessage    ;�������
 mov ah,9
 int  21h
 lea dx,cr     ;����
   mov ah,9
   int 21h  
 ret
 reoutput endp

;��Сд���
bsoutput proc near
 mov count[4],0
 mov count[8],0 
 mov cx,count[0]
 mov si,0
 dec cx

s1:  mov al,message[si]
 
;�Ƚ�,��������
 cmp al,41h               ;��A�Ƚ�
 jae next1                       ;�����С������ת
 jb   next                    ;���С������ת
 next1:   cmp al,5ah     ;��Z�Ƚ�
             ja compare     ;������ת
             jna change1    ;�����������ת��
 change1:  mov b_message[si],al
                  or al,00100000b  ; ��дת��ΪСд
                  mov s_message[si],al   ;�浽Сд�ַ��ڴ���
                  inc count[4]    ;��Ŵ�д�ַ��ĸ���
                  jmp nexts
 compare:   cmp al,61h   ;��a�Ƚ�
                    jae  next2     ;�����С������ת
                    jb next      ;���С������ת
 next2:  cmp al,7ah ;��z�Ƚ�
             jna change2 ;��������ת�� 
             ja   next  ;��������ת
 change2:   mov s_message[si],al
                    and al,11011111b  ;Сдת��Ϊ��д
                    mov b_message[si],al  ;�浽��д�ַ��ڴ���
                    inc count[8]   ;���Сд�ַ�����
                    jmp nexts
  next:  mov b_message[si],al
            mov s_message[si],al 
  nexts:  inc si
  loop s1  

 mov al,24h
 mov s_message[si],al
 mov b_message[si],al

lea dx,s_output  ;��ʾСд���
 mov ah,9
 int 21h
 lea dx,s_message
 mov ah,9
 int 21h
   lea dx,cr     ;����
   mov ah,9
   int 21h  

 lea dx,b_output  ;��ʾ��д���
 mov ah,9
 int 21h   
 lea dx,b_message
 mov ah,9
 int 21h
   lea dx,cr     ;����
   mov ah,9
   int 21h 
 ret
 bsoutput endp       

;ͳ�����ָ���
num_count proc near
     mov count[12],0
     mov count[16],0
     mov cx,count[0]
     dec cx
     mov si,0
   circle:   mov al,message[si]
                cmp al,30h   ;����0
                jae nextcompare   ;���ڵ�������ת
                jna next3
   nextcompare:
                cmp al,39h   ;����9
                ja  next3   ;��������ת
                inc count[12]  ;�������ָ���
                sub al,30h
                add count[16],al
               
   next3 :  inc si 
  loop circle

 lea dx,countbchar  ;��ʾ�����д�ַ�����
 mov ah,9
 int 21h
 mov si,4
 call changenum
 lea dx,count[4] 
 mov ah,9
 int 21h
   lea dx,cr     ;����
   mov ah,9
   int 21h  

 lea dx,countschar  ;��ʾ���Сд�ַ�����
 mov ah,9
 int 21h
  mov si,8
 call changenum
 lea dx,count[8]
 mov ah,9
 int 21h
   lea dx,cr     ;����
   mov ah,9
   int 21h  
 
  
 lea dx,countnum  ;��ʾ������ָ���
 mov ah,9
 int 21h
 mov si,12
 call changenum
 lea dx,count[12]
 mov ah,9
 int 21h   
   lea dx,cr     ;����
   mov ah,9
   int 21h 
        
 lea dx,addnum  ;��ʾ�����ۼ���� 
 mov ah,9
 int 21h
  mov si,16
 call changenum
 lea dx,count[16]  
 mov ah,9
 int 21h   
   lea dx,cr     ;����
   mov ah,9
   int 21h 

 lea dx,allcount     ;��ʾ�����ַ���
 mov ah,9
 int 21h
 
 mov si,0
 call changenum
 lea dx,count
 mov ah,9
 int 21h
   lea dx,cr     ;����
   mov ah,9
   int 21h  
ret     
num_count endp

;ʮ������ת��Ϊʮ����
changenum proc near
  mov cx,count[si]   ;��ʱ����
  mov count[si],0    ;��ʼ��
  mov count[si+1],0

  cmp cx,0ah
  jae c2  ;�������10 
  jb end1  ;0-9����Ҫ������ת��

 c2:sub cx,0ah
      inc count[si]
      cmp cx,0ah
      jb end2   ;��0-9����count[si+1]
      jae c2

end2:mov count[si+1],cx
         jmp end3

end3:add count[si],30h
          add count[si+1],30h
          jmp end4

end1: mov count[si],cx
           add count[si],30h
            
end4: ret
changenum endp

code ends
end start





