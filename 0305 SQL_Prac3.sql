-- 1번
SET @sche_date = '1990-01-01';
select @sche_date 조회일자, dept_name 부서명, count(E.emp_no) 직원수, SUM(salary) 보수총액
from departments D, dept_emp DE, employees E, salaries S
where D.dept_no = DE.dept_no
and DE.emp_no = E.emp_no
and E.emp_no = S.emp_no
and @sche_date > DE.from_date and @sche_date < DE.to_date
and @sche_date > S.from_date and @sche_date < S.to_date
group by dept_name;

-- 2번
SET @sche_date = '1990-01-01';
SET @ROWNUM:=0;
select @sche_date 조회일자, @rownum:= @rownum+1 랭킹, T.*
from(select concat(first_name, " ", last_name) 매니저명, D.dept_name 부서명, SUM(salary) 보수
from dept_manager DM, employees E, dept_emp DE, salaries S, departments D
where E.emp_no = DM.emp_no
and E.emp_no = DE.emp_no
and D.dept_no = DE.dept_no
and E.emp_no = S.emp_no
group by 매니저명,  dept_name
order by 보수 desc
limit 5) T;

set @rownum =0;
select curdate() 조회일자, @rownum := @rownum +1 랭킹 , T.*
from (select concat(E.first_name, " ", E.last_name) 매니저명, dept_name, sum(salary) 보수
from salaries S, employees E, departments D, dept_manager DM
where S.emp_no = E.emp_no
and E.emp_no = DM.emp_no
and  D.dept_no = DM.dept_no
group by 매니저명, dept_name
order by 보수 desc
limit 5)T, (select @rownum=0) TMP;

-- 1번 풀이
SET @sche_date = '1990-01-01';
select @sche_date 조회일자, dept_name 부서명, count(E.emp_no) 직원수, SUM(salary) 보수총액
from departments D, dept_emp DE, employees E, salaries S
where D.dept_no = DE.dept_no
and DE.emp_no = E.emp_no
and E.emp_no = S.emp_no
and DE.from_date <= @sche_date and DE.to_date >= @sche_date
and S.from_date <= @sche_date  and S.to_date >= @sche_date
group by D.dept_name;


-- 2번 풀이
SET @sche_date = '1990-01-01';
SET @ROWNUM:=0;
select @rownum := @rownum+1 랭킹, T.*
from (select @sche_date 조회일자, E.first_name 매니저명, dept_name 부서명, salary 보수
	from departments D, employees E, salaries S, dept_manager DM
	where DM.dept_no = D.dept_no
	and E.emp_no = S.emp_no
	and E.emp_no = DM.emp_no
	and S.from_date <= @sche_date  and S.to_date >= @sche_date
	and DM.from_date <= @sche_date  and DM.to_date >= @sche_date
	order by S.salary DESC
	limit 5) T;


-- 3번 월별 채용 직원 수 : 연도, 월, 직원수
select year(hire_date) 연도, month(hire_date) 월, count(emp_no) 직원수
from employees
group by year(hire_date), month(hire_date);

-- 4번
select year(hire_date) 연도, gender 성별, count(E.emp_no) 직원수, AVG(salary) 평균보수, MIN(salary) 최저보수, MAX(salary) 최고보수, SUM(salary) 보수총액
from employees E, salaries S
where E.emp_no = S.emp_no
group by year(hire_date), gender;

-- 4번 풀이
SET @sche_date = '1990-01-01';
select year(@sche_date), gender 성별, count(E.emp_no) 직원수, AVG(salary) 평균보수, MIN(salary) 최저보수, MAX(salary) 최고보수, SUM(salary) 보수총액
from employees E, salaries S
where E.emp_no = S.emp_no
and S.from_date <= @sche_date and S.to_date >= @sche_date
group by gender
union
select Year(DATE_ADD(@sche_date, interval 1 year)), gender 성별, count(E.emp_no) 직원수, AVG(salary) 평균보수, MIN(salary) 최저보수, MAX(salary) 최고보수, SUM(salary) 보수총액
from employees E, salaries S
where E.emp_no = S.emp_no
and S.from_date <= DATE_ADD(@sche_date, interval 1 year) and S.to_date >= DATE_ADD(@sche_date, interval 1 year)
group by gender
union
select Year(DATE_ADD(@sche_date, interval 2 year)), gender 성별, count(E.emp_no) 직원수, AVG(salary) 평균보수, MIN(salary) 최저보수, MAX(salary) 최고보수, SUM(salary) 보수총액
from employees E, salaries S
where E.emp_no = S.emp_no
and S.from_date <= DATE_ADD(@sche_date, interval 2 year) and S.to_date >= DATE_ADD(@sche_date, interval 2 year)
group by gender;

