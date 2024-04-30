---------------
-- JOIN
---------------

-- employees와 departments
DESC employees;
DESC departments;

SELECT * FROM employees;    --  107
SELECT * FROM departments;  --  27

SELECT * 
FROM employees, departments;
-- 카티전 프로덕트

SELECT *
FROM employees, departments
WHERE employees.department_id = departments.department_id;  --  106
-- INNER JOIN, EQUI-JOIN


-- alias를 이용한 원하는 필드의 Projection
------------------------------
-- Simple Join or Equi-Join
------------------------------

SELECT first_name,
    emp.department_id,
    dept.department_id,
    department_name
FROM employees emp, departments dept
WHERE emp.department_id = dept.department_id;   --  106명, department_id 가 null인 직원은 JOIN에서 배제

SELECT * FROM employees
WHERE department_id IS NULL;    --  178 Kimberly

SELECT emp.first_name,
    dept.department_name
FROM employees emp JOIN departments dept USING (department_id);

---------------
-- Theta Join
---------------

-- Join 조건이 = 아닌 다른 조건들

-- 급여가 직군 평균 급여보나 낮은 직원들 목록
SELECT 
    emp.employee_id,
    emp.first_name,
    emp.salary,
    emp.job_id,
    j.job_id,
    j.job_title
FROM 
    employees emp
    JOIN jobs j
        ON emp.job_id = j.job_id
WHERE emp.salary <= (j.min_salary + j.max_salary) / 2;



--------------------
-- OUTER JOIN
--------------------

-- 조건을 만족하는 짝이 없는 튜플도 NULL을 포함해서 결과 출력 참여시키는 방법
-- 모든 결과를 표현한 테이블이 어느 쪽에 위치하는가에 따라 LEFT, RIGHT, FULL OUTER JOIN으로 구분
-- ORACLE SQL의 경우 NULL이 출력되는 쪽에 (+)를 붙인다.

--------------------
-- LEFT OUTER JOIN
--------------------
-- LEFT 테이블의 모든 레코드가 출력 결과에 참여

-- Oracle SQL
SELECT emp.first_name,
    emp.department_id,
    dept.department_id,
    department_name
FROM employees emp, departments dept
WHERE emp.department_id = dept.department_id (+);   -- null이 포함된 테이블 쪽에 (+) 표기


SELECT * FROM employees WHERE department_id IS NULL;    -- Kimberly -> 부서에 소속되지 않음


-- ANSI SQL - 명시적으로 JOIN 방법을 정한다
SELECT first_name,
    emp.department_id,
    dept.department_id,
    department_name
FROM employees emp 
    LEFT OUTER JOIN departments dept
        ON emp.department_id = dept.department_id;


--------------------
-- RIGHT OUTER JOIN
--------------------
-- RIGHT 테이블의 모든 레코드가 출력 결과에 참여

-- Oracle SQL
SELECT first_name,
    emp.department_id,
    dept.department_id,
    department_name
FROM employees emp, departments dept
WHERE emp.department_id (+) = dept.department_id;   --  departments 테이블 레코드 전부를 출력에 참여 -- 122 레코드

-- ANSI SQL
SELECT first_name,
    emp.department_id,
    dept.department_id,
    department_name
FROM employees emp 
    RIGHT OUTER JOIN departments dept
        ON emp.department_id = dept.department_id;
        
--------------------
-- FULL OUTER JOIN
--------------------

-- JOIN에 참여한 모든 테이블의 모든 레코드를 출력에 참여
-- 짝이 없는 레코드들은 null을 포함해서 출력에 참여

-- ANSI SQL
SELECT first_name,
    emp.department_id,
    dept.department_id,
    department_name
FROM employees emp
    FULL OUTER JOIN departments dept
        ON emp.department_id = dept.department_id;



--------------------
-- NATURAL JOIN
--------------------

--  조인할 테이블에 같은 이름의 컬럼이 있을 경우, 해당 컬럼을 기준으로 JOIN
--  실제 본인이 JOIN 할 조건과 일치하는지 확인 
SELECT * FROM employees emp NATURAL JOIN departments dept;

--SELECT * FROM employees emp JOIN departments dept ON emp.department_id = dept.department_id;
--SELECT * FROM employees emp JOIN departments dept ON emp.manager_id = dept.manager_id;
SELECT * FROM employees emp JOIN departments dept ON emp.manager_id = dept.manager_id AND emp.department_id = dept.department_id;


--------------------
-- SELF JOIN
--------------------

-- 자기 자신과 JOIN
-- 자신을 두번 호출 -> 별칭을 반드시 부여해야 할 필요가 있는 조인

