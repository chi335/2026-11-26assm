.386
.model flat, c
.stack 4096

; 라이브러리 자동 링크
includelib libcmt.lib
includelib legacy_stdio_definitions.lib
includelib ucrt.lib
includelib vcruntime.lib

; C 표준 라이브러리 함수 선언 (scanf 추가)
extrn printf:proc
extrn scanf:proc
extrn exit:proc

.data
    myArray   DWORD 5 DUP(0)               ; 사용자 입력을 저장할 5개짜리 비어있는 배열
    arrayLen  DWORD 5                      ; 배열 크기
    
    ; 입출력 포맷 문자열
    fmtPrompt DB "Enter integer %d: ", 0    ; 입력 안내 멘트
    fmtScan   DB "%d", 0                   ; scanf 포맷
    fmtSum    DB 0Ah, "Array Sum : %d", 0Ah, 0
    fmtAvg    DB "Array Avg : %d", 0Ah, 0

.code
main PROC
    ; --------------------------------------------------
    ; [Step 1] 사용자로부터 정수 5개 입력받기 (scanf)
    ; --------------------------------------------------
    MOV ESI, OFFSET myArray    ; ESI = 배열 시작 주소
    MOV EBX, 1                 ; EBX = 순서 카운터 (1부터 5까지)

InputLoop:
    ; 1) 안내 멘트 출력 ("Enter integer 1: ")
    PUSH EBX                   ; %d에 들어갈 숫자 (1, 2, 3...)
    PUSH OFFSET fmtPrompt      ; 포맷 문자열 주소
    CALL printf                ; printf(fmtPrompt, EBX)
    ADD ESP, 8                 ; 스택 정돈

    ; 2) 키보드 입력 받기 (scanf("%d", &myArray[i]))
    PUSH ESI                   ; 입력받은 값을 저장할 메모리 주소 (&myArray[i])
    PUSH OFFSET fmtScan        ; "%d" 포맷 주소
    CALL scanf                 ; scanf("%d", &myArray[i])
    ADD ESP, 8                 ; 스택 정돈

    ADD ESI, 4                 ; DWORD는 4바이트이므로 다음 입력 공간으로 이동
    INC EBX                    ; 카운터 1 증가
    CMP EBX, 5                 ; 5개 입력을 마쳤는지 비교
    JLE InputLoop              ; EBX <= 5 이면 반복

    ; --------------------------------------------------
    ; [Step 2] 배열의 합계(Sum) 구하기
    ; --------------------------------------------------
    MOV ECX, arrayLen          ; ECX = 루프 횟수 (5)
    MOV ESI, OFFSET myArray    ; ESI = 배열 시작 주소로 재설정
    XOR EAX, EAX               ; 누적 합계 EAX = 0 초기화

SumLoop:
    ADD EAX, [ESI]             ; 현재 입력된 원소 더하기
    ADD ESI, 4                 ; 다음 원소 주소로 이동
    LOOP SumLoop               ; ECX 1 차감 후 반복

    MOV EDI, EAX               ; 구해진 합계(EAX)를 EDI에 임시 보관

    ; --- 합계 출력 ---
    PUSH EDI                   ; 2번째 인자 (합계)
    PUSH OFFSET fmtSum         ; 1번째 인자 (포맷)
    CALL printf
    ADD ESP, 8

    ; --------------------------------------------------
    ; [Step 3] 배열의 평균(Average) 구하기
    ; --------------------------------------------------
    MOV EAX, EDI               ; 합계 값 복원
    XOR EDX, EDX               ; 나눗셈용 EDX = 0 초기화
    DIV arrayLen               ; EAX / 5 (몫은 EAX에 저장)

    ; --- 평균 출력 ---
    PUSH EAX                   ; 2번째 인자 (평균)
    PUSH OFFSET fmtAvg         ; 1번째 인자 (포맷)
    CALL printf
    ADD ESP, 8

    ; --------------------------------------------------
    ; [Step 4] 프로그램 종료
    ; --------------------------------------------------
    PUSH 0
    CALL exit
main ENDP
END main