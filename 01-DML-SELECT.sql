-- SQL 문장의 주석
-- 마지막에 세미콜론(;)으로 끝난다 
-- 키워드들 테이블병, 컬럼 등은 대소문자 구분하지 않는다
-- 실제 데이터의 경우 대소문자를 구분

-- 테이블 구조 확인 (DESCRIBE)
DESCRIBE employees;
--describe EMPLOYEES;
Describe Departments;
Describe Locations;

-- DML(Data Manipulation Language)
-- SELECT

-- * : 테이블 내의 모든 컬럼 Projection, 테이블 설계시에 정의한 순서대로
SELECT * FROM employees;

-- 특정 컬럼만 Projection하고자 하면 열 목록을 명시

-- employees 테이블의 first_name, phone_number, hire_date, salary 만 보고 싶다면
SELECT first_name, phone_number, hire_date, salary FROM employees;

-- 사원의 이름, 성, 급여, 전화번호, 입사일 정보 출력
SELECT first_name,
    last_name,
    salary,
    phone_number,
    hire_date
FROM employees;

-- 사원 정보로부터 사번, 이름, 성 정보 출력
SELECT employee_id, first_name, last_name FROM employees;

-- 산술연산 : 기본적인 산술연산을 수행할 수 있다.
-- 특정 테이블의 값이 아닌 시스템으로부터 데이터를 받아오고자 할때 : dual (가상테이블)
SELECT 3.14159 * 10 * 10 FROM dual;

-- NULL
-- 이름, 급여, 커미션 비율을 출력
SELECT first_name, salary, commission_pct
FROM employees;

-- 이름, 커미션까지 포함한 급여를 출력
SELECT first_name, salary, commission_pct, 
        salary + salary * commission_pct
FROM employees;
-- NULL이 포함된 연산식의 결과는 NULL
-- NULL을 처리하기 위한 함수 NVL이 필요
-- NVL(표현식1, 표현식1이 널일 경우의 대체값)

-- NVL활용 대체값 계산
SELECT first_name, salary, commission_pct,
        salary + salary * NVL(commission_pct, 0)
FROM employees;

-- NULL은 0이나 "" 와 다르게 빈 값이다.
-- NULL은 산술연산 결과, 통계 결과를 왜곡 -> NULL에 대한 처리는 철저하게!

-- 별칭 Alias
-- Projection 단계에서 출력용으로 표시되는 임시 컬럼 제목

-- 컬럼명 뒤에 별칭
-- 컬럼명 뒤에 as 별칭
-- 표시명에 특수문자 포함된 경우 ""로 묶어서 부여

-- 직원 아이디, 이름, 급여 출력
--  직원 아이디는 empNo, 이름은 f-name, 급여는 월 급으로 표시
SELECT employee_id empNo    -- 컬럼명 뒤에 별칭
    , first_name as "f-name"    -- as 별칭, 특수문자 포함되면 ""로 묶음
    , salary "급 여"              -- 공백문자도 특수문자
FROM employees;

-- 직원 이름(first_name last_name 합쳐서 출력) name
-- 급여(커미션이 포함된 급여), 급여 * 12 연봉 별칭으로 표기
SELECT first_name || ' ' || last_name "Full Name",  -- 문자열 합치기는 ||를 사용
    salary + salary * nvl(commission_pct, 0) "급여(커미션포함)",
    salary * 12 연봉
FROM employees;

-- 연습: Alias 붙이기 (employees 테이블)
-- 이름: first_name last_name
-- 입사일: hire_date
-- 전화번호: phone_number
-- 급여: salary
-- 연봉: salary * 12
SELECT
    first_name || ' ' || last_name 이름,
    hire_date 입사일,
    phone_number 전화번호,
    salary 급여,
    salary * 12 연봉
FROM employees;

----------
-- WHERE
----------
-- 특정 조건을 기준으로 레코드를 선택 (SELECTION)

-- 비교연산 : =, <>, >, >=, <, <=

-- 사원들 중, 급여가 15000 이상인 직원의 이름과 급여
SELECT 
    first_name, salary
FROM
    employees
WHERE 
    salary >= 15000;