SELECT * FROM employees;    -- 107

SELECT
    emp.employee_id,
    emp.first_name,
    emp.manager_id,
    man.first_name
--FROM employees emp JOIN employees man
--        ON emp.manager_id = man.employee_id;
FROM employees emp, employees man
WHERE emp.manager_id = man.employee_id; --  106

-- 해봅시다. Steven (매니저 없는 분)까지 포함해서 출력



-------------------------
-- Group Aggregation 
-------------------------

-- 집계 : 여러 행으로부터 데이터를 수집, 하나의 행으로 반환

-- COUNT : 갯수 세기 함수
-- employees 테이블의 총 레코드 갯수?
SELECT COUNT(*) FROM employees; --  107

-- *로 카운트 하면 모든 행의 수를 반환
-- 특정 컬럼 내에 null 값이 포함되어 있는지의 여부는 중요하지 않음

-- commission을 받는 직원의 수를 알고 싶을 경우
-- commission_pct가 null인 경우를 제외하고 싶을 경우
SELECT COUNT(commission_pct) FROM employees;    --  35
-- 컬럼 내에 포함된 null 데이터를 카운트하지 않음

-- 위 쿼리는 아래 쿼리와 같다
SELECT COUNT(*) FROM employees
WHERE commission_pct IS NOT NULL;

-- SUM : 합계 함수
-- 모든 사원의 급여의 합계
SELECT SUM(salary) FROM employees;

-- AVG : 평균 함수
-- 사원들의 평균 급여?
SELECT AVG(salary) FROM employees;

-- 사원들이 받는 커미션 비율의 평균을 얼마인가?
SELECT AVG(commission_pct) FROM employees;  --  22%
-- AVG 함수는 null 값이 포함되어 있을 경우 그 값을 집계 수치에서 제외
-- null 값을 집계 결과에 포함시킬지의 여부는 정책으로 결정하고 수행해야 한다
SELECT AVG(NVL(commission_pct, 0)) FROM employees;  --  7%

-- min / max : 최솟값 / 최댓값
-- avg / median : 산술평균 / 중앙값
SELECT
    MIN(salary) 최소급여,
    MAX(salary) 최대급여,
    AVG(salary) 평균급여,
    MEDIAN(salary) 급여중앙값
FROM employees;


-- 흔히 범하는 오류
-- 부서별로 평균 급여를 구하고자 할 때
SELECT department_id, AVG(salary)
FROM employees;

SELECT department_id FROM employees;    --  여러 개의 레코드
SELECT AVG(salary) FROM employees;      --  단일 레코드


SELECT department_id, salary
FROM employees
ORDER BY department_id;

-- GROUP BY
SELECT department_id, ROUND(AVG(salary), 2)
FROM employees
GROUP BY department_id  --  집계를 위해 특정 컬럼을 기준으로 그룹핑
ORDER BY department_id;


-- 부서별 평균 급여에 부서명도 포함하여 출력
SELECT emp.department_id, dept.department_name, ROUND(AVG(emp.salary), 2)
FROM employees emp
    JOIN departments dept
        ON emp.department_id = dept.department_id
GROUP BY emp.department_id, dept.department_name
ORDER BY emp.department_id;

-- GROUP BY 절 이후에는 GROUP BY에 참여한 컬럼과 집계 함수만 남는다.


-- 평균 급여가 7000 이상인 부서만 출력
SELECT
    department_id, AVG(salary)
FROM employees
WHERE AVG(salary) >= 7000   --  아직 집계 함수 시행되지 않은 상태 -> 집계 함수의 비교 불가
GROUP BY department_id
ORDER BY department_id;


-- 집계 함수 이후의 조건 비교 HAVING 절을 이용
SELECT 
    department_id, AVG(salary)
FROM employees
GROUP BY department_id
    HAVING AVG(salary) >= 7000  --   GROUP BY aggregation의 조건 필터링
ORDER BY department_id;


-- ROLLUP
-- GROUP BY 절과 함께 사용
-- 그룹지어진 결과에 대한 좀 더 상세한 요약을 제공하는 기능 수행
-- 일종의 ITEM TOTAL
SELECT
    department_id,
    job_id,
    SUM(salary)
FROM employees
GROUP BY ROLLUP(department_id, job_id)
ORDER BY department_id;



-- CUBE
-- CrossTab에 대한 Summary를 함께 추출하는 함수
-- Rollup 함수에 의해 출력되는 Item Total 값과 함께
-- Column Total 값을 함께 추출
SELECT 
    department_id,
    job_id,
    SUM(salary)
FROM employees
GROUP BY CUBE(department_id, job_id)
ORDER BY department_id;



