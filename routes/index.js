const { isNumber } = require("class-validator");
var express = require("express");
var { Pool } = require("pg");
var createError = require("http-errors");
var router = express.Router();
router.get("/hi",function (req, res, next){
	res.send("hello");
});
router.post("/", async function (req, res, next) {
  const { phrase, pageSize, page } = req.body;
  if (phrase==null || pageSize == null || page==null){
	next(createError(500,new Error("An error occurred at model input (phrase,page,pageSize)")));
  }
  else if (!(isNumber(pageSize) && isNumber(page))) {
	next(createError(500,new Error("An error occurred at page or pageSize")));
  } else {
    const timeBegin = new Date();
    const result = await searchPhrase(phrase, pageSize, page);
    const timeEnd = new Date();
    res.setHeader("Content-Type", "application/json");
    res.send(
      JSON.stringify({
        phrase: phrase,
        time: (timeEnd - timeBegin) / 1000,
        count: (await result).rows.length,
        data: result.rows,
      })
    );
  }
});
/**
 *
 * @param {*} phrase
 * @param {*} pageSize
 * @param {*} page
 * @returns
 */
async function searchPhrase(phrase, pageSize, page) {
	console.log(process.env.CONNECTION_STRING);
  const pool = new Pool({connectionString: process.env.CONNECTION_STRING,});  
  //const phraseto_tsquery = await phrasetoTsQuery(client, phrase);
  const arr_word = phrase.split(" ").filter((n) => n);
  const qWord = arr_word.join("|").toString();
  const result = await pool.query(query_sql, [
    qWord,
    phrase,
    pageSize,
    page * pageSize,
  ]);
  await pool.end();
  return result;
}
/**
 *
 * @param {*} client
 * @param {*} phrase
 * @returns
 */
async function phrasetoTsQuery(client, phrase) {
  const result = await client.query("select phraseto_tsquery($1)", [phrase]);
  return result.rows[0].phraseto_tsquery;
}

const query_sql = `
select 	
	fulltextTbl.seq
	,ts_headline(title, to_tsquery($1)) ts_headline_title
	,ts_headline(category, to_tsquery($1)) ts_headline_category
	,ts_headline(description, to_tsquery($1)) ts_headline_description
	,ts_headline(history_comment,to_tsquery($1)) ts_headline_history_comment
	,username creator
	,rank
	from (
		select 
		ts_rank(
			setWeight(title_vector,'A') 
			||setWeight(category_vector ,'C') 
			||setWeight(description_vector ,'B') 
			||setWeight(history_comment_vector ,'C') ,
			to_tsquery($1) || phraseto_tsquery($2)
		) rank,*
		from "MyRequestFullTextSearch"
		where 
		title_vector @@ (to_tsquery($1) || phraseto_tsquery($2))
		or "category_vector" @@ (to_tsquery($1) || phraseto_tsquery($2))
		or description_vector @@ (to_tsquery($1) || phraseto_tsquery($2))
		or history_comment_vector @@ (to_tsquery($1) || phraseto_tsquery($2))
		limit $3
		offset $4
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
`;

module.exports = router;
