《深入浅出Oracle》

变量和类型,控制语句(IF ELSE)和循环(FOR),过程和函数,对象类型和方法.

&&&&1.块:
PL/SQL都是由块组成的.

DECLARE
--变量声明
global_var VARCHAR2(20) DEFAULT '一个变量';
BEGIN
	--执行部分
	DBMS_OUTPUT.PUT_LINE(global_var);
	EXCEPTION
	--异常处理部分
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('没有找到对应数据!');
END;

块的分类:
1.匿名块,带名块-通常是动态生成,一般不储存在数据库中,只能执行一次,执行过后对象便被销毁.
2.子程序,存储过程/函数/包-子程序可以存储在数据库中,可以被外部程序调用.
3.触发器,是一种存储在数据库中的带名块,当相应触发事件(一般指DML操作)发生时会被调用.

块的嵌套使用:
--<<gobal>>--最外围的块,不能声明块名
DECLARE
BEGIN
	<<outer>>--块名
	DECLARE
	--变量声明
	out_var VARCHAR2(20) DEFAULT '外部变量';
	BEGIN
		DBMS_OUTPUT.PUT_LINE(out_var);
		--DBMS_OUTPUT.PUT_LINE(inner.inner_var);--异常:标记'inner'引用超出范围.

		<<inner>>
		DECLARE
		--变量声明
		inner_var	VARCHAR2(20) DEFAULT '内部变量';
		out_var		VARCHAR2(20) DEFAULT '内部同名变量';
		BEGIN
			DBMS_OUTPUT.PUT_LINE(inner_var);
			DBMS_OUTPUT.PUT_LINE(out_var);--优先访问内部变量
			DBMS_OUTPUT.PUT_LINE(outer.out_var);--通过父级块名方式,可以访问到外部变量.
		END inner;
	END outer;
END;




&&&&2.变量

PL/SQL变量的声明规则:var_name [CONSTANT] type [NOT NULL] [:= value|DEFAULT value];
CONSTANT表示该变量是常量.
NOT NUll表示该变量不能为空.

非法声明:
var_1,var_2 VARCHAR2(20);--PL/SQL中每行只能声明一个变量.

变量类型:
1.标量类型(不包含任何组件),数字型(INT,NUMBER...),字符型(CHAR,VARCHAR2...),日期型(DATE,TIMESTAMP...),布尔型(BOOLEAN).
2.复合类型(可以包含很多组件)-RECORD(记录),TABLE(表),VARRAY(数组)
3.引用类型(指向另一个类型的指针)-REF CURSOR(游标),REF object_type
4.LOB类型(用于存储大型对象)-BLOB,CLOB...
5.用户自定义类型.

用户自定义类型声明:
DECLARE
SUBTYPE MYTYPE1 IS NUMBER;
SUBTYPE MYTYPE2 IS NUMBER;
num MYTYPE1(7,2) DEFAULT 1000.05;
num2 MYTYPE2(7,2);
BEGIN
	DBMS_OUTPUT.PUT_LINE(num);
	num2 := num; --只要自定义类型的基类型相同且没有限制,便可以互相赋值.
	DBMS_OUTPUT.PUT_LINE(num2);
END;


关于NULL比较.
DECLARE
x INT := 5;
y INT := NULL;
z INT := NULL;
str VARCHAR2(20) := '';
BEGIN
	IF x != y THEN --结果为null,NULL与任何值比较都为NULL
		DBMS_OUTPUT.PUT_LINE('x != y');--不会被执行
	END IF;
	IF y = NULL THEN --结果为NULL
		DBMS_OUTPUT.PUT_LINE('y = NULL');
	END IF;
	IF y = z THEN --结果为NULL
		DBMS_OUTPUT.PUT_LINE('y = z');
	END IF;
	IF y IS NULL THEN --结果为true
		DBMS_OUTPUT.PUT_LINE('y IS NULL');
	END IF;
	IF str IS NULL THEN --结果为true,PL/SQL将空字符看做null
		DBMS_OUTPUT.PUT_LINE('str IS NULL');
	END IF;
	DBMS_OUTPUT.PUT_LINE('I' || NULL || ' love' || NULL || ' oracle!' || ' NULL');--I love oracle! NULL,null值会被忽略.
END;


IF,CASE,
NOT,LIKE,IN,BETWEEN


&&&&3.表和记录
%TYPE,%ROWTYPE(RECORD)

DECLARE
v_id		NUMBER;
v_name  	VARCHAR2(20);
v_age		NUMBER;
v_address	VARCHAR2(20);
BEGIN
	select id,name,age,addresss into v_id,v_name,v_age,v_address from table_dual where id = 9527;--很麻烦
END;

RECORD类型.
DECLARE
TYPE v_record IS RECORD( --声明记录类型变量.
	v_id		NUMBER;
	v_name  	VARCHAR2(20);
	v_age		NUMBER;
	v_address	VARCHAR2(20);
);
BEGIN
	select id,name,age,addresss into v_record from table_dual where id = 9527;--方便容易维护.
	DBMS_OUTPUT.PUT_LINE(v_record.v_id);--9527.
