
select 	
	fulltextTbl.seq
	,ts_headline(title, to_tsquery('erp<->elasticsearch|erp|Elasticsearch')) ts_headline_title
	,ts_headline(category, to_tsquery('erp<->elasticsearch|erp|Elasticsearch')) ts_headline_category
	,ts_headline(description, to_tsquery('erp<->elasticsearch|erp|Elasticsearch')) ts_headline_description
	,ts_headline(history_comment,to_tsquery('erp<->elasticsearch|erp|Elasticsearch')) ts_headline_history_comment
	,username creator
	,rank
	from (
		select 
		ts_rank(
			setWeight(title_vector,'A') 
			||setWeight(category_vector ,'C') 
			||setWeight(description_vector ,'B') 
			||setWeight(history_comment_vector ,'C') ,
			to_tsquery('erp<->elasticsearch|erp|Elasticsearch')
		) rank,*
		from "MyRequestFullTextSearch"
		where 
		title_vector @@ to_tsquery('erp<->elasticsearch|erp|Elasticsearch')
		or "category_vector" @@ to_tsquery('erp<->elasticsearch|erp|Elasticsearch')
		or description_vector @@ to_tsquery('erp<->elasticsearch|erp|Elasticsearch')
		or history_comment_vector @@ to_tsquery('erp<->elasticsearch|erp|Elasticsearch')
		limit 1
		offset 0
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