-- 5번 -> FAIL
SET @sche_date = '1990-01-01';
select  @sche_date 조회일자, concat(last_name, " ", first_name) 직원명,  AVG(salary) 평균보수, AVG(salary)/AVG(T.평균보수1) percentile
from employees E, salaries S
	(select  MAX(평균보수) 평균보수1
	from (select @sche_date 조회일자, concat(last_name, " ", first_name) 직원명, AVG(salary) 평균보수
		from employees E, salaries S
		where E.emp_no = S.emp_no
		and @sche_date > S.from_date and @sche_date < S.to_date
		group by @sche_date LIMIT count(E.emp_no)*0.2) T);

-- 5번 풀이
SET @sche_date = '1990-01-01';
select @sche_date 조회일자, E.first_name, S.salary, S.salary/MS.최고연봉
from employees E, salaries S,
	(select MAX(salary) 최고연봉 from salaries where from_date <= @sche_date and to_date >= @sche_date) MS
where E.emp_no = S.emp_no
and  S.from_date <= @sche_date and S.to_date >= @sche_date
and S.salary/MS.최고연봉 > 0.8
order by S.salary DESC;


-- 6번
SET @sche_date = '1990-01-01';
select dept_name 부서명, @sche_date 조회일자1, count(E.emp_no) 직원수1, SUM(salary) 보수총액1, dateadd(year, -1, getdate()) 조회일자2, 직원수2, 보수총액2, 증감
from departments D, dept_emp DE, employees.E, salaries S
where D.dept_no = DE.dept_no
and DE.emp_no = E.emp_no
and E.emp_no = S.emp_no
and @sche_date > DE.from_date and @sche_date < DE.to_date
and @sche_date > S.from_date and @sche_date < S.to_date
group by dept_name;

-- 6번 풀이
SET @sche_date = '1990-01-01';
select TY.부서명, TY.조회일자, TY.직원수, TY.보수총액, PY.조회일자, PY.직원수, PY.보수총액, TY.보수총액-PY.보수총액 증감
from	(select @sche_date 조회일자, dept_name 부서명, count(E.emp_no) 직원수, SUM(salary) 보수총액
		from departments D, dept_emp DE, employees E, salaries S
		where D.dept_no = DE.dept_no
		and DE.emp_no = E.emp_no
		and E.emp_no = S.emp_no
		and @sche_date > DE.from_date and @sche_date < DE.to_date
		and @sche_date > S.from_date and @sche_date < S.to_date
		group by dept_name) TY,

		(select dateadd(@sche_date, interval -1 YEAR) 조회일자, dept_name 부서명, count(E.emp_no) 직원수, SUM(salary) 보수총액
		from departments D, dept_emp DE, employees.E, salaries S
		where D.dept_no = DE.dept_no
		and DE.emp_no = E.emp_no
		and E.emp_no = S.emp_no
		and dateadd(@sche_date, interval -1 YEAR) > DE.from_date and dateadd(@sche_date, interval -1 YEAR) < DE.to_date
		and dateadd(@sche_date, interval -1 YEAR) > S.from_date and dateadd(@sche_date, interval -1 YEAR) < S.to_date
		group by dept_name) PY
	where TY.부서명 = PY.부서명;
    
-- 7번
SET @sche_date = '1990-01-01';
select @sche_date 조회일자, D.dept_name 부서명, concat(E.first_name, " ", E.last_name) 직원명
from departments D, dept_emp DE, employees E
where D.dept_no = DE.dept_no
and DE.emp_no = E.emp_no
and DE.from_date <= @sche_date and DE.to_date >= @sche_date;