END;

%TPYE类型
DECLARE
TYPE v_record IS RECORD( --声明记录类型变量.
	v_id		table_dual.id%TYPE;
	v_name  	table_dual.name%TYPE;--声明变量类型为table_dual.name的类型.
	v_age		table_dual.age%TYPE;
	v_address	table_dual.addresss%TYPE;
);
BEGIN
	select id,name,age,addresss into v_record from table_dual where id = 9527;
	DBMS_OUTPUT.PUT_LINE(v_record.v_id);--9527.
END;
###使用%TYPE的好处显而易见,不显式的声明变量类型,日后表字段类型改变后不必重新维护之前写好的代码.


%ROWTYPE
DECLARE
v_t_record table_dual%ROWTYPE;--声明变量类型为table_dual表的行类型.
BEGIN
	select * into v_t_record from table_dual where id = 9527;
	DBMS_OUTPUT.PUT_LINE(v_t_record.id);--9527.
END;
###比%TYPE更方便.


伪列
--ROWID伪列表示表中记录的二进制地址.每个表都有这个伪列
SELECT ROWID FROM dual;
:AAAAB0AABAAAAOhAAA

/*
使用UROWID类型的变量可以储存rowid
*/
DECLARE
v_rowid UROWID;
BEGIN
	select ROWID into v_rowid from dual;
	DBMS_OUTPUT.PUT_LINE(v_rowid);--AAAAB0AABAAAAOhAAA
END;


--ROWNUM伪列指从表中检索数据的次序,返回当前的行序号.注意它不受order by子句影响.
select * from sys_user where rownum => 2 and rownum <=9;

============================================================================================
============================================================================================

&&&&4.PL/SQL控制及结构
三种控制结构:
1.条件控制(选择结构):IF,CASE
2.重复控制(循环结构):LOOP
3.顺序控制:GOTO

----条件控制
IF语法:
IF a > b THEN
	DBMS_OUTPUT.PUT_LINE('a > b');
ELSIF a < b THEN
	DBMS_OUTPUT.PUT_LINE('a < b');
ELSE
	DBMS_OUTPUT.PUT_LINE('a = b');
END IF;

CASE语法:
<<test_case>>--可以带标签.
CASE name --CASE语句的可读性与效率都比IF高.
WHEN 'san' THEN DBMS_OUTPUT.PUT_LINE('name is san');
WHEN 'tom' THEN DBMS_OUTPUT.PUT_LINE('name is tom');
WHEN 'susan' THEN DBMS_OUTPUT.PUT_LINE('name is susan');
END CASE test_case;

CASE另一种写法
<<test_case>>
CASE 
WHEN name = 'san' THEN DBMS_OUTPUT.PUT_LINE('name is san');
WHEN name = 'tom' THEN DBMS_OUTPUT.PUT_LINE('name is tom');
WHEN name = 'susan' THEN DBMS_OUTPUT.PUT_LINE('name is susan');
END CASE test_case;


----重复控制
-1.LOOP循环

LOOP
	i:=i+1;
	DBMS_OUTPUT.PUT_LINE(i);
	IF i > 100 THEN
		EXIT;--跳出循环.RETURN跳出块.
	END IF;
END LOOP;

EXIT语句简写
LOOP
	i:=i+1;
	DBMS_OUTPUT.PUT_LINE(i);
	EXIT WHEN i > 100; --三行简写成一行.
END LOOP;

嵌套循环.
<<outloop>>
LOOP
	i:=i+1;
	DBMS_OUTPUT.PUT_LINE('i:'||i);
	<<inloop>> --嵌套循环
	LOOP
		j = i*j;
		DBMS_OUTPUT.PUT_LINE('j:'||j);
		EXIT inloop/*outloop*/ WHEN j > 10; --这里也可以跳出最外层循环.
	END	LOOP inloop;
	EXIT outloop WHEN i > 10;
END LOOP outloop;


-2.WHILE-LOOP循环,每次循环前会先判断.
WHILE i >100 LOOP
	i := i + 1;
END LOOP;


-3.FOR循环,特点:确定的循环次数
FOR i IN 1..3 LOOP --1.2.3 to i,执行三次循环
	...
END LOOP;

FOR i IN 3..3 LOOP --3 to i ,只执行一次循环
	...
END LOOP;

FOR i IN REVERSE 1..3 LOOP --3.2.1 to i ,倒序执行
	...
	--i := 5;--注意,循环中i不可赋值.
END LOOP;

嵌套循环
<<outloop>>
FOR step IN 1..25 LOOP
	<<inloop>>
	FOR step IN 1..10 LOOP
		DBMS_OUTPUT.PUT_LINE(inloop.step*outloop.step);
	END LOOP;
END LOOP;


----顺序控制
-1.GOTO
FOR i IN 1..25 LOOP
	IF i == 10 THEN
		GOTO next_label;
	END IF;
