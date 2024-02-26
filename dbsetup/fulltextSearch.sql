SELECT 'a fat cat sat on a mat and ate a fat rat'::tsvector @@ 'cat & rat'::tsquery;

SELECT 'a fat cat sat on a mat and ate a fat rat'::tsvector 

select '스칼라로 쓰여진 한국어 처리기입니다. 현재 텍스트 정규화와 형태소 분석, 스테밍을 지원하고 있습니다. 짧은 트윗은 물론이고 긴 글도 처리할 수 있습니다. 개발에 참여하시고 싶은 분은 Google Forum에 가입해 주세요. 사용법을 알고자 하시는 초보부터 코드에 참여하고 싶으신 분들까지 모두 환영합니다.'
::tsvector 

select *,"Category".id from "Category"

SELECT to_tsvector('The quick brown fox jumped over the lazy dog.') @@ to_tsquery('jumped<4>dog');

select "categoryId",* from
"MyRequest"

--Full text search

select * from (
select seq, title, "categoryId","Category".name,"MyRequest"."description" as description_req
from "MyRequest"
left join "Category"
on "Category".id = "MyRequest"."categoryId")
"tblMain"
where 

replace("tblMain".title,':','')::tsvector @@ 'Error&ERP'::tsquery
or
replace(striphtml(description_req),':','')::tsvector @@ '설명을'::tsquery


--limit 5


select 'cat & rat'::tsquery;
select replace('ERP System Error: ...',':','')::tsvector
select * from "History"


-----------
select 'ERP System Error ...'::tsvector @@ 'ERP&Error'::tsquery


-- Lay History theo requestId
select "RequestSeq", string_agg(comment, ',') comment_history from (
select replace(striphtml(comment),':','') comment,"RequestSeq" from "History" where comment is not null and comment <> ''
)tbl
group by "RequestSeq"


--
--tao function tach HTML
--sudo apt-get install libhtml-strip-perl
SELECT * FROM pg_language;

CREATE EXTENSION plperl;
CREATE LANGUAGE plperlu;


CREATE OR REPLACE FUNCTION striphtml(html text) RETURNS text
LANGUAGE plperlu
AS $$
use strict; use warnings; use 5.10.1;
use HTML::Strip;

my $hs = HTML::Strip->new(decode_entities => 1);
my $stripped = $hs->parse($_[0]);
$hs->eof;
return $stripped;
$$;


---
select phraseto_tsquery('english', 'rain of debris')
select phraseto_tsquery('english', 'Error&ERP')
select to_tsquery('english', 'rain & of & debris')
select to_tsquery('english', 'rain of debris')

SELECT striphtml('<div align="right"><font color="3366FF"><b><font size="3">it''s&nbsp;test</font></b></font></div>');
select 'ERP Error'::tsvector 
select (to_tsvector('ERP Error'))


SELECT ts_headline('english',
  'The most common type of search
is to find all documents containing given query terms
and return them in order of their similarity to the
query.',
  to_tsquery('english', 'query abc & similarity'));