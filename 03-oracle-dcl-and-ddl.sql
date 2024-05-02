--------------------
-- DCL and DDL
--------------------
-- 사용자 생성
-- CREATE USER 권한이 있어야 함
-- system 계정으로 수행
--connect system/manager

-- himedia라는 이름의 계정을 만들고 비밀번호 himedia로 설정
CREATE USER himedia IDENTIFIED BY himedia;

-- Oracle 18버전부터 Container Database 개념 도입
-- 계정 생성 방법1. 사용자 계정 C##
CREATE USER C##HIMEDIA IDENTIFIED BY himedia;

-- 비밀번호 변경 : ALTER USER 
ALTER USER C##HIMEDIA IDENTIFIED BY new_password;
-- 계정 삭제 : DROP USER 
DROP USER C##HIMEDIA CASCADE;   -- CASCADE : 폭포수 or 연결된 것 의미

-- 계정 생성 방법 2. CD 기능 무력화
-- 연습 상태, 방법 2를 사용해서 사용자 생성 (추천하지는 않음)
ALTER SESSION SET "_ORACLE_SCRIPT" = true;
CREATE USER himedia IDENTIFIED BY himedia;

-- 아직 접속 불가
-- 데이터베이스 접속, 테이블 생성 데이터베이스 객체 작업을 수행 -> CONNECT, RESOURCE ROLE
GRANT CONNECT, RESOURCE TO himedia;  
-- cmd : sqlplus himedia/himedia
-- CREATE TABLE test(a NUMBER);
-- DESC test;  --  테이블 test의 구조 보기

-- himedia 사용자로 진행
-- 데이터 추가
DESCRIBE test;
INSERT INTO test VALUES (2024);
-- USERS 테이블스페이스에 대한 권한이 없다
-- 18이상
-- SYSTEM 계정으로 수행
ALTER USER himedia DEFAULT TABLESPACE USERS
    QUOTA unlimited on USERS;   -- tablespace 권한 부여
-- himedia로 복귀
INSERT INTO test VALUES (2024);
SELECT * FROM test;

SELECT * FROM USER_USERS;   --  현재 로그인한 사용자 정보(나)
SELECT * FROM ALL_USERS;    --  모든 사용자 정보
-- DBA 전용 (sysdba로 로그인 해야 확인 가능)
-- cmd : sqlplus sys/oracle as sysdba   -> sysdba로 접속 가능
SELECT * FROM DBA_USERS;

-- 시나리오: HR 스키마의 employees 테이블 조회 권한을 himedia에게 부여하고자 한다
-- HR 스키마의 owner -> HR
-- HR로 접속
GRANT select ON employees To himedia;

-- himedia 권한
SELECT * FROM hr.employees; --  hr.employees에 select 할 수 있는 권한
SELECT * FROM hr.departments;   -- hr.departments에 대한 권한은 없다.

-- 현재 사용자에게 부여된 ROLE의 확인

---------------
-- DDL
---------------

-- 스키마 내의 모든 테이블을 확인
SELECT * FROM tabs; --  tabs : 테이블 정보 DICTIONARY

--  테이블 생성 : CREATE TABLE
CREATE TABLE book (
    book_id NUMBER(5),
    title VARCHAR2(50),
    author VARCHAR2(10),
    pub_date DATE DEFAULT SYSDATE
);

-- 테이블 정보 확인
DESC book;


--  Subquery를 이용한 테이블 생성
SELECT * FROM hr.employees;

-- HR.employees 테이블에서 job_id가 IT_ 관련된 직원의 목록으로 새테이블을 생성
SELECT * FROM hr.employees WHERE job_id LIKE 'IT_%';

CREATE TABLE emp_it AS (
    SELECT * FROM hr.employees WHERE job_id LIKE 'IT_%'
);
-- NOT NULL 제약 조건만 물려받음

SELECT * FROM tabs;

DESC EMP_IT;

-- 테이블 삭제
DROP TABLE emp_it;

SELECT * FROM tabs;

DESC book;