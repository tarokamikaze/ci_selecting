package main

import (
	"fmt"
	"github.com/couchbase/gocb"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"github.com/pkg/errors"
)

type (
	User struct {
		Id        string   `json:"uid"`
		Email     string   `json:"email"`
		Interests []string `json:"interests"`
	}
)

func main() {
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.GET("/hello", MainPage)

	e.Start(":8080") //ポート番号指定してね
}

func MainPage(c echo.Context) error {
	DBMS := "mysql"
	USER := "root"
	PASS := ""
	PROTOCOL := "tcp(127.0.0.1:3306)"
	DBNAME := "sample"

	CONNECT := USER + ":" + PASS + "@" + PROTOCOL + "/" + DBNAME
	db, err := gorm.Open(DBMS, CONNECT)
	if err != nil {
		return errors.Wrap(err, "cannot connect to mysql host")
	}
	defer db.Close()

	cluster, err := gocb.Connect("couchbase://localhost")
	if err != nil {
		return errors.Wrap(err, "cannot connect to cb host")
	}
	defer cluster.Close()
	bucket, err := cluster.OpenBucket("db_test", "testpass")
	if err != nil {
		return errors.Wrap(err, "cannot connect to cb bucket")
	}

	bucket.Upsert("u:kingarthur",
		User{
			Id:        "kingarthur",
			Email:     "kingarthur@couchbase.com",
			Interests: []string{"Holy Grail", "African Swallows"},
		}, 0)

	// Get the value back
	var inUser User
	bucket.Get("u:kingarthur", &inUser)
	fmt.Printf("User: %v\n", inUser)

	bm := bucket.Manager("testuser", "testpass")
	bm.Flush()

	return nil
}