-------------------
-- SUBQUERY
-------------------

-- 모든 직원 급여의 중앙값보다 많은 급여를 받는 사원의 목록

-- 1) 직원 급여의 중앙값?
-- 2) 1)번의 결과보다 많은 급여를 받는 직원의 목록?

-- 1) 직원 급여의 중앙값
SELECT MEDIAN(salary) FROM employees;   -- 6200
-- 2) 1)번의 결과(6200)보다 많은 급여를 받는 직원의 목록
SELECT first_name, salary 
FROM employees
WHERE salary >= 6200;

-- 1), 2) 쿼리 합치기
SELECT first_name, salary
FROM employees
WHERE salary >= (SELECT MEDIAN(salary) FROM employees)
ORDER BY salary DESC;

-- Susan보다 늦게 입사한 사원의 정보
-- 1) Susan의 입사일
-- 2) 1)번의 결과보다 늦게 입사한 사원의 정보를 추출

-- 1) Susan의 입사일
SELECT hire_date FROM employees
WHERE first_name = 'Susan';     --  12/06/07

-- 2) 1)의 결과보다 늦게 입사한 직원의 목록을 추출하는 쿼리
SELECT first_name, hire_date
FROM employees 
WHERE hire_date > '12/06/07';

-- 두 쿼리 합치기
SELECT first_name, hire_date
FROM employees
WHERE hire_date > (SELECT hire_date FROM employees WHERE first_name='Susan');


-- 연습문제
-- 급여를 모든 직원 급여의 중앙값보다 많이 받으면서 수잔보다 늦게 입사한 직원의 목록
-- 조건 1. 급여를 모든 직원 급여의 중앙값보다 많이 받는 조건
-- 조건 2. 수잔의 입사일보다 hire_date 늦게 입사한 조건
SELECT first_name, salary, hire_date
FROM employees
WHERE salary > (SELECT MEDIAN(salary) FROM employees) AND       -- 조건 1
    hire_date > (SELECT hire_date FROM employees WHERE first_name = 'Susan')
ORDER BY hire_date ASC, salary DESC;


-- 다중행 서브쿼리
-- 서브쿼리 결과가 둘 이상의 레코드일때 단일행 비교연산자는 사용할 수 없다
-- 집합 연산에 관련된 IN, ANY, ALL, EXISTS 등을 사용해야 한다

-- 직원들 중,
-- 110번 부서 사람들이 받는 급여와 같은 급여를 받는 직원들의 목록

-- 1. 110 부서 사람들은 얼마의 급여를 받는 가?
SELECT salary FROM employees
WHERE department_id = 110;  --  12008, 8300

-- 2. 직원 중, 급여가 12008, 8300인 직원의 목록
SELECT first_name, salary
FROM employees
WHERE salary IN (12008, 8300);

-- 두 쿼리를 하나로 합쳐보면5265
SELECT first_name, salary
FROM employees
WHERE salary IN (SELECT salary 
                    FROM employees
                    WHERE department_id = 110);

-- 110번 부서 사람들이 받는 급여보다 많은 급여를 받는 직원들의 목록
-- 1. 110번 부서 사람들이 받는 급여?
SELECT salary FROM employees
WHERE department_id = 110;

-- 2. 1번 쿼리 전체보다 많은 급여를 받는 직원들의 목록
SELECT first_name, salary
FROM employees
WHERE salary > ALL (12008, 8300);

-- 110번 부서 사람들이 받는 급여 중 하나보다 많은 급여를 받는 직원들의 목록
-- 1. 110번 부서 사람들이 받는 급여?
SELECT salary FROM employees
WHERE department_id = 110;

-- 2. 1번 쿼리 중 하나보다 많은 급여를 받는 직원들의 목록
SELECT first_name, salary
FROM employees
WHERE salary > ANY (12008, 8300)
ORDER BY salary DESC;


-- Correlated Query : 연관 쿼리
-- 바깥쪽 쿼리(Outer Query)와 안쪽 쿼리(Inner Query)가 서로 연관된 쿼리
SELECT
    first_name,
    salary,
    department_id
FROM employees outer 
WHERE salary > (SELECT AVG(salary)
                FROM employees
                WHERE department_id = outer.department_id);
                
-- 외부 쿼리: 급여를 특정 값보다 많이 받는 직원의 이름, 급여, 부서 아이디

-- 내부 쿼리: 특정 부서에 소속된 직원의 평균 급여

-- 자신이 속한 부서의 평균 급여보다 많이 받는 직원의 목록을 구하라는 의미
-- 외부 쿼리가 내부 쿼리에 영향을 미치고
-- 내부 쿼리 결과가 다시 외부 쿼리에 영향을 미침


