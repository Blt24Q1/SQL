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
SELECT * FROM USER_ROLE_PRIVS;

-- CONNECT와 RESOURCE 역할은 어떤 권한으로 구성되어 있는가?
-- sysdba로 진행
-- cmd
-- sqlplus sys/oracle as sysdba
-- DESC role_sys_privs;
-- CONNECT롤에는 어떤 권한이 포함되어 있는가?
-- SELECT privilege FROM role_sys_privs WHERE role='CONNECT';
-- RESOURCE롤에는 어떤 권한이 포함되어 있는가?
-- SELECT privilege FROM role_sys_privs WHERE role='RESOURCE';

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

-- author 테이블 생성
CREATE TABLE author (
    author_id NUMBER(10),
    anthor_name VARCHAR2(100) NOT NULL,
    author_desc VARCHAR2(500),
    PRIMARY KEY (author_id)
);

DESC author;

-- book 테이블의 author 컬럼 삭제
-- 나중에 author_id 컬럼 추가 -> author.author_id와 참조 연결할 예정
ALTER TABLE book DROP COLUMN author;
DESC book;

-- book 테이블에 author_id 컬럼 추가
-- author.author_id를 참조하는 컬럼 author.author_id 컬럼과 같은 형태여야 한다.
ALTER TABLE book ADD (author_id NUMBER(10));
DESC book;
DESC author;

-- book 테이블의 book_id도 author 테이블의 PK와 같인 데이터타입 (NUMBER(10))으로 변경
ALTER TABLE book MODIFY (book_id NUMBER(10));
DESC book;

-- book 테이블의 book_id 컬럼에 PRIMARY KEY 제약조건을 부여
ALTER TABLE book
ADD CONSTRAINT pk_book_id PRIMARY KEY (book_id);
DESC book;

-- book 테이블의 author_id 컬럼과 author 테이블의 author_id를 FK로 연결
ALTER TABLE book
ADD CONSTRAINT fk_author_id
    FOREIGN KEY (author_id)
        REFERENCES author(author_id);
        
-- DICTIONARY

-- USER_ : 현재 로그인된 사용자에게 허용된 뷰
-- ALL_ : 모든 사용자 뷰
-- DBA_ : DBA에게 허용된 뷰

-- 모든 딕셔너리 확인
SELECT * FROM DICTIONARY;
        
-- 사용자 스키마 객체 : USER_OBJECTS
SELECT * FROM USER_OBJECTS;
-- 사용자 스키마의 이름과 타입 정보 출력
SELECT OBJECT_NAME, OBJECT_TYPE FROM USER_OBJECTS;

-- 제약 조건의 확인
SELECT * FROM USER_CONSTRAINTS;
SELECT CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    SEARCH_CONDITION,
    TABLE_NAME
FROM USER_CONSTRAINTS;

-- BOOK 테이블에 적용된 제약조건의 확인
SELECT CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    SEARCH_CONDITION
FROM USER_CONSTRAINTS
WHERE TABLE_NAME='BOOK';

TRUNCATE TABLE author;

-- INSERT : 테이블에 새 레코트(튜플) 추가
-- 제공된 컬럼 목록의 순서와 타입, 값 목록의 순서와 타입이 일치해야 함
-- 컬럼 목록을 제공하지 않으면 테이블 생성시 정의된 컬럼의 순서의 타입을 따른다

-- 컬럼 목록이 제시되지 않았을 때
INSERT INTO author
VALUES(1, '박경리', '토지 작가');

SELECT * FROM author;

-- 컬럼 목록을 제시했을 때,
--  제시한 컬럼의 순서와 타입대로 값 목록을 제공해야 함
INSERT INTO author (author_id, author_name)
VALUES(2, '김영하');

SELECT * FROM author;

-- 컬럼 목록을 제공했을 때,
-- 테이블 생성시 정의된 컬럼의 순서와 상관 없이 데이터 제공 가능
INSERT INTO author (author_name, author_id, author_desc)
VALUES('류츠신', 3, '삼체 작가');

SELECT * FROM author;
--desc author;
--ALTER TABLE author RENAME COLUMN ANTHOR_NAME TO author_name;
--DESC author;

ROLLBACK; -- 반영 취소

SELECT * FROM author;

INSERT INTO author
VALUES(1, '박경리', '토지 작가');
INSERT INTO author (author_id, author_name)
VALUES(2, '김영하');
INSERT INTO author (author_name, author_id, author_desc)
VALUES('류츠신', 3, '삼체 작가');

SELECT * FROM author;

COMMIT;     --  변경사항 반영

SELECT * FROM author;

-- UPDATE
-- 특정 레코드의 컬럼 값을 변경한다
-- WHERE 절이 없으면 모든 레코드가 변경
-- 가급적 WHERE 절로 변경하고자 하는 레코드를 지정하도록 함