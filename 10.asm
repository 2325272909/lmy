;输入输出和逆序输出，字符大小写转换并输出，统计字符个数 ,十六进制转换为十进制
;增加功能内存溢出报错

data segment
  message db 50 DUP()  ;存储信息
  remessage db 50 dup()  ;存储逆序信息
  b_message db 50 dup();存储大写英文字符
  s_message db 50 dup() ;存储小写英文字符
  
  enter db 'message: ',24h  ;提示输入信息
  m_output db 'zhengxu: ',24h   ;提示正序输出信息
  r_output db 'nixu:    ',24h     ;提示逆序输出信息
  b_output db 'daxie:   ',24h  ;字符大写输出
  s_output db 'xiaoxie: ',24h ;字符小写输出 
  error db 13,10,'error! yichu!',13,10,24h  ;提示错误
  countbchar db 'daxiezifu:' ,24h  ;提示大写字符个数
  countschar db 'xiaoxiezifu:',24h  ;提示小写字符个数
  countnum db 'shuzi: '  ,24h      ;提示数字个数
  addnum db 'addnum: ',24h     ;数字累加求和
  allcount db 'allcount: ',24h     ; 字符个数

 count dw 0,2424h ,0,2424h,0,2424h,0,2424h, 0,2424h    ;计数
 ;count[0]统计字符个数    count[4]统计大写字符  
 ;count[8]统计小写字符    count[12]统计数字个数
 ;count[16]存储数字累加值
 ;其中统计的字符个数包括回车

  cr db 13,10,24h  ;换行
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
   call input  ;输入
   call output ;输出
   lea dx,cr     ;换行
   mov ah,9
   int 21h     
   call reoutput  ;逆序输出
   call bsoutput  ; 大小写输出
   call num_count ;  统计字符输出
    
   mov ah,4ch
   int 21h

;输入
input proc near
 lea dx,enter  ;提示输入
 mov ah,9
 int 21h

 mov si,0
 mov count,0  ;初始化

 _enter:
 inc count 
mov ah,1
int 21h
mov bl,al

 cmp al,0dH        ;与回车键比较，回车则输入结束
  je  _endenter   
  jne _store

_store:   ;存储信息
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

;输出
output proc near
 

 lea dx,m_output     ;提示正序输出
 mov ah,9
 int 21h
 lea dx,message 
 mov ah,9
 int 21h

 
 ret
output endp

;逆序输出
reoutput proc near
 lea dx,r_output    ;提示逆序输出
 mov ah,9
 int 21h

 mov cx,count[0]
 dec cx
 mov si,0
s:
 push message[si]      ;进栈
 inc si
 loop s

mov cx,count[0]
dec cx
mov si,0
o:
 pop remessage[si]    ;出栈
 inc si
 loop o

 mov al,24h
 mov remessage[si],al  ;输入'$’

 lea dx,remessage    ;逆序输出
 mov ah,9
 int  21h
 lea dx,cr     ;换行
   mov ah,9
   int 21h  
 ret
 reoutput endp

;大小写输出
bsoutput proc near
 mov count[4],0
 mov count[8],0 
 mov cx,count[0]
 mov si,0
 dec cx

s1:  mov al,message[si]
 
;比较,分类讨论
 cmp al,41h               ;与A比较
 jae next1                       ;如果不小于则跳转
 jb   next                    ;如果小于则跳转
 next1:   cmp al,5ah     ;与Z比较
             ja compare     ;大于跳转
             jna change1    ;如果不大于则转换
 change1:  mov b_message[si],al
                  or al,00100000b  ; 大写转换为小写
                  mov s_message[si],al   ;存到小写字符内存中
                  inc count[4]    ;存放大写字符的个数
                  jmp nexts
 compare:   cmp al,61h   ;与a比较
                    jae  next2     ;如果不小于则跳转
                    jb next      ;如果小于则跳转
 next2:  cmp al,7ah ;与z比较
             jna change2 ;不大于则转换 
             ja   next  ;大于则跳转
 change2:   mov s_message[si],al
                    and al,11011111b  ;小写转换为大写
                    mov b_message[si],al  ;存到大写字符内存中
                    inc count[8]   ;存放小写字符个数
                    jmp nexts
  next:  mov b_message[si],al
            mov s_message[si],al 
  nexts:  inc si
  loop s1  

 mov al,24h
 mov s_message[si],al
 mov b_message[si],al

lea dx,s_output  ;提示小写输出
 mov ah,9
 int 21h
 lea dx,s_message
 mov ah,9
 int 21h
   lea dx,cr     ;换行
   mov ah,9
   int 21h  

 lea dx,b_output  ;提示大写输出
 mov ah,9
 int 21h   
 lea dx,b_message
 mov ah,9
 int 21h
   lea dx,cr     ;换行
   mov ah,9
   int 21h 
 ret
 bsoutput endp       

;统计数字个数
num_count proc near
     mov count[12],0
     mov count[16],0
     mov cx,count[0]
     dec cx
     mov si,0
   circle:   mov al,message[si]
                cmp al,30h   ;数字0
                jae nextcompare   ;大于等于则跳转
                jna next3
   nextcompare:
                cmp al,39h   ;数字9
                ja  next3   ;大于则跳转
                inc count[12]  ;储存数字个数
                sub al,30h
                add count[16],al
               
   next3 :  inc si 
  loop circle

 lea dx,countbchar  ;提示输出大写字符个数
 mov ah,9
 int 21h
 mov si,4
 call changenum
 lea dx,count[4] 
 mov ah,9
 int 21h
   lea dx,cr     ;换行
   mov ah,9
   int 21h  

 lea dx,countschar  ;提示输出小写字符个数
 mov ah,9
 int 21h
  mov si,8
 call changenum
 lea dx,count[8]
 mov ah,9
 int 21h
   lea dx,cr     ;换行
   mov ah,9
   int 21h  
 
  
 lea dx,countnum  ;提示输出数字个数
 mov ah,9
 int 21h
 mov si,12
 call changenum
 lea dx,count[12]
 mov ah,9
 int 21h   
   lea dx,cr     ;换行
   mov ah,9
   int 21h 
        
 lea dx,addnum  ;提示数字累加求和 
 mov ah,9
 int 21h
  mov si,16
 call changenum
 lea dx,count[16]  
 mov ah,9
 int 21h   
   lea dx,cr     ;换行
   mov ah,9
   int 21h 

 lea dx,allcount     ;提示输入字符数
 mov ah,9
 int 21h
 
 mov si,0
 call changenum
 lea dx,count
 mov ah,9
 int 21h
   lea dx,cr     ;换行
   mov ah,9
   int 21h  
ret     
num_count endp

;十六进制转换为十进制
changenum proc near
  mov cx,count[si]   ;临时变量
  mov count[si],0    ;初始化
  mov count[si+1],0

  cmp cx,0ah
  jae c2  ;如果大于10 
  jb end1  ;0-9不需要在这里转换

 c2:sub cx,0ah
      inc count[si]
      cmp cx,0ah
      jb end2   ;将0-9存入count[si+1]
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





