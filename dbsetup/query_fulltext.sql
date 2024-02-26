DO $$ 
DECLARE 
std_query TEXT := 'hello';
--std_department VARCHAR(30) := 'Computer Science';
BEGIN
	-- 
	
		-- END
	
END $$;;
-- Tim kiem

	select 	
	fulltextTbl.seq
	,ts_headline(title, to_tsquery('ERP')) ts_headline_title
	,ts_headline(category, to_tsquery('ERP')) ts_headline_category
	,ts_headline(description, to_tsquery('ERP')) ts_headline_description
	,ts_headline(history_comment,to_tsquery('ERP')) ts_headline_history_comment
	,username creator
	,rank
	from (
		select 
		ts_rank(
			setWeight(title_vector,'A') 
			||setWeight(category_vector ,'C') 
			||setWeight(description_vector ,'B') 
			||setWeight(history_comment_vector ,'C') ,
			to_tsquery('ERP')
		) rank,*

		from "MyRequestFullTextSearch"
		where 
		title_vector @@ to_tsquery('erp')
		or "category_vector" @@ to_tsquery('ERP')
		or description_vector @@ to_tsquery('ERP')
		or history_comment_vector @@ to_tsquery('ERP|zip')
	)fulltextTbl
	left join 
	(select seq, title,"creatorId","categoryId",description from "MyRequest") "mRequest"
	on "mRequest".seq = fulltextTbl.seq
	left join 
	(select id, name category from "Category") "category"
	on category.id = "mRequest"."categoryId"
	left join "User"
	on "User".id= "mRequest"."creatorId"
	order by rank DESC
	


--
select * from "MyRequestFullTextSearch"
select * from "MyRequest"
select * from "Category"
select "RequestSeq",comment,*  from "History"

----TRIGGER MYREQUEST
CREATE TRIGGER TRIGGER_CREATE_VECTOR_MYREQUEST
AFTER INSERT ON "MyRequest"
FOR EACH ROW
EXECUTE PROCEDURE FUNC_CREATE_VECTOR_MYREQUEST();

CREATE OR REPLACE FUNCTION FUNC_CREATE_VECTOR_MYREQUEST()
RETURNS TRIGGER AS
$BODY$
BEGIN
    INSERT INTO "MyRequestFullTextSearch" (seq, title_vector,description_vector,category_vector,history_comment_vector)
    VALUES (NEW.seq, 
			to_tsvector(replace(NEW.title,':','')),
			to_tsvector(replace(striphtml(NEW.description),':','')), 
			to_tsvector(
				replace(
					(select "name" from "Category" where NEW."categoryId"="Category".id)
				,':','')
			),
		   	NULL);
			
    RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql;

--TRIGGER HISTORY REQUEST
CREATE TRIGGER TRIGGER_CREATE_VECTOR_HISTORY
AFTER INSERT ON "History"
FOR EACH ROW
EXECUTE PROCEDURE FUNC_CREATE_VECTOR_HISTORY();

CREATE OR REPLACE FUNCTION FUNC_CREATE_VECTOR_HISTORY()
RETURNS TRIGGER AS
$BODY$
BEGIN
	if NEW."comment" is NOT NULL and NEW."comment" <> '' then
		RAISE NOTICE 'NEW.COMMENT';
		update "MyRequestFullTextSearch"
		set
		--Join history	
		history_comment_vector = to_tsvector(		
			(select string_agg(comment, '. ') comment_history  from (
			select replace(striphtml(comment),':','') comment,"RequestSeq" from "History" 
			where comment is not null and comment <> ''
			and "RequestSeq" = NEW."RequestSeq"
			)tbl
			group by "RequestSeq")
		)
		,history_comment = (select string_agg(comment, '. ') comment_history  from (
			select 
			'['||(select username  from "User" where id ="History".owner_id ) || '<commented/>' ||replace(striphtml(comment),':','') || ']' comment,
			"RequestSeq" from "History" 
			where comment is not null and comment <> ''
			and "RequestSeq" = NEW."RequestSeq"
			)tbl
			group by "RequestSeq")
		where "MyRequestFullTextSearch".seq = NEW."RequestSeq";
	end if;	
    RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql;


(select "RequestSeq", string_agg(comment, '. ') comment_history  from (
			select '['||(select username  from "User" where id ="History".owner_id ) || '<commented/>' ||replace(striphtml(comment),':','') || ']' comment ,
			"RequestSeq"
			from "History" 
			where comment is not null and comment <> ''
			and "RequestSeq" = 38
			)tbl
			group by "RequestSeq")
		