-- 입사일이 17/01/01 이후인 직원들의 이름과 입사일
SELECT
    first_name, hire_date
FROM employees
WHERE hire_date >= '17/01/01';

-- 급여가 4000 이하이거나, 17000 이상인 사원의 이름과 급여
SELECT first_name, salary
FROM employees
WHERE salary <= 4000    --  첫번째 조건
    OR                  -- 논리합
    salary >= 17000;    --  두번째 조건 

-- 급여가 14000 이상이고, 17000이하인 사원의 이름과 급여
SELECT first_name, salary
FROM employees
WHERE salary >= 14000 AND
    salary <= 17000;
    
-- BETWEEN : 범위 비교
SELECT first_name, salary
FROM employees
WHERE salary BETWEEN 14000 AND 17000;

-- NULL 체크 =, <> 사용하면 안됨
-- IS NULL, IS NOT NULL

-- commission을 받지 않는 사람들 (-> commission_pct 가 null인 레코드)
SELECT first_name, commission_pct
FROM employees
WHERE commission_pct IS NULL;   --  NULL 체크

-- commission을 받는 사람들 (-> commission_pct가 널이 아닌 레코드) IS NOT NULL
SELECT first_name, commission_pct
FROM employees
WHERE commission_pct IS NOT NULL;   --  NULL이 아님 체크

-- 사원들 중 10, 20, 40번 부서에서 근무하는 직원들의 이름과 부서 아이디
SELECT first_name, department_id
FROM employees
WHERE department_id = 10 OR
    department_id = 20 OR
    department_id = 40;
    
-- IN 연산자 : 특정 집합의 요소와 비교
SELECT first_name, department_id
FROM employees
WHERE department_id IN (10, 20, 40);

---------------
-- Like 연산
---------------
-- 와일드카드(%, _)를 이용한 부분 문자열 매핑
-- % : 0개 이상의 정해지지 않은 문자열
-- _ : 1개의 정해지지 않은 문자

-- 이름에 am을 포함하고 있는 사원의 이름과 급여 출력
SELECT first_name, salary
FROM employees
WHERE LOWER(first_name) LIKE '%am%';

-- 이름의 두 번째 글자가 a인 사원의 이름과 급여
SELECT first_name, salary
FROM employees
WHERE LOWER(first_name) LIKE '_a%';

-- 이름의 네번째 글자가 a인 사원의 이름과 급여
SELECT first_name, salary
FROM employees
WHERE first_name LIKE '___a%';

-- 이름이 네글자인 사원들 중에서 두번째 글자가 a인 사원의 이름과 급여
SELECT first_name, salary
FROM employees
WHERE first_name LIKE '_a__';

-- 쿼리 연습
-- 부서 ID가 90인 사원 중, 급여가 20000 이상인 사원 이름, department_id, 급여
SELECT first_name, department_id, salary
FROM employees
WHERE department_id = 90    --  조건1: 부서가 90
        AND
    salary >= 20000;        --  조건2: 급여가 20000 이상

-- 입사일이 11/01/01 ~ 17/12/31 구간에 있는 사원의 목록 이름, 입사일
--  1. 비교 조합
SELECT first_name, hire_date
FROM employees
WHERE hire_date >= '11/01/01'   -- 조건1
        AND
    hire_date <= '17/12/31';    -- 조건2

--  2. BETWEEN 연산자 활용
SELECT first_name, hire_date
FROM employees
WHERE hire_date BETWEEN '11/01/01' AND '17/12/31';

-- manager_id가 100, 120, 147인 사원의 명단. 사원 id, 이름, manager_id
-- 1. 비교연산자+논리연산자의 조합
SELECT employee_id, first_name, manager_id
FROM employees
WHERE manager_id = 100 OR   --   조건1: 100번 매니저
    manager_id = 120 OR     --  조건2: 120번 매니저
    manager_id = 147;        --  조건3: 147번 매니저
-- 2. IN 연산자 이용
SELECT employee_id, first_name, manager_id
FROM employees
WHERE manager_id IN (100, 120, 147);
--  두 쿼리를 비교

--------------
-- ORDER BY
--------------

