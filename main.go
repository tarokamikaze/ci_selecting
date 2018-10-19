package main

import (
	"fmt"
	"github.com/couchbase/gocb"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
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
	db, err := gorm.Open("mysql", "root@localhost?charset=utf8&parseTime=True&loc=Local")
	if err != nil {
		return err
	}
	defer db.Close()

	cluster, err := gocb.Connect("couchbase://localhost")
	if err != nil{
		return err
	}
	defer cluster.Close()
	cluster.Authenticate(gocb.PasswordAuthenticator{
		Username: "testuser",
		Password: "testpass",
	})
	bucket, err := cluster.OpenBucket("db_test", "testpass")
	if err != nil{
		return err
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

	return nil
}
