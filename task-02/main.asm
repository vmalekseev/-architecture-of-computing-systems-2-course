; Студент: Алексеев Валерий Михайлович
; Группа: БПИ197
; Вариант: 1

; Разработать программу, которая вводит одномерный массив A[N], формирует из элементов массива A новый массив B по правилам, указанным в таблице, и выводит его.
; Память под массивы может выделяться как статически, так и динамически по выбору разработчика.
; 
; Разбить решение задачи на функции следующим образом:
;
; 1) Ввод и вывод массивов оформить как подпрограммы.
; 2) Выполнение задания по варианту оформить как процедуру
; 3) Организовать вывод как исходного, так и сформированного массивов
; Указанные процедуры могут использовать данные напрямую (имитация процедур без параметров). Имитация работы с параметрами также допустима.
; Массив B из положительных элементов A.



format PE console
entry main

include 'win32a.inc'


section '.data' data readable writable
        inputVectorSize_str     db 'Input vector size: ', 0
        incorrectVectorSizeInput_str   db 'Incorrect vector size %d! Program finished!', 10, 0
        inputVectorElement_str    db 'Input {%d} element of vector: ', 0
        inputInteger_fmt     db '%d', 0
        outputResultVector_str      db 10,'Vector of %d positive numbers:', 10, 0
        outputVectorElement_fmt  db '{%d} element = %d', 10, 0

        i            dd ?
        j            dd 0
        current          dd ?
        currentStack     dd ?

        vector          rd 100
        vector_size     dd 0
        resultVector       rd 100
        resultVector_size  dd 0

section '.code' code readable executable

; Main procedures

; main - entry point of program
main:
        call inputVector
        call filterVector
        call outputVector
; finish - end point of program
finish:
        call [getch]

        push 0
        call [ExitProcess]

; Input vector procedures

; inputVector - input vector size + calling input elements
inputVector:
        push inputVectorSize_str
        call [printf]
        add esp, 4

        push vector_size
        push inputInteger_fmt
        call [scanf]
        add esp, 8

        mov eax, [vector_size]
        cmp eax, 0
        jg  inputVectorElements

        push [vector_size]
        push incorrectVectorSizeInput_str
        call [printf]
        push 0
        call finish
; inputVectorElements - input vector elements procedure
inputVectorElements:
        xor ecx, ecx
        mov ebx, vector
; inputElementsLoop - loop that inputs vector elements by one
inputElemetnsLoop:
        mov [current], ebx
        cmp ecx, [vector_size]
        jge endInputVector

        mov [i], ecx
        push ecx
        push inputVectorElement_str
        call [printf]
        add esp, 8

        push ebx
        push inputInteger_fmt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [current]
        add ebx, 4
        jmp inputElemetnsLoop
; endInputVector - end of input vector elements
endInputVector:
        ret

; Filter vector procedures

; filterector - start of searching positive numbers in vector
filterVector:
        xor ecx, ecx
        mov ebx, vector

        mov edx, resultVector

        mov [i], ecx
; filterVectorLooop - loop that finds positive elements of vector by one
filterVectorLoop:
        mov ecx, [i]
        cmp ecx, [vector_size]
        je endFilterVector

        cmp dword [ebx], 0
        jg  addPositiveToResultVector

        inc [i]
        add ebx, 4
        jmp filterVectorLoop
; addPositiveToResultVector - writes positive elements of given vector to result vector
addPositiveToResultVector:
        mov eax, [ebx]
        mov [edx], eax

        add edx, 4
        add ebx, 4

        inc [i]
        inc [j]

        jmp filterVectorLoop
; endFilterVector - ends filtering vector
endFilterVector:
        mov eax, [j]
        mov [resultVector_size], eax
        ret
; Output filtered vector procedures
; outputVector - start of output result vetor with size
outputVector:
        push [resultVector_size]
        push outputResultVector_str
        call [printf]
        add esp, 8

        mov [currentStack], esp
        xor ecx, ecx
        mov ebx, resultVector
; outputVectorLooop - loop that output elements of result vector by one
outputVectorLoop:
        mov [current], ebx
        cmp ecx, [resultVector_size]
        je endOutputVector

        mov [i], ecx

        push dword [ebx]
        push ecx
        push outputVectorElement_fmt
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [current]
        add ebx, 4
        jmp outputVectorLoop
; endOutputVector - ends output result vector
endOutputVector:
        mov esp, [currentStack]
        ret

; includes                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'
