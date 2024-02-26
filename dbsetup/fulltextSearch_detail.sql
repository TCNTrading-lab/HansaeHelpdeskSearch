select seq
	,ts_rank(
	setWeight(title_vector,'A') 
	||setWeight(category_vector ,'B') 
	||setWeight(description_req_vector ,'C') 
	||setWeight(comment_history_vector ,'D') ,to_tsquery('Error')) rank
from (
select seq, title, "categoryId"
	,"Category".name "Category", 
	"MyRequest"."creatorId"
	,"User"."username" "creatorName"
	,"MyRequest"."description" as description_req
	,"tbl_group"."comment_history"
	,to_tsvector(replace(coalesce(title,''),':','')) title_vector
	,to_tsvector(replace(coalesce("Category".name,''),':','')) "category_vector"
	,to_tsvector(replace(coalesce(striphtml("MyRequest"."description"),''),':','')) description_req_vector
	,"tbl_group"."comment_history_vector" comment_history_vector
from "MyRequest"
left join "Category"
on "Category".id = "MyRequest"."categoryId"
left join "User"
on "User".Id = "MyRequest"."creatorId"
left join 
(
--Table History
select "RequestSeq", string_agg(comment, ' ') comment_history, to_tsvector(coalesce(string_agg(comment, ' '),'')) comment_history_vector  from (
select replace(striphtml(comment),':','') comment,"RequestSeq" from "History" where comment is not null and comment <> ''
)tbl
group by "RequestSeq"
--
)tbl_group
on tbl_group."RequestSeq"= seq
)
"tblMain"
where 
1=1
--"tblMain".title_vector @@ 'Error'::tsquery
--or "tblMain"."category_vector" @@ 'Error'::tsquery
--or "tblMain".description_req_vector @@ 'Error'::tsquery
--or "tblMain".comment_history_vector @@ 'Error'::tsquery

--"tblMain".title_vector @@ to_tsquery('Error')
--or "tblMain"."category_vector" @@ to_tsquery('Error')
--or "tblMain".description_req_vector @@ to_tsquery('Error')
--or "tblMain".comment_history_vector @@ to_tsquery('Error')


--
ALTER TABLE "MyRequestFullTextSearch"
ADD COLUMN history_comment text;