-- 8번
SET @sche_date = '1990-01-01';
select @sche_date 조회일자, D.dept_name 부서명, concat(E.first_name, " ", E.last_name) 매니저명
from departments D, dept_emp DE, employees E, dept_manager DM
where D.dept_no = DE.dept_no
and DE.emp_no = E.emp_no
and E.emp_no = DM.emp_no
and DM.from_date <= @sche_date and DM.to_date >= @sche_date
and DE.from_date <= @sche_date and DE.to_date >= @sche_date
group by 부서명, 매니저명;

-- 9번
SET @sche_date = '1990-01-01';
select D.dept_name 부서명, concat(E.first_name, " ", E.last_name) 매니저명, T.직원명
from dept_manager DM, dept_emp DE, employees E, departments D,
		(select @sche_date, D.dept_name, concat(E.first_name, " ", E.last_name) 직원명
		from departments D, dept_emp DE, employees E, dept_manager DM
		where D.dept_no = DE.dept_no
		and DE.emp_no = E.emp_no
        and E.emp_no = DM.emp_no
		and DM.from_date <= @sche_date and DM.to_date >= @sche_date
		group by  D.dept_name, concat(E.first_name, " ", E.last_name)) T
		where D.dept_no = DM.dept_no
		and DE.emp_no = E.emp_no
        and DM.emp_no = E.emp_no
        group by 부서명, 매니저명, T.직원명;


-- 10번
SET @sche_date = '1990-01-01';
select @sche_date 조회일자, D.dept_name 부서명, count(D.dept_no) 직원수, SUM(S.salary) 보수총액
from departments D, dept_emp DE, employees E, salaries S
where D.dept_no = DE.dept_no
and DE.emp_no = E.emp_no
and E.emp_no = S.emp_no
and DE.from_date <= @sche_date and DE.to_date >= @sche_date
and S.from_date <= @sche_date and S.to_date >= @sche_date
group by 부서명;

-- 11번
SET @sche_date = '1990-01-01';
SET @ROWNUM:=0;
select @sche_date 조회일자, @rownum := @rownum+1 랭킹, T.*
from (select concat(E.first_name, " ", E.last_name) 매니저명, D.dept_name 부서명, AVG(S.salary) 보수
	from departments D, dept_emp DM, employees E, salaries S
	where D.dept_no = DM.dept_no
	and DM.emp_no = E.emp_no
	and E.emp_no = S.emp_no
	and DM.from_date <= @sche_date and DM.to_date >= @sche_date
	and S.from_date <= @sche_date and S.to_date >= @sche_date
	group by 매니저명, 부서명
    order by 보수 DESC) T
limit 5;

-- 마지막
SET @sche_date = '1990-01-01';
SET @rownum1 = 0 , @rownum2 = 0;
select T.매니저명, T.랭킹1, T.조회일자, T.보수, P.랭킹2 ,P.조회일자, P.보수, T.랭킹1 - P.랭킹2 랭킹증감, T.보수- P.보수 보수증감
from
	(select @rownum1 := @rownum1 +1 랭킹1, TY.*
		from (select @sche_date 조회일자, concat(E.first_name, " ", E.last_name) 매니저명, AVG(S.salary) 보수
			from dept_manager DM, employees E, salaries S
			where DM.emp_no = E.emp_no
			and E.emp_no = S.emp_no
			and DM.from_date <= @sche_date and DM.to_date >= @sche_date
			and S.from_date <= @sche_date and S.to_date >= @sche_date
			group by 매니저명) TY) T,
	(select @rownum2 := @rownum2 +1 랭킹2, PY.*
		from(select date_add(@sche_date, interval -1 year) 조회일자, concat(E.first_name, " ", E.last_name) 매니저명, avg(S.salary) 보수
		from dept_manager DM, employees E, salaries S
		where DM.emp_no = E.emp_no
		and E.emp_no = S.emp_no
		and DM.from_date <= date_add(@sche_date, interval -1 year)  and DM.to_date >=date_add(@sche_date, interval -1 year) 
		and S.from_date <= date_add(@sche_date, interval -1 year)  and S.to_date >= date_add(@sche_date, interval -1 year) 
		group by 매니저명) PY) P
where T.매니저명 = P.매니저명
    
