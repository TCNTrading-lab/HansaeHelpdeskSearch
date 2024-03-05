INSERT INTO "MyRequestFullTextSearch"
select *
from (
select seq
	,to_tsvector(replace(coalesce(title,''),':','')) title_vector
	,to_tsvector(replace(coalesce(striphtml("MyRequest"."description"),''),':','')) description_vector
	,to_tsvector(replace(coalesce("Category".name,''),':','')) "category_vector"
	,to_tsvector(replace(coalesce("tbl_group"."history_comment_vector",''),':','')) history_comment_vector
	,history_comment
from "MyRequest"
left join "Category"
on "Category".id = "MyRequest"."categoryId"
left join "User"
on "User".Id = "MyRequest"."creatorId"
left join 
(
--Table History
select "RequestSeq", string_agg(comment, ' ') history_comment_vector, string_agg(history_comment, ' ') history_comment  from (
select 
	replace(striphtml(comment),':','') comment
	,''||(select username  from "User" where id ="History".owner_id ) || '/ ' ||replace(striphtml(comment),':','') || ';.' history_comment
	,"RequestSeq"
	from "History" where comment is not null and comment <> ''
)tbl
group by "RequestSeq"
--
)tbl_group
on tbl_group."RequestSeq"= seq
)
"tblMain"