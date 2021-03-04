-- 1번
select PL.productLine, count(*)
from productlines PL, products P
where PL.productLine = P.productLine
group by PL.productLine;

-- 2번
select O.country 국가, count(employeeNumber) 직원수
from employees E, offices O
where O.officeCode = E.officeCode
group by O.country;

-- 3번
select productName 상품명, orderDate 판매일자, SUM(quantityOrdered) 판매수량, SUM(quantityOrdered*priceEach) 판매금액
from products P, orderdetails OD, orders O
where P.productCode = OD.productCode
AND OD.orderNumber = O.orderNumber
group by productName, orderDate;

-- 4번
select country 국가, state 주, city 도시, year(orderDate) 연도, month(orderDate) 월, SUM(quantityOrdered) 판매수량, SUM(quantityOrdered*priceEach) 판매금액
from customers C, orders O, orderdetails OD, products P
where C.customerNumber = O.customerNumber
and O.orderNumber = OD.orderNumber
and OD.productCode = P.productCode
group by country, state, city, year(orderDate), month(orderDate);

-- 5번 Q.고객별 Credit 잔여 한도 (creditlimit - 카드사용금액):고객명,잔여한도,한도소진율
select customerName 고객명, creditLimit-amount 잔여한도, amount/creditLimit 한도소진율
from customers C, payments P
where C.customerNumber = P.customerNumber
order by 잔여한도, 한도소진율 desc;

-- 6번
SET @ROWNUM:=0;
select @rownum:= @rownum+1 랭킹, T.*
From(select E.lastName, E.firstName, sum(OD.quantityOrdered) 판매수량, sum(OD.quantityOrdered * OD.priceEach) 판매금액, (OD.quantityOrdered * P.buyprice)/Max(OD.quantityOrdered * P.buyprice) 1등대비판매금액
from orderdetails OD, orders O, customers C, employees E, products P
where E.employeeNumber = C.salesRepEmployeeNumber
and C.customerNumber = O.customerNumber
and O.orderNumber = OD.orderNumber
and OD.productCode = P.productCode
group by E.lastName, E.firstName
order by 판매금액 desc
limit 10) T;

-- 7번
SET @ROWNUM:=0;
select @rownum:= @rownum+1 랭킹, T.*
from (select concat(lastName, " ", firstName) 직원명, SUM(quantityOrdered) 판매수량, SUM(quantityOrdered * priceEach) 판매금액, sum(quantityOrdered * (priceEach - buyPrice)) 수익금액, (quantityOrdered * (priceEach - buyPrice))/Max(quantityOrdered * (priceEach - buyPrice)) as 1등대비수익금액
from orderdetails OD, orders O, customers C, employees E, products P
where E.employeeNumber = C.salesRepEmployeeNumber
and O.orderNumber = OD.orderNumber
and C.customerNumber = O.customerNumber
and P.productCode = OD.productCode
group by 직원명
order by 수익금액 desc
limit 10) T;


