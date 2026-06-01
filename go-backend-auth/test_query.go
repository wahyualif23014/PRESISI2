package main

import (
	"encoding/json"
	"fmt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

type Result struct {
	IdLahan string `json:"id_lahan"`
	IdTanam string `json:"id_tanam"`
	Status  string `json:"status"`
}

func main() {
	dsn := "root:@tcp(127.0.0.1:3306)/presisi?charset=utf8mb4&parseTime=True&loc=Local"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		fmt.Println(err)
		return
	}

	var results []Result
	db.Raw(`SELECT 
			l.idlahan as id_lahan, 
			COALESCE(CAST(t_latest.idtanam AS CHAR), '') as id_tanam,
			CASE WHEN l.validoleh IS NOT NULL THEN 'VALIDATED' ELSE 'PENDING' END as status
			FROM lahan l
			LEFT JOIN (
				SELECT t1.* FROM tanam t1 
				INNER JOIN (SELECT idlahan, MAX(idtanam) as max_id FROM tanam GROUP BY idlahan) t2 
				ON t1.idlahan = t2.idlahan AND t1.idtanam = t2.max_id
			) t_latest ON t_latest.idlahan = l.idlahan
			WHERE l.validoleh IS NOT NULL
			LIMIT 15;`).Scan(&results)

	b, _ := json.Marshal(results)
	fmt.Println(string(b))
}
