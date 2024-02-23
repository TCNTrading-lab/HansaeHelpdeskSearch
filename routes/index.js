var express = require("express");
var { Client } = require("pg");
var router = express.Router();

router.post("/search", async function (req, res, next) {
  const phrase = req.body.phrase;
  const timeBegin = new Date();
  const result = await searchPhrase(phrase);
  const timeEnd = new Date();
  res.setHeader("Content-Type", "application/json");
  res.send(
    JSON.stringify({
      phrase: phrase,
	  time:(timeEnd-timeBegin)/1000,
      count: (await result).rows.length,
      data: result.rows,
    })
  );
});

async function searchPhrase(phrase) {
  const client = new Client({
    user: process.env.USER,
    host: process.env.HOST,
    database: process.env.DATABASE,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
  });

  await client.connect();
  const phraseto_tsquery = await phrasetoTsQuery(client, phrase);
  const arr_word = phrase.split(" ").filter((n) => n);

  const result = await client.query(query_sql, [
    phraseto_tsquery + "|" + arr_word.join("|"),
  ]);
  await client.end();
  return result;
}
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
			to_tsquery($1)
		) rank,*

		from "MyRequestFullTextSearch"
		where 
		title_vector @@ to_tsquery($1)
		or "category_vector" @@ to_tsquery($1)
		or description_vector @@ to_tsquery($1)
		or history_comment_vector @@ to_tsquery($1)
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