-- 특정 컬럼명, 연산식, 별칭, 컬럼 순서를 기준으로 레코드 정렬
-- ASC(오름차순: default), DESC(내림차순)
-- 여러개의 컬럼에 적용할 수 있고 ,로 구분

-- 부서 번호의 오름차순으로 정렬, 부서번호, 급여, 이름 출력
SELECT department_id, salary, first_name
FROM employees
ORDER By department_id ASC;    --  ASC 생략 가능

-- 급여가 10000 이상인 직원 대상, 급여의 내림차순으로 출력. 이름, 급여
SELECT first_name, salary
FROM employees
WHERE salary >= 10000
ORDER BY salary DESC;   --  급여 내림차순

-- 부서 번호, 급여, 이름순으로 출력. 정렬 기준 부서번호 오름차순, 급여 내림차순
SELECT department_id, salary, first_name
FROM employees
ORDER BY department_id ASC,
        salary DESC;

-- 정렬 기준을 어떻게 세우느냐에 따라 성능, 출력 결과 영향을 미칠 수 있다

---------------
-- 단일행 함수
---------------

-- 단일 레코드를 기준으로 특정 컬럼에 값에 적용되는 함수

-- 문자열 단일행 함수
SELECT first_name, last_name,
    CONCAT(first_name, CONCAT(' ', last_name)), -- 문자열 연결 함수
    first_name || ' ' || last_name, -- 문자열 연결 연산
    INITCAP(first_name || ' ' || last_name)     -- 각 단어의 첫 글자 대문자
FROM employees;

SELECT first_name, last_name,
    LOWER(first_name),  --  모두 소문자
    UPPER(first_name),  --  모두 대문자로
    LPAD(first_name, 20, '*'),  --  왼쪽 빈 자리 채움
    RPAD(first_name, 20, '*')   --  오른쪽 빈 자리 채움
FROM employees;

SELECT '   Oracle    ',
    '*****Database*****',
    LTRIM('   Oracle    '), -- 왼쪽의 빈 공간 삭제
    RTRIM('   Oracle    '),  --  오른쪽의 빈 공간 삭제
    TRIM('*' FROM '*****Database*****'),    --  앞뒤의 잡음 문자 제거
    SUBSTR('Oracle Database', 8, 4),     -- 부분 문자열 
    SUBSTR('Oracle Database', -8, 4),    -- 역인덱스 이용 부분 문자열
    LENGTH('Oracle Database')           -- 문자열 길이
FROM dual;

-- 수치형 단일행 함수

SELECT 3.14159,
    ABS(-3.14),  --  절대값
    CEIL(3.14), -- 올림
    FLOOR(3.14), -- 버림
    ROUND(3.5), -- 반올림
    ROUND(3.14159, 3),   -- 소수점 세째 자리까지 반올림 (네째 자리에서 반올림)
    TRUNC(3.5),  --  버림
    TRUNC(3.14159, 3),   -- 소수점 네째 자리에서 버림
    SIGN(-3.14159),     --  부호 (-1: 음수, 0:0, 1: 양수)
    MOD(7, 3),  --  7을 3으로 나눈 나머지
    POWER(2, 4) --  2의 4제곱
FROM dual;

---------------
-- DATA FORMAT
---------------

-- 현재 세션 정보 확인
SELECT * 
FROM nls_session_parameters;

-- 현재 날짜 포맷이 어떻게 되는가
-- 딕셔너리를 확인
SELECT value FROM nls_session_parameters
WHERE parameter='NLS_DATE_FORMAT';

-- 현재 날짜 : SYSDATE
SELECT sysdate FROM dual;   -- 가상 테이블 dual로부터 받아오므로 1개의 레코드

SELECT sysdate FROM employees;  --  employees 테이블로부터 받아오므로 employees 테이블 레코드의 갯수만큼

-- 날짜 관련 단일행 함수
SELECT
    sysdate,
    ADD_MONTHS(sysdate, 2),  --  2개월이 지난 후의 날짜
    LAST_DAY(sysdate),        -- 현재 달의 마지막 날
    MONTHS_BETWEEN('12/09/24', sysdate), --  두 날짜 사이의 개월 차
    NEXT_DAY(sysdate, 7),      --      1:일 ~ 7:토
    NEXT_DAY(sysdate, '일'),     --  NLS_DATE_LANGUAGE의 설정에 따름
    ROUND(sysdate, 'MONTH'),     --  MONTH를 기준으로 반올림
    TRUNC(sysdate, 'MONTH')  --  MONTH를 기준으로 버림