END LOOP;
<<next_label>>
INSERT INTO emp VALUSE ...

GOTO语句需要注意:
1.不能跳到子块中.
2.不能跳到循环中.
3.不能跳到IF,CASE中.
4.不能从IF(CASE)的一部分跳到另一部分.
5.不能从异常处理部分跳出.

-2.NULL语句,空操作.
IF i > 90 THEN
	...
ELSE 
	NULL;
END IF;


============================================================================================
============================================================================================

&&&&5.SQL分类.
1.DDL(数据定义语言):DROP,CREATE,ALTER,GRANT,REVOKE --针对数据库中的对象,表,视图,子程序(函数,存储过程),索引,序列等等
2.DML(数据操作语言):SELECT,INSERT,UPDATE,DELETE --针对表中的数据,查询/删除/修改/插入等.
3.事物控制:COMMIT,ROLLBACK,SAVEPOINT --组织sql并进行操作.
4.会话控制:ALTER SESSION --数据库连接设置.
5.系统控制:ALTER SYSTEM --数据库设置.
6.嵌入式SQL.

DML和事务控制语句是唯一不会修改数据库对象的语句,所以他们也是PL/SQL块中唯一合法的语句.

LOCK TABLE.

declare

v_row_ce cap_extpaydata%ROWTYPE;
cursor userRows is select * from cap_extpaydata; 

begin
	v_row_ce

end;


--DDL
用于建立,更改或删除表,视图,索引等对象.
对特权角色的授权或回收.
建立审计选择(迷!)
在数据字典中增加注释.
注意:在每一条DDL语言执行前后oracle会隐式地提交事务.

--事务控制.
COMMIT,ROLLBACK,SAVEPOINT
例子:
set Transaction Read only Write only Use Rollback segment 回滚段名.

set Transaction Read only;
select count(*) from dual;
update ....;
commit;


--会话控制,可以动态地控制一个用户会话的特性.
-使用SQL追踪功能
-调整NLS参数(国际语言支持,修改数据库字符集)
-改变会话缺省标号格式
-关闭一个数据库连接
-发送命令到远程数据库,解决一个分布式处理.
-在函数或存储过程中使用COMMIT,ROLLBACK语句.
-修改基于开销的优化方法啊


--系统控制,alter system
-资源限制
--全库资源限制,oracle分配内存大小,总会话数量,后台进程数量,CPU使用
--用户资源限制,表空间大小,会话参数设置,
-管理共享服务器进程或调度进程.
--专用服务器模式
----一般在使用数据仓库时才会使用该模式,或是只有少量客户端,或联机事务处理系统(A.用户连接请求大于共享进程,B.事务大部分是长事务大事务).
----数据仓库,将业务数据以时间序列的方式存储起来.用于日后决策使用,数据仓库是只能查询不能更新的.
--共享服务器模式(三个结构:客户端监听器,一个或多个调度进行,一个或多个共享服务器进程)
----用户在发送sql时,监听器会把负载最小的调用进程地址给用户进程.用户进程直接连接到这个调度进程,调度进程将用户请求放入请求队列中,如果有空闲共享服务器进程时,将执行这个请求
----请求队列是一个公共的队列,他同时被多个调度进程调用.
-显示地转换日志文件组.
--oracle的日志文件是一个系统性的东西.
1.参数文件(pfile(oracle 9i前)和spfile(oracle 9i后))
	设置数据库的资源限制,设置用户或进程的限制,调整系统性能

2.控制文件(Control Files)
	数据库名称,数据库创建时间,数据文件/在线重做日志/归档日志的信息.
	表空间信息,备份和恢复信息.

3.数据文件(Data Files)
	存储实际数据,隶属于某个表空间(数据表空间,undo表空间,临时表空间),执行查询sql语句.

4.临时文件(Temp Files)
	隶属于某个临时表空间.
	
5.日志文件(Log Files)
	日志文件分为:重做日志(redo log),警报日志(Alert log)->生成追踪文件(Trace files)
	Logminer工具,用于可视化的分析redo log,重做日志(redo log),最少被备份在两个不同硬盘中.

参数文件与控制文件的关系.
oracle启动分为三个阶段:
1.shutdown状态:此时数据库处于停止状态,不能接受外界任何请求,没有进程和占用内存.
2.nomount状态:首先查找参数文件,根据参数文件中SGA信息,建立共享内存区(SGA)和oracle实例,Nomount的过程是启动数据库实例的过程.
3.mount状态:从参数文件中获得控制文件的位置信息,然后开打控制文件(控制文件是可以指定多个的，只要有个一个不能成功读取，这个阶段将会失败).加载所有的数据文件/重做日志.
4.open状态:开打所有的数据文件(data files)和重做日志.

-显示地执行一个检查点.
-检验对数据文件的存取.
-限制用户的登录.
-设置自动归档文件组功能.
-清楚SGA共享池中的全部数据
-终止一个会话.










Ivree
Ivy Tree











































