-- 서브쿼리 연습
-- 각 부서별로 최고 급여를 받는 사원의 목록 (조건절에서 서브쿼리 활용)
-- 1. 각 부서의 최고 급여를 출력하는 쿼리
SELECT department_id, MAX(salary)
FROM employees
GROUP BY department_id;

-- 2. 1번 쿼리에서 나온 department_id, max(salary)값을 이용해서 외부 쿼리를 작성
SELECT department_id, employee_id, first_name, salary
FROM employees
WHERE (department_id, salary) IN 
    (SELECT department_id, MAX(salary)
        FROM employees
        GROUP BY department_id)
ORDER BY department_id;

-- 각 부서별로 최고 급여를 받는 사원의 목록 (서브쿼리를 이용, 임시 테이블 생성 -> 테이블 조인 결과 뽑기)
-- 1. 각 부서의 최고 급여를 출력하는 쿼리를 생성
SELECT department_id, MAX(salary)
FROM employees
GROUP BY department_id;

-- 2. 1번 쿼리에서 생성한 임시 테이블과 외부 쿼리를 조인하는 쿼리
SELECT emp.department_id, emp.employee_id, emp.first_name, emp.salary
FROM employees emp, (SELECT department_id, MAX(salary) salary
                        FROM employees
                        GROUP BY department_id) sal
WHERE emp.department_id = sal.department_id     --  JOIN 조건
    AND emp.salary = sal.salary
ORDER BY emp.department_id;



-- TOP-K 쿼리 
-- 질의의 결과로 부여된 가상 컬럼 rownum 값을 사용해서 쿼리순서 반환
-- rownum 값을 활용 상위 k개의 값을 얻어오는 쿼리

-- 2017년 입사자 중에서 연봉 순위 5위까지 출력

-- 1. 2017년 입사자는 누구?
SELECT * FROM employees
WHERE hire_date LIKE '17%'
ORDER BY salary DESC;

-- 2. 1번 쿼리를 활용, rownum 값까지 확인, rownum <= 5이하인 레코들 -> 상위 5개의 레코드
SELECT rownum, first_name, salary
FROM (SELECT * FROM employees
        WHERE hire_date LIKE '17%'
        ORDER BY salary DESC)
WHERE rownum <= 5;  --  상위5개



-- 집합 연산

SELECT first_name, salary, hire_date FROM employees WHERE hire_date < '15/01/01';   --  15/01/01 이전 입사자 (24)
SELECT first_name, salary, hire_date FROM employees WHERE salary > 12000;           --  12000 초과 급여 받는 직원 목록    (8)

-- 합집합
SELECT first_name, salary, hire_date FROM employees WHERE hire_date < '15/01/01'
UNION       -- 중복 레코드는 한개로 취급
SELECT first_name, salary, hire_date FROM employees WHERE salary > 12000;           --  26

SELECT first_name, salary, hire_date FROM employees WHERE hire_date < '15/01/01'
UNION ALL   -- 중복 레코드는 별개로 취급               
SELECT first_name, salary, hire_date FROM employees WHERE salary > 12000;           -- 32 

SELECT first_name, salary, hire_date FROM employees WHERE hire_date < '15/01/01'
INTERSECT   -- 교집합  -> INNER JOIN과 비슷               
SELECT first_name, salary, hire_date FROM employees WHERE salary > 12000;           -- 6

SELECT first_name, salary, hire_date FROM employees WHERE hire_date < '15/01/01'
MINUS   -- 차집합
SELECT first_name, salary, hire_date FROM employees WHERE salary > 12000;           -- 18

-- RANK 관련 함수 (Oracle 특화 함수)
SELECT salary, first_name,  
    RANK() OVER (ORDER BY salary DESC) as rank, --  일반적인 순위
    DENSE_RANK() OVER (ORDER BY salary DESC) as dense_link,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as row_number, --  정렬 했을때의 실제 행번호
    rownum                                      -- 쿼리 결과의 행번호 (가상 컬럼)
FROM employees;


-- Hierarchical Query (Oracle 특화)
-- 트리 형태 구조 표현
-- level 가상 컬럼 활용 쿼리
SELECT level, employee_id, first_name, manager_id
FROM employees
START WITH manager_id IS NULL               -- 트리 형태의 root가 되는 조건 명시
CONNECT BY PRIOR employee_id = manager_id   -- 상위 레벨과의 연결 조건 (가지치기 조건)
ORDER BY level;                             --  트리의 깊이를 나타내는 Oracle 가상 컬럼