FROM dual;

SELECT first_name, hire_date,
    ROUND(MONTHS_BETWEEN(sysdate, hire_date)) as 근속월수
FROM employees;

---------------
-- 변환함수
---------------

-- TO_NUMBER(s, fmt) : 문자열 -> 숫자
-- TO_DATE(s, fmt) : 문자열 -> 날짜
-- TO_CHAR(o, fmt) : 숫자, 날짜 -> 문자열 

-- TO_CHAR

SELECT first_name,
    TO_CHAR(hire_date, 'YYYY-MM-DD')    --   년-월-일
FROM employees;

-- 현재 시간을 년-월-일 시:분:초로 표기
SELECT sysdate,
    TO_CHAR(sysdate, 'YYYY-MM-DD HH:MI:SS')
FROM dual;

SELECT
    TO_CHAR(3000000, 'L999,999,999.99')
FROM dual;

-- 모든 직원의 이름과 연봉 정보를 표시
SELECT
    first_name, salary, commission_pct, 
    TO_CHAR((salary + salary * nvl(commission_pct, 0))*12, '$999,999.99') 연봉
FROM employees;

-- 문자 -> 숫자 : TO_NUMBER
SELECT '$57,600',
    TO_NUMBER('$57,600', '$999,999') / 12 월급
FROM dual;

-- 문자열 -> 날짜
SELECT '2012-09-24 13:48:00',
    TO_DATE('2012-09-24 13:48:00', 'YYYY-MM-DD HH24:MI:SS')
FROM dual;

-- 날짜 연산
-- Date +/- Number : 특정 날수를 더하거나 뺄 수 있다.
-- Date - Date : 두 날짜의 경과 일수
-- Date + Number / 24 : 특정 시간이 지난 후의 날짜 
SELECT
    sysdate,
    sysdate + 1, sysdate - 1,
    sysdate - TO_DATE('20120924'), 
    sysdate + 48 / 24   --  48 시간이 지난 후의 날짜
FROM dual;


-- nvl function
SELECT first_name, 
    salary, 
    nvl(salary * commission_pct, 0) commission  -- nvl(표현식, 대체값)
FROM employees;

-- nvl2 function
SELECT first_name,
    salary,
    nvl2(commission_pct, salary * commission_pct, 0) commission -- nvl2(조건문, null이 아닐때의 값, null일 때의 값)
FROM employees;

-- CASE function
-- 보너스를 지급하기로 했습니다.
--  AD관련 직종에게는 20%, SA관련 직원에게는 10%, IT관련 직원들에게는 8%, 나머지에게는 5%
SELECT first_name, job_id, salary,
    SUBSTR(job_id, 1, 2),
    CASE SUBSTR(job_id, 1, 2) WHEN 'AD' THEN salary * 0.2
                              WHEN 'SA' THEN salary * 0.1 
                              WHEN 'IT' THEN salary * 0.08
                              ELSE salary * 0.05
    END bonus
FROM employees;

-- DECODE 함수
SELECT first_name, job_id, salary,
    SUBSTR(job_id, 1, 2),
    DECODE(SUBSTR(job_id, 1, 2),    --  비교할 값
                        'AD', salary * 0.2,
                        'SA', salary * 0.1,
                        'IT', salary * 0.08,
                        salary * 0.05) bonus
FROM employees;

-- 연습문제
-- 직원의 이름, 부서, 팀을 출력
-- 팀은 부서 ID로 결정
-- 10 ~ 30 : A-GROUP
-- 40 ~ 50 : B-GROUP
-- 60 ~ 100 : C-GROUP
-- 나머지 부서 : REMAINDER
SELECT first_name, department_id,
    CASE WHEN department_id <= 30 THEN 'A-GROUP'
        WHEN department_id <= 50 THEN 'B-GROUP'
        WHEN department_id <= 100 THEN 'C-GROUP'
        ELSE 'REMAINDER'
    END team
FROM employees;